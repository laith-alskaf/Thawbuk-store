import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية
  static const Color primary = Color(0xFF2E7D32); // أخضر داكن
  static const Color primaryLight = Color(0xFF4CAF50); // أخضر فاتح
  static const Color primaryDark = Color(0xFF1B5E20); // أخضر أغمق
  
  static const Color secondary = Color(0xFFFF9800); // برتقالي
  static const Color secondaryLight = Color(0xFFFFB74D); // برتقالي فاتح
  static const Color secondaryDark = Color(0xFFE65100); // برتقالي غامق
  
  static const Color tertiary = Color(0xFF795548); // بني فاتح
  static const Color tertiaryLight = Color(0xFFA1887F); // بني فاتح جداً
  static const Color tertiaryDark = Color(0xFF5D4037); // بني غامق
  
  static const Color accent = Color(0xFF795548); // بني فاتح
  static const Color accentLight = Color(0xFFA1887F); // بني فاتح جداً
  static const Color accentDark = Color(0xFF5D4037); // بني غامق

  // ألوان الخلفية
  static const Color background = Color(0xFFF5F5F5); // رمادي فاتح جداً
  static const Color surface = Color(0xFFFFFFFF); // أبيض
  static const Color surfaceVariant = Color(0xFFFAFAFA); // أبيض مائل للرمادي
  static const Color primaryContainer = Color(0xFFE8F5E8); // حاوي أساسي
  static const Color secondaryContainer = Color(0xFFFFF3E0); // حاوي ثانوي
  static const Color tertiaryContainer = Color(0xFFF3E5F5); // حاوي ثالث

  // ألوان النص
  static const Color onPrimary = Color(0xFFFFFFFF); // أبيض على الأساسي
  static const Color onSecondary = Color(0xFFFFFFFF); // أبيض على الثانوي
  static const Color onTertiary = Color(0xFFFFFFFF); // أبيض على الثالث
  static const Color onBackground = Color(0xFF212121); // أسود على الخلفية
  static const Color onSurface = Color(0xFF212121); // أسود على السطح
  static const Color onSurfaceVariant = Color(0xFF757575); // رمادي على السطح
  static const Color onPrimaryContainer = Color(0xFF1B5E20); // أخضر غامق على الحاوي الأساسي
  static const Color onSecondaryContainer = Color(0xFFE65100); // برتقالي غامق على الحاوي الثانوي
  static const Color onTertiaryContainer = Color(0xFF5D4037); // بني غامق على الحاوي الثالث
  
  // ألوان النص المتدرجة
  static const Color textPrimary = Color(0xFF212121); // أسود
  static const Color textSecondary = Color(0xFF757575); // رمادي متوسط
  static const Color textHint = Color(0xFFBDBDBD); // رمادي فاتح
  static const Color textDisabled = Color(0xFF9E9E9E); // رمادي

  // ألوان الحالة
  static const Color success = Color(0xFF4CAF50); // أخضر للنجاح
  static const Color warning = Color(0xFFFF9800); // برتقالي للتحذير
  static const Color error = Color(0xFFD32F2F); // أحمر للخطأ
  static const Color info = Color(0xFF2196F3); // أزرق للمعلومات

  // ألوان إضافية
  static const Color divider = Color(0xFFE0E0E0); // خط الفاصل
  static const Color outline = Color(0xFFE0E0E0); // حدود
  static const Color shadow = Color(0x1F000000); // ظل خفيف
  static const Color overlay = Color(0x80000000); // طبقة شفافة
  
  // ألوان التقييم
  static const Color star = Color(0xFFFFD700); // ذهبي للنجوم
  static const Color starEmpty = Color(0xFFE0E0E0); // رمادي للنجوم الفارغة

  // ألوان الشبكات الاجتماعية
  static const Color facebook = Color(0xFF1877F2);
  static const Color instagram = Color(0xFFE4405F);
  static const Color whatsapp = Color(0xFF25D366);

  // تدرجات لونية
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [surface, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ألوان للمنتجات والتصنيفات
  static const List<Color> categoryColors = [
    Color(0xFF2E7D32), // أخضر
    Color(0xFF1976D2), // أزرق
    Color(0xFF7B1FA2), // بنفسجي
    Color(0xFFD32F2F), // أحمر
    Color(0xFFFF9800), // برتقالي
    Color(0xFF795548), // بني
    Color(0xFF607D8B), // رمادي مزرق
    Color(0xFF388E3C), // أخضر فاتح
  ];

  // الحصول على لون عشوائي للتصنيفات
  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }

  // ألوان للحالات المختلفة
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warning;
      case 'confirmed':
        return info;
      case 'processing':
        return primary;
      case 'shipped':
        return primaryLight;
      case 'delivered':
        return success;
      case 'cancelled':
        return error;
      default:
        return textSecondary;
    }
  }

  // ألوان للمقاسات
  static const List<Color> sizeColors = [
    Color(0xFFE3F2FD), // أزرق فاتح
    Color(0xFFE8F5E8), // أخضر فاتح
    Color(0xFFFFF3E0), // برتقالي فاتح
    Color(0xFFF3E5F5), // بنفسجي فاتح
    Color(0xFFFFEBEE), // أحمر فاتح
  ];

  // الحصول على لون للمقاس
  static Color getSizeColor(int index) {
    return sizeColors[index % sizeColors.length];
  }
}