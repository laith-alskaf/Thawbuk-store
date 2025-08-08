# دليل استكشاف الأخطاء - نظام التنقل المحسن

## مشاكل شائعة وحلولها

### 1. 🚫 "Route not found" Error

**المشكلة:** خطأ في العثور على المسار
```
GoException: no routes for location: /some/path
```

**الحلول:**
```dart
// ✅ تأكد من تسجيل المسار في AppRouterImproved
GoRoute(
  path: '/some/path',
  name: 'some-path',
  builder: (context, state) => SomePage(),
),

// ✅ استخدم NavigationService بدلاً من المسارات المباشرة
context.nav.goToHome(); // بدلاً من context.go('/app/home')
```

### 2. 🔄 Bottom Navigation لا يعمل بشكل صحيح

**المشكلة:** التبديل بين tabs لا يعمل كما متوقع

**الحلول:**
```dart
// ❌ خطأ: استخدام push للتنقل بين tabs
context.nav.pushProducts(); // خطأ!

// ✅ صحيح: استخدام go للتنقل بين tabs
context.nav.goToProducts(); // صحيح!
```

### 3. 🔙 Back Button لا يعمل

**المشكلة:** زر الرجوع لا يظهر أو لا يعمل

**الحلول:**
```dart
// ✅ للصفحات المستقلة، تأكد من وجود AppBar
Scaffold(
  appBar: AppBar(
    title: Text('العنوان'),
    // leading: سيتم إضافة زر الرجوع تلقائياً
  ),
  body: YourContent(),
)

// ✅ أو استخدم back navigation programmatically
IconButton(
  icon: Icon(Icons.arrow_back),
  onPressed: () => context.nav.back(),
)
```

### 4. 💾 State Loss عند التنقل

**المشكلة:** فقدان البيانات عند التنقل بين الصفحات

**الحلول:**
```dart
// ✅ استخدم Shell Routes للمحافظة على الـ state
ShellRoute(
  builder: (context, state, child) => MainAppShell(child: child),
  routes: [...],
)

// ✅ استخدم Bloc/Provider للبيانات المشتركة
BlocProvider.value(
  value: existingBloc,
  child: NewPage(),
)
```

### 5. 🔐 Authentication Redirect Loop

**المشكلة:** تكرار لا نهائي في إعادة التوجيه

**الحلول:**
```dart
// ✅ تأكد من منطق الredirect في AppRouterImproved
String? _handleGlobalRedirect(AuthState authState, GoRouterState state) {
  // تجنب الredirect للصفحة نفسها
  if (state.uri.path == '/auth/login' && !isLoggedIn) {
    return null; // لا تعيد توجيه
  }
  
  // منطق الredirect الصحيح
  return targetPath;
}
```

## اختبار النظام

### 1. اختبار التنقل الأساسي

```dart
// Test: Main App Navigation
void testMainAppNavigation() {
  // 1. ابدأ من الرئيسية
  context.nav.goToHome();
  
  // 2. انتقل للمنتجات
  context.nav.goToProducts();
  
  // 3. انتقل للسلة
  context.nav.goToCart();
  
  // 4. تحقق من الـ current location
  assert(context.nav.currentLocation == '/app/cart');
}
```

### 2. اختبار Push/Pop Navigation

```dart
void testPushPopNavigation() {
  // 1. ابدأ من المنتجات
  context.nav.goToProducts();
  
  // 2. ادفع صفحة تفاصيل المنتج
  context.nav.goToProductDetail('product-1');
  
  // 3. تحقق من إمكانية الرجوع
  assert(context.nav.canPop() == true);
  
  // 4. ارجع
  context.nav.back();
  
  // 5. تحقق من العودة للمنتجات
  assert(context.nav.currentLocation == '/app/products');
}
```

### 3. اختبار Admin Navigation

```dart
void testAdminNavigation() {
  // 1. تسجيل دخول كمدير
  // (تأكد أن المستخدم لديه isOwner = true)
  
  // 2. انتقل للوحة الإدارة
  context.nav.goToAdminDashboard();
  
  // 3. انتقل لإدارة المنتجات
  context.nav.goToAdminProducts();
  
  // 4. ادفع صفحة التعديل
  context.nav.pushEditProduct(sampleProduct);
  
  // 5. تحقق من الرجوع
  context.nav.back();
  assert(context.nav.currentLocation == '/admin/products');
}
```

### 4. اختبار Authentication Flow

```dart
void testAuthFlow() {
  // 1. مستخدم غير مسجل
  // يجب إعادة توجيهه للـ login
  context.nav.goToHome();
  // Expected: redirect to /auth/login
  
  // 2. بعد تسجيل الدخول
  // يجب إعادة توجيهه للرئيسية
  // (simulate login success)
  // Expected: redirect to /app/home
  
  // 3. محاولة دخول Admin بدون صلاحية
  context.nav.goToAdminDashboard();
  // Expected: redirect to /app/home (if not owner)
}
```

## Debug Tips

### 1. تفعيل Debug Mode

```dart
AppRouterImproved() {
  _router = GoRouter(
    debugLogDiagnostics: true, // ✅ تفعيل Debug
    // ...
  );
}
```

### 2. تتبع Navigation Events

```dart
// في NavigationService
void goToHome() {
  debugPrint('Navigating to Home');
  _router.go('/app/home');
  debugPrint('Current location: ${currentLocation}');
}
```

### 3. فحص الـ State

```dart
// تحقق من حالة المصادقة
void debugAuthState(BuildContext context) {
  final authState = context.read<AuthBloc>().state;
  debugPrint('Auth State: $authState');
  
  if (authState is AuthAuthenticated) {
    debugPrint('User: ${authState.user.name}');
    debugPrint('Is Owner: ${authState.user.isOwner}');
  }
}
```

## Performance Monitoring

### 1. قياس Navigation Time

```dart
class NavigationTimer {
  static void timeNavigation(String routeName, VoidCallback navigation) {
    final stopwatch = Stopwatch()..start();
    navigation();
    stopwatch.stop();
    debugPrint('Navigation to $routeName took: ${stopwatch.elapsedMilliseconds}ms');
  }
}

// Usage
NavigationTimer.timeNavigation('Home', () => context.nav.goToHome());
```

### 2. Memory Usage Monitoring

```dart
void checkMemoryUsage() {
  // استخدم Flutter Inspector أو
  // DevTools للمراقبة
}
```

## Best Practices للاختبار

### ✅ افعل:
- اختبر جميع مسارات التنقل
- تحقق من الـ Back navigation
- اختبر Auth redirects
- اختبر على أجهزة مختلفة
- استخدم Flutter Inspector

### ❌ لا تفعل:
- لا تعتمد على hard-coded delays
- لا تتجاهل الـ edge cases
- لا تنس اختبار الـ deep links
- لا تتجاهل Memory leaks

## إعداد Integration Tests

```dart
// test/integration_test/navigation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:thawbuk_store/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Navigation Tests', () {
    testWidgets('Complete user journey', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Test splash screen
      expect(find.text('ثوبك'), findsOneWidget);
      
      // Test navigation to login
      await tester.pumpAndSettle();
      // Add your test logic...
    });
  });
}
```