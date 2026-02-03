// Esta es la parte de login
import 'package:flutter/material.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPage();
}

class _ConfiguracionPage extends State<ConfiguracionPage> {

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  
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
          'Configuración',
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
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Carlos Rodríguez',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Administrador',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                'Información Personal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Column(
                  children: [
                    _buildInfoField(
                      label: 'Nombres',
                      value: 'Carlos Roberto',
                    ),
                    
                    Container(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    
                    _buildInfoField(
                      label: 'Apellidos',
                      value: 'Rodríguez Casas',
                    ),
                    
                    Container(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    
                    _buildInfoField(
                      label: 'Correo Electrónico',
                      value: 'carlosrodriguez@gmail.com',
                    ),
                    
                    Container(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    
                    _buildInfoField(
                      label: 'Teléfono',
                      value: '+51 989 765 432',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                'Preferencia y Seguridad',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Column(
                  children: [
                    _buildPreferenceItem(
                      icon: Icons.lock,
                      text: 'Cambiar Contraseña',
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ),
                    
                    Container(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    
                    _buildPreferenceItem(
                      icon: Icons.notifications,
                      text: 'Notificaciones',
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                        activeColor: Colors.blue,
                      ),
                    ),
                    
                    Container(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    
                    _buildPreferenceItem(
                      icon: Icons.dark_mode,
                      text: 'Modo Oscuro',
                      trailing: Switch(
                        value: _darkModeEnabled,
                        onChanged: (value) {
                          setState(() {
                            _darkModeEnabled = value;
                          });
                        },
                        activeColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red, width: 1.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Center(
                child: Text(
                  'versión 1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoField({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget para items de preferencias
  Widget _buildPreferenceItem({
    required IconData icon,
    required String text,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}