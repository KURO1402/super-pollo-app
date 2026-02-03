// Esta es la parte de login
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PedidoMenuPage extends StatefulWidget {
  const PedidoMenuPage({super.key});

  @override
  State<PedidoMenuPage> createState() => _PedidoMenuPage();
}

class _PedidoMenuPage extends State<PedidoMenuPage> {
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
          onPressed: () {},
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
      body: Column(
        children: [
          // Barra de menú
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Pestaña Mesas
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.transparent, width: 2),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Mesas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Pestaña Menú (seleccionada)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Menú',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Pestaña Confirmar
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.transparent, width: 2),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Campo de búsqueda
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 16),
                        Icon(Icons.search, color: Colors.grey, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Buscar platillo...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Título "Todas"
                  const Text(
                    'Todas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Botones de categoría
                  Row(
                    children: [
                      // Botón Todas (seleccionado)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue, width: 1.5),
                          ),
                          child: const Center(
                            child: Text(
                              'Todas',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Botón Pollos
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.transparent, width: 1.5),
                          ),
                          child: const Center(
                            child: Text(
                              'Pollos',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Botón Porciones
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.transparent, width: 1.5),
                          ),
                          child: const Center(
                            child: Text(
                              'Porciones',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Línea separadora
                  Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Lista de platillos
                  Expanded(
                    child: ListView(
                      children: const [
                        // Item 1
                        MenuItemWidget(
                          itemName: '1/4 de Pollo a la Brasa',
                          description: 'Pollo + papas fritas + ensalada ...',
                          price: 'S/ 14.00',
                          quantity: 2,
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Item 2
                        MenuItemWidget(
                          itemName: '1/4 de Pollo a la Brasa',
                          description: 'Pollo + papas fritas + ensalada ...',
                          price: 'S/ 14.00',
                          quantity: 1,
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Item 3
                        MenuItemWidget(
                          itemName: '1/4 de Pollo a la Brasa',
                          description: 'Pollo + papas fritas + ensalada ...',
                          price: 'S/ 14.00',
                          quantity: 1,
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Item 4
                        MenuItemWidget(
                          itemName: '1/4 de Pollo a la Brasa',
                          description: 'Pollo + papas fritas + ensalada ...',
                          price: 'S/ 14.00',
                          quantity: 1,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Resumen del pedido
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Total
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total (3 items)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'S/ 24.00',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.go("/pedido_resumen");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
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
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para los items del menú
class MenuItemWidget extends StatelessWidget {
  final String itemName;
  final String description;
  final String price;
  final int quantity;
  
  const MenuItemWidget({
    super.key,
    required this.itemName,
    required this.description,
    required this.price,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del platillo
          Text(
            itemName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Descripción
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Precio y contador
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Precio
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              // Contador
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Row(
                  children: [
                    // Botón menos
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '-',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    
                    // Cantidad
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    
                    // Botón más
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}