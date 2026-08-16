import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/models/listar_pedidos_model.dart';
import 'package:super_pollo_app/utils/notificaciones_state.dart';
import 'package:super_pollo_app/utils/pedidos_state.dart';
import 'package:super_pollo_app/state/estadisticas_state.dart';
import 'package:super_pollo_app/widgets/pedidos_widget.dart';
import 'package:super_pollo_app/theme/app_colors.dart';
import '../utils/token_storage.dart';
import 'package:pusher_beams/pusher_beams.dart';
import 'package:permission_handler/permission_handler.dart';

class MenuPrincipalPage extends StatefulWidget {
  const MenuPrincipalPage({super.key});

  @override
  State<MenuPrincipalPage> createState() => _MenuPrincipalPageState();
}

class _MenuPrincipalPageState extends State<MenuPrincipalPage> {
  String nombre = "";
  String apellido = "";
  final PedidosState _pedidosState = PedidosState();
  final NotificacionesState _notifState = NotificacionesState();
  final EstadisticasState _estadisticasState = EstadisticasState();
  Timer? _timerEstadisticas;

  @override
  void initState() {
    super.initState();
    _notifState.addListener(_actualizar);
    _pedidosState.addListener(_actualizar);
    _estadisticasState.addListener(_actualizar);
    _pedidosState.cargar();
    _estadisticasState.cargar();
    _suscribirNotificacionesPush();

    // Refresca las estadísticas cada 30 segundos mientras la pantalla esté activa
    _timerEstadisticas = Timer.periodic(const Duration(seconds: 30), (_) {
      _estadisticasState.cargar();
    });
  }

