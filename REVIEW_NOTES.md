# ملاحظات مراجعة

## فجوات اختبار تحتاج قرارًا

- اختبارات repositories الكاملة بـ mock لـ `SupabaseClient` تحتاج refactor صغير لطبقة بيانات قابلة للحقن أو adapter حول Supabase query builders. المستودعات الحالية تستدعي fluent builders مباشرة (`from().select().eq()...`) وهذا يجعل mock دقيق للحالات الناجحة/timeout/empty هشًا جدًا. أضفت اختبارات للمنطق القابل للعزل وvalidation، لكن تغطية repository integration الحقيقية تحتاج قرارًا بتقديم adapter أو استخدام Supabase local test instance.

## أفكار مستقبلية

- إضافة طبقة `DatabaseClient` رفيعة لتسهيل اختبارات repositories بدون الاعتماد على Supabase runtime.

