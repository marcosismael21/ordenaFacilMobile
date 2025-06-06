import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/home_page.dart';
import 'widgets/cart_page.dart';
import 'services/cart_service.dart';
import 'widgets/perfil/direcciones_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (ctx) => CartService())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ordena Fácil',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Tema personalizado con fondo gradiente
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          shadowColor: Colors.black.withOpacity(0.1),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 20,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8FBFF), // Azul muy claro casi blanco
                Color(0xFFE3F2FD), // Azul claro
                Color(0xFFBBDEFB), // Azul medio claro
                Color(0xFFE1F5FE), // Azul cyan claro
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: child,
        );
      },
      home: const HomePage(),
      routes: {
        '/home': (ctx) => const HomePage(),
        '/cart': (ctx) => const CartPage(),
        '/perfil/direcciones': (ctx) => const DireccionesPage(),
      },
    );
  }
}
