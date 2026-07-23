# PESAPOP AI — Flutter App

## Setup

```bash
# Install dependencies
flutter pub get

# Set your API URL (for physical device, use your computer's local IP)
# Edit lib/core/constants/api_constants.dart → baseUrl

# Run
flutter run

# Build release APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release

# Build iOS
flutter build ipa --release
```

## Firebase Setup (Required for push notifications)

1. Create project at https://console.firebase.google.com
2. Add Android app (package: `com.pesapop.app`)
3. Download `google-services.json` → place in `android/app/`
4. Add iOS app → download `GoogleService-Info.plist` → place in `ios/Runner/`
5. Run `flutterfire configure`

## Connect Flutter to Backend

Edit `lib/core/constants/api_constants.dart`:

```dart
// Development (Android emulator)
static const String baseUrl = 'http://10.0.2.2:4000/api/v1';

// Development (physical device — use your machine's IP)
static const String baseUrl = 'http://192.168.1.x:4000/api/v1';

// Production
static const String baseUrl = 'https://api.pesapop.africa/api/v1';
```

## Architecture

```
Flutter App
├── Riverpod providers (state)
│   └── Repositories (data layer)
│       └── ApiService (Dio HTTP client)
│           └── PESAPOP Backend API
```

Every `// TODO: Replace with real API call` has been replaced.
The app is now fully wired to the live backend.
