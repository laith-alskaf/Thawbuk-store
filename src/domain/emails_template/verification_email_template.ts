export const VERIFICATION_EMAIL_TEMPLATE = `
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>تأكيد البريد الإلكتروني - متجر ثوبك</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;600;700&display=swap');
  </style>
</head>
<body style="font-family: 'Cairo', Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
  
  <!-- Header -->
  <div style="background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%); padding: 30px 20px; text-align: center; border-radius: 12px 12px 0 0;">
    <div style="background-color: white; width: 80px; height: 80px; border-radius: 50%; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
      <span style="font-size: 36px; color: #6366f1;">👗</span>
    </div>
    <h1 style="color: white; margin: 0; font-size: 28px; font-weight: 700;">متجر ثوبك</h1>
    <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0; font-size: 16px;">أهلاً وسهلاً بك في عالم الأزياء</p>
  </div>
  
  <!-- Main Content -->
  <div style="background-color: white; padding: 40px 30px; border-radius: 0 0 12px 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.1);">
    <div style="text-align: center; margin-bottom: 30px;">
      <h2 style="color: #1f2937; margin: 0 0 10px; font-size: 24px; font-weight: 600;">تأكيد البريد الإلكتروني</h2>
      <p style="color: #6b7280; margin: 0; font-size: 16px;">مرحباً بك في متجر ثوبك! نحن سعداء لانضمامك إلينا</p>
    </div>
    
    <p style="color: #374151; font-size: 16px; margin-bottom: 25px;">
      شكراً لك على التسجيل في متجر ثوبك! لإكمال عملية التسجيل، يرجى استخدام رمز التحقق التالي:
    </p>
    
    <!-- Verification Code -->
    <div style="text-align: center; margin: 40px 0; padding: 30px; background: linear-gradient(135deg, #f3f4f6 0%, #e5e7eb 100%); border-radius: 12px; border: 2px dashed #6366f1;">
      <p style="color: #6b7280; margin: 0 0 15px; font-size: 14px; font-weight: 600;">رمز التحقق</p>
      <span style="font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #6366f1; font-family: 'Courier New', monospace; background-color: white; padding: 15px 25px; border-radius: 8px; box-shadow: 0 2px 10px rgba(99, 102, 241, 0.2);">{verificationCode}</span>
    </div>
    
    <!-- Instructions -->
    <div style="background-color: #f8fafc; padding: 25px; border-radius: 8px; border-right: 4px solid #6366f1; margin: 30px 0;">
      <h3 style="color: #1f2937; margin: 0 0 15px; font-size: 18px; font-weight: 600;">كيفية استخدام الرمز:</h3>
      <ul style="color: #4b5563; margin: 0; padding-right: 20px; font-size: 15px;">
        <li style="margin-bottom: 8px;">انسخ رمز التحقق أعلاه</li>
        <li style="margin-bottom: 8px;">الصقه في صفحة التحقق في التطبيق</li>
        <li style="margin-bottom: 8px;">اضغط على "تأكيد" لإكمال التسجيل</li>
      </ul>
    </div>
    
    <!-- Warning -->
    <div style="background-color: #fef3cd; padding: 20px; border-radius: 8px; border: 1px solid #fbbf24; margin: 25px 0;">
      <p style="color: #92400e; margin: 0; font-size: 14px; font-weight: 500;">
        ⚠️ هذا الرمز صالح لمدة 10 دقائق فقط لأسباب أمنية
      </p>
    </div>
    
    <p style="color: #6b7280; font-size: 14px; margin: 30px 0 0;">
      إذا لم تقم بإنشاء حساب في متجر ثوبك، يرجى تجاهل هذا البريد الإلكتروني.
    </p>
  </div>
  
  <!-- Footer -->
  <div style="text-align: center; margin-top: 30px; padding: 20px; color: #9ca3af; font-size: 13px;">
    <p style="margin: 0 0 10px;">مع أطيب التحيات،<br><strong style="color: #6366f1;">فريق متجر ثوبك</strong></p>
    <p style="margin: 0;">هذه رسالة تلقائية، يرجى عدم الرد على هذا البريد الإلكتروني</p>
    <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #e5e7eb;">
      <p style="margin: 0; color: #6b7280;">© 2024 متجر ثوبك. جميع الحقوق محفوظة.</p>
    </div>
  </div>
</body>
</html>
`;