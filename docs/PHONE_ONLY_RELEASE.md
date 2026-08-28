# تشغيل وتطوير ونشر نُمُوّ من الموبايل فقط

هذا الملف هو دليل التشغيل الرسمي لنُمُوّ بدون الحاجة إلى لابتوب. الهاتف هو لوحة التحكم، بينما GitHub Actions وCodemagic ينفذان البناء والاختبارات في السحابة.

## الشكل النهائي

```text
ChatGPT / GitHub Mobile
        |
        v
GitHub repository
   |          |
   |          +--> GitHub Actions: analyze + tests + Android debug + web build
   |
   +--> GitHub Pages: browser preview
   |
   +--> Codemagic
          |--> signed Android AAB/APK
          |--> Google Play Internal
          +--> signed iOS IPA --> TestFlight

Flutter app --> Supabase --> Edge Functions --> AI provider
```

## قواعد الأسرار

لا ترسل أو تحفظ أيًا من القيم التالية داخل GitHub files أو Issues أو Pull Requests أو المحادثات:

- Android keystore passwords.
- Android `.jks` / `.keystore` except as a short-lived private workflow artifact.
- Apple `.p8` private API key.
- Apple distribution certificates/private keys.
- Google Play service-account JSON.
- Supabase secret/service-role keys.
- Gemini/OpenAI/provider secret keys.

استخدم GitHub Secrets أو Codemagic Environment Variables أو Supabase Edge Function Secrets.

## 1. GitHub — إعداد مرة واحدة

### Secrets المطلوبة للـWeb Preview

من Repo نُمُوّ:

`Settings -> Secrets and variables -> Actions -> New repository secret`

أضف:

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

هذه القيم خاصة بالـfrontend فقط. لا تضع Supabase secret key أو service-role key.

### تفعيل GitHub Pages

`Settings -> Pages -> Build and deployment -> Source -> GitHub Actions`

بعد الدمج في `numuw-redesign` سيقوم workflow `Deploy mobile web preview` ببناء ونشر نسخة Flutter Web.

ملاحظة: GitHub Pages للـprivate repositories يتطلب خطة GitHub تدعم Pages للـprivate repos. إذا لم تكن متاحة للحساب، يبقى CI وCodemagic شغالين وسنستخدم مزود preview خارجي لاحقًا.

## 2. Supabase — المطلوب

الكود الحالي يشير إلى مشروع:

`mwqscuoutmbihexphocx`

ولكي نستطيع إدارة backend من الاتصال الحالي يجب أن يصبح هذا المشروع ظاهرًا في حساب Supabase المتصل أو يتم ربط الحساب/الـorganization الذي يملكه.

المطلوب ليس إرسال أي secret في المحادثة. فقط:

- اربط حساب Supabase الذي يحتوي المشروع، أو
- أضف الحساب الحالي كعضو في الـSupabase organization المناسبة.

بعدها يجب مراجعة:

- Auth settings.
- RLS policies.
- Storage policies.
- migrations.
- `ai-assistant` Edge Function.
- `ai-assistant-chat` Edge Function.
- AI provider secret الموجود داخل Supabase فقط.
- Security and performance advisors.

## 3. Android upload keystore — بدون لابتوب

تمت إضافة workflow باسم:

`Generate Android upload keystore`

قبل تشغيله أضف GitHub Secrets:

- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`

استخدم كلمتي مرور قويتين مختلفتين أو متطابقتين حسب تفضيلك واحفظهما في password manager.

ثم من GitHub على الموبايل:

`Actions -> Generate Android upload keystore -> Run workflow`

بعد نجاحه:

1. افتح الـworkflow run.
2. نزّل Artifact باسم `numuw-upload-keystore`.
3. احتفظ بنسخة آمنة ودائمة من ملف `numuw-upload-keystore.jks` خارج GitHub.
4. الـArtifact على GitHub مضبوط على retention يوم واحد فقط.

الـalias المستخدم هو:

`numuw`

لا تفقد الـkeystore أو كلمات مروره. يجب استخدام نفس upload key في الإصدارات التالية.

## 4. Codemagic — ربط المشروع

1. افتح Codemagic من Safari/Chrome.
2. سجّل الدخول بـGitHub.
3. أضف `amohamed-alt/Numuw`.
4. اختر branch الذي يحتوي `codemagic.yaml`.
5. استخدم YAML workflows.

الملف يحتوي 3 workflows:

- `numuw-android-build`: يبني AAB وAPK موقعين بدون نشر، مناسب لأول رفع إلى Play Console.
- `numuw-android-play-internal`: يبني وينشر إلى Google Play Internal بعد تجهيز Play API.
- `numuw-ios-testflight`: يبني IPA موقعًا ويرفعه إلى TestFlight.

### Codemagic group: `numuw_backend`

أضف متغيرين:

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

### Android signing identity

من:

`Team settings -> codemagic.yaml settings -> Code signing identities -> Android keystores`

ارفع ملف الـJKS الذي تم إنشاؤه من GitHub، واستخدم Reference name بالضبط:

`numuw-upload-keystore`

أدخل:

- Keystore password.
- Key alias: `numuw`.
- Key password.

## 5. Google Play

يلزم حساب Google Play Console.

هوية Android الرسمية:

`com.numuw.app`

من Codemagic شغّل أولًا:

`numuw-android-build`

سينتج `.aab` موقعًا. لأول إصدار، أنشئ التطبيق في Play Console وارفع أول AAB يدويًا من المتصفح. بعد ذلك يمكن تفعيل النشر الآلي.

### للنشر الآلي بعد أول رفع

أنشئ Google Cloud service account ومنحه صلاحية مناسبة في Play Console، ثم ضع JSON الكامل داخل Codemagic كـSecret variable:

`GOOGLE_PLAY_SERVICE_ACCOUNT_CREDENTIALS`

داخل group باسم:

`google_play`

بعدها استخدم workflow:

`numuw-android-play-internal`

وهو مضبوط على track:

`internal`

والرفع الآلي مضبوط حاليًا كـdraft للحماية أثناء الإعداد الأول.

## 6. Apple / TestFlight

يلزم Apple Developer Program فعال وإنشاء App record في App Store Connect.

هوية iOS الرسمية:

`com.numuw.app`

اسم التطبيق:

`نُمُوّ`

### App Store Connect API key

من App Store Connect:

`Users and Access -> Integrations -> App Store Connect API`

أنشئ API key مخصصًا لـCodemagic بصلاحية `App Manager`، واحتفظ بـ:

- `.p8` private key.
- Key ID.
- Issuer ID.

أضف في Codemagic group باسم `appstore_credentials`:

- `APP_STORE_CONNECT_PRIVATE_KEY`
- `APP_STORE_CONNECT_KEY_IDENTIFIER`
- `APP_STORE_CONNECT_ISSUER_ID`

جميعها Secrets.

### iOS code signing identities

في Codemagic:

`Team settings -> codemagic.yaml settings -> Code signing identities`

جهّز Apple Distribution certificate وApp Store provisioning profile المطابق لـ:

`com.numuw.app`

يمكن لـCodemagic إنشاء/جلب ملفات التوقيع بعد ربط App Store Connect API key، فلا تحتاج Mac.

بعدها شغّل:

`numuw-ios-testflight`

الـworkflow يستخدم أحدث Xcode في Codemagic، ويشغّل tests ثم يبني IPA ويرفع إلى TestFlight، ولا يرسل التطبيق تلقائيًا لمراجعة App Store.

## 7. التطوير اليومي من الهاتف

التدفق الموصى به:

1. اطلب التعديل من ChatGPT/Codex.
2. يتم العمل في branch صغير.
3. افتح Pull Request.
4. GitHub Actions يشغل analyze/tests/web build/Android debug build.
5. راجع الـPR من GitHub Mobile.
6. راجع الـWeb Preview من Safari عندما يكون Pages مفعّلًا.
7. Merge بعد نجاح CI والمراجعة.
8. عند الحاجة لتجربة native حقيقية شغّل Codemagic ثم TestFlight أو Play Internal.

## 8. متطلبات المتاجر التي يجب الحفاظ عليها

- Android: التطبيق مضبوط على API 36 حاليًا.
- iOS builds: استخدم Xcode 26 أو أحدث وفق متطلبات App Store الحالية.
- لا يتم استخدام debug signing في Android production.
- يجب زيادة build number لكل build يتم رفعه للمتاجر.
- Screenshots وprivacy/data-safety/content-rating/store metadata يتم إكمالها داخل المتاجر قبل production release.

## 9. البيانات التي يمكن إرسالها في المحادثة لإكمال الإعداد

يمكن إرسال هذه المعلومات لأنها ليست أسرارًا:

- هل حساب Apple Developer تم شراؤه وتفعيله أم لا؟
- هل Google Play Console تم إنشاؤه أم لا؟
- هل لديك GitHub Pro إذا كان الـrepo سيظل Private؟
- الاسم القانوني/اسم الشركة الذي سيظهر كDeveloper/Seller.
- الدولة التي سيتم النشر منها.
- Support URL المطلوب.
- Privacy Policy URL المطلوب، أو الدومين الذي سننشئ الصفحة عليه.
- هل نُمُوّ مجاني بالكامل أم فيه Premium/Subscription؟
- الدول المستهدفة عند الإطلاق الأول.

لا ترسل كلمات مرور أو ملفات `.p8` أو `.jks` أو service-account JSON في المحادثة.
