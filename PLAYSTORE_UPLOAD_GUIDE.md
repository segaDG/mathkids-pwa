# 📱 MathKids Play Store Upload Guide

## ✅ Pre-flight Checklist

- [x] Signed AAB built (`android/app/build/outputs/bundle/release/app-release.aab`)
- [x] Keystore backed up (Google Drive + password manager)
- [x] Privacy Policy hosted ([www/privacy.html](www/privacy.html) — deploy via GitHub Pages)
- [ ] Google Play Console account created ($25 one-time)
- [ ] App icon 512×512 px PNG
- [ ] Feature graphic 1024×500 px PNG
- [ ] At least 2 phone screenshots (1080×1920 or 9:16)
- [ ] App description prepared ([PLAYSTORE_LISTING.md](PLAYSTORE_LISTING.md))

---

## STEP 1: Deploy Privacy Policy

Privacy policy must be publicly accessible before submitting:

```bash
cd /Users/segadharmawan/Desktop/WORKS/Claude/Mathkids
git add www/privacy.html
git commit -m "docs: add privacy policy"
git push origin main
git subtree split --prefix www -b tmp && git push origin tmp:gh-pages --force && git branch -D tmp
```

After deploy, your privacy policy will be at:
**https://segadg.github.io/mathkids-pwa/privacy.html**

Verify it loads in your browser before continuing.

---

## STEP 2: Create Asset Images

### Option A: Use the HTML templates I created

1. Open `feature_graphic.html` in Chrome
2. Right-click → Inspect → toggle device toolbar (Cmd+Shift+M)
3. Set custom resolution: 1024×500
4. Right-click on the graphic → "Capture node screenshot"
5. Save as `feature_graphic.png`

For screenshots:
1. Open `screenshot_template.html` in Chrome
2. Each card is 540×960 (will export at 2x = 1080×1920)
3. Use browser screenshot tool or DevTools "Capture node screenshot"
4. Save as `screenshot_1.png`, `screenshot_2.png`, etc.

### Option B: Use Figma/Canva (recommended for quality)

Templates with these specs:
- **App icon**: 512×512 px (no transparency, square)
- **Feature graphic**: 1024×500 px (no text near edges)
- **Phone screenshots**: 1080×1920 px (or 9:16 ratio)

---

## STEP 3: Google Play Console Setup

1. Go to https://play.google.com/console
2. Sign in with Google account
3. Pay **$25 one-time registration fee**
4. Verify identity (KTP/passport scan)
5. Wait for verification (1-3 days)

---

## STEP 4: Create App in Play Console

1. Click **"Create app"**
2. Fill in:
   - **App name**: MathKids
   - **Default language**: English (United States)
   - **App or game**: Game
   - **Free or paid**: Free
3. Accept declarations:
   - ✅ Developer Program Policies
   - ✅ US export laws
4. Click **"Create app"**

---

## STEP 5: Set Up Store Listing

### Main store listing
Path: Grow > Store presence > Main store listing

- **App name**: MathKids: Math Learning Game
- **Short description**: (copy from PLAYSTORE_LISTING.md)
- **Full description**: (copy from PLAYSTORE_LISTING.md)
- **App icon**: upload 512×512 PNG
- **Feature graphic**: upload 1024×500 PNG
- **Phone screenshots**: upload 2-8 screenshots

### Categorization
Path: Grow > Store presence > Store settings

- **App category**: Education
- **Tags**: Math, Education, Kids
- **Email**: sega1902@gmail.com
- **Website**: https://segadg.github.io/mathkids-pwa/
- **Privacy Policy URL**: https://segadg.github.io/mathkids-pwa/privacy.html

---

## STEP 6: App Content (CRITICAL for kids apps)

Path: Policy > App content

### Privacy policy
- URL: `https://segadg.github.io/mathkids-pwa/privacy.html`

### App access
- All functionality is available without restrictions ✅

### Ads
- ❌ **No, my app does not contain ads**

### Content rating
1. Click **"Start questionnaire"**
2. Email: sega1902@gmail.com
3. Category: **Reference, News, or Educational**
4. Answer all questions honestly:
   - Violence: No
   - Sexual content: No
   - Profanity: No
   - Drugs: No
   - Gambling: No
   - User-generated content: No (names are filtered)
   - Sharing user location: No
   - Personal info collected: Yes (name, age — anonymous)
   - Digital purchases: Yes (subscription)
