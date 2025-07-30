// Email Template Constants - ثوابت قوالب الإيميل

export const EMAIL_COLORS = {
  // Project Colors - ألوان المشروع
  primary: '#8B4513',      // بني تقليدي
  primaryLight: '#D2691E',
  primaryDark: '#654321',
  
  secondary: '#DC143C',    // أحمر تقليدي
  secondaryLight: '#FFB6C1',
  secondaryDark: '#8B0000',
  
  // Status Colors - ألوان الحالة
  success: '#10b981',      // أخضر النجاح
  warning: '#f59e0b',      // برتقالي التحذير
  error: '#ef4444',        // أحمر الخطأ
  info: '#3b82f6',         // أزرق المعلومات
  
  // Neutral Colors - ألوان محايدة
  white: '#ffffff',
  black: '#000000',
  gray: {
    50: '#f9fafb',
    100: '#f3f4f6',
    200: '#e5e7eb',
    300: '#d1d5db',
    400: '#9ca3af',
    500: '#6b7280',
    600: '#4b5563',
    700: '#374151',
    800: '#1f2937',
    900: '#111827',
  }
};

export const EMAIL_FONTS = {
  arabic: "'Cairo', Arial, sans-serif",
  english: "'Inter', Arial, sans-serif",
  fallback: "Arial, sans-serif"
};

export const EMAIL_STYLES = {
  container: {
    maxWidth: '600px',
    margin: '0 auto',
    padding: '20px',
    backgroundColor: EMAIL_COLORS.gray[50],
    fontFamily: EMAIL_FONTS.arabic
  },
  
  header: {
    background: `linear-gradient(135deg, ${EMAIL_COLORS.primary} 0%, ${EMAIL_COLORS.primaryDark} 100%)`,
    padding: '40px 20px',
    textAlign: 'center',
    borderRadius: '12px 12px 0 0',
    position: 'relative',
    overflow: 'hidden'
  },
  
  content: {
    backgroundColor: EMAIL_COLORS.white,
    padding: '40px 30px',
    borderRadius: '0 0 12px 12px',
    boxShadow: '0 4px 20px rgba(0,0,0,0.1)'
  },
  
  button: {
    display: 'inline-block',
    background: `linear-gradient(135deg, ${EMAIL_COLORS.primary} 0%, ${EMAIL_COLORS.primaryDark} 100%)`,
    color: EMAIL_COLORS.white,
    padding: '18px 40px',
    textDecoration: 'none',
    borderRadius: '50px',
    fontWeight: '600',
    fontSize: '18px',
    boxShadow: `0 4px 15px rgba(139, 69, 19, 0.3)`
  },
  
  footer: {
    textAlign: 'center',
    marginTop: '30px',
    padding: '25px',
    color: EMAIL_COLORS.gray[400],
    fontSize: '13px'
  }
};

export const EMAIL_MESSAGES = {
  arabic: {
    greeting: 'مرحباً',
    regards: 'مع أطيب التحيات',
    team: 'فريق متجر ثوبك',
    copyright: '© 2024 متجر ثوبك. جميع الحقوق محفوظة.',
    automated: 'هذه رسالة تلقائية، يرجى عدم الرد على هذا البريد الإلكتروني',
    support: 'إذا كان لديك أي استفسار، فريق خدمة العملاء متاح على مدار الساعة'
  },
  
  english: {
    greeting: 'Hello',
    regards: 'Best regards',
    team: 'Thawbuk Store Team',
    copyright: '© 2024 Thawbuk Store. All rights reserved.',
    automated: 'This is an automated message, please do not reply to this email',
    support: 'If you have any questions, our customer service team is available 24/7'
  }
};

export const COMPANY_INFO = {
  name: 'متجر ثوبك',
  nameEn: 'Thawbuk Store',
  website: 'https://thawbuk.com',
  email: 'support@thawbuk.com',
  phone: '+966 XX XXX XXXX',
  address: 'المملكة العربية السعودية'
};