import 'package:flutter/material.dart';
import 'dart:async';
import '../models/tipo_platillo.dart';
import '../services/tipo_platillo_service.dart';
import '../theme/app_theme.dart';
import 'MenuPlatillosPage.dart';
import 'login_page.dart';
import 'navigation/pedidos_page.dart';
import 'navigation/perfil_page.dart';
import 'navigation/configuracion.dart';
import 'cart_page.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final TipoPlatilloService _tipoPlatilloService = TipoPlatilloService();
  List<TipoPlatillo> _tiposPlatillo = [];

  Future<void> _loadTiposPlatillo() async {
    final tiposPlatillo = await _tipoPlatilloService.getAllTipoPlatillo();
    setState(() {
      _tiposPlatillo = tiposPlatillo;
    });
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _mostrarModalLogin();
      return;
    }

    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _loadTiposPlatillo();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (_selectedIndex == 0) {
      _loadTiposPlatillo();
    }
  }

  void _mostrarModalLogin() {
    showDialog(
      context: context,
      barrierDismissible: true, // Permite cerrar tocando fuera
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header del modal con botón de cerrar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Acceso Restringido',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Contenido del login
                Flexible(
                  child: LoginPage(
                    isModal: true,
                    onLoginComplete: (bool loginExitoso) {
                      Navigator.of(context).pop(); // Cerrar modal

                      if (loginExitoso) {
                        // Login exitoso - ir a configuración
                        setState(() {
                          _selectedIndex = 2;
                        });

                        // Mostrar mensaje de éxito
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Acceso concedido'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      } else {
                        // Login fallido - mostrar mensaje (opcional)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Acceso denegado'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuCards() {
    if (_tiposPlatillo.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _tiposPlatillo.length,
      itemBuilder: (context, index) {
        final tipoPlatillo = _tiposPlatillo[index];
        return Card(
          elevation: 8,
          shadowColor: AppColors.grey300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: AppColors.cardGradient,
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            MenuPlatillosPage(tipoPlatillo: tipoPlatillo),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Imagen del tipo de platillo
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: Icon(
                          _getIconForTipoPlatillo(tipoPlatillo.descripcion),
                          size: 60,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tipoPlatillo.descripcion,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.accent,
                                  AppColors.accentLight,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Ver menú',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Función auxiliar para obtener iconos según el tipo de platillo
  IconData _getIconForTipoPlatillo(String descripcion) {
    final desc = descripcion.toLowerCase();
    if (desc.contains('desayuno')) return Icons.breakfast_dining;
    if (desc.contains('almuerzo') || desc.contains('comida'))
      return Icons.lunch_dining;
    if (desc.contains('cena')) return Icons.dinner_dining;
    if (desc.contains('postre')) return Icons.cake;
    if (desc.contains('bebida')) return Icons.local_drink;
    if (desc.contains('ensalada')) return Icons.eco;
    if (desc.contains('pizza')) return Icons.local_pizza;
    if (desc.contains('hamburguesa')) return Icons.lunch_dining;
    return Icons.restaurant_menu;
  }

  Widget _buildBody() {
    if (_selectedIndex != 0) {
      switch (_selectedIndex) {
        case 1:
          return const PedidosPage();
        case 2:
          return const ConfiguracionPage();
        default:
          return const Center(child: Text('Página no encontrada'));
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título principal con fondo semi-transparente
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey300.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback:
                      (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                  child: const Text(
                    '¡Bienvenido!',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Elige tu menú favorito',
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Cartas de menú
          _buildMenuCards(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Ordena Fácil',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        actions: [
          // Botón de carrito con contador
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, size: 50),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                },
              ),
              if (cartService.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.error,
                          AppColors.error.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${cartService.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.grey300.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconSize: 35,
          selectedFontSize: 25,
          unselectedFontSize: 20,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Pedidos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Configuración',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey500,
          onTap: _onItemTapped,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}