  @override
  void dispose() {
    _notifState.removeListener(_actualizar);
    _pedidosState.removeListener(_actualizar);
    _estadisticasState.removeListener(_actualizar);
    _timerEstadisticas?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  void _actualizar() => setState(() {});

  void _loadUserData() {
    final data = GoRouterState.of(context).extra as Map?;
    if (data != null) {
      setState(() {
        nombre = data["nombre"] ?? "";
        apellido = data["apellido"] ?? "";
      });
    }
  }

  Future<void> _suscribirNotificacionesPush() async {
    final status = await Permission.notification.request();
    if (!status.isGranted) {
      print('Permiso de notificaciones no concedido');
      return;
    }

    try {
      await PusherBeams.instance.addDeviceInterest('pedidos');
    } catch (e) {
      print('Error al suscribir notificaciones push: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await PusherBeams.instance.removeDeviceInterest('pedidos');
    } catch (e) {
      print('Error al desuscribir notificaciones push: $e');
    }
    await TokenStorage.clearTokens();
    if (!mounted) return;
    context.go("/");
  }

  void _navigateTo(String route) => context.go(route);

  void _showOrderDetails(Pedido pedido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsModal(
        pedido: pedido,
        onEditarPedido: () => context.push('/editar_pedido', extra: pedido),
        onPedidoCancelado: () => _pedidosState.cargar(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              _pedidosState.cargar(),
              _estadisticasState.cargar(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderWithMenuAndUser(),
                const SizedBox(height: 24),
                _buildStatisticsCards(),
                const SizedBox(height: 24),
                _buildSectionTitle('Acciones Rápidas'),
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
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeaderWithMenuAndUser() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.navyCard : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.menu, color: colorScheme.primary, size: 26),
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("En línea",
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
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
                  gradient: AppColors.flameGradientLight,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: cardColor,
                  child:
                      Icon(Icons.person, color: colorScheme.primary, size: 20),
                ),
              ),
              const SizedBox(width: 4),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_outlined,
                        color: colorScheme.primary, size: 26),
                    onPressed: () => context.push("/notificaciones"),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                          color: AppColors.error, shape: BoxShape.circle),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${_notifState.conteo}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
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

  // ── Menú lateral ─────────────────────────────────────────────────────────────
  void _showLeftMenu() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.navyCard : Colors.white;
    final footerColor = isDark ? AppColors.navyLight : const Color(0xFFF9F9F9);
    final borderColor = isDark ? AppColors.navyLight : AppColors.grey100;

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
                  builder: (context, value, child) => Transform.translate(
                    offset:
                        Offset(MediaQuery.of(context).size.width * value, 0),
                    child: child,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: cardColor,
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(2, 0))
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header con gradiente de marca
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: isDark
                                  ? AppColors.flameGradientDark
                                  : AppColors.flameGradientLight,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Menú',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.white),
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
                                      child: Icon(Icons.person,
                                          color: AppColors.brandRed, size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "$nombre $apellido"
                                                    .trim()
                                                    .isEmpty
                                                ? "Usuario"
                                                : "$nombre $apellido",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text('Administrador',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Items
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              children: [
                                _buildMenuItem(
                                  icon: Icons.dashboard,
                                  label: 'Dashboard',
                                  color: colorScheme.primary,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _navigateTo("/menu_principal");
                                  },
                                ),
                                _buildMenuItem(
                                  icon: Icons.table_restaurant,
                                  label: 'Gestión de Mesas',
                                  color: AppColors.success,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _navigateTo("/gestion_mesas");
                                  },
                                ),
                                _buildMenuItem(
                                  icon: Icons.shopping_cart,
                                  label: 'Pedidos',
                                  color: AppColors.brandOrange,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _navigateTo("/gestion_pedidos");
                                  },
                                ),
                                _buildMenuItem(
                                  icon: Icons.settings,
                                  label: 'Configuración',
                                  color: AppColors.grey500,
                                  onTap: () {
                                    Navigator.pop(context);
                                    context.push("/configuracion");
                                  },
                                ),
                                Divider(
                                    height: 32,
                                    indent: 16,
                                    endIndent: 16,
                                    color: borderColor),
                                _buildMenuItem(
                                  icon: Icons.logout,
                                  label: 'Cerrar Sesión',
                                  color: AppColors.error,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _logout();
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Footer
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: footerColor,
                              border:
                                  Border(top: BorderSide(color: borderColor)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildFooterIcon(Icons.help_outline, 'Ayuda'),
                                _buildFooterIcon(
                                    Icons.info_outline, 'Acerca de'),
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
      title: Text(label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w500, fontSize: 15)),
      trailing: badge != null
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(badge,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            )
          : Icon(Icons.arrow_forward_ios,
              color: color.withOpacity(0.4), size: 14),
      onTap: onTap,
    );
  }

  Widget _buildFooterIcon(IconData icon, String label) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.grey500, size: 18),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(color: AppColors.grey500, fontSize: 10)),
        ],
      ),
    );
  }

  // ── Estadísticas ──────────────────────────────────────────────────────────────
  Widget _buildStatisticsCards() {
    final colorScheme = Theme.of(context).colorScheme;
    final mesas = _estadisticasState.mesasActivas;
    final ventas = _estadisticasState.ventasHoy;

    return Row(
      children: [
        Expanded(
          child: _buildStatisticCard(
            icon: Icons.table_restaurant,
            iconColor: AppColors.success,
            label: 'Mesas Activas',
            value: mesas != null ? '${mesas.mesasActivas}' : '--',
            trend: mesas != null ? '${mesas.porcentajeOcupacion}%' : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatisticCard(
            icon: Icons.attach_money,
            iconColor: colorScheme.primary,
            label: 'Ventas Hoy',
            value: ventas != null
                ? 'S/ ${ventas.montoVentasHoy.toStringAsFixed(0)}'
                : 'S/ --',
            trend: ventas != null
                ? '${ventas.esPositivo ? '+' : ''}${ventas.porcentajeVariacion.toStringAsFixed(0)}%'
                : null,
            trendPositivo: ventas?.esPositivo ?? true,
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
    bool trendPositivo = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.navyCard : Colors.white;
    final trendColor = trendPositivo ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
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
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendPositivo
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: trendColor,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(trend,
                          style: TextStyle(
                              fontSize: 12,
                              color: trendColor,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontSize: 18)),
    );
  }

  // ── Acciones rápidas ──────────────────────────────────────────────────────────
  Widget _buildQuickActionsButtons() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.add_circle,
            iconColor: colorScheme.primary,
            label: 'Nuevo Pedido',
            subtitle: 'Crear pedido',
            onTap: () => context.push("/pedido_mesas"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.table_chart,
            iconColor: AppColors.success,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.navyCard : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
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
                    color: iconColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(height: 12),
                Text(label,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Pedidos recientes ─────────────────────────────────────────────────────────
  Widget _buildRecentOrdersHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle('Pedidos Recientes'),
        TextButton(
          onPressed: () => _navigateTo("/gestion_pedidos"),
          style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
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
    if (_pedidosState.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (_pedidosState.recientes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              const Icon(Icons.shopping_cart_outlined,
                  size: 48, color: AppColors.grey300),
              const SizedBox(height: 16),
              Text('No hay pedidos disponibles',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    final recientes = _pedidosState.recientes;
    return Column(
      children: [
        for (var i = 0; i < recientes.length; i++)
          Column(
            children: [
              OrderCardWidget(
                pedido: recientes[i],
                onTap: () => _showOrderDetails(recientes[i]),
              ),
              if (i < recientes.length - 1) const SizedBox(height: 16),
            ],
          ),
      ],
    );
  }
}