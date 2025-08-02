# مشروع ثوبك - تطبيق Flutter للمتجر الإلكتروني

## 📋 نظرة عامة على المشروع

**ثوبك** هو تطبيق Flutter احترافي لمتجر ألبسة تقليدية وعصرية، مطور باستخدام Clean Architecture ومصمم خصيصاً للمستخدم العربي مع دعم كامل للغة العربية واتجاه النص RTL.

## 🏗️ معمارية المشروع (Clean Architecture)

```
lib/
├── core/                    # الأساسيات المشتركة
│   ├── di/                 # Dependency Injection
│   ├── errors/             # معالجة الأخطاء
│   ├── network/            # إعدادات الشبكة
│   ├── theme/              # التصميم والألوان
│   ├── navigation/         # التنقل والتوجيه
│   ├── services/           # الخدمات المشتركة
│   ├── validators/         # التحقق من البيانات
│   └── usecases/           # Use Cases الأساسية
├── data/                   # طبقة البيانات
│   ├── datasources/        # مصادر البيانات (API, Local)
│   ├── models/             # نماذج البيانات (DTOs)
│   └── repositories/       # تنفيذ المستودعات
├── domain/                 # طبقة المنطق التجاري
│   ├── entities/           # الكيانات الأساسية
│   ├── repositories/       # واجهات المستودعات
│   └── usecases/           # حالات الاستخدام
└── presentation/           # طبقة العرض
    ├── app.dart            # تطبيق Flutter الرئيسي
    ├── blocs/              # إدارة الحالة (BLoC)
    ├── pages/              # الصفحات الرئيسية
    ├── widgets/            # الويدجت المخصصة
    └── utils/              # أدوات العرض
```

## 🎯 الميزات الأساسية

### 🔐 نظام المصادقة
- تسجيل الدخول والخروج
- إنشاء حساب جديد
- استعادة كلمة المرور
- التحقق من البريد الإلكتروني
- إدارة الأدوار (Admin, Customer)

### 🛍️ إدارة المنتجات
- عرض المنتجات مع الصور
- البحث والفلترة
- التصنيفات
- تفاصيل المنتج
- المراجعات والتقييمات

### 🛒 سلة التسوق
- إضافة/حذف المنتجات
- تحديث الكميات
- حساب المجموع
- حفظ السلة محلياً

### ❤️ قائمة الأمنيات
- إضافة/حذف المنتجات المفضلة
- مزامنة مع الخادم
- عرض سريع للمفضلات

### 📦 إدارة الطلبات
- إنشاء طلبات جديدة
- تتبع حالة الطلب
- تاريخ الطلبات

## 🌍 دعم اللغة العربية

### إعدادات التعريب
- اللغة الأساسية: العربية
- اتجاه النص: RTL (من اليمين لليسار)
- دعم `flutter_localizations`
- ملفات الترجمة في `assets/lang/`

### بنية ملفات الترجمة
```
assets/
└── lang/
    ├── ar.json         # النصوص العربية
    └── en.json         # النصوص الإنجليزية (اختيارية)
```

## 🎨 نظام التصميم

### لوحة الألوان
```dart
// الألوان الأساسية
primary: Color(0xFF2E7D32)      // أخضر داكن
secondary: Color(0xFF4CAF50)    // أخضر فاتح
accent: Color(0xFFFF9800)       // برتقالي
background: Color(0xFFF5F5F5)   // رمادي فاتح
surface: Color(0xFFFFFFFF)      // أبيض
error: Color(0xFFD32F2F)        // أحمر
```

### الخطوط
- الخط الأساسي: Cairo (يدعم العربية)
- أحجام متدرجة للعناوين والنصوص
- وزن مختلف للتأكيد

## 🔧 إعدادات التطوير

### المتطلبات
- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- Android Studio / VS Code
- Git

### تثبيت المشروع
```bash
# استنساخ المشروع
git clone [repository-url]

# الانتقال لمجلد Flutter
cd Thawbuk-store/Thawbuk-store

# تثبيت التبعيات
flutter pub get

# تشغيل المشروع
flutter run
```

### الحزم المستخدمة
```yaml
# إدارة الحالة
flutter_bloc: ^8.1.3
equatable: ^2.0.5

# الشبكة والبيانات
dio: # للطلبات HTTP
json_annotation: ^4.9.0
shared_preferences: ^2.2.2
hive: ^2.2.3

# واجهة المستخدم
google_fonts: ^6.1.0
flutter_svg: ^2.0.7
cached_network_image: ^3.3.0
shimmer: ^3.0.0

# التنقل
go_router: ^12.1.1

# الأدوات
intl: # للتواريخ والأرقام
uuid: ^4.1.0
dartz: ^0.10.1
```

## 🔗 ربط الـ Backend

### Base URL
```dart
static const String baseUrl = 'https://your-api-domain.com/api';
```

### نقاط النهاية الرئيسية
```dart
// المصادقة
POST /auth/register          // تسجيل حساب جديد
POST /auth/login             // تسجيل الدخول
POST /auth/logout            // تسجيل الخروج
POST /auth/forgot-password   // استعادة كلمة المرور
POST /auth/verify-email      // التحقق من البريد

// المنتجات
GET  /public/products        // جلب جميع المنتجات
GET  /public/products/:id    // تفاصيل منتج
GET  /public/products/search // البحث
GET  /public/products/filter // الفلترة
GET  /public/products/byCategory/:categoryId // حسب التصنيف

// التصنيفات
GET  /public/categories      // جلب التصنيفات

// سلة التسوق (تتطلب مصادقة)
GET    /cart                 // جلب السلة
POST   /cart/add             // إضافة منتج
PUT    /cart/update          // تحديث منتج
DELETE /cart/remove/:id      // حذف منتج
DELETE /cart/clear           // مسح السلة

// قائمة الأمنيات (تتطلب مصادقة)
GET    /wishlist             // جلب المفضلات
POST   /wishlist             // إضافة منتج
POST   /wishlist/toggle      // تبديل حالة المنتج
DELETE /wishlist/product     // حذف منتج
DELETE /wishlist/all-product // مسح جميع المنتجات
```

