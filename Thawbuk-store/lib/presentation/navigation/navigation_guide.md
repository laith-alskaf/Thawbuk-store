# دليل نظام التنقل المحسن

## المفاهيم الأساسية

### 1. Shell Routes
Shell Routes تسمح بوجود Layout ثابت مع تغيير المحتوى الداخلي فقط:
- **Main App Shell**: للتطبيق الرئيسي مع Bottom Navigation
- **Admin Shell**: للوحة الإدارة مع Bottom Navigation منفصلة

### 2. Navigation Hierarchy

```
Application
├── Splash (مستقل)
├── Auth Routes (مستقلة)
├── Main App Shell
│   └── Bottom Navigation Tabs (go navigation)
├── Admin Shell  
│   └── Bottom Navigation Tabs (go navigation)
└── Standalone Pages (push/pop navigation)
```

## كيفية التنقل

### استخدام NavigationService
```dart
// في أي مكان في التطبيق
context.nav.goToHome();           // للانتقال للرئيسية
context.nav.pushEditProduct(product); // لفتح صفحة التعديل
context.nav.back();               // للرجوع للخلف
```

### أنواع التنقل

#### 1. Go Navigation (للتبديل بين Tabs)
```dart
context.nav.goToHome();          // Tab navigation
context.nav.goToAdminDashboard(); // Admin tab navigation
```

#### 2. Push Navigation (للصفحات الفرعية)
```dart
context.nav.pushEditProduct(product);  // يمكن الرجوع منها
context.nav.pushProductAnalytics();    // يمكن الرجوع منها
```

## مثال على الاستخدام

### في صفحة المنتجات الإدارية:
```dart
// للانتقال لتعديل منتج (مع إمكانية الرجوع)
void _editProduct(ProductEntity product) {
  context.nav.pushEditProduct(product);
}

// للانتقال للوحة التحكم (تبديل tab)
void _goToDashboard() {
  context.nav.goToAdminDashboard();
}
```

## مزايا النظام الجديد

1. **تنقل طبيعي**: Back button يعمل بشكل صحيح
2. **تنظيم واضح**: فصل واضح بين الـ tabs والصفحات الفرعية
3. **أداء أفضل**: Shell routes تحافظ على الـ state
4. **سهولة الصيانة**: NavigationService مركزي
5. **Type Safety**: استخدام AppRoutes constants

## الفرق بين القديم والجديد

### القديم (مشاكل):
```dart
// مشكلة: initialIndex مع Layout
GoRoute(
  path: '/admin/products',
  builder: (context, state) => AdminLayout(initialIndex: 1),
)

// مشكلة: خلط go و push
context.go('/admin/add-product', extra: product);
```

### الجديد (محسن):
```dart
// حل: Shell route مع nested routes
ShellRoute(
  builder: (context, state, child) => AdminShell(child: child),
  routes: [
    GoRoute(path: '/admin/products', ...),
  ],
)

// حل: استخدام صحيح للتنقل
context.nav.pushEditProduct(product);
```

## قواعد التنقل

1. **للتبديل بين الأقسام الرئيسية**: استخدم `go`
2. **لفتح صفحة فرعية**: استخدم `push`
3. **للرجوع**: استخدم `pop` أو زر الرجوع
4. **للبيانات المؤقتة**: مرر عبر `extra`
5. **للمعرفات**: استخدم path parameters

## نصائح التطوير

### التحقق من المسار الحالي:
```dart
bool isInAdmin = context.nav.isInAdminArea;
String currentPath = context.nav.currentLocation;
```

### التنقل المخصص:
```dart
// مع animation مخصص
context.nav.navigateWithTransition('/custom-page', extra: data);

// إزالة الـ history
context.nav.clearAndNavigateTo('/new-start');
```