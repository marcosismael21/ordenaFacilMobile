import 'package:flutter/material.dart';
import 'dart:async';
import '../models/tipo_platillo.dart';
import '../services/tipo_platillo_service.dart';
import 'MenuPlatillosPage.dart';
import 'navigation/pedidos_page.dart';
import 'navigation/perfil_page.dart';
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
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen del tipo de platillo
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.withOpacity(0.8),
                            Colors.blue.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Icon(
                        _getIconForTipoPlatillo(tipoPlatillo.descripcion),
                        size: 60,
                        color: Colors.white,
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
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Ver menú',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
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
          return const PerfilPage();
        default:
          return const Center(child: Text('Página no encontrada'));
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título principal
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Bienvenido!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Elige tu menú favorito',
                  style: TextStyle(fontSize: 28, color: Colors.grey),
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
      appBar: AppBar(
        title: const Text('Ordena Fácil',
        style: TextStyle(fontSize: 25)),
        automaticallyImplyLeading: false,
        actions: [
          // Botón de carrito con contador
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart,
                size: 35,),
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
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartService.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 35,
        selectedFontSize: 25,
        unselectedFontSize: 20,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mi Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }
}
