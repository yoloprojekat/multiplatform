# 🏎️ YOLO VOZILO • Futuristic Multiplatform Cockpit

A high-performance, futuristic telemetry and remote control cockpit for smart Raspberry Pi vehicles, powered by **Flutter**. Supports **all platforms** from a single unified codebase: **Web**, **Android**, **iOS**, **Windows**, **macOS**, and **Linux**.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-00E5FF?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.47%2B-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.13%2B-0175C2?style=for-the-badge&logo=dart)
![CI/CD](https://img.shields.io/badge/GitHub_Actions-Automated_Build_%26_Release-2088FF?style=for-the-badge&logo=githubactions)

---

## Features & Enhancements

- 🖥️ **Cockpit Telemetry Dashboard**: High-contrast, cyberpunk HUD interface with responsive layouts that automatically adapt between desktop/tablet cockpit and thumb-friendly mobile layouts.
- 📹 **Live MJPEG Video Feed**: Real-time camera feed parser with frame rate throttling (saving battery and bandwidth), live rolling FPS counter, and roundtrip ping latency monitor.
- 🎮 **Dual Driving Controllers**:
  - **Tactile Compact D-Pad**: High-tech directional pad with 4 cardinal directions, 2 rotation triggers, and instant-stop on pointer release.
  - **Virtual Joystick**: 360-degree analog joystick with dynamic angle mapping, radial deadzone filtering, and spring-return animation.
- ⌨️ **Keyboard Support**: Full WASD / Arrow keys, QE rotation, and Spacebar emergency stop support for desktop and web users.
- 🤖 **Remote AI Control**:
  - **Vision AI**: Remotely toggles onboard YOLO object detection with server-drawn bounding boxes.
  - **Person Follow AI**: Autonomous person-tracking mode with automatic safety interlock (disabling vision automatically disarms follow).
- 🔤 **OCR & AutoPilot**:
  - Scans and detects directional keywords (`forward`, `backward`, `left`, `right`, `rotate`).
  - Autonomous driving loop: moves for 1.5s, stops for 0.5s, and re-arms.
  - Interactive simulator injector allows testing the autopilot state machine on any device or browser without physical signage!
- 📸 **Snapshot & Video Recording**:
  - High-res photo capture saved directly to device storage or browser download (`PI_CAP_<timestamp>.jpg`).
  - Continuous video recording buffered in memory and encoded as cross-platform animated clips with preview and download dialog.
- 🧪 **Integrated Robot Simulator Mode**: Test video streaming, AI toggles, joystick, and autopilot right inside the web browser or on desktop without a physical Raspberry Pi!
- ⚙️ **Configurable Host & Presets**: Easily switch between `http://pametno-vozilo.local:1607`, `localhost`, or direct LAN IPs (`http://192.168.x.x:1607`).

---

## 🕹️ Controls & Keyboard Shortcuts

| Action | Command Code | D-Pad Symbol | Keyboard Shortcut |
| :--- | :--- | :---: | :---: |
| **Drive Forward** | `napred` | ▲ | `W` or `↑` |
| **Drive Backward** | `nazad` | ▼ | `S` or `↓` |
| **Steer Left** | `levo` | ◀ | `A` or `←` |
| **Steer Right** | `desno` | ▶ | `D` or `→` |
| **Rotate Counter-Clockwise** | `rot_levo` | ↺ | `Q` |
| **Rotate Clockwise** | `rot_desno` | ↻ | `E` |
| **Emergency Stop** | `stop` | ■ | `Spacebar` (or release key/touch) |

---

## 🌐 Network Protocol Specification

The app communicates with the Raspberry Pi vehicle over HTTP REST and MJPEG streaming:

| Endpoint | Method | Payload | Description |
| :--- | :---: | :--- | :--- |
| `/control` | `POST` | `{"cmd": "<command>"}` | Sends driving command (`napred`, `nazad`, `levo`, `desno`, `rot_levo`, `rot_desno`, `stop`). Auto-repeated every 1.5s when moving. |
| `/video_feed` | `GET` | *None* | Multipart MJPEG stream returning JPEG images delimited by `0xFF, 0xD8` and `0xFF, 0xD9`. |
| `/toggle_detection` | `POST` | `{"enable": true/false}` | Toggles remote YOLO object detection on the Pi. |
| `/toggle_follow` | `POST` | `{"enable": true/false}` | Toggles autonomous person-following mode on the Pi. |

---

## 🚀 Running & Testing Web Directly

You can run and test the web app directly in your browser without rebuilding everything:

### Option 1: Flutter Web Dev Server (Hot Reload)
```bash
flutter run -d chrome
# or with Edge:
flutter run -d edge
```

### Option 2: Test the Built Web Release Bundle
```bash
# Build the release bundle
flutter build web --release

# Serve locally (using Dart built-in server script):
dart run tool/serve_web.dart
```
Open **`http://localhost:8085`** in your browser.
> **Tip**: Enable **Mock Robot Simulator** inside the Settings dialog (`⚙️` icon in the top bar) to test the stream HUD, bounding boxes, driving controls, and OCR AutoPilot without needing the robot connected!

---

## 📦 Building for Target Platforms

### Android
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Windows Desktop
```bash
flutter build windows --release
# Output: build/windows/x64/runner/Release/
```

### Linux Desktop
```bash
# Ensure build essentials are installed:
# sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

### macOS Desktop
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/
```

### iOS
```bash
flutter build ios --release
```

---

## 🤖 GitHub Actions Automated CI/CD

The repository includes a comprehensive GitHub Actions workflow at [`.github/workflows/build_and_publish.yml`](.github/workflows/build_and_publish.yml).

### What It Does:
1. **Quality Gate**: Runs static analysis (`flutter analyze`) and unit/widget tests (`flutter test`) on every push and pull request.
2. **Multiplatform Matrix Build**: Automatically compiles:
   - Android Release APK (`yolo-vozilo-android.apk`)
   - Flutter Web Release bundle (`yolo-vozilo-web.zip`) and deploys to **GitHub Pages**
   - Windows Desktop x64 (`yolo-vozilo-windows-x64.zip`)
   - Linux Desktop x64 (`yolo-vozilo-linux-x64.tar.gz`)
3. **Automated GitHub Releases**: When a version tag is pushed (e.g. `v1.0.0`), it automatically drafts and publishes a GitHub Release with all compiled platform binaries attached!

### To trigger a release:
```bash
git tag v1.0.0
git push origin v1.0.0
```

---

## 📂 Project Architecture

```text
lib/
├── controllers/
│   └── robot_controller.dart        # Main ViewModel: command loop, streaming, autopilot, recording
├── core/
│   ├── constants/
│   │   └── robot_constants.dart     # Command codes, endpoints, timings, OCR keywords
│   ├── theme/
│   │   ├── app_colors.dart          # Cyberpunk telemetry color palette
│   │   └── app_theme.dart           # Dark theme with Outfit typography
│   └── utils/
│       ├── file_saver.dart          # Cross-platform snapshot & recording file saver
│       ├── file_saver_web.dart      # Web browser direct download implementation
│       ├── file_saver_io.dart       # Android/Desktop native filesystem saver
│       └── mjpeg_decoder.dart       # Chunked MJPEG frame stream parser
├── data/
│   ├── models/
│   │   ├── robot_command.dart       # Command enums, hotkeys, and symbols
│   │   └── robot_status.dart        # Connection states, telemetry model
│   └── services/
│       ├── mjpeg_stream_service.dart# HTTP stream listener & rolling FPS calculator
│       ├── mock_robot_service.dart  # Offline robot simulator with animated canvas feed
│       └── robot_api_service.dart   # REST client for /control and /toggle_*
├── ui/
│   ├── screens/
│   │   └── cockpit_screen.dart      # Adaptive Cockpit UI (Desktop & Mobile layouts)
│   └── widgets/
│       ├── compact_dpad.dart        # High-tech tactile D-Pad with keyboard indicators
│       ├── connection_settings_dialog.dart # Host IP configuration & simulator toggle
│       ├── feature_pill.dart        # Glowing cyberpunk action buttons
│       ├── keyboard_shortcuts_listener.dart # WASD/Arrow/QE key event listener
│       ├── media_preview_dialog.dart# Photo/recording save confirmation modal
│       ├── video_hud_player.dart    # Live video player with HUD overlays & standby radar
│       └── virtual_joystick.dart    # 360-degree analog joystick with spring return
└── main.dart                        # Application bootstrap & System UI setup
```

---

## 📄 License & Attribution

Author: **Danilo Stoletović** • Mentor: **Dejan Batanjac**  
**ETŠ „Nikola Tesla“ Niš** • 2026

Licensed under the **[MIT License](LICENSE)**.
