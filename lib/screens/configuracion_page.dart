import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/services/usuario_service.dart';
import 'package:super_pollo_app/models/usuario_detail_model.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  late Future<UsuarioDetailModel> _usuario;

  @override
  void initState() {
    super.initState();
    _usuario = UsuarioService().obtenerUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Gris muy suave estilo minimalista
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => GoRouter.of(context).canPop() ? GoRouter.of(context).pop() : GoRouter.of(context).go('/'),
        ),
        title: const Text(
          'Configuración',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<UsuarioDetailModel>(
        future: _usuario,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final usuario = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(usuario),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Información Personal'),
                  _buildInfoCard([
                    _buildInfoField('Nombres', usuario.nombreUsuario),
                    _buildInfoField('Apellidos', usuario.apellidoUsuario),
                    _buildInfoField('Correo', usuario.correoUsuario),
                    _buildInfoField('Teléfono', usuario.telefonoUsuario),
                  ]),
                  
                  const SizedBox(height: 32),
                  _buildSectionTitle('Historial de Roles'),
                  _buildRolesList(usuario.roles),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Preferencias'),
                  _buildInfoCard([
                    _buildPreferenceItem(
                      icon: Icons.notifications_none_rounded,
                      text: 'Notificaciones',
                      trailing: Switch.adaptive(
                        value: _notificationsEnabled,
                        activeColor: Colors.blue,
                        onChanged: (v) => setState(() => _notificationsEnabled = v),
                      ),
                    ),
                    _buildPreferenceItem(
                      icon: Icons.dark_mode_outlined,
                      text: 'Modo Oscuro',
                      trailing: Switch.adaptive(
                        value: _darkModeEnabled,
                        activeColor: Colors.blue,
                        onChanged: (v) => setState(() => _darkModeEnabled = v),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return const Center(child: Text('No hay datos'));
        },
      ),
    );
  }

  // --- COMPONENTES CON ESTILO MEJORADO ---

  Widget _buildHeader(UsuarioDetailModel usuario) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue.shade50,
                child: const Icon(Icons.person_rounded, size: 50, color: Colors.blue),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  child: const Icon(Icons.verified_user, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${usuario.nombreUsuario} ${usuario.apellidoUsuario}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            usuario.nombreRol.toUpperCase(),
            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildRolesList(List<RolModel> roles) {
    if (roles.isEmpty) return const Text('Sin historial');

    return Column(
      children: roles.map((rol) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.work_outline_rounded, color: Colors.blue),
            ),
            title: Text(rol.nombreRol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  _buildDateBadge(rol.fechaInicio, Colors.green),
                  const Icon(Icons.arrow_right_alt, size: 16, color: Colors.grey),
                  _buildDateBadge(rol.fechaFin, Colors.orange),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateBadge(String date, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(
        date,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPreferenceItem({required IconData icon, required String text, required Widget trailing}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700, size: 22),
      title: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: trailing,
    );
  }
}