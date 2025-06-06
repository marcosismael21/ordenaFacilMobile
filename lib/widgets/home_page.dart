import 'package:flutter/material.dart';
import 'dart:async';
import '../models/platillo.dart';
import '../models/promocion.dart';
import '../models/tipo_platillo.dart';
import '../services/platillo_service.dart';
import '../services/promocion_service.dart';
import '../services/tipo_platillo_service.dart';
import 'navigation/pedidos_page.dart';
import 'navigation/perfil_page.dart';
import 'platillo_detail_page.dart';
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
  int _selectedMenuIndex = 0;
  final PageController _pageController = PageController();
  final PromocionService _promocionService = PromocionService();
  final TipoPlatilloService _tipoPlatilloService = TipoPlatilloService();
  final PlatilloService _platilloService = PlatilloService();
  List<Platillo> _platillos = [];
  List<Promocion> _promociones = [];
  List<TipoPlatillo> _tiposPlatillo = [];
  int _currentPage = 0;
  Timer? _timer;

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_promociones.isNotEmpty) {
        if (_currentPage < _promociones.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Future<void> _loadPromociones() async {
    final promociones = await _promocionService.getAllPromociones();
    setState(() {
      _promociones = promociones;
    });
  }

  Future<void> _loadTiposPlatillo() async {
    final tiposPlatillo = await _tipoPlatilloService.getAllTipoPlatillo();
    setState(() {
      _tiposPlatillo = tiposPlatillo;
    });
  }

  Future<void> _loadPlatillos() async {
    final platillos = await _platilloService.getAllPlatillos();
    setState(() {
      _platillos = platillos;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _loadPromociones();
        _loadPlatillos();
        _startAutoScroll();
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (_selectedIndex == 0) {
      _loadPromociones();
      _loadTiposPlatillo();
      _loadPlatillos();
      _startAutoScroll();
    }
  }

  Widget _buildMenuContent() {
    if (_tiposPlatillo.isEmpty) {
      return const Center(child: Text('No hay menús disponibles'));
    }

    // Filtrar platillos según el tipo seleccionado
    final platillosFiltrados =
        _platillos
            .where(
              (platillo) =>
                  platillo.tipoPlatilloId ==
                  _tiposPlatillo[_selectedMenuIndex].id,
            )
            .toList();

    if (platillosFiltrados.isEmpty) {
      return const Center(
        child: Text('No hay platillos disponibles en este menú'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: platillosFiltrados.length,
      itemBuilder: (context, index) {
        final platillo = platillosFiltrados[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: () {
              // Navegar a la página de detalle del platillo
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PlatilloDetailPage(platillo: platillo),
                ),
              );
            },
            child: SizedBox(
              height: 120,
              child: Row(
                children: [
                  // Imagen del platillo
                  SizedBox(
                    width: 120,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(4),
                      ),
                      child: Image.network(
                        platillo.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                  ),
                  // Información del platillo
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            platillo.nombre,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            platillo.descripcion,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'L.${platillo.precio.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Flecha indicadora
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
          // Carrusel de promociones
          SizedBox(
            height: 200,
            child:
                _promociones.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemCount: _promociones.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              _promociones[index].urlImage,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Text('Error al cargar la imagen'),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
          ),

          // Indicadores de página del carrusel
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                _promociones.map((promocion) {
                  int index = _promociones.indexOf(promocion);
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentPage == index
                              ? Colors.blue
                              : Colors.blue.withOpacity(0.4),
                    ),
                  );
                }).toList(),
          ),

          // Título de los menús
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Nuestros Menús',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          // Menús dinámicos
          if (_tiposPlatillo.isEmpty)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: [
                // Botones de navegación de menús
                SizedBox(
                  height: 45,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        _tiposPlatillo.length,
                        (index) => SizedBox(
                          width:
                              MediaQuery.of(context).size.width /
                              3, // Ancho fijo para cada botón
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color:
                                      _selectedMenuIndex == index
                                          ? Colors.blue
                                          : Colors.grey[300]!,
                                  width: 2.0,
                                ),
                              ),
                              color: Colors.white,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedMenuIndex = index;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                  ),
                                  child: Text(
                                    _tiposPlatillo[index].descripcion,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                          _selectedMenuIndex == index
                                              ? Colors.blue
                                              : Colors.black87,
                                      fontWeight:
                                          _selectedMenuIndex == index
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Contenido del menú seleccionado
                _buildMenuContent(),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordena Fácil'),
        automaticallyImplyLeading: false,
        actions: [
          // Botón de carrito con contador
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
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
      ),
    );
  }
}
