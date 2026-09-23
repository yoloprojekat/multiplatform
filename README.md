# 📱 Smart Vehicle Control Terminal (Multiplatform)
### Next-Generation Telemetry & Command Interface for Autonomous Robotics
**Target Platforms: Android • iOS • Web • Windows • macOS • Linux**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-00E5FF?style=for-the-badge)](#)
[![Flutter](https://img.shields.io/badge/Flutter-3.47%2B-02569B?style=for-the-badge&logo=flutter)](#)
[![Dart](https://img.shields.io/badge/Dart-3.13%2B-0175C2?style=for-the-badge&logo=dart)](#)
[![CI/CD](https://img.shields.io/badge/GitHub_Actions-Automated_Build_%26_Release-2088FF?style=for-the-badge&logo=githubactions)](#)

**Smart Vehicle Control Terminal** is a high-performance, thin-client cross-platform interface designed for real-time robotic teleoperation and computer vision telemetry. All heavy AI inference (YOLO object detection) and bounding box overlays are processed on the Edge (Raspberry Pi 5), ensuring **0% AI CPU load** on the client while enabling sub-millisecond teleoperation, OCR command extraction, and live video streaming.

---

## 📸 Application Interface Showcase

| 🧠 YOLO Edge Detection Stream | 🔤 OCR Command Vision System |
| :---: | :---: |
| Pre-rendered YOLO bounding boxes & joystick telemetry feed | Cross-platform OCR text analysis & live autonomous command verification |
| Real-time MJPEG feed with HUD overlays, FPS counter, and latency monitor | Keyword detection (`forward`, `backward`, `left`, `right`, `rotate`) with auto-pilot state loop |

---

## 🚀 Key Features & Architectural Modules

### 🧠 Server-Side Computer Vision (YOLO Edge AI)
- **Pre-Rendered Stream**: The vehicle's onboard Raspberry Pi 5 runs real-time YOLO object detection and draws bounding boxes directly onto frame buffers prior to transmission.
- **Zero Client Overhead**: The Flutter multiplatform application displays the processed high-fps stream, keeping client CPU and GPU utilization minimal for optimal thermal and power efficiency across mobile, web, and desktop.
- **Ultra-Low Latency Display**: Optimized chunked JPEG parsing with frame throttling ensures smooth 60+ FPS UI rendering with immediate visual feedback for agile robotic maneuvering.

### 🔤 OCR Command System (Optical Character Recognition)
- **Autonomous Environmental Guidance**: Recognizes textual commands and road signs from the surrounding environment (e.g., speed limits, direction markers, stop instructions).
- **Live Telemetry Verification**: Decoded text directives are displayed in real-time on the cockpit dashboard, providing immediate visual confirmation of autonomous navigation decisions.
- **Universal Multiplatform Vision**: Features an autonomous state machine that drives for 1.5s, stops for 0.5s, and re-arms, with an interactive testing injector for browser and desktop validation.

### 🎮 Precision Robotic Control
- **Direct HTTP REST Command Bridge**: Transmits low-latency motor steering directives via `POST /control` with automatic 1.5s keep-alive repetition.
- **Dual Controllers**:
  - **Tactile Compact D-Pad**: High-tech directional buttons (`▲`, `▼`, `◀`, `▶`), rotation triggers (`↺`, `↻`), and center emergency stop. Sends directives on press and stops instantly on release.
  - **360° Virtual Joystick**: Analog touch and mouse drag joystick with dynamic angle mapping, radial deadzone filtering, and smooth spring-return animation.
- **Full Keyboard Navigation**: Desktop and Web users can pilot using `W`/`S` (forward/back), `A`/`D` (left/right), `Q`/`E` (rotation), and `Spacebar` (emergency stop).
- **Bi-Directional Feedback Loop**: Real-time status badges, ping latency monitor, and visual indicators reflecting active movement states.

### ⚡ Optimization & System Engineering
- **Thin Client Architecture**: Engineered for maximum field battery life, low memory footprint, and instantaneous startup.
- **Universal Multiplatform Parity**: Runs identical logic and visuals across Web, Android, iOS, Windows, macOS, and Linux from a single codebase.
- **Offline Robot Simulator Mode**: Integrated mock service generates a simulated cockpit HUD video feed, YOLO bounding boxes, and telemetry, enabling instant web and local testing without requiring physical robot hardware.
- **Photo Snapshot & Video Recording**: High-resolution JPEG frame snapshots and animated clip recordings saved directly to user downloads on Web or storage on desktop and mobile.

---

## 🛠 Tech Stack

| Domain | Technology | Description |
| :--- | :--- | :--- |
| **Language** | **Dart 3.13.4** | Modern, sound type-safe, and asynchronous runtime |
| **UI Framework** | **Flutter 3.47+ (Material 3)** | Declarative multiplatform UI with custom cybernetic telemetry styling |
| **Networking** | **`package:http` & MJPEG Decoder** | Non-blocking chunked HTTP streaming and low-latency REST control |
| **File Management** | **Cross-Platform `FileSaver`** | Web Blob/Anchor download API & native `path_provider` on mobile/desktop |
| **Edge Compute** | **YOLO on Raspberry Pi 5** | Server-side real-time object detection and frame rendering |
| **Typography** | **Google Fonts (Outfit)** | Futuristic, high-legibility telemetry typography |
| **CI / CD** | **GitHub Actions Matrix** | Automated analysis, testing, multiplatform compilation, and GitHub Releases |

---

## 🔧 Network & Communication Architecture

The terminal communicates with the autonomous vehicle via a dedicated private local network, Wi-Fi Access Point (Hotspot), or direct IP:

```
┌─────────────────────────────────────────┐
│             Raspberry Pi 5              │
│      (Onboard Autonomous Vehicle)       │
└────┬───────────────────────────────▲────┘
     │                               │
     │ HTTP Video Feed               │ HTTP Low-Latency Commands
     │ (Pre-rendered BBoxes)         │ POST /control {"cmd": "..."}
     │ GET /video_feed               │ POST /toggle_detection
     │                               │ POST /toggle_follow
     │                               │
┌────▼───────────────────────────────┴────┐
│      Multiplatform Cockpit App          │
│   (Web • Android • Desktop • iOS)       │
└─────────────────────────────────────────┘
```

- **HTTP Video Stream**: Continuous multipart MJPEG stream from `http://pametno-vozilo.local:1607/video_feed`.
- **REST Control Protocol**: Sends JSON payloads `{"cmd": "<command>"}` to `/control`.
- **AI Toggles**: Remotely arms or disarms onboard YOLO Vision (`/toggle_detection`) and autonomous Person Follow (`/toggle_follow`) with safety interlocks.
- **OCR Feedback Protocol**: Synchronizes environmental text directives with the telemetry HUD banner and triggers the autonomous driving cycle.

---

## 🎨 UI Design System & Visual Palette

The application uses a **Dark Future Cockpit** theme designed for maximum contrast, high legibility, and OLED energy savings:

- 🔵 **Primary Neon Cyan (`#00E5FF`)**: Brand titles, active control buttons, joystick thumb, and crosshair reticles.
- 🔷 **Secondary Electric Azure (`#2979FF`)**: Rotation triggers, status cards, and action pills.
- 🟢 **Vision & Online (`#00E676`)**: Status badge for active YOLO detection, online connectivity, and AutoPilot verification.
- 🔴 **Alert & Emergency (`#FF1744`)**: Emergency stop buttons, recording indicators, and disconnection alerts.
- 🌐 **Simulated Mode (`#00B0FF`)**: Clear indicator when operating in offline Mock Robot Simulator mode.
- 🌚 **Obsidian Background (`#090C12`)**: Deep dark layout minimizing OLED power consumption and enhancing visual focus during extended operation.

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

## 🚀 Running & Testing Web Directly

You can run and test the web client directly in your browser without rebuilding everything:

### Option 1: Direct Web Dev Server (Hot Reload)
```bash
flutter run -d chrome
# or with Edge:
flutter run -d edge
```

### Option 2: Run Built Web Release with Local Server
```bash
# Compile web release
flutter build web --release

# Serve locally (using Dart built-in server script):
dart run tool/serve_web.dart
```
Navigate to **`http://localhost:8085`** in your browser.

> **💡 Pro Tip**: Click the **Settings icon (⚙️ / tune)** in the top bar and enable **Mock Robot Simulator** to test live video HUD rendering, YOLO bounding boxes, D-Pad/Joystick driving, and OCR AutoPilot command injections immediately!

---

## 🛠 Build & Installation

### Prerequisites
- **Flutter SDK**: 3.47+ (Dart 3.13+)
- **Java**: JDK 17 (for Android builds)
- **C++ Build Tools**: Visual Studio with C++ (for Windows), clang/cmake/ninja (for Linux), Xcode (for macOS/iOS)

### Building from Source

```bash
# Clone the repository
git clone https://github.com/yoloprojekat/multiplatform.git
cd multiplatform

# Install dependencies
flutter pub get

# Run static analysis and tests
flutter analyze
flutter test

# Build for your target platform:
flutter build web --release       # Web Bundle
flutter build apk --release       # Android APK
flutter build windows --release   # Windows Desktop x64
flutter build linux --release     # Linux Desktop x64
flutter build macos --release     # macOS Desktop
flutter build ios --release       # iOS Bundle
```

---

## 🤖 GitHub Actions Automated CI/CD

The repository includes an enterprise-grade CI/CD pipeline at [`.github/workflows/build_and_publish.yml`](.github/workflows/build_and_publish.yml):

- **Automated Validation**: Runs static analysis (`flutter analyze`) and unit/widget tests on every commit and PR.
- **Cross-Platform Matrix Builds**:
  - Compiles **Android Release APK** (`yolo-vozilo-android.apk`)
  - Compiles **Web Release bundle** (`yolo-vozilo-web.zip`) and deploys to **GitHub Pages**
  - Compiles **Windows Desktop x64** (`yolo-vozilo-windows-x64.zip`)
  - Compiles **Linux Desktop x64** (`yolo-vozilo-linux-x64.tar.gz`)
- **Automated Releases**: Pushing a version tag automatically creates a GitHub Release with all compiled artifacts attached:
  ```bash
  git tag v1.0.0
  git push origin v1.0.0
  ```

---

## 📄 License & Attribution

Author: **Danilo Stoletović** • Mentor: **Dejan Batanjac**  
**ETŠ „Nikola Tesla“ Niš** • 2026

Licensed under the **[MIT License](LICENSE)**.