5. Submit

### Target audience
- **Target age**: 5 and under, 6-8, 9-12 (multi-select)
- **Appeals to children**: Yes
- **Mixed audiences**: No (children only)

### News app declaration
- ❌ Not a news app

### COVID-19 contact tracing
- ❌ Not a tracing app

### Data safety
Path: App content > Data safety

Declare:
- **Data collected**: Name (display), Age, Country, Game progress
- **Data shared with third parties**: No
- **Data encrypted in transit**: Yes (HTTPS)
- **Users can request data deletion**: Yes (in-app delete account)
- **All data**: Optional (user can play without account)

### Government apps
- ❌ Not a government app

### Financial features
- ❌ Not a financial app

### Health
- ❌ Not a health app

### Families self-certification (REQUIRED for kids apps)
- ✅ Complies with Families Policy
- ✅ Complies with COPPA
- ✅ Designed primarily for children
- ✅ No age-inappropriate content
- ✅ No third-party advertising

---

## STEP 7: Pricing & Distribution

Path: Monetize > Products > In-app products (skip for now if no IAP yet)

Path: Release > Production > Countries / regions

Select countries to distribute:
- ✅ Indonesia
- ✅ United States
- ✅ Malaysia
- ✅ Singapore
- ✅ Australia
- ✅ United Kingdom
- ✅ France
- ✅ Japan
- ✅ All other countries (recommended)

---

## STEP 8: Upload AAB

Path: Release > Production > Create new release

1. Click **"Create new release"**
2. **App signing**: Use Google Play App Signing (recommended) — Google will manage your signing key
3. Click **"Upload"** and select:
   `/Users/segadharmawan/Desktop/WORKS/Claude/Mathkids/android/app/build/outputs/bundle/release/app-release.aab`
4. Wait for upload + processing
5. **Release name**: 1.0.0
6. **Release notes** (per language):

```
🎉 Welcome to MathKids!

The first release of MathKids brings:
✨ 270+ math levels across 9 categories
🌍 5 languages (Indonesian, English, Malay, French, Japanese)
💰 8 real currencies for money lessons
🏆 Global leaderboards
🎭 9 adorable mascots to unlock
☁️ Cloud sync across devices
🔐 Parent zone with PIN protection

Download now and watch your child fall in love with math!
```

7. Click **"Save"**
8. Click **"Review release"**
9. Fix any errors shown
10. Click **"Start rollout to Production"**

---

## STEP 9: Wait for Review

- **Initial review**: 7 days (first submission can take longer)
- **Updates**: usually 1-3 days
- You'll receive email notifications about review status

### Common rejection reasons (avoid these):
- ❌ Privacy policy not accessible
- ❌ Privacy policy doesn't match data collection declared
- ❌ App targets children but has third-party ads
- ❌ Inappropriate content not filtered
- ❌ Misleading metadata
- ❌ App crashes on first launch

### If rejected:
1. Read the rejection email carefully
2. Fix the specific issue
3. Build new AAB with **incremented versionCode**
4. Re-upload and explain the fix in release notes

---

## STEP 10: After Approval

🎉 Your app is live on Play Store!

URL format: `https://play.google.com/store/apps/details?id=com.mathkids.app`

### Next steps:
1. **Share** with friends/family for first reviews
2. **Monitor** crashes in Play Console > Quality > Android vitals
3. **Respond** to user reviews (Play Console > Reviews)
4. **Update** regularly with bug fixes (increment versionCode each time)

---

## 🚨 IMPORTANT REMINDERS

1. **Keystore backup** — if you lose `mathkids-release.keystore`, you can NEVER update this app
2. **Increment versionCode** — every new upload needs versionCode > previous
3. **Update privacy policy** — if you add new data collection, update the policy
4. **Respond to reviews** — Google ranks apps higher when developers reply
5. **Test before release** — install AAB on real device first via internal testing track

---

## 📞 Need help?

- Play Console help: https://support.google.com/googleplay/android-developer
- Families Policy: https://support.google.com/googleplay/android-developer/answer/9893335
- COPPA guidance: https://www.ftc.gov/business-guidance/privacy-security/childrens-privacy

Good luck! 🚀
