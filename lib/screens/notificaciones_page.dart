// Esta es la parte de login
import 'package:flutter/material.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPage();
}

class _NotificacionesPage extends State<NotificacionesPage> {
  int _selectedFilter = 0; // 0: Todas, 1: Pedidos, 2: Pagados

  // Datos de ejemplo para las notificaciones
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Nuevo Pedido - Mesa 4',
      'time': 'Hace 2 min',
      'type': 'pedido',
      'content': '4 items : 2x 1/4 de Pollo a la Brasa, 2x Gaseosas Personales.',
      'note': 'Nota: Gaseosas heladas.',
      'action': 'Ver Detalles',
      'color': Colors.blue,
    },
    {
      'title': 'Pago Confirmado - Mesa 03',
      'time': 'Hoy a las 20:30 PM',
      'type': 'pago',
      'content': 'Pago de S/24.00 recibido exitosamente vía Yape',
      'note': '',
      'action': 'Ver Recibo',
      'color': Colors.green,
    },
    {
      'title': 'Retraso en Cocina - Mesa 10',
      'time': 'Hace 12 min',
      'type': 'retraso',
      'content': '4 items : 2x 1/4 de Pollo a la Brasa, 2x Gaseosas Personales.',
      'note': 'Nota: Gaseosas heladas.',
      'action': 'Ver Detalles',
      'color': Colors.orange,
    },
  ];

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
          'Notificaciones',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Acción para limpiar todo
            },
            child: const Text(
              'Limpiar todo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              // Filtros
              Row(
                children: [
                  _buildFilterButton('Todas', 0),
                  const SizedBox(width: 12),
                  _buildFilterButton('Pedidos', 1),
                  const SizedBox(width: 12),
                  _buildFilterButton('Pagados', 2),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Línea separadora
              Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
              
              const SizedBox(height: 16),
              
              // Sección Hoy
              const Text(
                'Hoy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Línea separadora debajo de Hoy
              Container(
                height: 1,
                color: Colors.grey.shade300,
              ),
              
              const SizedBox(height: 16),
              
              // Lista de notificaciones
              Column(
                children: _notifications.map((notification) {
                  return Column(
                    children: [
                      _buildNotificationCard(notification),
                      if (_notifications.indexOf(notification) < _notifications.length - 1)
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
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget para botones de filtro
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
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Widget para tarjeta de notificación
  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y tiempo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  notification['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                notification['time'],
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Contenido
          Text(
            notification['content'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),
          
          // Nota (si existe)
          if (notification['note'].isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              notification['note'],
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade700,
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Botón de acción
          Container(
            width: double.infinity,
            height: 36,
            decoration: BoxDecoration(
              color: notification['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: notification['color'],
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                notification['action'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: notification['color'],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}