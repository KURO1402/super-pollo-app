import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/screens/configuracion_page.dart';
import 'package:super_pollo_app/screens/gestion_mesas_page.dart';
import 'package:super_pollo_app/screens/gestion_pedidos_page.dart';
import 'package:super_pollo_app/screens/inicio_sesion_page.dart';
import 'package:super_pollo_app/screens/menu_principal_page.dart';
import 'package:super_pollo_app/screens/notificaciones_page.dart';
import 'package:super_pollo_app/screens/pedido_menu_page.dart';
import 'package:super_pollo_app/screens/pedido_mesas_page.dart';
import 'package:super_pollo_app/screens/pedido_resumen_page.dart';

void main() {
  runApp(const MyApp());
}

/// The route configuration.
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const InicioSesionPage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'menu_principal',
          builder: (BuildContext context, GoRouterState state) {
            return const MenuPrincipalPage();
          },
        ),
        GoRoute(
          path: 'pedido_mesas',
          builder: (BuildContext context, GoRouterState state) {
            return const PedidoMesasPage();
          },
        ),
        GoRoute(
          path: 'pedido_menu',
          builder: (BuildContext context, GoRouterState state) {
            return const PedidoMenuPage();
          },
        ),
        GoRoute(
          path: 'pedido_resumen',
          builder: (BuildContext context, GoRouterState state) {
            return const PedidoResumenPage();
          },
        ),
        GoRoute(
          path: 'gestion_mesas',
          builder: (BuildContext context, GoRouterState state) {
            return const GestionMesasPage();
          },
        ),
        GoRoute(
          path: 'gestion_pedidos',
          builder: (BuildContext context, GoRouterState state) {
            return const GestionPedidosPage();
          },
        ),
        GoRoute(
          path: 'notificaciones',
          builder: (BuildContext context, GoRouterState state) {
            return const NotificacionesPage();
          },
        ),
        GoRoute(
          path: 'configuracion',
          builder: (BuildContext context, GoRouterState state) {
            return const ConfiguracionPage();
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
