import 'package:flutter/material.dart';

class InputPersonalizado extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool
  isPassword; // Nuevo parámetro para controlar si es un campo de contraseña

  const InputPersonalizado({
    Key? key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.isPassword = false, // Por defecto no es un campo de contraseña
  }) : super(key: key);

  @override
  _InputPersonalizadoState createState() => _InputPersonalizadoState();
}

class _InputPersonalizadoState extends State<InputPersonalizado> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 1),
        Stack(
          children: [
            TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: _obscureText,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: Colors.grey),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: const Color(
                      0xFF0F6BFF,
                    ), // Color del borde al enfocar
                    width: 2.0, // Grosor del borde
                  ),
                ),
                contentPadding: EdgeInsets.only(
                  left: 7,
                  bottom: -16,
                ), // Ajuste del padding
                alignLabelWithHint: true,
              ),
            ),
            // Mostrar el ícono solo si es un campo de contraseña
            if (widget.isPassword)
              Positioned(
                right: 0, // Alinea el ícono a la derecha
                top: 10, // Posición vertical
                bottom: 0, // Alineación vertical
                child: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}
