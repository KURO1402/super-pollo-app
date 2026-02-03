// Esta es la parte de login
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PedidoMesasPage extends StatefulWidget {
  const PedidoMesasPage({super.key});

  @override
  State<PedidoMesasPage> createState() => _PedidoMesasPage();
}

class _PedidoMesasPage extends State<PedidoMesasPage> {

  int _selectedFilter = 0; // 0: Todas, 1: Libres, 2: Ocupadas
  int? _selectedTable; // null: ninguna seleccionada, 1-6: mesa seleccionada

  // Datos de ejemplo para las mesas
  final List<Map<String, dynamic>> _tables = [
    {'id': 1, 'name': 'Mesa 1', 'capacity': 4, 'status': 'libre'},
    {'id': 2, 'name': 'Mesa 2', 'capacity': 4, 'status': 'libre'},
    {'id': 3, 'name': 'Mesa 3', 'capacity': 4, 'status': 'ocupada'},
    {'id': 4, 'name': 'Mesa 4', 'capacity': 4, 'status': 'libre'},
    {'id': 5, 'name': 'Mesa 5', 'capacity': 4, 'status': 'ocupada'},
    {'id': 6, 'name': 'Mesa 6', 'capacity': 4, 'status': 'libre'},
  ];

  // Filtrar mesas según el filtro seleccionado
  List<Map<String, dynamic>> get _filteredTables {
    if (_selectedFilter == 0) return _tables; // Todas
    if (_selectedFilter == 1) {
      return _tables.where((table) => table['status'] == 'libre').toList(); // Libres
    }
    return _tables.where((table) => table['status'] == 'ocupada').toList(); // Ocupadas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () {
            // Acción para retroceder
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Nuevo Pedido',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Subtítulo "Seleccione una mesa"
            const Text(
              'Seleccione una mesa',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Sala Principal (preseleccionada)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sala Principal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                    size: 20,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Filtros
            const Text(
              'Todas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Botones de filtro
            Row(
              children: [
                _buildFilterButton('Todas', 0),
                const SizedBox(width: 12),
                _buildFilterButton('Libres', 1),
                const SizedBox(width: 12),
                _buildFilterButton('Ocupadas', 2),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Listado de mesas
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: _filteredTables.length,
                itemBuilder: (context, index) {
                  final table = _filteredTables[index];
                  final isSelected = _selectedTable == table['id'];
                  final isOccupied = table['status'] == 'ocupada';
                  
                  return GestureDetector(
                    onTap: isOccupied ? null : () {
                      setState(() {
                        _selectedTable = table['id'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isOccupied 
                          ? Colors.grey.shade200 
                          : (isSelected ? Colors.blue.withOpacity(0.1) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isOccupied 
                            ? Colors.grey.shade400 
                            : (isSelected ? Colors.blue : Colors.grey.shade300),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            table['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isOccupied ? Colors.grey.shade600 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${table['capacity']} Personas',
                            style: TextStyle(
                              fontSize: 14,
                              color: isOccupied ? Colors.grey.shade600 : Colors.grey.shade700,
                            ),
                          ),
                          if (isOccupied) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Ocupada',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botón Continuar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedTable == null ? null : () {
                  context.go("/pedido_menu");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedTable == null ? Colors.grey : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
Widget _buildFilterButton(String text, int index) {
    final isSelected = _selectedFilter == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
