# Numuw Store Release Checklist

## Fixed application identity

- Product: `نُمُوّ | Numuw`
- Android package: `com.numuw.app`
- iOS bundle identifier: `com.numuw.app`
- Android target SDK: API 36
- Version source: `pubspec.yaml`

## Technical release gates

- [ ] `flutter analyze --no-fatal-infos` passes.
- [ ] `flutter test -r expanded` passes.
- [ ] Android release AAB builds with production upload key.
- [ ] Android release is not debug-signed.
- [ ] iOS signed IPA builds with App Store distribution profile.
- [ ] TestFlight installation works on a physical iPhone.
- [ ] Play Internal installation works on a physical Android device.
- [ ] Login/sign-up works against production Supabase.
- [ ] RLS/guardian access is verified with two separate user accounts.
- [ ] AI Edge Functions work without exposing provider keys to the client.
- [ ] Notifications are verified on iOS and Android.
- [ ] Account deletion flow is available and verified before store submission.

## Current product blocker: Premium

The current Premium screen displays monthly/annual pricing, a seven-day trial, renewal language, restore-purchase wording, and a purchase CTA, but the purchase function is currently a UI placeholder and no native in-app purchase dependency is configured.

Before production store review, choose one path:

### Option A — launch v1 free

- Remove/hide paid pricing and trial claims from the production build.
- Keep Premium as a future feature or waitlist only.
- Do not claim restore-purchase functionality.

### Option B — launch with subscription

Provide and implement:

- Apple subscription product IDs.
- Google Play subscription/base-plan IDs.
- Monthly and annual pricing strategy.
- Trial duration.
- Entitlement model in Supabase.
- Purchase validation/server-side entitlement synchronization.
- Restore purchases.
- Manage subscription links.
- Terms of Use and Privacy Policy links on the paywall.
- Store-compliant subscription disclosures.

Do not submit the current placeholder paywall as a functional paid subscription flow.

## Privacy and data safety

Review every collected data type before filling store forms. Based on the current product scope this may include account data, child profile data, care logs, health-related tracking data, uploaded child documents/images, AI questions, and diagnostics. The final declarations must match actual production behavior.

- [ ] Privacy Policy URL exists publicly.
- [ ] Support URL exists publicly.
- [ ] Data retention policy is defined.
- [ ] Account deletion policy is defined.
- [ ] User can request/delete account data.
- [ ] Google Play Data safety form completed accurately.
- [ ] Apple App Privacy nutrition labels completed accurately.
- [ ] AI/provider data processing is described accurately where required.
- [ ] Child/family data handling and guardian access are explained clearly.

## Permissions

Current Android manifest requests:

- Internet access.
- Post notifications.

Before release, re-audit Android and iOS permissions after every dependency addition. Do not request camera/photos/microphone/location permissions unless a shipped feature actually requires them and the corresponding store/privacy explanations are present.

## App Store Connect

- [ ] Apple Developer Program active.
- [ ] App record created for bundle ID `com.numuw.app`.
- [ ] Primary category selected.
- [ ] Updated age-rating questions completed.
- [ ] Privacy Policy URL entered.
- [ ] Support URL entered.
- [ ] Arabic and English store name/subtitle/description prepared.
- [ ] iPhone screenshots prepared for required device sizes.
- [ ] App icon reviewed at store size.
- [ ] TestFlight internal test completed.
- [ ] Review notes and test account prepared if login is required.

## Google Play Console

- [ ] Developer account active and verified.
- [ ] App created as `com.numuw.app`.
- [ ] First signed AAB uploaded manually.
- [ ] Play App Signing enabled.
- [ ] Store listing completed.
- [ ] App access instructions/test account added if login is required.
- [ ] Ads declaration matches production behavior.
- [ ] Content rating completed.
- [ ] Target audience/children policy questions completed accurately.
- [ ] Data safety completed.
- [ ] Internal testing completed.
- [ ] Service account configured for Codemagic after first upload.

## Owner decisions/details still required

These are safe to provide in chat:

- Apple Developer account: active / not active.
- Google Play Console account: active / not active.
- GitHub plan if private Pages is desired.
- Developer/Seller legal name.
- Launch country/countries.
- Primary app category.
- Support domain/URL.
- Privacy Policy domain/URL.
- Launch model: free v1 or paid subscription.
- If paid: monthly/annual prices and desired trial.

Never provide passwords, private keys, service-account JSON, keystore files, or secret API keys in chat.
