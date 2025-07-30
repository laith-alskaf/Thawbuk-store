export const PASSWORD_RESET_SUCCESS_TEMPLATE = `
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>تم تغيير كلمة المرور بنجاح - متجر ثوبك</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;600;700&display=swap');
  </style>
</head>
<body style="font-family: 'Cairo', Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
  
  <!-- Success Header -->
  <div style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); padding: 40px 20px; text-align: center; border-radius: 12px 12px 0 0; position: relative; overflow: hidden;">
    <div style="position: absolute; top: -50px; right: -50px; width: 100px; height: 100px; background: rgba(255,255,255,0.1); border-radius: 50%;"></div>
    <div style="position: absolute; bottom: -30px; left: -30px; width: 60px; height: 60px; background: rgba(255,255,255,0.1); border-radius: 50%;"></div>
    
    <div style="background-color: white; width: 100px; height: 100px; border-radius: 50%; margin: 0 auto 25px; display: flex; align-items: center; justify-content: center; box-shadow: 0 8px 25px rgba(0,0,0,0.15); position: relative; z-index: 1;">
      <span style="font-size: 48px; color: #10b981;">✓</span>
    </div>
    <h1 style="color: white; margin: 0; font-size: 28px; font-weight: 700; position: relative; z-index: 1;">تم تغيير كلمة المرور!</h1>
    <p style="color: rgba(255,255,255,0.95); margin: 15px 0 0; font-size: 16px; position: relative; z-index: 1;">تم تحديث كلمة المرور بنجاح</p>
  </div>
  
  <!-- Main Content -->
  <div style="background-color: white; padding: 40px 30px; border-radius: 0 0 12px 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.1);">
    
    <div style="text-align: center; margin-bottom: 30px;">
      <h2 style="color: #1f2937; margin: 0 0 15px; font-size: 24px; font-weight: 600;">مرحباً!</h2>
      <p style="color: #6b7280; margin: 0; font-size: 16px; line-height: 1.6;">
        نكتب إليك لتأكيد أنه تم تغيير كلمة المرور الخاصة بك بنجاح في متجر ثوبك.
      </p>
    </div>
    
    <!-- Security Notice -->
    <div style="background-color: #fef3cd; padding: 25px; border-radius: 12px; margin: 30px 0; border-right: 4px solid #f59e0b;">
      <h3 style="color: #92400e; margin: 0 0 15px; font-size: 18px; font-weight: 600;">⚠️ إشعار أمني مهم</h3>
      <p style="color: #92400e; margin: 0; font-size: 15px; line-height: 1.6;">
        إذا لم تقم بتغيير كلمة المرور، يرجى التواصل مع فريق الدعم فوراً لحماية حسابك.
      </p>
    </div>
    
    <!-- Security Tips -->
    <div style="background-color: #f8fafc; padding: 25px; border-radius: 12px; margin: 30px 0; border-right: 4px solid #6366f1;">
      <h3 style="color: #1f2937; margin: 0 0 20px; font-size: 18px; font-weight: 600;">🔒 نصائح أمنية للحفاظ على حسابك:</h3>
      <ul style="color: #4b5563; margin: 0; padding-right: 20px; font-size: 15px; line-height: 1.8;">
        <li style="margin-bottom: 10px;">استخدم كلمة مرور قوية وفريدة</li>
        <li style="margin-bottom: 10px;">لا تشارك كلمة المرور مع أي شخص</li>
        <li style="margin-bottom: 10px;">تجنب استخدام نفس كلمة المرور في مواقع أخرى</li>
        <li style="margin-bottom: 10px;">قم بتحديث كلمة المرور بانتظام</li>
      </ul>
    </div>
    
    <!-- Support Info -->
    <div style="background-color: #f0fdf4; padding: 25px; border-radius: 12px; margin: 30px 0; text-align: center; border: 1px solid #bbf7d0;">
      <h4 style="color: #166534; margin: 0 0 15px; font-size: 18px; font-weight: 600;">🤝 نحن هنا لمساعدتك</h4>
      <p style="color: #166534; margin: 0; font-size: 15px; line-height: 1.6;">
        إذا كان لديك أي استفسار أو تحتاج إلى مساعدة، فريق خدمة العملاء متاح على مدار الساعة.<br>
        شكراً لك على مساعدتنا في الحفاظ على أمان حسابك.
      </p>
    </div>
    
    <div style="text-align: center; margin-top: 40px;">
      <p style="color: #6b7280; margin: 0 0 20px; font-size: 16px;">
        مع أطيب التحيات،<br>
        <strong style="color: #6366f1; font-size: 18px;">فريق متجر ثوبك</strong>
      </p>
    </div>
  </div>
  
  <!-- Footer -->
  <div style="text-align: center; margin-top: 30px; padding: 25px; color: #9ca3af; font-size: 13px;">
    <div style="border-top: 1px solid #e5e7eb; padding-top: 20px;">
      <p style="margin: 0; color: #6b7280;">© 2024 متجر ثوبك. جميع الحقوق محفوظة.</p>
      <p style="margin: 10px 0 0; color: #9ca3af;">هذه رسالة تلقائية، يرجى عدم الرد على هذا البريد الإلكتروني</p>
    </div>
  </div>
</body>
</html>
`;