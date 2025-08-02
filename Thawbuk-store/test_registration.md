# اختبار عملية التسجيل

## البيانات المطلوبة للعميل (Customer):
```json
{
  "email": "customer@test.com",
  "password": "123456",
  "role": "customer",
  "name": "أحمد محمد",
  "age": 25,
  "gender": "male",
  "address": {
    "city": "دمشق"
  }
}
```

## البيانات المطلوبة للمتجر (Admin):
```json
{
  "email": "admin@test.com",
  "password": "123456",
  "role": "admin",
  "companyDetails": {
    "companyName": "متجر الأزياء",
    "companyAddress": {
      "city": "حلب"
    }
  }
}
```

## الحقول المطلوبة حسب الباك إند:

### للعميل (Customer):
- ✅ email (مطلوب)
- ✅ password (مطلوب)
- ✅ role = "customer" (مطلوب)
- ✅ name (مطلوب للعميل)
- ✅ age (مطلوب للعميل، min: 18, max: 120)
- ✅ gender (مطلوب للعميل: male/female/other)
- ✅ address.city (مطلوب للعميل)

### للمتجر (Admin):
- ✅ email (مطلوب)
- ✅ password (مطلوب)
- ✅ role = "admin" (مطلوب)
- ✅ companyDetails.companyName (مطلوب للمتجر)
- ✅ companyDetails.companyAddress.city (مطلوب للمتجر)

## التحسينات المطبقة:
1. ✅ إضافة حقل المدينة للعميل
2. ✅ إصلاح منطق إرسال البيانات
3. ✅ تحسين validation للحقول
4. ✅ إضافة مسح البيانات عند تغيير نوع الحساب
5. ✅ تحسين معالجة الأخطاء في HttpClient
6. ✅ إضافة logging أفضل لتتبع المشاكل