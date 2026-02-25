import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sindò',
      theme: _buildTheme(context),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    const Color primaryColor = Color(0xFF008753); // Vert institutionnel
    const Color secondaryColor = Color(0xFFFDD835); // Jaune doux
    const Color accentColor = Color(0xFFD32F2F); // Rouge discret
    const Color backgroundColor = Color(0xFFF5F5F5); // Fond gris clair
    const Color surfaceColor = Colors.white; // Couleur des cartes
    const Color onTextColor = Color(0xFF333333); // Texte principal
    const Color subduedTextColor = Color(0xFF666666); // Texte secondaire

    final colorScheme = ColorScheme(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: onTextColor,
      error: accentColor,
      onError: Colors.white,
      background: backgroundColor,
      onBackground: onTextColor,
      surface: surfaceColor,
      onSurface: onTextColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'times', // Police sobre et moderne

      // Styles de texte
      textTheme: Theme.of(context).textTheme.apply(
            bodyColor: onTextColor,
            displayColor: onTextColor,
            fontFamily: 'times',
          ),

      // Style des cartes
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Style des champs de saisie
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: const TextStyle(color: subduedTextColor),
      ),

      // Style des boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
        ).copyWith(
          elevation: ButtonStyleButton.allOrNull(0),
        ),
      ),
    );
  }
}
