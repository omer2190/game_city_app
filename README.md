# 🎮 Gaming City App

تطبيق **Gaming City** هو تطبيق Flutter موجه لمجتمع اللاعبين، يجمع بين الأخبار، الألعاب المجانية/المخفضة، المجتمع والدردشة، والإشعارات في تجربة واحدة تدعم اللغة العربية وتكامل Firebase.

---

## ✨ المزايا الرئيسية

- ✅ نظام مصادقة متكامل (تسجيل دخول، تسجيل جديد، تحقق بريد، استعادة كلمة المرور، تغيير كلمة المرور).
- ✅ متابعة الأخبار مع عرض التفاصيل والتعليقات.
- ✅ استكشاف الألعاب (مجانية، مخفضة، تفاصيل اللعبة، الطلب/البحث).
- ✅ مجتمع اللاعبين (أصدقاء، غرف دردشة، ملفات شخصية).
- ✅ قائمة مفضلة (Wishlist) للألعاب.
- ✅ إشعارات فورية عبر Firebase Cloud Messaging.
- ✅ بنية Modular مبنية على GetX لتسهيل التوسعة والصيانة.

---

## 🧱 التقنية المستخدمة

- **Framework:** Flutter
- **Language:** Dart
- **State Management & Routing:** GetX
- **Networking:** Dio + HTTP
- **Realtime & Notifications:** Firebase (Core, Messaging, Realtime Database)
- **Local Storage:** GetStorage + SharedPreferences
- **UI:** Google Fonts, SVG, Cached Network Images

---

## 📁 هيكلة المشروع

```text
lib/
├─ core/        # ثوابت، Theme، خدمات عامة، الشبكات
├─ data/        # Models + Repositories
├─ modules/     # Features (Auth, Home, News, Games, Community...)
├─ routes/      # تعريف المسارات والصفحات
└─ shared/      # Widgets ومكونات مشتركة
```

---

## 🚀 التشغيل المحلي

### 1) المتطلبات

- Flutter SDK (متوافق مع Dart `^3.9.2`)
- Android Studio أو VS Code
- جهاز محاكي أو هاتف فعلي
- مشروع Firebase مهيأ للتطبيق

### 2) تثبيت الاعتمادات

```bash
flutter pub get
```

### 3) تشغيل التطبيق

```bash
flutter run
```

### 4) بناء نسخة إنتاج

**Android APK:**

```bash
flutter build apk --release
```

**Android App Bundle:**

```bash
flutter build appbundle --release
```

**iOS:**

```bash
flutter build ios --release
```

---

## ⚙️ الإعدادات المهمة

- إعدادات Firebase موجودة في:
  - `lib/firebase_options.dart`
  - `android/app/google-services.json`
- نقطة الاتصال الأساسية للـ API معرفة في:
  - `lib/core/values/api_constants.dart`
- توثيق نقاط النهاية متوفر في:
  - `API_ENDPOINTS.md`

> ملاحظة: قبل النشر، تأكد من تحديث `baseUrl` بما يتناسب مع بيئة التشغيل (Development / Staging / Production).

---

## 🔐 الوحدات الأساسية داخل التطبيق

- **Auth:** تسجيل/دخول/تحقق/استعادة كلمة المرور.
- **Home:** لوحة رئيسية وملخصات.
- **News:** أخبار وتفاصيل وتفاعل المستخدم.
- **Games:** ألعاب مجانية/مخفضة وتفاصيل اللعبة.
- **Community & Chat:** غرف دردشة، أصدقاء، وبروفايلات.
- **Notifications:** إدارة وعرض الإشعارات.
- **Settings:** إعدادات التطبيق.

---

## 🧪 الاختبارات

لتشغيل اختبارات Flutter:

```bash
flutter test
```

---

## 🤝 المساهمة

1. أنشئ فرعًا جديدًا:

```bash
git checkout -b feature/your-feature-name
```

2. نفّذ التعديلات المطلوبة مع الالتزام بالبنية الحالية.
3. شغّل الاختبارات وتأكد من عدم وجود أخطاء.
4. افتح Pull Request مع وصف واضح للتغييرات.

---

## 📄 الترخيص

هذا المشروع خاص/داخلي حاليًا (`publish_to: none`) ما لم يتم تحديد خلاف ذلك.

---

## 👨‍💻 فريق التطوير

تم تطوير التطبيق باستخدام Flutter وفق نهج Modular قابل للتوسع لتقديم منصة مجتمع ألعاب حديثة وسريعة.
