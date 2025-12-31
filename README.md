# KaamCam Native Mobile App (Cordova)

Build KaamCam as a native Android and iOS app that wraps the production website at **https://kaamcam.com** with native features like push notifications, camera access, offline support, and more.

## Features

- **Animated Splash Screen** - Beautiful emerald green splash with camera logo animation
- **Push Notifications** - Firebase Cloud Messaging for Android, APNs for iOS
- **Offline Support** - Offline indicator and graceful error handling
- **Native Camera** - Access device camera directly
- **Geolocation** - GPS-based location tagging
- **Native App Feel** - Status bar styling, back button handling, smooth transitions
- **Production URL Loading** - Loads live app from https://kaamcam.com/login

## Project Structure

```
cordova-template/
├── config.xml           # Cordova configuration with plugins
├── www/                 # Web assets (animated splash + native bridge)
│   ├── index.html       # Main HTML with splash animation
│   └── css/
│       └── splash.css   # Additional splash animations
├── res/                 # App icons and splash screens
│   ├── android/         # Android icon sizes
│   └── ios/             # iOS icon sizes
├── scripts/
│   └── generate-icons.sh  # Icon generation script
├── bitrise.yml          # CI/CD configuration
├── BITRISE_SETUP.md     # Detailed Bitrise instructions
└── README.md            # This file
```

## Quick Start

### Prerequisites

- Node.js 18+ 
- Cordova CLI: `npm install -g cordova@12`
- For Android: Android Studio with SDK 34+
- For iOS: Xcode 15+ (macOS only)
- ImageMagick (for icon generation): `brew install imagemagick`

### 1. Create Cordova Project

```bash
# Create new Cordova project
cordova create kaamcam-app com.kaamcam.app KaamCam

# Navigate to project
cd kaamcam-app

# Copy files from template
cp ../cordova-template/config.xml ./config.xml
cp -r ../cordova-template/www ./www
cp -r ../cordova-template/res ./res

# Add platforms
cordova platform add android@12
cordova platform add ios@7  # macOS only
```

### 2. Install Required Plugins

```bash
# All plugins at once
cordova plugin add cordova-plugin-device \
  cordova-plugin-camera \
  cordova-plugin-geolocation \
  cordova-plugin-file \
  cordova-plugin-network-information \
  cordova-plugin-statusbar \
  cordova-plugin-splashscreen \
  cordova-plugin-media-capture \
  cordova-plugin-inappbrowser \
  cordova-plugin-whitelist

# Push notifications (requires Firebase)
cordova plugin add phonegap-plugin-push \
  --variable ANDROID_SUPPORT_V13_VERSION=28.0.0 \
  --variable FCM_VERSION=23.0.6
```

### 3. Generate Icons

```bash
# Place your 1024x1024 logo at res/icon-source.png
# Then run the icon generator
cd ../cordova-template
./scripts/generate-icons.sh
cd ../kaamcam-app
cp -r ../cordova-template/res ./res
```

### 4. Build and Run

```bash
# Debug build (Android)
cordova build android --debug
cordova run android --device

# Debug build (iOS)
cordova build ios --debug
cordova run ios --device

# Release build (Android)
cordova build android --release
```

## Bitrise CI/CD Setup

This template includes full Bitrise configuration for automated builds.

### Required Secrets in Bitrise

