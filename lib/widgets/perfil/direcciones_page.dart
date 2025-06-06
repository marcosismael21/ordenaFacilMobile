import 'package:flutter/material.dart';
import '../../models/direccion.dart';
import '../../services/direccion_service.dart';
import '../../services/auth_service.dart';

class DireccionesPage extends StatefulWidget {
  const DireccionesPage({Key? key}) : super(key: key);

  @override
  State<DireccionesPage> createState() => _DireccionesPageState();
}

class _DireccionesPageState extends State<DireccionesPage> {
  final DireccionService _direccionService = DireccionService();
  final AuthService _authService = AuthService();
  List<Direccion> _direcciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDirecciones();
  }

  Future<void> _cargarDirecciones() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final direcciones = await _direccionService.getDireccionesByCliente();
      setState(() {
        _direcciones = direcciones;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar direcciones: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminarDireccion(Direccion direccion) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _direccionService.eliminarDireccion(direccion.id!);
      
      if (success) {
        await _cargarDirecciones();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dirección eliminada con éxito'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar la dirección'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Direcciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDirecciones,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _direcciones.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _direcciones.length,
                  itemBuilder: (context, index) {
                    final direccion = _direcciones[index];
                    return _buildDireccionCard(direccion);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioDireccion(null),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes direcciones guardadas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega una dirección para facilitar tus pedidos',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _mostrarFormularioDireccion(null),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Dirección'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDireccionCard(Direccion direccion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    direccion.alias,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _mostrarFormularioDireccion(direccion);
                    } else if (value == 'delete') {
                      _mostrarDialogoEliminar(direccion);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 4),
            Text(
              direccion.descripcion,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoEliminar(Direccion direccion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Dirección'),
          content: Text('¿Estás seguro que deseas eliminar la dirección "${direccion.alias}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _eliminarDireccion(direccion);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarFormularioDireccion(Direccion? direccion) async {
    // Si es null, estamos creando una nueva dirección, sino estamos editando
    final esEdicion = direccion != null;
    
    final _aliasController = TextEditingController(text: direccion?.alias ?? '');
    final _descripcionController = TextEditingController(text: direccion?.descripcion ?? '');
    final _formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(esEdicion ? 'Editar Dirección' : 'Agregar Dirección'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _aliasController,
                    decoration: const InputDecoration(
                      labelText: 'Alias (ej. Casa, Trabajo)',
                      prefixIcon: Icon(Icons.label),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un alias';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección Completa',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la dirección';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(esEdicion ? 'Actualizar' : 'Guardar'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final clienteId = await _authService.getUserId();
        if (clienteId == null) {
          throw Exception('No se pudo obtener el ID del cliente');
        }

        if (esEdicion) {
          // Actualizar dirección existente
          final direccionActualizada = Direccion(
            id: direccion.id,
            clienteId: direccion.clienteId,
            alias: _aliasController.text,
            descripcion: _descripcionController.text,
            estado: direccion.estado,
          );

          final success = await _direccionService.actualizarDireccion(direccionActualizada);
          
          if (success) {
            await _cargarDirecciones();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dirección actualizada con éxito'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            setState(() {
              _isLoading = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error al actualizar la dirección'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          // Crear nueva dirección
          final nuevaDireccion = Direccion(
            clienteId: clienteId,
            alias: _aliasController.text,
            descripcion: _descripcionController.text,
          );

          final success = await _direccionService.crearDireccion(nuevaDireccion);
          
          if (success) {
            await _cargarDirecciones();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dirección agregada con éxito'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            setState(() {
              _isLoading = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error al agregar la dirección'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // Limpiar controladores
    _aliasController.dispose();
    _descripcionController.dispose();
  }
}