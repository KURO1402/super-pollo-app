import 'package:flutter/material.dart';

class CategoriaButtonWidget extends StatelessWidget {
  final String nombre;
  final bool seleccionado;
  final VoidCallback onTap;

  const CategoriaButtonWidget({
    super.key,
    required this.nombre,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: seleccionado ? Colors.blue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: seleccionado ? Colors.blue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            nombre,
            style: TextStyle(
              color: seleccionado ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
