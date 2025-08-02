# Email Verification Testing Checklist - قائمة اختبار تأكيد البريد الإلكتروني

## 🧪 Manual Testing Steps خطوات الاختبار اليدوي

### 1. Registration Flow اختبار التسجيل
- [ ] **Start Registration** - بدء التسجيل
  - Navigate to registration page
  - Fill all required fields
  - Submit form
  - **Expected**: Success message and redirect to verification page

- [ ] **Email Delivery** - وصول الإيميل
  - Check email inbox
  - **Expected**: Verification email received with 6-digit code
  - **Expected**: Email has proper Arabic content and project branding

### 2. Email Verification Flow اختبار تأكيد الإيميل
- [ ] **Verification Page UI** - واجهة صفحة التحقق
  - **Expected**: 6 input fields for OTP
  - **Expected**: 10-minute countdown timer
  - **Expected**: Resend button (disabled initially)
  - **Expected**: Proper Arabic text and styling

- [ ] **Valid Code Entry** - إدخال رمز صحيح
  - Enter the 6-digit code from email
  - **Expected**: Auto-submit when all fields filled
  - **Expected**: Success dialog appears
  - **Expected**: Welcome email sent
  - **Expected**: Redirect to login page

- [ ] **Invalid Code Entry** - إدخال رمز خاطئ
  - Enter wrong 6-digit code
  - **Expected**: Error message displayed
  - **Expected**: Fields cleared and focused on first field

### 3. Resend Functionality اختبار إعادة الإرسال
- [ ] **Timer Countdown** - العد التنازلي
  - Wait for timer to reach 0
  - **Expected**: Resend button becomes enabled
  - **Expected**: Timer shows "00:00"

- [ ] **Resend Code** - إعادة إرسال الرمز
  - Click resend button
  - **Expected**: New verification email sent
  - **Expected**: Timer resets to 10:00
  - **Expected**: Success message shown
  - **Expected**: Input fields cleared

### 4. Error Scenarios اختبار حالات الخطأ
- [ ] **Expired Code** - رمز منتهي الصلاحية
  - Wait more than 10 minutes
  - Try to verify with old code
  - **Expected**: "Expired code" error message

- [ ] **Network Error** - خطأ في الشبكة
  - Disconnect internet
  - Try to verify code
  - **Expected**: Network error message

- [ ] **Server Error** - خطأ في الخادم
  - Stop backend server
  - Try to verify code
  - **Expected**: Server error message

### 5. Email Templates اختبار قوالب الإيميل
- [ ] **Verification Email** - إيميل التحقق
  - **Expected**: Arabic subject line
  - **Expected**: Project colors and branding
  - **Expected**: Clear 6-digit code display
  - **Expected**: Professional design
  - **Expected**: Mobile responsive

- [ ] **Welcome Email** - إيميل الترحيب
  - **Expected**: Sent after successful verification
  - **Expected**: Arabic welcome message
  - **Expected**: Project branding
  - **Expected**: Helpful onboarding content

## 🔧 Technical Testing الاختبار التقني

### Backend API Testing
```bash
# Test Registration
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User",
    "role": "customer"
  }'

# Test Email Verification
curl -X POST http://localhost:3000/api/auth/verify-email \
  -H "Content-Type: application/json" \
  -d '{
    "code": "123456"
  }'

# Test Resend Verification
curl -X POST http://localhost:3000/api/auth/resend-verification \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com"
  }'
```

### Database Verification
- [ ] **User Creation** - إنشاء المستخدم
  - Check user exists in database
  - **Expected**: `isEmailVerified: false`
  - **Expected**: `otpCode` field populated
  - **Expected**: `otpCodeExpires` set to +10 minutes

- [ ] **After Verification** - بعد التحقق
  - **Expected**: `isEmailVerified: true`
  - **Expected**: `otpCode` cleared
  - **Expected**: `otpCodeExpires` cleared

### Email Service Testing
- [ ] **SMTP Configuration** - إعداد SMTP
  - Check environment variables
  - Test email service connection
  - **Expected**: No connection errors

- [ ] **Email Queue** - طابور الإيميلات
  - Check email sending logs
  - **Expected**: Emails sent successfully
  - **Expected**: No delivery failures

## 📱 Mobile Testing اختبار الجوال

