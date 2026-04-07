# MathKids - Build & Play Store Guide

## Prerequisites

1. **Node.js** (v18+): `brew install node`
2. **Android Studio** (latest): https://developer.android.com/studio
3. **Java JDK 17**: `brew install --cask temurin`

## Quick Setup

```bash
# 1. Install dependencies & setup Android
./setup.sh

# 2. Test PWA locally
npx serve www
# Open http://localhost:3000 in browser

# 3. Open in Android Studio
npx cap open android
```

## Project Structure

```
Mathkids/
├── www/                    # Web app (PWA)
│   ├── index.html          # Main app
│   ├── manifest.json       # PWA manifest
│   ├── sw.js               # Service worker
│   └── icons/              # App icons (72-512px)
├── android/                # Android project (generated)
├── resources/              # Source assets
│   └── android/
│       ├── icon/           # Source icons
│       └── splash/         # Splash screen
├── package.json            # npm config
├── capacitor.config.ts     # Capacitor config
├── setup.sh                # Auto-setup script
└── BUILD_GUIDE.md          # This file
```

## Development Workflow

### Edit → Sync → Test

```bash
# 1. Edit files in www/
# 2. Sync to Android
npx cap sync

# 3. Run on emulator/device from Android Studio
#    OR command line:
cd android && ./gradlew installDebug
```

### Live Reload (Development)

Edit `capacitor.config.ts` temporarily:
```ts
server: {
  url: 'http://YOUR_IP:3000',  // from `npx serve www`
  cleartext: true,
}
```
Then `npx cap sync` and run. Remove before release build.

## Building for Play Store

### Step 1: Generate Signing Key

```bash
keytool -genkey -v -keystore release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias mathkids \
  -storepass YOUR_STORE_PASSWORD \
  -keypass YOUR_KEY_PASSWORD
```

**IMPORTANT:** Keep `release-key.jks` safe! You need it for every update.

### Step 2: Configure Signing in Gradle

Edit `android/app/build.gradle`, add inside `android { }`:

```gradle
signingConfigs {
    release {
        storeFile file('../../release-key.jks')
        storePassword 'YOUR_STORE_PASSWORD'
        keyAlias 'mathkids'
        keyPassword 'YOUR_KEY_PASSWORD'
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled false
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

### Step 3: Update Version

Edit `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        versionCode 1      // Increment for each upload
        versionName "3.0.0"
    }
}
```

### Step 4: Build Release AAB

```bash
cd android
./gradlew bundleRelease
```

Output: `android/app/build/outputs/bundle/release/app-release.aab`

### Step 5: Test Release Build

```bash
# Build APK for testing
cd android
./gradlew assembleRelease

# Install on device
adb install app/build/outputs/apk/release/app-release.apk
```

## Play Store Submission

### Google Play Console Setup

1. Go to https://play.google.com/console
2. Pay $25 developer registration fee (one-time)
3. Create new app:
   - **App name:** MathKids
   - **Default language:** Indonesian (Bahasa Indonesia)
   - **App type:** App
   - **Free or paid:** Free

### Store Listing

| Field | Value |
|-------|-------|
| **App name** | MathKids - Belajar Matematika Seru! |
| **Short description** | Belajar matematika menyenangkan untuk anak 3-10 tahun |
| **Full description** | (see below) |
| **Category** | Education |
| **Content rating** | Everyone |
| **Target audience** | Ages 3-10 |

#### Full Description (ID)
```
MathKids adalah aplikasi belajar matematika yang menyenangkan untuk anak-anak usia 3-10 tahun!

Fitur Utama:
🍎 Menghitung - Belajar menghitung benda
➕ Penjumlahan - Dari mudah sampai sulit
➖ Pengurangan - Step by step
✖️ Perkalian - Tabel perkalian interaktif
➗ Pembagian - Latihan pembagian

Keunggulan:
⭐ 150+ level dengan 3 tingkat kesulitan
🦊 9 karakter lucu yang menemani belajar
🌍 4 bahasa: Indonesia, English, Melayu, Français
🏆 Leaderboard dan sistem ranking
🎯 Tantangan harian
🎮 Gameplay yang seru dan edukatif
💜 Aman untuk anak - tanpa konten berbahaya

Cocok untuk:
- Anak TK & SD kelas 1-4
- Belajar di rumah
- Persiapan masuk sekolah
- Latihan matematika sehari-hari
```

### Required Assets

| Asset | Size | Notes |
|-------|------|-------|
| App icon | 512x512 PNG | Use `www/icons/icon-512x512.png` |
| Feature graphic | 1024x500 PNG | Create in Canva/Figma |
| Screenshots | Min 2 per device | Phone: 16:9 or 9:16 |

### Screenshots Tips

Use Android Studio emulator to capture:
1. Home screen with character
2. Level selection map
3. Game screen (answering question)
4. Result screen with stars
5. Leaderboard

### Privacy Policy

Required for apps targeting children. Create a simple privacy policy page stating:
- No personal data collected
- Data stored locally on device only
- No third-party analytics
- Compliant with COPPA

Host it on a simple webpage (GitHub Pages, Google Sites, etc.)

### Content Rating

Fill out the IARC questionnaire:
- Violence: None
- Sexual content: None
- Language: None
- Controlled substances: None
- **Result: Rated for Everyone**

## Android Permissions

The app requires minimal permissions. Edit `android/app/src/main/AndroidManifest.xml` if needed:

```xml
<!-- Internet for loading fonts (optional - fonts can be bundled) -->
<uses-permission android:name="android.permission.INTERNET" />
```

## Troubleshooting

### White screen on Android
- Check `capacitor.config.ts` → `webDir` points to `www`
- Run `npx cap sync` after any web changes

### Icons not showing
- Run setup.sh again
- Or manually copy icons to `android/app/src/main/res/mipmap-*/`

### Build fails
- Ensure Java 17: `java -version`
- Ensure Android SDK installed via Android Studio
- Set `ANDROID_HOME`: `export ANDROID_HOME=~/Library/Android/sdk`

### Sync issues
```bash
npx cap sync --force
```
