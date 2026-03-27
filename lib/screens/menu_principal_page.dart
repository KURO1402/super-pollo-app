import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/services/listar_pedidos_service.dart';
import 'package:super_pollo_app/models/listar_pedidos_model.dart';
import 'package:super_pollo_app/utils/notificaciones_state.dart';
import 'package:super_pollo_app/widgets/pedidos_widget.dart';
import '../utils/token_storage.dart';

class MenuPrincipalPage extends StatefulWidget {
  const MenuPrincipalPage({super.key});

  @override
  State<MenuPrincipalPage> createState() => _MenuPrincipalPageState();
}

class _MenuPrincipalPageState extends State<MenuPrincipalPage> {
  String mensaje = "Esperando datos ...";
  String nombre = "";
  String apellido = "";
  List<Pedido> _recentOrders = [];
  bool _isLoadingOrders = false;
  final NotificacionesState _notifState = NotificacionesState();

  @override
  void initState() {
    super.initState();
    _notifState.addListener(_actualizarConteo);
    _cargarPedidosRecientes();
  }

  /// Carga los pedidos recientes desde el backend
  void _cargarPedidosRecientes() async {
    setState(() {
      _isLoadingOrders = true;
    });

    try {
      final ahora = DateTime.now();
      final fecha =
          '${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}';
      final hora =
          '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';

      final response = await PedidosService.listarPedidos(
        fecha: fecha,
        hora: hora,
      );

      if (mounted) {
        setState(() {
          if (response.ok) {
            // Tomar solo los primeros 3 pedidos para "recientes"
            _recentOrders = response.pedidos.take(3).toList();
          }
          _isLoadingOrders = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingOrders = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _notifState.removeListener(_actualizarConteo);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  void _actualizarConteo() {
    setState(() {});
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

  void _showOrderDetails(Pedido pedido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsModal(pedido: pedido),
    );
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
          Row(
            children: [
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
                      child: Text(
                        '${_notifState.conteo}',
                        style: const TextStyle(
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
                onTap: () {},
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
        Navigator.pop(context);
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
    if (_isLoadingOrders) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No hay pedidos disponibles',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < _recentOrders.length; i++)
          Column(
            children: [
              OrderCardWidget(
                pedido: _recentOrders[i],
                onTap: () => _showOrderDetails(_recentOrders[i]),
              ),
              if (i < _recentOrders.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                ),
            ],
          ),
      ],
    );
  }
}