### نماذج البيانات الأساسية
```dart
// المستخدم
class User {
  final String id;
  final String email;
  final String? name;
  final UserRole role;
  final int? age;
  final Gender? gender;
  final List<Child>? children;
  final CompanyDetails? companyDetails;
  final Address? address;
  final bool isEmailVerified;
}

// المنتج
class Product {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final double price;
  final String categoryId;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final int stock;
  final String? brand;
  final AgeRange? ageRange;
  final double? rating;
  final int? reviewsCount;
  final int? favoritesCount;
  final int? viewsCount;
  final bool? isActive;
}

// التصنيف
class Category {
  final String id;
  final String name;
  final String nameAr;
  final String? description;
  final String? descriptionAr;
  final String image;
  final int? productsCount;
}
```

## 🔐 إدارة التوكن والصلاحيات

### تخزين التوكن
```dart
// حفظ التوكن
await SharedPreferences.getInstance()
    .then((prefs) => prefs.setString('auth_token', token));

// جلب التوكن
final token = SharedPreferences.getInstance()
    .then((prefs) => prefs.getString('auth_token'));

// حذف التوكن (تسجيل الخروج)
await SharedPreferences.getInstance()
    .then((prefs) => prefs.remove('auth_token'));
```

### إضافة التوكن للطلبات
```dart
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    final token = getStoredToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  },
));
```

### التحقق من الصلاحيات
```dart
enum UserRole { admin, customer, superAdmin }

bool hasAdminAccess(User user) {
  return user.role == UserRole.admin || user.role == UserRole.superAdmin;
}

bool hasCustomerAccess(User user) {
  return user.role == UserRole.customer;
}
```

## 📱 بناء الميزات

### إرشادات تطوير الميزات
1. **ابدأ بالـ Entity** في `domain/entities/`
2. **أنشئ Repository Interface** في `domain/repositories/`
3. **اكتب Use Case** في `domain/usecases/`
4. **أنشئ Data Model** في `data/models/`
5. **نفذ Data Source** في `data/datasources/`
6. **نفذ Repository** في `data/repositories/`
7. **أنشئ BLoC** في `presentation/blocs/`
8. **اكتب UI** في `presentation/pages/` و `presentation/widgets/`

### مثال: إضافة ميزة جديدة
```dart
// 1. Entity
class NewFeature {
  final String id;
  final String name;
  // ...
}

// 2. Repository Interface
abstract class NewFeatureRepository {
  Future<List<NewFeature>> getFeatures();
  Future<NewFeature> getFeature(String id);
}

// 3. Use Case
class GetFeaturesUseCase {
  final NewFeatureRepository repository;
  
  Future<List<NewFeature>> call() async {
    return await repository.getFeatures();
  }
}

// 4. BLoC
class NewFeatureBloc extends Bloc<NewFeatureEvent, NewFeatureState> {
  final GetFeaturesUseCase getFeaturesUseCase;
  
  NewFeatureBloc({required this.getFeaturesUseCase}) : super(NewFeatureInitial()) {
    on<LoadFeatures>(_onLoadFeatures);
  }
}
```

## 🧪 الاختبارات

### بنية الاختبارات
```
test/
├── unit/                   # اختبارات الوحدة
│   ├── domain/
│   ├── data/
│   └── presentation/
├── widget/                 # اختبارات الويدجت
└── integration/            # اختبارات التكامل
```

### تشغيل الاختبارات
```bash
# جميع الاختبارات
flutter test

# اختبارات محددة
flutter test test/unit/domain/

# اختبارات مع التغطية
flutter test --coverage
```

## 📚 التوثيق المرحلي

يتم توثيق كل مرحلة تطوير في مجلد `docs/stages/` مع تفاصيل:
- الميزات المنجزة
- الـ APIs المربوطة
- الملفات المنشأة
- القرارات التصميمية
- المهام المتبقية

## 🚀 النشر

### بناء التطبيق
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

### متغيرات البيئة
```dart
// lib/core/config/environment.dart
class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.thawbuk.com',
  );
  
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );
}
```

## 🔧 أدوات التطوير

### VS Code Extensions المفيدة
- Flutter
- Dart
- Bloc
- Flutter Intl
- Arabic Support

### أوامر مفيدة
```bash
# تنظيف المشروع
flutter clean && flutter pub get

# تحديث التبعيات
flutter pub upgrade

# تحليل الكود
flutter analyze

# تنسيق الكود
dart format .

# إنشاء الأيقونات
flutter pub run flutter_launcher_icons:main

# إنشاء شاشة البداية
flutter pub run flutter_native_splash:create
```

## 📞 الدعم والمساعدة

### للمطورين الجدد
1. اقرأ هذا الملف بالكامل
2. تصفح بنية المشروع
3. ابدأ بالميزات البسيطة
4. اتبع نمط Clean Architecture
5. اكتب اختبارات لكودك

### للـ AI المساعد
- استخدم هذا التوثيق كمرجع أساسي
- اتبع نفس النمط في التطوير
- حافظ على بنية المشروع
- وثق أي تغييرات جديدة

---

**تم إنشاء هذا التوثيق في:** [التاريخ]
**آخر تحديث:** [التاريخ]
**الإصدار:** 1.0.0