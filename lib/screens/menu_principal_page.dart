import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/token_storage.dart';

class MenuPrincipalPage extends StatefulWidget {
  const MenuPrincipalPage({super.key});

  @override
  State<MenuPrincipalPage> createState() => _MenuPrincipalPageState();
}

class _MenuPrincipalPageState extends State<MenuPrincipalPage> {
  String nombre = "";
  String apellido = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  void _loadUserData() {
    final data = GoRouterState.of(context).extra as Map?;
    if (data != null) {
      setState(() {
        nombre = data["nombre"] ?? "";
        apellido = data["apellido"] ?? "";
      });
    }
  }

  Future<void> _logout() async {
    await TokenStorage.clearToken();
    if (!mounted) return;
    context.go("/");
  }

  void _navigateTo(String route) {
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderWithMenuAndUser(),
              const SizedBox(height: 24),
              _buildStatisticsCards(),
              const SizedBox(height: 24),
              _buildQuickActionsTitle(),
              const SizedBox(height: 16),
              _buildQuickActionsButtons(),
              const SizedBox(height: 32),
              _buildRecentOrdersHeader(),
              const SizedBox(height: 16),
              _buildRecentOrdersList(),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== WIDGETS SECCIONADOS ====================

  Widget _buildHeaderWithMenuAndUser() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón de menú (hamburguesa) a la izquierda
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.blue, size: 26),
              onPressed: _showLeftMenu,
            ),
          ),

          const Spacer(),

          // Usuario y notificaciones juntos a la derecha
          Row(
            children: [
              // Información del usuario
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "$nombre $apellido".trim().isEmpty
                        ? "Usuario"
                        : "$nombre $apellido",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "En línea",
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 8),

              // Avatar del usuario
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue, size: 20),
                ),
              ),

              const SizedBox(width: 8),

              // Notificaciones al lado del usuario
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.blue,
                      size: 26,
                    ),
                    onPressed: () => context.push("/notificaciones"),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Menú que se desliza desde la izquierda ocupando la mitad de la pantalla
  void _showLeftMenu() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {}, // Evita que se cierre al tocar el menú
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: -1.0, end: 0.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(
                        MediaQuery.of(context).size.width * value,
                        0,
                      ),
                      child: child,
                    );
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(2, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header del menú
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade700,
                                  Colors.blue.shade500,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Menú',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.blue,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "$nombre $apellido".trim().isEmpty
                                                ? "Usuario"
                                                : "$nombre $apellido",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'Administrador',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
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
                          ),

                          // Opciones del menú
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              children: [
                                _buildMenuItem(
                                  icon: Icons.dashboard,
                                  label: 'Dashboard',
                                  color: Colors.blue,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _navigateTo("/menu_principal");
                                  },
                                ),
                                _buildMenuItem(
                                  icon: Icons.table_restaurant,
                                  label: 'Gestión de Mesas',
                                  color: Colors.green,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _navigateTo("/gestion_mesas");
                                  },
                                ),
                                _buildMenuItem(
                                  icon: Icons.shopping_cart,
                                  label: 'Pedidos',
                                  color: Colors.orange,
                                  badge: '5',
                                  onTap: () {
                                    Navigator.pop(context);
                                    _navigateTo("/gestion_pedidos");
                                  },
                                ),
                                _buildMenuItem(
                                  icon: Icons.bar_chart,
                                  label: 'Reportes',
                                  color: Colors.purple,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _navigateTo("/reportes");
                                  },
                                ),
                                _buildMenuItem(
                                  icon: Icons.settings,
                                  label: 'Configuración',
                                  color: Colors.grey[700]!,
                                  onTap: () {
                                    Navigator.pop(context);
                                    context.push("/configuracion");
                                  },
                                ),

                                const Divider(
                                  height: 32,
                                  indent: 16,
                                  endIndent: 16,
                                ),

                                // Opción de cerrar sesión
                                _buildMenuItem(
                                  icon: Icons.logout,
                                  label: 'Cerrar Sesión',
                                  color: Colors.red,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _logout();
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Footer del menú
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              border: Border(
                                top: BorderSide(color: Colors.grey[200]!),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildFooterIcon(Icons.help_outline, 'Ayuda'),
                                _buildFooterIcon(
                                  Icons.info_outline,
                                  'Acerca de',
                                ),
                                _buildFooterIcon(Icons.policy, 'Términos'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
    String? badge,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Icon(
              Icons.arrow_forward_ios,
              color: color.withOpacity(0.4),
              size: 14,
            ),
      onTap: onTap,
    );
  }

  Widget _buildFooterIcon(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        // Aquí puedes agregar acciones para cada opción del footer
        Navigator.pop(context);
        // _navigateTo("/ayuda"); etc.
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey[600], size: 18),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatisticCard(
            icon: Icons.table_restaurant,
            iconColor: Colors.green,
            label: 'Mesas Activas',
            value: '8',
            trend: '+2',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatisticCard(
            icon: Icons.attach_money,
            iconColor: Colors.blue,
            label: 'Ventas Hoy',
            value: 'S/ 1,240',
            trend: '+15%',
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Colors.green,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        'Acciones Rápidas',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildQuickActionsButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.add_circle,
            iconColor: Colors.blue,
            label: 'Nuevo Pedido',
            subtitle: 'Crear pedido',
            onTap: () => context.push("/pedido_mesas"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.table_chart,
            iconColor: Colors.green,
            label: 'Ver Mesas',
            subtitle: 'Gestionar mesas',
            onTap: () => context.push("/gestion_mesas"),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrdersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Pedidos Recientes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        TextButton(
          onPressed: () => _navigateTo("/gestion_pedidos"),
          style: TextButton.styleFrom(foregroundColor: Colors.blue),
          child: const Row(
            children: [
              Text('Ver todos'),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersList() {
    return Column(
      children: [
        _buildOrderItem(
          tableNumber: 'M5',
          tableName: 'Mesa 5',
          items: '3 items',
          time: 'Hace 5 min',
          amount: 'S/ 45.00',
          status: 'En preparación',
        ),
        const SizedBox(height: 12),
        _buildOrderItem(
          tableNumber: 'M1',
          tableName: 'Mesa 1',
          items: '2 items',
          time: 'Hace 3 min',
          amount: 'S/ 24.00',
          status: 'Entregado',
        ),
        const SizedBox(height: 12),
        _buildOrderItem(
          tableNumber: 'M8',
          tableName: 'Mesa 8',
          items: '5 items',
          time: 'Hace 7 min',
          amount: 'S/ 76.00',
          status: 'Pendiente',
        ),
      ],
    );
  }

  Widget _buildOrderItem({
    required String tableNumber,
    required String tableName,
    required String items,
    required String time,
    required String amount,
    required String status,
  }) {
    Color getStatusColor() {
      switch (status) {
        case 'En preparación':
          return Colors.orange;
        case 'Entregado':
          return Colors.green;
        case 'Pendiente':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Número de mesa con diseño mejorado
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                tableNumber,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Información del pedido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tableName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          color: getStatusColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      items,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),

          // Monto
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.blue,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