### Responsive Design
- [ ] **Phone Portrait** - الهاتف عمودي
  - Test on iPhone/Android portrait mode
  - **Expected**: UI elements properly sized
  - **Expected**: Text readable without zooming

- [ ] **Phone Landscape** - الهاتف أفقي
  - Test on iPhone/Android landscape mode
  - **Expected**: Layout adapts properly

- [ ] **Tablet** - الجهاز اللوحي
  - Test on iPad/Android tablet
  - **Expected**: Proper spacing and sizing

### Touch Interactions
- [ ] **OTP Input** - إدخال الرمز
  - **Expected**: Easy to tap input fields
  - **Expected**: Proper keyboard appears
  - **Expected**: Auto-focus works correctly

- [ ] **Buttons** - الأزرار
  - **Expected**: Buttons have proper touch targets
  - **Expected**: Visual feedback on press

## 🌐 Browser Testing اختبار المتصفحات

### Desktop Browsers
- [ ] **Chrome** - كروم
- [ ] **Firefox** - فايرفوكس
- [ ] **Safari** - سفاري
- [ ] **Edge** - إيدج

### Mobile Browsers
- [ ] **Chrome Mobile** - كروم الجوال
- [ ] **Safari Mobile** - سفاري الجوال
- [ ] **Samsung Internet** - متصفح سامسونج

## 🔒 Security Testing اختبار الأمان

### Code Security
- [ ] **Code Length** - طول الرمز
  - **Expected**: Exactly 6 digits
  - **Expected**: Only numeric characters accepted

- [ ] **Code Expiration** - انتهاء صلاحية الرمز
  - **Expected**: Code expires after 10 minutes
  - **Expected**: Expired codes rejected

- [ ] **Rate Limiting** - تحديد المعدل
  - Try multiple resend requests quickly
  - **Expected**: Proper rate limiting applied

### Input Validation
- [ ] **Email Validation** - التحقق من الإيميل
  - Try invalid email formats
  - **Expected**: Proper validation errors

- [ ] **Code Validation** - التحقق من الرمز
  - Try non-numeric codes
  - Try codes with wrong length
  - **Expected**: Proper validation errors

## 📊 Performance Testing اختبار الأداء

### Load Testing
- [ ] **Multiple Users** - عدة مستخدمين
  - Test with multiple simultaneous registrations
  - **Expected**: System handles load properly

- [ ] **Email Delivery Speed** - سرعة توصيل الإيميل
  - Measure time from registration to email receipt
  - **Expected**: Emails delivered within 30 seconds

### Memory Usage
- [ ] **Frontend Memory** - ذاكرة الواجهة
  - Monitor app memory usage
  - **Expected**: No memory leaks

- [ ] **Backend Memory** - ذاكرة الخادم
  - Monitor server memory usage
  - **Expected**: Stable memory consumption

## ✅ Success Criteria معايير النجاح

### Functional Requirements
- ✅ User can register and receive verification email
- ✅ User can verify email with 6-digit code
- ✅ User can resend verification code
- ✅ User receives welcome email after verification
- ✅ User is redirected to login after verification

### Non-Functional Requirements
- ✅ Email templates are professionally designed
- ✅ UI is responsive and mobile-friendly
- ✅ Arabic text is properly displayed
- ✅ System handles errors gracefully
- ✅ Performance is acceptable under normal load

### Security Requirements
- ✅ Codes expire after 10 minutes
- ✅ Only verified users can login
- ✅ Input validation prevents malicious input
- ✅ Rate limiting prevents abuse

## 🐛 Bug Reporting تقرير الأخطاء

### Bug Template
```
**Title**: Brief description of the issue
**Steps to Reproduce**:
1. Step 1
2. Step 2
3. Step 3

**Expected Result**: What should happen
**Actual Result**: What actually happened
**Environment**: Browser/Device/OS
**Severity**: High/Medium/Low
**Screenshots**: If applicable
```

### Common Issues to Watch For
- Email delivery delays
- Timer not updating correctly
- UI layout issues on different screen sizes
- Network error handling
- Code validation edge cases
- Navigation issues after verification

---

**Testing Status**: 🔄 **IN PROGRESS - قيد التنفيذ**

Complete this checklist to ensure the email verification system is production-ready.

أكمل هذه القائمة للتأكد من أن نظام تأكيد البريد الإلكتروني جاهز للإنتاج.