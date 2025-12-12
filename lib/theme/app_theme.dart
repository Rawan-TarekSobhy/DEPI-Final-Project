import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4FC3F7);    // اللبني الفاتح
  static const Color secondary = Color(0xFF0288D1);  // أزرق أغمق للتباين

  static const Color success = Color(0xFF26A69A);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFCA28);

  static const Color actionAddMed = Color(0xFF4FC3F7); // نفس لون اللوجو
  static const Color actionAssistant = Color(0xFF5C6BC0); // نيلي (Indigo) يليق مع الذكاء الاصطناعي
  static const Color actionPharmacy = Color(0xFF26A69A);  // نفس لون الـ Success (رمز الصيدلية)

  static const Gradient lightGradient = LinearGradient(
    colors: [Color(0xFF4FC3F7), Color(0xFF81D4FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient darkGradient = LinearGradient(
    colors: [Color(0xFF0288D1), Color(0xFF29B6F6)], // غمقنا الجرادينت شوية للدارك مود
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
class AppTheme {
  static ThemeData lightTheme({String? fontFamily}) {
    final base = ThemeData.light();
    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F7FB), // خلفية فاتحة جداً مريحة للعين
      primaryColor: AppColors.primary,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white, // النص علي الزرار الأساسي
        secondary: AppColors.secondary, // استخدام اللون الجديد
        onSecondary: Colors.white,
        error: AppColors.error,
        background: const Color(0xFFF5F7FB),
        onBackground: Colors.black87,
        surface: Colors.white, // كروت الدواء
      ),

      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary, // أو ممكن تخليه AppColors.secondary لو عايز تباين أقوى
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      iconTheme: const IconThemeData(color: AppColors.secondary), // الأيقونات باللون الغامق عشان تبان

      textTheme: (base.textTheme).apply(
        bodyColor: const Color(0xFF263238), // لون رصاصي غامق مريح للقراءة أحسن من الأسود الصريح
        displayColor: Colors.black87,
        fontFamily: fontFamily,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // خليته 12 أشيك
          elevation: 2,
        ),
      ),

      // إضافة ستايل للـ Floating Action Button لو موجود
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary, // الزرار العائم بلون مميز
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData darkTheme({String? fontFamily}) {
    final base = ThemeData.dark();
    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: AppColors.primary,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: const Color(0xFF121212), // النص هنا أسود عشان الخلفية فاتحة
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        error: AppColors.error,
        background: const Color(0xFF121212),
        onBackground: Colors.white,
        surface: const Color(0xFF1E1E1E), // كروت الدواء
      ),

      cardColor: const Color(0xFF1E1E1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E), // في الدارك مود الأفضل البار يكون نفس لون الكروت
        foregroundColor: AppColors.primary, // العنوان ياخد لون اللوجو
        elevation: 0,
        centerTitle: true,
      ),

      iconTheme: const IconThemeData(color: AppColors.primary), // الأيقونات تنور بلون اللوجو

      textTheme: (base.textTheme).apply(
        bodyColor: const Color(0xFFE0E0E0), // أبيض هادي
        displayColor: Colors.white,
        fontFamily: fontFamily,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: const Color(0xFF121212), // نص أسود علي زرار لبني عشان القراءة
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
      ),
    );
  }
}