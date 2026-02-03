import 'package:flutter/material.dart';

class GestionPedidosPage extends StatefulWidget {
  const GestionPedidosPage({super.key});

  @override
  State<GestionPedidosPage> createState() => _GestionPedidosPageState();
}

class _GestionPedidosPageState extends State<GestionPedidosPage> {
  int _selectedTab = 0; // 0: Todos, 1: Pendientes

  // Datos de ejemplo para los pedidos
  final List<Map<String, dynamic>> _orders = [
    {
      'table': '04',
      'status': 'pendiente',
      'total': 'S/ 45.50',
      'items': 4,
      'time': '2 min',
      'priority': 2,
      'statusColor': Colors.orange,
      'waiter': 'Juan Perez',
      'orderDetails': [
        {
          'name': '1/4 de Pollo a la Brasa',
          'description': 'Sin ensalada',
          'price': 'S/ 28.00',
        },
        {
          'name': 'Gaseosa Inka Kola Personal',
          'description': 'Helada',
          'price': 'S/ 4.00',
        },
        {
          'name': 'Porción de Papas',
          'description': '',
          'price': 'S/ 6.00',
        },
        {
          'name': 'Porción de Ensalada',
          'description': '',
          'price': 'S/ 6.00',
        },
      ],
      'subtotal': 'S/ 44.00',
      'total': 'S/ 42.00',
    },
    {
      'table': '12',
      'status': 'entregado',
      'total': 'S/ 14.00',
      'items': 1,
      'time': '12 min',
      'priority': 0,
      'statusColor': Colors.green,
      'waiter': 'Maria Rodriguez',
      'orderDetails': [
        {
          'name': '1/4 de Pollo a la Brasa',
          'description': 'Con ensalada',
          'price': 'S/ 14.00',
        },
      ],
      'subtotal': 'S/ 14.00',
      'total': 'S/ 14.00',
    },
    {
      'table': '12',
      'status': 'pendiente',
      'total': 'S/ 16.00',
      'items': 2,
      'time': '5 min',
      'priority': 0,
      'statusColor': Colors.orange,
      'waiter': 'Carlos Gomez',
      'orderDetails': [
        {
          'name': '1/2 Pollo a la Brasa',
          'description': 'Con papas fritas',
          'price': 'S/ 24.00',
        },
        {
          'name': 'Gaseosa Personal',
          'description': '',
          'price': 'S/ 3.00',
        },
      ],
      'subtotal': 'S/ 27.00',
      'total': 'S/ 27.00',
    },
  ];

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOrderDetailsModal(order),
    );
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
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Gestión de Pedidos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              // Pestañas Todos | Pendientes
              Row(
                children: [
                  _buildOrderTab('Todos', 0),
                  const SizedBox(width: 16),
                  _buildOrderTab('Pendientes', 1),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Lista de pedidos
              Column(
                children: _orders.map((order) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () => _showOrderDetails(context, order),
                        child: _buildOrderCard(order),
                      ),
                      if (_orders.indexOf(order) < _orders.length - 1)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            height: 1,
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget para pestañas
  Widget _buildOrderTab(String text, int index) {
    final isSelected = _selectedTab == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          height: 40,
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
  
  // Widget para tarjeta de pedido
  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna izquierda: Información principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mesa
                  Text(
                    'Mesa ${order['table']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Estado
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: order['statusColor'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order['status'].toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: order['statusColor'],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Total y items
                  Row(
                    children: [
                      Text(
                        order['total'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${order['items']} ${order['items'] == 1 ? 'item' : 'items'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Columna derecha: Tiempo y prioridad
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Tiempo
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order['time'],
                      style: TextStyle(
                        fontSize: 14,
                        color: order['status'] == 'entregado' 
                            ? Colors.green 
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Indicador de prioridad (solo para algunos pedidos)
                if (order['priority'] > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.priority_high,
                          size: 12,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${order['priority']} más',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Modal/BottomSheet para detalles del pedido
  Widget _buildOrderDetailsModal(Map<String, dynamic> order) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicador de arrastre
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Título: Mesa
                  Text(
                    'Mesa ${order['table']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Mesero
                  Text(
                    'Mesero: ${order['waiter']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Estado Pending
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange, width: 1),
                    ),
                    child: const Text(
                      'PENDIENTE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Lista de productos
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var item in order['orderDetails'])
                        Column(
                          children: [
                            _buildOrderItem(item),
                            const SizedBox(height: 16),
                          ],
                        ),
                    ],
                  ),
                  
                  // Línea separadora
                  const Divider(
                    height: 1,
                    color: Color(0xFFE0E0E0),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Subtotal y Total
                  Column(
                    children: [
                      // Subtotal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            order['subtotal'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Total
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              order['total'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Botones de acción
                  Row(
                    children: [
                      // Botón + Productos
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Acción para agregar productos
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue, width: 1.5),
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Productos',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Botón Editar
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Acción para editar
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Editar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget para item del pedido en el modal
  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['name'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        if (item['description'].isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            item['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
        
        const SizedBox(height: 8),
        
        Text(
          item['price'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}