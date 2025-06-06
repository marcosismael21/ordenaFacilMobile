import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/home_page.dart';
import 'widgets/cart_page.dart';
import 'services/cart_service.dart';
import 'widgets/perfil/direcciones_page.dart';
import 'theme/app_theme.dart';

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
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
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
