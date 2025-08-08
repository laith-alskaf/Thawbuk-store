# خريطة التنقل المحسنة - Thawbuk Store

## نظرة عامة على التسلسل الهرمي

```
Thawbuk Store App
│
├── 🚀 Splash Screen (/splash)
│   └── → Auto redirect based on auth state
│
├── 🔐 Authentication Flow (/auth/*)
│   ├── Login (/auth/login)
│   ├── Register (/auth/register)
│   └── Email Verification (/auth/verify-email/:email)
│
├── 🏪 Main App Shell (/app/*) - مع Bottom Navigation
│   ├── 📱 Tab Navigation (Go Router)
│   │   ├── 🏠 Home (/app/home)
│   │   ├── 🛍️ Products (/app/products)
│   │   ├── 🛒 Cart (/app/cart)
│   │   ├── ❤️ Favorites (/app/favorites)
│   │   └── 👤 Profile (/app/profile)
│   │
│   └── 📄 Standalone Pages (Push Navigation)
│       ├── 📦 Product Detail (/product/:id)
│       ├── 📋 Orders (/orders)
│       ├── ⚙️ Settings (/settings)
│       └── 🏪 Store Profile (/store/:id)
│
└── 👑 Admin Shell (/admin/*) - مع Bottom Navigation منفصلة
    ├── 📱 Tab Navigation (Go Router)
    │   ├── 📊 Dashboard (/admin/dashboard)
    │   ├── 📦 My Products (/admin/products)
    │   ├── ➕ Add Product (/admin/add-product)
    │   ├── 📋 All Products (/admin/all-products)
    │   └── 👤 Admin Profile (/admin/profile)
    │
    └── 📄 Standalone Pages (Push Navigation)
        ├── ✏️ Edit Product (/admin/edit-product)
        ├── 📈 Products Analytics (/admin/products-analytics)
        ├── 🏪 Store Profile (/admin/store-profile)
        └── ⚙️ Admin Settings (/admin/settings)
```

## الفرق بين أنواع التنقل

### 1. Go Navigation (للتبديل بين Tabs)
```
State يتم الحفاظ عليه ✅
Bottom Navigation يتغير ✅
URL يتغير ✅
Back Button لا يؤثر على التنقل ❌ (يخرج من التطبيق)
```

### 2. Push Navigation (للصفحات الفرعية)
```
State يتم الحفاظ عليه ✅
Bottom Navigation يختفي أو يبقى حسب التصميم ✅
URL يتغير ✅
Back Button يرجع للصفحة السابقة ✅
```

## مثال على الرحلة التنقلية

### رحلة العميل العادي:
```
1. 🚀 Splash → 🔐 Login → 🏠 Home (Main Shell)
2. 🏠 Home → 🛍️ Products (Go Navigation داخل Shell)
3. 🛍️ Products → 📦 Product Detail (Push Navigation)
4. 📦 Product Detail → Back Button → 🛍️ Products
5. 🛍️ Products → 🛒 Cart (Go Navigation داخل Shell)
6. 🛒 Cart → 📋 Orders (Push Navigation)
7. 📋 Orders → Back Button → 🛒 Cart
```

### رحلة المدير:
```
1. 🚀 Splash → 🔐 Login → 🏠 Home
2. 🏠 Home → Navigate to Admin → 📊 Dashboard (Admin Shell)
3. 📊 Dashboard → 📦 My Products (Go Navigation داخل Admin Shell)
4. 📦 My Products → ✏️ Edit Product (Push Navigation)
5. ✏️ Edit Product → Back Button → 📦 My Products
6. 📦 My Products → ➕ Add Product (Go Navigation داخل Admin Shell)
7. ➕ Add Product → 📈 Analytics (Push Navigation)
8. 📈 Analytics → Back Button → ➕ Add Product
```

## Navigation Service Methods

### للانتقال بين الأقسام الرئيسية (Go):
```dart
context.nav.goToHome()              // 🏠 الرئيسية
context.nav.goToProducts()          // 🛍️ المنتجات
context.nav.goToCart()              // 🛒 السلة
context.nav.goToFavorites()         // ❤️ المفضلة
context.nav.goToProfile()           // 👤 الملف الشخصي

context.nav.goToAdminDashboard()    // 📊 لوحة الإدارة
context.nav.goToAdminProducts()     // 📦 منتجات الإدارة
context.nav.goToAddProduct()        // ➕ إضافة منتج
```

### للصفحات الفرعية (Push):
```dart
context.nav.pushEditProduct(product)     // ✏️ تعديل منتج
context.nav.pushProductAnalytics()       // 📈 إحصائيات
context.nav.pushStoreProfile()           // 🏪 ملف المتجر
context.nav.pushSettings()               // ⚙️ الإعدادات
context.nav.pushOrders()                 // 📋 الطلبات
```

### للرجوع والتحكم:
```dart
context.nav.back()                       // رجوع واحد
context.nav.canPop()                     // تحقق من إمكانية الرجوع
context.nav.clearAndNavigateTo('/app/home') // مسح السجل والانتقال
```

## مزايا النظام الجديد

### 1. ⚡ الأداء
- **Shell Routes**: تحافظ على الـ state بدون إعادة بناء
- **Lazy Loading**: الصفحات تُحمل عند الحاجة فقط
- **Efficient Navigation**: تنقل سريع بدون rebuild للـ layouts

### 2. 🧭 تجربة المستخدم
- **Natural Back Navigation**: زر الرجوع يعمل كما متوقع
- **Consistent UI**: تطابق في التصميم عبر الصفحات
- **Clear Hierarchy**: تسلسل واضح ومنطقي

### 3. 🔧 قابلية الصيانة
- **Centralized Navigation**: كل التنقل من مكان واحد
- **Type Safety**: استخدام constants ومنع الأخطاء
- **Clean Code**: كود منظم وقابل للقراءة

### 4. 🛡️ الأمان
- **Route Guards**: حماية تلقائية للصفحات
- **Auth State Management**: إدارة محكمة لحالة المصادقة
- **Admin Protection**: حماية صفحات الإدارة

## قواعد التطوير

### ✅ افعل:
- استخدم `context.nav.goTo*()` للتبديل بين الأقسام الرئيسية
- استخدم `context.nav.push*()` للصفحات الفرعية
- استخدم `AppRoutes` constants بدلاً من strings
- اختبر التنقل على أجهزة مختلفة

### ❌ لا تفعل:
- لا تستخدم `context.go()` مباشرة للصفحات الفرعية
- لا تخلط بين go و push navigation
- لا تنس إضافة Back Button للصفحات المستقلة
- لا تتجاهل معالجة الأخطاء في التنقل

## رسم بياني للـ State Management

```
AuthBloc State → Router Redirect Logic
    ↓
┌─ Unauthenticated → Auth Pages
├─ Authenticated + Regular User → Main App Shell  
└─ Authenticated + Admin → Admin Shell (+ Main App Shell)
    ↓
Navigation Service → GoRouter → Page Builder
    ↓
Shell Route → Bottom Navigation + Content Area
```