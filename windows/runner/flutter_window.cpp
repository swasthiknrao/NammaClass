#include "flutter_window.h"

#include <optional>
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

}  // namespace

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
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Must run before HandleTopLevelWindowProc so the engine never sees the
  // half-baked Alt key packet that triggers raw_keyboard.dart assertions.
  if (message == WM_SYSKEYDOWN || message == WM_SYSKEYUP) {
    if (IsBareAltVirtualKey(wparam)) {
      return 0;
    }
  }
  if (message == WM_KEYDOWN || message == WM_KEYUP) {
    // Left/right Alt sometimes arrive on the non-system key path (0xA4 / 0xA5).
    if (wparam == VK_LMENU || wparam == VK_RMENU) {
      return 0;
    }
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
