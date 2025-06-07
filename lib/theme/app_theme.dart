import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE07B39);
  static const Color primaryLight = Color(0xFFE89A5F);
  static const Color primaryDark = Color(0xFFCC6A28);

  // Colores secundarios - Verde menta suave para contraste
  static const Color secondary = Color(0xFF9BDEAC); // Verde menta suave
  static const Color secondaryLight = Color(0xFFB8E6C4); // Verde menta claro
  static const Color secondaryDark = Color(0xFF7BC88E); // Verde menta oscuro

  // Colores de acento
  static const Color accent = Color(0xFFF4D1AE); // Beige/crema cálido
  static const Color accentLight = Color(0xFFF8E1C8); // Beige muy claro

  // Colores neutros
  static const Color background = Color(0xFFFFFBF8); // Blanco cálido
  static const Color surface = Color(0xFFFFFFFF); // Blanco puro
  static const Color onPrimary = Color(0xFFFFFFFF); // Texto sobre primary
  static const Color onSecondary = Color(0xFFFFFFFF); // Texto sobre secondary
  static const Color onBackground = Color(0xFF2C2C2C); // Texto oscuro
  static const Color onSurface = Color(0xFF333333); // Texto sobre surface

  // Colores de estado
  static const Color success = Color(0xFF7BC88E); // Verde éxito
  static const Color warning = Color(0xFFFFB74D); // Naranja advertencia
  static const Color error = Color(0xFFE57373); // Rojo suave error
  static const Color info = Color(0xFF81C7D4); // Azul info suave

  // Grises suaves
  static const Color grey100 = Color(0xFFF8F6F4);
  static const Color grey200 = Color(0xFFEFEBE7);
  static const Color grey300 = Color(0xFFE0D8D1);
  static const Color grey400 = Color(0xFFB8ACA0);
  static const Color grey500 = Color(0xFF8E7E6F);
  static const Color grey600 = Color(0xFF6B5D52);
  static const Color grey700 = Color(0xFF4A3F37);

  // Gradientes para fondos
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFBF8), // Blanco cálido
      Color(0xFFF8F2EC), // Beige muy claro
      Color(0xFFF2E6D8), // Beige claro
      Color(0xFFEFE3D5), // Beige
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFFFBF8)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF98D4AA)],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Esquema de colores
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surface,
        background: AppColors.background,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurface,
        onBackground: AppColors.onBackground,
        error: AppColors.error,
      ),

      // Configuración de Scaffold
      scaffoldBackgroundColor: Colors.transparent,

      // Tema del AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.onPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.onPrimary, size: 28),
      ),

      // Tema de las tarjetas
      cardTheme: CardTheme(
        color: AppColors.surface,
        shadowColor: AppColors.grey300,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),

      // Tema de la barra de navegación inferior
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 20,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey500,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        type: BottomNavigationBarType.fixed,
      ),

      // Tema de botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 4,
          shadowColor: AppColors.grey300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Tema de botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Tema de campos de texto
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.grey100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Tema de chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.accent,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(color: AppColors.onBackground),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Tema de texto
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.onBackground,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: AppColors.onBackground,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: AppColors.onBackground,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.onBackground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.onBackground,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: AppColors.grey600,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Configuración de iconos
      iconTheme: const IconThemeData(color: AppColors.primary, size: 24),
    );
  }
}

// Extensiones útiles para usar en los widgets
extension AppColorsExtension on Color {
  static Color get restaurantPrimary => AppColors.primary;
  static Color get restaurantSecondary => AppColors.secondary;
  static Color get restaurantAccent => AppColors.accent;
  static Color get restaurantSuccess => AppColors.success;
  static Color get restaurantWarning => AppColors.warning;
  static Color get restaurantError => AppColors.error;
}

// Helpers para gradientes comunes
class AppGradients {
  static const LinearGradient primary = AppColors.primaryGradient;
  static const LinearGradient background = AppColors.backgroundGradient;
  static const LinearGradient card = AppColors.cardGradient;
  static const LinearGradient secondary = AppColors.secondaryGradient;
  static const LinearGradient success = AppColors.successGradient;

  // Gradiente para botones de acción principal
  static const LinearGradient actionButton = LinearGradient(
    colors: [AppColors.secondary, AppColors.secondaryDark],
  );

  // Gradiente para tarjetas de platillos
  static const LinearGradient dishCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFAF6F2)],
  );

  // Gradiente para overlay de imágenes
  static LinearGradient imageOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.black.withOpacity(0.3), Colors.transparent],
  );
}
