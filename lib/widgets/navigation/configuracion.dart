import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/mesa_service.dart';
import '../../models/mesa.dart';
import '../login_page.dart';
import '../../theme/app_theme.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  final AuthService _authService = AuthService();
  final MesaService _mesaService = MesaService();

  // Variables para almacenar los valores
  String _numeroMesa = '';
  String _colaboradorAsignado = '';
  String _mesasAsociadas = '';

  // Variables para el modal de mesas
  List<Mesa> _mesas = [];
  bool _isLoadingMesas = false;
  Mesa? _mesaSeleccionada;

  @override
  void initState() {
    super.initState();
    _loadConfiguracion();
  }

  Future<void> _loadConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar mesa seleccionada desde SharedPreferences
    final mesaId = prefs.getInt('mesa_seleccionada_id');
    final mesaDescripcion = prefs.getString('mesa_seleccionada_descripcion');

    setState(() {
      _numeroMesa = mesaDescripcion ?? 'No asignada';
      _colaboradorAsignado = 'No asignado';
      _mesasAsociadas = 'Ninguna';
    });
  }

  Future<void> _saveMesaSeleccionada(Mesa mesa) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mesa_seleccionada_id', mesa.id);
    await prefs.setString('mesa_seleccionada_descripcion', mesa.descripcion);

    setState(() {
      _numeroMesa = mesa.descripcion;
    });
  }

  Future<void> _loadMesasInModal(StateSetter setStateModal) async {
    setStateModal(() {
      _isLoadingMesas = true;
    });

    try {
      final mesas = await _mesaService.getAllMesa();
      setStateModal(() {
        _mesas = mesas;
        _isLoadingMesas = false;
      });
    } catch (e) {
      setStateModal(() {
        _isLoadingMesas = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar mesas: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadMesas() async {
    setState(() {
      _isLoadingMesas = true;
    });

    try {
      final mesas = await _mesaService.getAllMesa();
      setState(() {
        _mesas = mesas;
        _isLoadingMesas = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMesas = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar mesas: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _mostrarModalNumeroMesa() async {
    // Resetear selección
    _mesaSeleccionada = null;

    // Mostrar el modal primero
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            // Cargar mesas después de que el modal se haya mostrado
            if (_mesas.isEmpty && !_isLoadingMesas) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadMesasInModal(setStateModal);
              });
            }

            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.table_restaurant,
                    color: AppColors.primary,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Configurar Número de Mesa",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selecciona una mesa:',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                          _isLoadingMesas
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 3,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Cargando mesas...',
                                      style: TextStyle(
                                        color: AppColors.grey600,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : _mesas.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: AppColors.grey500,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No hay mesas disponibles',
                                      style: TextStyle(
                                        color: AppColors.grey600,
                                        fontSize: 25,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.builder(
                                itemCount: _mesas.length,
                                itemBuilder: (context, index) {
                                  final mesa = _mesas[index];
                                  final isSelected =
                                      _mesaSeleccionada?.id == mesa.id;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? AppColors.primary
                                                : AppColors.grey300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      color:
                                          isSelected
                                              ? AppColors.primary.withOpacity(
                                                0.1,
                                              )
                                              : AppColors.grey100,
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? AppColors.primary
                                                  : AppColors.grey400,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.table_restaurant,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                      title: Text(
                                        mesa.descripcion,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color:
                                              isSelected
                                                  ? AppColors.primary
                                                  : AppColors.onSurface,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Cupos: ${mesa.cupos}',
                                        style: TextStyle(
                                          color: AppColors.grey600,
                                          fontSize: 20,
                                        ),
                                      ),
                                      trailing:
                                          isSelected
                                              ? Icon(
                                                Icons.check_circle,
                                                color: AppColors.primary,
                                                size: 30,
                                              )
                                              : Icon(
                                                Icons.circle_outlined,
                                                color: AppColors.grey400,
                                                size: 30,
                                              ),
                                      onTap: () {
                                        setStateModal(() {
                                          _mesaSeleccionada = mesa;
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancelar",
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      _mesaSeleccionada == null
                          ? null
                          : () async {
                            await _saveMesaSeleccionada(_mesaSeleccionada!);
                            Navigator.of(context).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Mesa "${_mesaSeleccionada!.descripcion}" configurada correctamente',
                                  style: const TextStyle(fontSize: 25),
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    "Guardar",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveColaboradorData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('colaborador_id', userData['id'] ?? 0);
    await prefs.setString(
      'colaborador_nombre',
      userData['nombres'] ?? 'Sin nombre',
    );

    setState(() {
      _colaboradorAsignado = userData['nombres'] ?? 'Sin nombre';
    });
  }

  void _mostrarModalColaborador() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.65,
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
                // Header del modal
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
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Asignar Colaborador',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Información adicional
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: AppColors.grey100,
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ingresa las credenciales del colaborador que atenderá esta estación',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.grey700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenido del login
                Flexible(
                  child: LoginPage(
                    isModal: true,
                    onLoginComplete: (
                      bool loginExitoso, {
                      Map<String, dynamic>? userData,
                    }) {
                      Navigator.of(context).pop(); // Cerrar modal

                      if (loginExitoso && userData != null) {
                        // Guardar datos del colaborador
                        _saveColaboradorData(userData);

                        // Mostrar mensaje de éxito
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Colaborador "${userData['nombres']}" asignado correctamente',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      } else {
                        print(userData);
                        // Login fallido
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Credenciales incorrectas. Inténtalo de nuevo.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            duration: const Duration(seconds: 4),
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

  void _mostrarModalMesasAsociadas() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Configurar Mesas Asociadas"),
          content: const Text(
            "Modal para configurar mesas asociadas\n(Lógica pendiente)",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí iría la lógica para configurar mesas asociadas
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configuración',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuración General',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
              ),
              const SizedBox(height: 20),

              // Número de Mesa
              _buildConfigurationTile(
                icon: Icons.table_restaurant,
                title: 'Número de Mesa',
                value: _numeroMesa,
                onTap: _mostrarModalNumeroMesa,
              ),

              const SizedBox(height: 12),

              // Colaborador Asignado
              _buildConfigurationTile(
                icon: Icons.person_outline,
                title: 'Colaborador Asignado',
                value: _colaboradorAsignado,
                onTap: _mostrarModalColaborador,
              ),

              const SizedBox(height: 12),

              // Mesas Asociadas
              _buildConfigurationTile(
                icon: Icons.view_list,
                title: 'Mesas Asociadas',
                value: _mesasAsociadas,
                onTap: _mostrarModalMesasAsociadas,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigurationTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Configurar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 28),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: AppColors.grey600, fontSize: 14),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.grey500,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