| Secret | Description |
|--------|-------------|
| `BITRISEIO_ANDROID_KEYSTORE_URL` | Upload URL for your Android keystore |
| `BITRISEIO_ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `BITRISEIO_ANDROID_KEYSTORE_ALIAS` | Key alias |
| `BITRISEIO_ANDROID_KEYSTORE_PRIVATE_KEY_PASSWORD` | Key password |
| `APPLE_TEAM_ID` | Apple Developer Team ID (iOS) |
| `APPLE_ID` | Apple ID email (iOS) |
| `APPLE_APP_SPECIFIC_PASSWORD` | App-specific password (iOS) |

### Workflows

| Workflow | Trigger | Output |
|----------|---------|--------|
| `develop` | Push to `develop` | Debug APK |
| `primary` | Push to `main` | Signed Release APK |
| `ios` | Manual trigger | Signed IPA |
| `deploy-all` | Manual trigger | Both APK and IPA |

See `BITRISE_SETUP.md` for detailed instructions.

## Firebase Push Notifications

### Android Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create/select project
3. Add Android app with package: `com.kaamcam.app`
4. Download `google-services.json`
5. Place in `platforms/android/app/google-services.json`

### iOS Setup

1. In Firebase Console, add iOS app
2. Download `GoogleService-Info.plist`
3. Add to Xcode project under `platforms/ios/KaamCam/Resources/`
4. Enable Push Notifications capability in Xcode

### Server Configuration

Update your server's FCM sender ID in `www/index.html`:

```javascript
const push = PushNotification.init({
    android: {
        senderID: 'YOUR_FCM_SENDER_ID', // Replace with Firebase sender ID
        // ...
    }
});
```

## App Icons

### Required Sizes

**Android (res/android/)**
| File | Size |
|------|------|
| icon-ldpi.png | 36x36 |
| icon-mdpi.png | 48x48 |
| icon-hdpi.png | 72x72 |
| icon-xhdpi.png | 96x96 |
| icon-xxhdpi.png | 144x144 |
| icon-xxxhdpi.png | 192x192 |

**iOS (res/ios/)**
| File | Size |
|------|------|
| icon-20.png | 20x20 |
| icon-20@2x.png | 40x40 |
| icon-20@3x.png | 60x60 |
| icon-29.png | 29x29 |
| icon-29@2x.png | 58x58 |
| icon-29@3x.png | 87x87 |
| icon-40.png | 40x40 |
| icon-40@2x.png | 80x80 |
| icon-40@3x.png | 120x120 |
| icon-60@2x.png | 120x120 |
| icon-60@3x.png | 180x180 |
| icon-76.png | 76x76 |
| icon-76@2x.png | 152x152 |
| icon-83.5@2x.png | 167x167 |
| icon-1024.png | 1024x1024 |

## Signing for Release

### Android Keystore

```bash
# Generate keystore (one-time)
keytool -genkey -v -keystore kaamcam.keystore \
  -alias kaamcam \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

# Build signed APK
cordova build android --release -- \
  --keystore=kaamcam.keystore \
  --storePassword=YOUR_STORE_PASSWORD \
  --alias=kaamcam \
  --password=YOUR_KEY_PASSWORD
```

### iOS Code Signing

1. Open `platforms/ios/KaamCam.xcworkspace` in Xcode
2. Select your team under Signing & Capabilities
3. Enable automatic signing or configure manually
4. Archive: Product → Archive
5. Distribute: Organizer → Distribute App

## Native Bridge API

The app injects a `KaamCamNative` object into the web app for accessing native features:

```javascript
// Check if running in native app
if (window.KaamCamNative?.isNativeApp) {
    // Take photo
    window.KaamCamNative.takePhoto({ quality: 80 });
    
    // Get location
    window.KaamCamNative.getLocation();
    
    // Get push token
    window.KaamCamNative.getPushToken();
    
    // Vibrate
    window.KaamCamNative.vibrate(100);
}

// Listen for results
window.addEventListener('message', (event) => {
    if (event.data.type === 'photoResult') {
        console.log('Photo:', event.data.data);
    }
    if (event.data.type === 'locationResult') {
        console.log('Location:', event.data.latitude, event.data.longitude);
    }
});
```

## Testing

### Android Emulator
```bash
cordova emulate android
```

### Physical Device
```bash
# Android
adb devices
cordova run android --device

# iOS
cordova run ios --device
```

## Troubleshooting

### Camera not working
- Grant camera permission when prompted
- Ensure `AndroidManifest.xml` has CAMERA permission

### Location not updating
- Enable GPS on device
- Grant location permission

### Push notifications not received
- Verify `google-services.json` is in correct location
- Check FCM sender ID matches Firebase project
- Ensure device is registered with FCM

### Offline mode issues
- Clear app data and retry
- Check IndexedDB storage is available

### App shows error screen
- Check internet connection
- Verify https://kaamcam.com is accessible
- Try "Try Again" button

### Build fails on Bitrise
- Verify all secrets are configured correctly
- Check keystore file is uploaded
- Review build logs for specific errors

## Production Checklist

- [ ] Update version in `config.xml`
- [ ] Generate production icons using provided script
- [ ] Configure Firebase for production
- [ ] Create/configure Android keystore
- [ ] Set up iOS signing certificates
- [ ] Configure App Store Connect
- [ ] Test on multiple devices (phones and tablets)
- [ ] Verify push notifications work
- [ ] Test offline functionality
- [ ] Test camera and location features
- [ ] Review app store listing requirements

## Support

For issues with the native app wrapper, check:
1. Cordova documentation: https://cordova.apache.org/docs
2. Plugin documentation for specific features
3. Bitrise support for CI/CD issues

For KaamCam application issues, contact support@kaamcam.com
