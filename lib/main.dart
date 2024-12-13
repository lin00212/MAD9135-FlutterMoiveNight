import 'package:final_project/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/utils/app_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Pacifico',
        useMaterial3: true,
        textTheme: const TextTheme(
          // Primary Text Style
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          // Secondary Text Style
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        colorScheme: ColorScheme.light(
          // Primary Color
          primary: Colors.teal[600]!,
          onPrimary: Colors.white,
          // Secondary Color
          secondary: Colors.orange[400]!,
          onSecondary: Colors.white,
          // Basic Colors
          surface: Colors.grey[50]!,
          onSurface: Colors.grey[900]!,
          error: Colors.red[400]!,
          onError: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: 'Pacifico',
        useMaterial3: true,
        textTheme: const TextTheme(
          // Primary Text Style
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          // Secondary Text Style
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.white70,
          ),
        ),
        colorScheme: ColorScheme.dark(
          // Primary Color
          primary: Colors.tealAccent[200]!,
          onPrimary: Colors.black,
          // Secondary Color
          secondary: Colors.orangeAccent[200]!,
          onSecondary: Colors.black,
          // Basic Colors
          surface: const Color(0xFF121212),
          onSurface: Colors.white,
          error: Colors.red[300]!,
          onError: Colors.black,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const WelcomeScreen(),
    );
  }
}
