#include "flutter_window.h"

#include <optional>
#include <cstdio>
#include <windows.h>

#include "flutter/generated_plugin_registrant.h"

namespace {

// Flutter can assert in RawKeyboard when the Windows embedder forwards a bare
// Alt key-down with an empty modifier mask. Consuming those messages here keeps
// Alt+character combos (different virtual keys) working while dropping the
// problematic "Alt alone" events. See docs/WINDOWS_FLUTTER_DEBUG.md.
bool IsBareAltVirtualKey(WPARAM vk) {
  return vk == VK_MENU || vk == VK_LMENU || vk == VK_RMENU;
}

// HardwareKeyboard can assert when the same physical key is reported as Meta
// (Win) vs Control across synthesized events (e.g. usbHidUsage 0x1600000000).
// Dropping bare Win-key messages mirrors the Alt workaround.
bool IsBareWinVirtualKey(WPARAM vk) {
  return vk == VK_LWIN || vk == VK_RWIN;
}

int g_modifierInterceptLogCount = 0;
constexpr int kModifierInterceptLogLimit = 30;

void LogModifierIntercept(const char* tag, UINT message, WPARAM wparam) {
  if (g_modifierInterceptLogCount >= kModifierInterceptLogLimit) return;
  char buf[256];
  sprintf_s(
      buf,
      "%s: message=%u wparam=%u swallowed=%d\n",
      tag,
      static_cast<unsigned>(message),
      static_cast<unsigned>(wparam),
      g_modifierInterceptLogCount + 1);
  OutputDebugStringA(buf);
  g_modifierInterceptLogCount++;
}

// True if we should consume the message so the Flutter engine never sees it.
bool ShouldConsumeKnownBadModifierKey(UINT message, WPARAM wparam,
                                      const char** out_tag) {
  if (message == WM_SYSKEYDOWN || message == WM_SYSKEYUP) {
    if (IsBareAltVirtualKey(wparam)) {
      *out_tag = "BareAltIntercept";
      return true;
    }
  }
  if (message == WM_KEYDOWN || message == WM_KEYUP) {
    // Left/right/generic Alt on the non-system path (e.g. keyCode 164 / 0xA4).
    if (IsBareAltVirtualKey(wparam)) {
      *out_tag = "BareAltIntercept";
      return true;
    }
    if (IsBareWinVirtualKey(wparam)) {
      *out_tag = "BareWinIntercept";
      return true;
    }
  }
  return false;
}

}  // namespace

namespace {
FlutterWindow* g_view_keyboard_workaround_owner = nullptr;
}  // namespace

LRESULT CALLBACK FlutterWindow::ViewKeyboardWorkaroundWndProc(
    HWND hwnd,
    UINT message,
    WPARAM wparam,
    LPARAM lparam) noexcept {
  const char* tag = nullptr;
  if (g_view_keyboard_workaround_owner &&
      ShouldConsumeKnownBadModifierKey(message, wparam, &tag)) {
    LogModifierIntercept(tag, message, wparam);
    return 0;
  }
  if (g_view_keyboard_workaround_owner &&
      g_view_keyboard_workaround_owner->flutter_view_prev_proc_) {
    return CallWindowProc(
        g_view_keyboard_workaround_owner->flutter_view_prev_proc_, hwnd, message,
        wparam, lparam);
  }
  return DefWindowProc(hwnd, message, wparam, lparam);
}

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());
  SubclassFlutterViewForKeyboardWorkaround();

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  UnsubclassFlutterViewForKeyboardWorkaround();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

void FlutterWindow::SubclassFlutterViewForKeyboardWorkaround() {
  HWND view = flutter_controller_->view()->GetNativeWindow();
  if (!view || flutter_view_hwnd_) {
    return;
  }
  flutter_view_hwnd_ = view;
  g_view_keyboard_workaround_owner = this;
  flutter_view_prev_proc_ = reinterpret_cast<WNDPROC>(SetWindowLongPtr(
      view, GWLP_WNDPROC,
      reinterpret_cast<LONG_PTR>(ViewKeyboardWorkaroundWndProc)));
}

void FlutterWindow::UnsubclassFlutterViewForKeyboardWorkaround() {
  if (flutter_view_hwnd_ && flutter_view_prev_proc_) {
    SetWindowLongPtr(flutter_view_hwnd_, GWLP_WNDPROC,
                     reinterpret_cast<LONG_PTR>(flutter_view_prev_proc_));
  }
  if (g_view_keyboard_workaround_owner == this) {
    g_view_keyboard_workaround_owner = nullptr;
  }
  flutter_view_prev_proc_ = nullptr;
  flutter_view_hwnd_ = nullptr;
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Top-level window rarely receives WM_KEY* (focus is on the Flutter view),
  // but filter here too for completeness.
  const char* tag = nullptr;
  if (ShouldConsumeKnownBadModifierKey(message, wparam, &tag)) {
    LogModifierIntercept(tag, message, wparam);
    return 0;
  }

  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
