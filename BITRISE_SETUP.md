# KaamCam Bitrise Setup Guide

This guide explains how to configure Bitrise for automated builds of KaamCam mobile apps.

## Prerequisites

1. GitHub/GitLab repository with your KaamCam code
2. Bitrise account (free tier works for personal use)
3. Apple Developer account (for iOS builds)
4. Google Play Developer account (for Android distribution)

## Step 1: Connect Repository to Bitrise

1. Log in to [Bitrise](https://app.bitrise.io)
2. Click "Add New App"
3. Select your Git provider and repository
4. Choose the branch to build (main/develop)
5. Select "Cordova" as the project type
6. Use the provided `bitrise.yml` in `cordova-template/`

## Step 2: Configure Secrets

In Bitrise, go to **Workflow > Secrets** and add:

### Required for Android Release Builds

| Secret Key | Description |
|------------|-------------|
| `BITRISEIO_ANDROID_KEYSTORE_URL` | Upload your keystore file and use the URL |
| `BITRISEIO_ANDROID_KEYSTORE_PASSWORD` | Your keystore password |
| `BITRISEIO_ANDROID_KEYSTORE_ALIAS` | Key alias (e.g., "kaamcam") |
| `BITRISEIO_ANDROID_KEYSTORE_PRIVATE_KEY_PASSWORD` | Private key password |

### Required for iOS Release Builds

| Secret Key | Description |
|------------|-------------|
| `BITRISE_APPLE_APPLE_ID` | Your Apple ID email |
| `BITRISE_APPLE_TEAM_ID` | Your Apple Team ID |
| Certificate & Profile | Upload via Bitrise Code Signing |

### API Configuration

| Environment Variable | Description |
|---------------------|-------------|
| `VITE_API_URL` | Your production API URL (e.g., `https://kaamcam.replit.app`) |

## Step 3: Create Android Keystore

If you don't have a keystore, create one:

```bash
keytool -genkey -v \
  -keystore kaamcam-release.keystore \
  -alias kaamcam \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass YOUR_STORE_PASSWORD \
  -keypass YOUR_KEY_PASSWORD
```

**Important:** Store this keystore securely - you'll need it for all future updates!

## Step 4: Configure iOS Code Signing

1. In Bitrise, go to **Workflow > Code Signing**
2. Upload your Apple Distribution certificate (.p12)
3. Upload your provisioning profile
4. Enable Automatic Code Signing if preferred

## Workflows

### `develop` - Debug Builds
- Triggers on push to `develop` branch
- Builds debug APK for testing
- No signing required

### `primary` - Android Release
- Triggers on push to `main` branch
- Builds signed release APK
- Ready for Google Play upload

### `ios` - iOS Release
- Manual trigger or configure trigger for `main`
- Builds signed IPA
- Ready for App Store upload

## Environment Variables

Add these in Bitrise **Workflow > Env Vars**:

```
VITE_API_URL=https://your-kaamcam-app.replit.app
```

## Running Builds

### Manual Build
1. Go to your app in Bitrise
2. Click "Start/Schedule a Build"
3. Select the workflow (develop/primary/ios)
4. Click "Start Build"

### Automatic Builds
Builds trigger automatically based on `trigger_map` in bitrise.yml:
- Push to `main` → primary workflow
- Push to `develop` → develop workflow
- Pull requests → primary workflow

## Build Artifacts

After successful builds, download from Bitrise:

- **Android**: `app-release-signed.apk` or `app-debug.apk`
- **iOS**: `KaamCam.ipa`

## Publishing to Stores

### Google Play

1. Download signed APK from Bitrise
2. Go to [Google Play Console](https://play.google.com/console)
3. Create/select your app
4. Upload APK to Production/Beta track

Or add the `google-play-deploy` step to automate:

```yaml
- google-play-deploy@3:
    inputs:
      - service_account_json_key_path: $BITRISEIO_SERVICE_ACCOUNT_JSON_KEY_URL
      - package_name: com.kaamcam.app
      - track: internal
```

### App Store

1. Download IPA from Bitrise
2. Use Transporter or Xcode to upload to App Store Connect
3. Submit for review

Or add the `deploy-to-itunesconnect-application-loader` step:

```yaml
- deploy-to-itunesconnect-application-loader@1:
    inputs:
      - itunescon_user: $APPLE_ID
      - password: $APP_SPECIFIC_PASSWORD
```

## Troubleshooting

### Build fails at Cordova platform add
- Ensure platforms folder is not in .gitignore
- Clear cache in Bitrise settings

### Signing failed
- Verify keystore credentials are correct
- Ensure keystore file is uploaded to Bitrise secrets

### iOS build fails
- Check provisioning profile matches bundle ID
- Verify certificate is not expired

### Web build fails
- Check npm dependencies are committed
- Ensure package-lock.json is present

## Version Management

Update version before release builds:

1. Edit `cordova-template/config.xml`:
   ```xml
   <widget id="com.kaamcam.app" version="1.0.1" ...>
   ```

2. For Android version codes, add in config.xml:
   ```xml
   <widget ... android-versionCode="2">
   ```

## Firebase Push Notifications

For push notifications to work:

1. Create Firebase project
2. Download `google-services.json` (Android)
3. Add to Bitrise secrets: `GOOGLE_SERVICES_JSON`
4. Update build script to copy file:
   ```bash
   echo "$GOOGLE_SERVICES_JSON" > $CORDOVA_PROJECT_DIR/platforms/android/app/google-services.json
   ```

## Support

- [Bitrise Documentation](https://devcenter.bitrise.io/)
- [Cordova Documentation](https://cordova.apache.org/docs/)
- [KaamCam Support](mailto:support@kaamcam.com)
