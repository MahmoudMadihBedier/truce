# truce

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Local Development & Connectivity

The Truce Egypt mobile application connects to a custom Python scraping backend. To ensure successful data retrieval during development:

### 1. Run the Python Backend
Ensure you have the Python backend running on your host machine:
```bash
cd backend
pip install -r requirements.txt
python main.py
```
The backend starts on port `8000`.

### 2. Configure Mobile Connectivity
The app's API base URL is configured in `lib/core/utils/constants.dart`.

- **Android Emulator:** The default `http://10.0.2.2:8000` is pre-configured and should work out of the box.
- **iOS Simulator:** Update `apiBaseUrl` to `http://localhost:8000`.
- **Real Device (Android/iOS):**
    1. Find your computer's local IP address (e.g., `192.168.1.5`).
    2. Update `apiBaseUrl` to `http://<your-ip>:8000`.
    3. Ensure your mobile device is on the same Wi-Fi network as your computer.

### 3. Supabase Integration
The app uses a legacy JWT `anonKey` for maximum compatibility with all network configurations and project-level headers.
