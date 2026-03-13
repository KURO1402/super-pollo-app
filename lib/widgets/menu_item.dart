import 'package:flutter/material.dart';

class MenuItemWidget extends StatelessWidget {
  final String itemName;
  final String description;
  final String price;
  final int quantity;
  final List<String> images;
  final VoidCallback onIncrementar;
  final VoidCallback onDecrementar;

  const MenuItemWidget({
    super.key,
    required this.itemName,
    required this.description,
    required this.price,
    required this.quantity,
    required this.images,
    required this.onIncrementar,
    required this.onDecrementar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: images.isNotEmpty
                ? Image.network(
                    images[0],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : Container(width: 70, height: 70, color: Colors.grey[200]),
          ),
          const SizedBox(width: 12),

          // 2. Información del Producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
          ),

          // 3. Contador con callbacks
          _buildCounter(),
        ],
      ),
    );
  }

  Widget _buildCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onDecrementar, // ← conectado
            child: _buildActionButton(Icons.remove, isPrimary: false),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: onIncrementar, // ← conectado
            child: _buildActionButton(Icons.add, isPrimary: true),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, {required bool isPrimary}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF2196F3) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          if (!isPrimary)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Icon(
        icon,
        size: 18,
        color: isPrimary ? Colors.white : const Color(0xFF2196F3),
      ),
    );
  }
}