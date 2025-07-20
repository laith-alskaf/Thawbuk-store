# 🕯️ ثوبك - Thawbuk Store

**متجر الألبسة التقليدية والعصرية**  
*Traditional and Modern Clothing Store*

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-v18+-green)](https://nodejs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5+-blue)](https://www.typescriptlang.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-brightgreen)](https://www.mongodb.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue)](https://flutter.dev/)

## 📋 نظرة عامة

ثوبك هو تطبيق متجر إلكتروني متكامل للألبسة التقليدية والعصرية، يتضمن:
- 🔧 **Backend API** مبني بـ Node.js/TypeScript  
- 📱 **Flutter Mobile App** مع Clean Architecture
- 🗄️ **MongoDB Database** لتخزين البيانات

## 🚀 البدء السريع

### 🔧 تشغيل Backend

```bash
cd /app
npm install
npm run dev
```
الخادم سيعمل على: `http://localhost:5000`

### 📱 تشغيل Flutter App

```bash
cd /app/Thawbuk-store  
flutter pub get
flutter run
```

## 🏗️ هيكل المشروع

```
/app
├── src/                     # Backend (Node.js/TypeScript)
│   ├── application/         # Use Cases & DTOs
│   ├── domain/             # Entities & Repositories
│   ├── infrastructure/     # Database & External Services  
│   └── presentation/       # Controllers, Routes, Middleware
├── Thawbuk-store/          # Flutter Mobile App
│   ├── lib/
│   │   ├── core/           # DI, Constants, Theme, Network
│   │   ├── data/           # Data Sources, Models, Repositories
│   │   ├── domain/         # Entities, Use Cases, Repositories
│   │   └── presentation/   # Pages, Widgets, Bloc
└── .env                    # Environment Variables
```

## 📱 الميزات الرئيسية

### 👤 إدارة المستخدمين
- تسجيل الدخول والتسجيل
- أدوار مختلفة: عميل، تاجر، أدمن
- تأكيد الإيميل ونسيان كلمة المرور

### 🛍️ إدارة المنتجات  
- عرض المنتجات مع الصور
- تصنيفات متعددة
- البحث والفلترة
- إدارة المخزون

### 🛒 عملية الشراء
- إضافة للسلة والمفضلة
- إدارة الطلبات
- حساب الأسعار والضرائب

### 👨‍💼 لوحة الإدارة
- إضافة وتعديل المنتجات
- إدارة الفئات
- إحصائيات المبيعات

## 🔌 API Endpoints

### المصادقة
- `POST /api/auth/register` - تسجيل مستخدم جديد
- `POST /api/auth/login` - تسجيل الدخول

### المنتجات (عام)
- `GET /api/product` - جلب جميع المنتجات
- `GET /api/product/:id` - جلب منتج واحد  
- `GET /api/product/search` - البحث في المنتجات

### الفئات (عام)
- `GET /api/category` - جلب جميع الفئات
- `GET /api/category/:id` - جلب فئة واحدة

### محمية (تحتاج مصادقة)
- `GET /api/user/cart` - جلب السلة
- `POST /api/user/cart/add` - إضافة للسلة
- `GET /api/user/order` - جلب الطلبات
- `POST /api/user/order` - إنشاء طلب جديد

## 🛠️ التقنيات المستخدمة

### Backend
- **Node.js** + **TypeScript**
- **Express.js** - Web Framework
- **MongoDB** + **Mongoose** - Database
- **JWT** - Authentication  
- **Cloudinary** - Image Storage
- **Nodemailer** - Email Service
- **Joi** - Data Validation

### Frontend (Flutter)
- **Flutter** + **Dart**
- **Bloc/Cubit** - State Management
- **Go Router** - Navigation
- **Dio** - HTTP Client  
- **Hive** - Local Storage
- **GetIt** - Dependency Injection

### DevOps
- **Docker** Support
- **Vercel** Deployment Ready
- **MongoDB Atlas** Cloud Database

## 🔧 متطلبات التشغيل

### Backend
- Node.js 16+
- MongoDB Database
- Cloudinary Account (للصور)
- Gmail SMTP (للإيميلات)

### Flutter
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code

## 🌟 الحالة الحالية

- ✅ **Backend API**: مكتمل وجاهز (95%)
- ✅ **Flutter App**: مكتمل البناء (90%)  
- ✅ **Database**: تحتوي على بيانات اختبار
- ✅ **Authentication**: يعمل بكامل الميزات
- ✅ **File Upload**: متكامل مع Cloudinary

## 📞 للدعم

لأي استفسار أو مشكلة تقنية، يرجى مراجعة ملف `test_result.md` للتفاصيل الكاملة.

---

📬 **Contact**: Laithalskaf@gmail.com  
**مطور بـ ❤️ لخدمة المجتمع العربي**
