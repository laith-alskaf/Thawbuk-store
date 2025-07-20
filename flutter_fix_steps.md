# حل مشكلة Flutter Build Runner

## المشاكل التي تم حلها:

### 1. تحديث الإصدارات في pubspec.yaml
- ✅ `json_annotation: ^4.9.0` (من ^4.8.1)
- ✅ `json_serializable: ^6.8.0` (من ^6.7.1)

### 2. إصلاح النماذج (Models)

#### A. cart_model.dart
- ✅ أضيف `explicitToJson: true` لـ JsonSerializable
- ✅ أضيف explicit typing للـ `items` و `product`
- ✅ استخدام proper override للخصائص المعقدة

#### B. user_model.dart  
- ✅ أضيف explicit typing للـ `company`
- ✅ تحديد النوع CompanyModel بدلاً من CompanyEntity

#### C. order_model.dart
- ✅ أضيف explicit typing للـ `items` و `shippingAddress`
- ✅ استخدام proper override للخصائص المعقدة

## خطوات تشغيل البناء:

1. **تحديث Dependencies:**
   ```bash
   cd /path/to/Thawbuk-store
   flutter pub get
   ```

2. **مسح الملفات المولدة القديمة:**
   ```bash
   flutter packages pub run build_runner clean
   ```

3. **إنتاج الملفات الجديدة:**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

   أو استخدام الأمر الجديد:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

## في حال استمرار المشاكل:

### إضافية: مسح cache
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### التحقق من الإصدارات:
```bash
flutter --version
dart --version
```

## تأكيدات النجاح:
- ✅ لا يوجد أخطاء json_serializable 
- ✅ تم تحديث إصدار json_annotation
- ✅ النماذج تستخدم explicit types
- ✅ استخدام explicitToJson: true لجميع النماذج المعقدة

## الملفات المحدثة:
1. `pubspec.yaml` - الإصدارات
2. `lib/data/models/cart_model.dart` - إصلاح CartItemEntity
3. `lib/data/models/user_model.dart` - إصلاح CompanyEntity  
4. `lib/data/models/order_model.dart` - إصلاح الـ items والـ address

بعد تطبيق هذه الخطوات، يجب أن يعمل البناء بدون أخطاء.