import 'package:flutter/material.dart';

class AppTheme {
  // Modern & Beautiful Color Palette
  static const Color _primaryLight = Color(0xFF6C63FF); // Soft Purple/Indigo
  static const Color _primaryDark = Color(0xFF8B85FF); // Lighter Purple for dark mode
  static const Color _secondaryLight = Color(0xFFFF6584); // Soft Pink/Coral
  static const Color _secondaryDark = Color(0xFFFF7A97); // Lighter Pink for dark mode
  static const Color _accentLight = Color(0xFF4ECDC4); // Mint/Turquoise
  static const Color _accentDark = Color(0xFF6FD9D1); // Lighter Mint for dark mode
  
  // Background colors
  static const Color _backgroundLight = Color(0xFFF8F9FA);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _backgroundDark = Color(0xFF121212);
  static const Color _surfaceDark = Color(0xFF1E1E1E);
  static const Color _cardDark = Color(0xFF2C2C2C);
  
  // Text colors
  static const Color _textPrimaryLight = Color(0xFF2D3436);
  static const Color _textSecondaryLight = Color(0xFF636E72);
  static const Color _textPrimaryDark = Color(0xFFF5F6FA);
  static const Color _textSecondaryDark = Color(0xFFB2BEC3);
  
  // Border/Divider colors
  static const Color _borderLight = Color(0xFFE9ECEF);
  static const Color _borderDark = Color(0xFF2D3436);

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: _primaryLight,
    colorScheme: const ColorScheme.light(
      primary: _primaryLight,
      secondary: _secondaryLight,
      tertiary: _accentLight,
      surface: _surfaceLight,
      background: _backgroundLight,
      error: Color(0xFFE74C3C),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _textPrimaryLight,
      onBackground: _textPrimaryLight,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: _backgroundLight,
    cardColor: _surfaceLight,
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: _surfaceLight,
      foregroundColor: _textPrimaryLight,
      titleTextStyle: TextStyle(
        color: _textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: _textPrimaryLight,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: _textPrimaryLight,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: _textPrimaryLight,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: _textPrimaryLight,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _textPrimaryLight,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _textPrimaryLight,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _textPrimaryLight,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: _textPrimaryLight,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: _textSecondaryLight,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _textPrimaryLight,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _textSecondaryLight,
      ),
    ),
    
    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryLight,
        side: const BorderSide(color: _primaryLight, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderLight, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderLight, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 2),
      ),
      labelStyle: const TextStyle(color: _textSecondaryLight, fontSize: 16),
      hintStyle: const TextStyle(color: _textSecondaryLight, fontSize: 16),
      floatingLabelStyle: const TextStyle(color: _primaryLight),
      prefixIconColor: _textSecondaryLight,
      suffixIconColor: _textSecondaryLight,
    ),
    
    // Card Theme - Fixed: Using CardThemeData
    cardTheme: CardThemeData(
      color: _surfaceLight,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: _borderLight,
      deleteIconColor: _textSecondaryLight,
      labelStyle: const TextStyle(color: _textPrimaryLight, fontSize: 14),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 14),
      selectedColor: _primaryLight,
      secondarySelectedColor: _secondaryLight,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _surfaceLight,
      selectedItemColor: _primaryLight,
      unselectedItemColor: _textSecondaryLight,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Tab Bar Theme - Fixed: Using TabBarThemeData
    tabBarTheme: const TabBarThemeData(
      labelColor: _primaryLight,
      unselectedLabelColor: _textSecondaryLight,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: _primaryLight,
      labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 14),
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryLight,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    
    // Dialog Theme - Fixed: Using DialogThemeData
    dialogTheme: const DialogThemeData(
      backgroundColor: _surfaceLight,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      titleTextStyle: TextStyle(
        color: _textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(
        color: _textSecondaryLight,
        fontSize: 16,
      ),
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: _borderLight,
      thickness: 1,
      space: 1,
    ),
    
    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _primaryLight,
      circularTrackColor: _borderLight,
      linearTrackColor: _borderLight,
    ),
    
    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _primaryLight;
        }
        return _borderLight;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    
    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _primaryLight;
        }
        return _borderLight;
      }),
    ),
    
    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _primaryLight;
        }
        return _borderLight;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _primaryLight.withOpacity(0.5);
        }
        return _borderLight.withOpacity(0.5);
      }),
    ),
    
    // Slider Theme
    sliderTheme: SliderThemeData(
      activeTrackColor: _primaryLight,
      inactiveTrackColor: _borderLight,
      thumbColor: _primaryLight,
      overlayColor: _primaryLight.withOpacity(0.2),
      valueIndicatorColor: _primaryLight,
      valueIndicatorTextStyle: const TextStyle(color: Colors.white),
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: _primaryDark,
    colorScheme: const ColorScheme.dark(
      primary: _primaryDark,
      secondary: _secondaryDark,
      tertiary: _accentDark,
      surface: _surfaceDark,
      background: _backgroundDark,
      error: Color(0xFFE74C3C),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _textPrimaryDark,
      onBackground: _textPrimaryDark,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: _backgroundDark,
    cardColor: _cardDark,
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: _surfaceDark,
      foregroundColor: _textPrimaryDark,
      titleTextStyle: TextStyle(
        color: _textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: _textPrimaryDark,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: _textPrimaryDark,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: _textPrimaryDark,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: _textPrimaryDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _textPrimaryDark,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _textPrimaryDark,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _textPrimaryDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: _textPrimaryDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: _textSecondaryDark,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _textPrimaryDark,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _textSecondaryDark,
      ),
    ),
    
    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryDark,
        side: const BorderSide(color: _primaryDark, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderDark, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderDark, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 2),
      ),
      labelStyle: const TextStyle(color: _textSecondaryDark, fontSize: 16),
      hintStyle: const TextStyle(color: _textSecondaryDark, fontSize: 16),
      floatingLabelStyle: const TextStyle(color: _primaryDark),
      prefixIconColor: _textSecondaryDark,
      suffixIconColor: _textSecondaryDark,
    ),
    
    // Card Theme - Fixed: Using CardThemeData
    cardTheme: CardThemeData(
      color: _cardDark,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: _borderDark,
      deleteIconColor: _textSecondaryDark,
      labelStyle: const TextStyle(color: _textPrimaryDark, fontSize: 14),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 14),
      selectedColor: _primaryDark,
      secondarySelectedColor: _secondaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _surfaceDark,
      selectedItemColor: _primaryDark,
      unselectedItemColor: _textSecondaryDark,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Tab Bar Theme - Fixed: Using TabBarThemeData
    tabBarTheme: const TabBarThemeData(
      labelColor: _primaryDark,
      unselectedLabelColor: _textSecondaryDark,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: _primaryDark,
      labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 14),
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryDark,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    
    // Dialog Theme - Fixed: Using DialogThemeData
    dialogTheme: const DialogThemeData(
      backgroundColor: _surfaceDark,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      titleTextStyle: TextStyle(
        color: _textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(
        color: _textSecondaryDark,
        fontSize: 16,
      ),
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: _borderDark,
      thickness: 1,
      space: 1,
    ),
    
    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _primaryDark,
      circularTrackColor: _borderDark,
      linearTrackColor: _borderDark,
    ),
    
    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _primaryDark;
        }
        return _borderDark;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    
    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _primaryDark;
        }
        return _borderDark;
      }),
    ),
    
    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _primaryDark;
        }
        return _borderDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _primaryDark.withOpacity(0.5);
        }
        return _borderDark.withOpacity(0.5);
      }),
    ),
    
    // Slider Theme
    sliderTheme: SliderThemeData(
      activeTrackColor: _primaryDark,
      inactiveTrackColor: _borderDark,
      thumbColor: _primaryDark,
      overlayColor: _primaryDark.withOpacity(0.2),
      valueIndicatorColor: _primaryDark,
      valueIndicatorTextStyle: const TextStyle(color: Colors.white),
    ),
  );
}