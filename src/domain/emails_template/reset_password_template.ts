export const PASSWORD_RESET_REQUEST_TEMPLATE = `
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>إعادة تعيين كلمة المرور - متجر ثوبك</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;600;700&display=swap');
  </style>
</head>
<body style="font-family: 'Cairo', Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
  
  <!-- Header -->
  <div style="background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); padding: 30px 20px; text-align: center; border-radius: 12px 12px 0 0;">
    <div style="background-color: white; width: 80px; height: 80px; border-radius: 50%; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 15px rgba(0,0,0,0.1);">
      <span style="font-size: 36px; color: #f59e0b;">🔐</span>
    </div>
    <h1 style="color: white; margin: 0; font-size: 28px; font-weight: 700;">إعادة تعيين كلمة المرور</h1>
    <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0; font-size: 16px;">طلب تغيير كلمة المرور</p>
  </div>
  
  <!-- Main Content -->
  <div style="background-color: white; padding: 40px 30px; border-radius: 0 0 12px 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.1);">
    <div style="text-align: center; margin-bottom: 30px;">
      <h2 style="color: #1f2937; margin: 0 0 10px; font-size: 24px; font-weight: 600;">مرحباً!</h2>
      <p style="color: #6b7280; margin: 0; font-size: 16px;">تلقينا طلباً لإعادة تعيين كلمة المرور الخاصة بك</p>
    </div>
    
    <p style="color: #374151; font-size: 16px; margin-bottom: 25px;">
      إذا لم تقم بطلب إعادة تعيين كلمة المرور، يرجى تجاهل هذا البريد الإلكتروني.
    </p>
    
    <p style="color: #374151; font-size: 16px; margin-bottom: 30px;">
      لإعادة تعيين كلمة المرور، اضغط على الزر أدناه:
    </p>
    
    <!-- Reset Button -->
    <div style="text-align: center; margin: 40px 0;">
      <a href="{resetURL}" style="display: inline-block; background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); color: white; padding: 18px 40px; text-decoration: none; border-radius: 50px; font-weight: 600; font-size: 18px; box-shadow: 0 4px 15px rgba(245, 158, 11, 0.3);">
        🔑 إعادة تعيين كلمة المرور
      </a>
    </div>
    
    <!-- Warning -->
    <div style="background-color: #fef3cd; padding: 20px; border-radius: 8px; border: 1px solid #fbbf24; margin: 25px 0;">
      <p style="color: #92400e; margin: 0; font-size: 14px; font-weight: 500;">
        ⚠️ هذا الرابط صالح لمدة ساعة واحدة فقط لأسباب أمنية
      </p>
    </div>
    
    <!-- Security Tips -->
    <div style="background-color: #f8fafc; padding: 25px; border-radius: 8px; border-right: 4px solid #6366f1; margin: 30px 0;">
      <h3 style="color: #1f2937; margin: 0 0 15px; font-size: 18px; font-weight: 600;">نصائح أمنية:</h3>
      <ul style="color: #4b5563; margin: 0; padding-right: 20px; font-size: 15px;">
        <li style="margin-bottom: 8px;">تأكد من أنك في مكان آمن عند تغيير كلمة المرور</li>
        <li style="margin-bottom: 8px;">اختر كلمة مرور قوية تحتوي على أرقام وحروف ورموز</li>
        <li style="margin-bottom: 8px;">لا تشارك كلمة المرور الجديدة مع أي شخص</li>
      </ul>
    </div>
    
    <p style="color: #6b7280; font-size: 14px; margin: 30px 0 0;">
      إذا لم تطلب إعادة تعيين كلمة المرور، يرجى تجاهل هذا البريد الإلكتروني أو التواصل مع فريق الدعم.
    </p>
  </div>
  
  <!-- Footer -->
  <div style="text-align: center; margin-top: 30px; padding: 20px; color: #9ca3af; font-size: 13px;">
    <p style="margin: 0 0 10px;">مع أطيب التحيات،<br><strong style="color: #f59e0b;">فريق متجر ثوبك</strong></p>
    <p style="margin: 0;">هذه رسالة تلقائية، يرجى عدم الرد على هذا البريد الإلكتروني</p>
    <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #e5e7eb;">
      <p style="margin: 0; color: #6b7280;">© 2024 متجر ثوبك. جميع الحقوق محفوظة.</p>
    </div>
  </div>
</body>
</html>
`;