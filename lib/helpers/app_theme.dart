import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // === COLORS ===
  static const Color primary = Color(0xFF00561b); // Royal Green
  static const Color primaryDark = Color(0xFF003d13);
  static const Color primaryLight = Color(0xFF1a7a33);
  static const Color accent = Color(0xFF4CAF50);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7F5);
  static const Color textPrimary = Color(0xFF1A2C1E);
  static const Color textSecondary = Color(0xFF6B7C6E);
  static const Color divider = Color(0xFFE0E8E1);

  // === BMI STATUS COLORS ===
  static const Color bmiUnderweight = Color(0xFF2196F3);
  static const Color bmiNormal = Color(0xFF4CAF50);
  static const Color bmiOverweight = Color(0xFFFF9800);
  static const Color bmiObese = Color(0xFFF44336);

  // === GRADIENTS ===
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00561b), Color(0xFF1a7a33), Color(0xFF2E9E4A)],
  );

  static const LinearGradient subtleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF00561b), Color(0xFF007a28)],
  );

  // === CARD DECORATION ===
  static BoxDecoration cardDecoration({Color? shadowColor, double radius = 20}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: (shadowColor ?? primary).withValues(alpha: 0.08),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // === INPUT DECORATION ===
  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      prefixIcon: Icon(icon, color: primary),
      suffixIcon: suffixIcon,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: divider, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: bmiObese, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: bmiObese, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }

  // === BUTTON STYLE ===
  static ButtonStyle primaryButtonStyle({double radius = 14}) {
    return ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      elevation: 0,
      shadowColor: Colors.transparent,
    );
  }

  // === THEME DATA ===
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(
          color: primary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle(),
      ),
    );
  }
}
