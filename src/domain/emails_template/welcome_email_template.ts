export const WELCOME_EMAIL_TEMPLATE = `
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>أهلاً وسهلاً - متجر ثوبك</title>
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
            <span style="font-size: 48px;">🎉</span>
        </div>
        <h1 style="color: white; margin: 0; font-size: 32px; font-weight: 700; position: relative; z-index: 1;">أهلاً وسهلاً بك!</h1>
        <p style="color: rgba(255,255,255,0.95); margin: 15px 0 0; font-size: 18px; position: relative; z-index: 1;">تم تأكيد حسابك بنجاح في متجر ثوبك</p>
    </div>
    
    <!-- Main Content -->
    <div style="background-color: white; padding: 50px 40px; border-radius: 0 0 12px 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.1);">
        
        <div style="text-align: center; margin-bottom: 40px;">
            <h2 style="color: #1f2937; margin: 0 0 15px; font-size: 28px; font-weight: 600;">مرحباً {USER_NAME}! 👋</h2>
            <p style="color: #6b7280; margin: 0; font-size: 18px; line-height: 1.6;">
                نحن سعداء جداً لانضمامك إلى عائلة متجر ثوبك.<br>
                رحلتك في عالم الأزياء الراقية تبدأ الآن!
            </p>
        </div>
        
        <!-- Welcome Message -->
        <div style="background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%); padding: 30px; border-radius: 12px; margin: 30px 0; text-align: center; border: 1px solid #e2e8f0;">
            <h3 style="color: #1e293b; margin: 0 0 15px; font-size: 20px; font-weight: 600;">🌟 حسابك جاهز الآن!</h3>
            <p style="color: #475569; margin: 0; font-size: 16px;">
                يمكنك الآن الاستمتاع بجميع مزايا متجر ثوبك والتسوق من أفضل الأزياء
            </p>
        </div>
        
        <!-- Features -->
        <div style="margin: 40px 0;">
            <h3 style="color: #1f2937; margin: 0 0 25px; font-size: 22px; font-weight: 600; text-align: center;">ماذا يمكنك فعله الآن؟</h3>
            
            <div style="display: grid; gap: 20px;">
                <!-- Feature 1 -->
                <div style="display: flex; align-items: center; padding: 20px; background-color: #fef7ff; border-radius: 10px; border-right: 4px solid #8b5cf6;">
                    <div style="background-color: #8b5cf6; width: 50px; height: 50px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-left: 20px; flex-shrink: 0;">
                        <span style="font-size: 24px; color: white;">🛍️</span>
                    </div>
                    <div>
                        <h4 style="color: #1f2937; margin: 0 0 5px; font-size: 16px; font-weight: 600;">تسوق من أحدث المجموعات</h4>
                        <p style="color: #6b7280; margin: 0; font-size: 14px;">اكتشف أحدث صيحات الموضة والأزياء الراقية</p>
                    </div>
                </div>
                
                <!-- Feature 2 -->
                <div style="display: flex; align-items: center; padding: 20px; background-color: #f0fdf4; border-radius: 10px; border-right: 4px solid #10b981;">
                    <div style="background-color: #10b981; width: 50px; height: 50px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-left: 20px; flex-shrink: 0;">
                        <span style="font-size: 24px; color: white;">❤️</span>
                    </div>
                    <div>
                        <h4 style="color: #1f2937; margin: 0 0 5px; font-size: 16px; font-weight: 600;">أضف إلى المفضلة</h4>
                        <p style="color: #6b7280; margin: 0; font-size: 14px;">احفظ المنتجات المفضلة لديك للعودة إليها لاحقاً</p>
                    </div>
                </div>
                
                <!-- Feature 3 -->
                <div style="display: flex; align-items: center; padding: 20px; background-color: #fef3c7; border-radius: 10px; border-right: 4px solid #f59e0b;">
                    <div style="background-color: #f59e0b; width: 50px; height: 50px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-left: 20px; flex-shrink: 0;">
                        <span style="font-size: 24px; color: white;">🚚</span>
                    </div>
                    <div>
                        <h4 style="color: #1f2937; margin: 0 0 5px; font-size: 16px; font-weight: 600;">توصيل سريع ومجاني</h4>
                        <p style="color: #6b7280; margin: 0; font-size: 14px;">استمتع بالتوصيل المجاني لجميع الطلبات</p>
                    </div>
                </div>
                
                <!-- Feature 4 -->
                <div style="display: flex; align-items: center; padding: 20px; background-color: #fef2f2; border-radius: 10px; border-right: 4px solid #ef4444;">
                    <div style="background-color: #ef4444; width: 50px; height: 50px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-left: 20px; flex-shrink: 0;">
                        <span style="font-size: 24px; color: white;">🎁</span>
                    </div>
                    <div>
                        <h4 style="color: #1f2937; margin: 0 0 5px; font-size: 16px; font-weight: 600;">عروض حصرية</h4>
                        <p style="color: #6b7280; margin: 0; font-size: 14px;">احصل على خصومات وعروض خاصة للأعضاء</p>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- CTA Button -->
        <div style="text-align: center; margin: 40px 0;">
            <a href="#" style="display: inline-block; background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%); color: white; padding: 18px 40px; text-decoration: none; border-radius: 50px; font-weight: 600; font-size: 18px; box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3); transition: all 0.3s ease;">
                🛍️ ابدأ التسوق الآن
            </a>
        </div>
        
        <!-- Support Info -->
        <div style="background-color: #f8fafc; padding: 25px; border-radius: 10px; margin: 30px 0; text-align: center; border: 1px solid #e2e8f0;">
            <h4 style="color: #1f2937; margin: 0 0 15px; font-size: 18px; font-weight: 600;">🤝 نحن هنا لمساعدتك</h4>
            <p style="color: #6b7280; margin: 0; font-size: 15px; line-height: 1.6;">
                إذا كان لديك أي استفسار أو تحتاج إلى مساعدة، فريق خدمة العملاء متاح على مدار الساعة لمساعدتك.<br>
                لا تتردد في التواصل معنا في أي وقت!
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
        <div style="margin-bottom: 20px;">
            <p style="margin: 0; color: #6b7280; font-size: 14px;">تابعنا على وسائل التواصل الاجتماعي</p>
            <div style="margin-top: 15px;">
                <a href="#" style="display: inline-block; margin: 0 10px; padding: 10px; background-color: #6366f1; color: white; text-decoration: none; border-radius: 50%; width: 40px; height: 40px; text-align: center; line-height: 20px;">📘</a>
                <a href="#" style="display: inline-block; margin: 0 10px; padding: 10px; background-color: #1da1f2; color: white; text-decoration: none; border-radius: 50%; width: 40px; height: 40px; text-align: center; line-height: 20px;">🐦</a>
                <a href="#" style="display: inline-block; margin: 0 10px; padding: 10px; background-color: #e4405f; color: white; text-decoration: none; border-radius: 50%; width: 40px; height: 40px; text-align: center; line-height: 20px;">📷</a>
            </div>
        </div>
        
        <div style="border-top: 1px solid #e5e7eb; padding-top: 20px;">
            <p style="margin: 0; color: #6b7280;">© 2024 متجر ثوبك. جميع الحقوق محفوظة.</p>
            <p style="margin: 10px 0 0; color: #9ca3af;">هذه رسالة تلقائية، يرجى عدم الرد على هذا البريد الإلكتروني</p>
        </div>
    </div>
</body>
</html>`