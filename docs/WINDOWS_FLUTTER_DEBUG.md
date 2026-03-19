# Windows / Flutter debug console notes

## RawKeyboard assertion (Alt Left)

When running on **Windows**, you may see:

```text
Attempted to send a key down event when no keys are in keysPressed
RawKeyDownEvent ... LogicalKeyboardKey ... "Alt Left" ... modifiers: 0
'package:flutter/src/services/raw_keyboard.dart': Failed assertion ...
```

**Cause:** The Windows embedder can deliver an Alt key down event with **no modifier flags** set. Flutter’s `RawKeyboard` expects modifier keys to maintain internal consistency, so this trips a **framework assertion**.

**Dart-only fix:** There is no public Dart API to rewrite these events before they reach `RawKeyboard`. The real fix belongs in the **Flutter engine**.

**Runner workaround (this repo):** [`windows/runner/flutter_window.cpp`](../windows/runner/flutter_window.cpp) intercepts **bare Alt** messages (`WM_SYSKEYDOWN` / `WM_SYSKEYUP` for `VK_MENU` / `VK_LMENU` / `VK_RMENU`, plus `WM_KEYDOWN` / `WM_KEYUP` for left/right Alt) **before** `HandleTopLevelWindowProc`, so the engine never receives the broken packet. **Alt+letter** shortcuts still use `WM_SYSKEYDOWN` with the **letter** virtual key, not Alt’s VK, so they continue to work.

**Trade-off:** Flutter code that relies on `RawKeyboard` seeing **Alt pressed alone** (no second key) will not get those events on Windows.

**Also try:**

1. **Upgrade Flutter** (`flutter upgrade` on stable) and retest.
2. Prefer **full restart** instead of repeated hot restart when validating keyboard issues.
3. If problems remain, **file or follow** an issue on [flutter/flutter](https://github.com/flutter/flutter/issues) with `flutter doctor -v` and your Windows build.

## `Unable to parse JSON message: The document is empty`

This often appears **next to** the keyboard assertion or after a **failed platform message** / hot restart. It is usually **tooling or channel noise**, not your app’s JSON parsing, unless you explicitly parse JSON from a `MethodChannel` with empty payloads.

**Mitigation:** Treat it as a **secondary symptom**; fix/avoid the underlying keyboard or hot-restart instability first.

## Timeline zoom (`LateInitializationError` for animation controller)

If you see `LateInitializationError` for `_zoomMorphController` after hot reload, do a **cold run** (`Stop` → `flutter run -d windows`). Hot reload can leave `StatefulWidget` fields in an inconsistent state when controller initialization changes.

The project uses a **nullable** `AnimationController?` and lazy initialization so a **fresh process** should not hit this error.
