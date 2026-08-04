import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/models/listar_pedidos_model.dart';
import 'package:super_pollo_app/screens/configuracion_page.dart';
import 'package:super_pollo_app/screens/editar_pedido_page.dart';
import 'package:super_pollo_app/screens/gestion_mesas_page.dart';
import 'package:super_pollo_app/screens/gestion_pedidos_page.dart';
import 'package:super_pollo_app/screens/inicio_sesion_page.dart';
import 'package:super_pollo_app/screens/menu_principal_page.dart';
import 'package:super_pollo_app/screens/notificaciones_page.dart';
import 'package:super_pollo_app/screens/pedido_menu_page.dart';
import 'package:super_pollo_app/screens/pedido_mesas_page.dart';
import 'package:super_pollo_app/screens/pedido_resumen_page.dart';
import 'package:super_pollo_app/state/pedido_flow_state.dart';
import 'package:super_pollo_app/utils/notificaciones_state.dart';
import 'package:super_pollo_app/utils/pedidos_state.dart';
import 'package:super_pollo_app/utils/token_storage.dart';
import 'package:super_pollo_app/theme/app_theme.dart';
import 'package:super_pollo_app/theme/theme_provider.dart';
import 'package:pusher_beams/pusher_beams.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter( 
  navigatorKey: navigatorKey,
  redirect: (context, state) async {
    final haySesion = await TokenStorage.haySession();
    final enLogin = state.matchedLocation == '/';

    if (!haySesion && !enLogin) return '/';
    if (haySesion && enLogin) return '/menu_principal';
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const InicioSesionPage(),
    ),
    GoRoute(
      path: '/menu_principal',
      builder: (BuildContext context, GoRouterState state) =>
          const MenuPrincipalPage(),
    ),
    GoRoute(
      path: '/pedido_mesas',
      builder: (BuildContext context, GoRouterState state) {
        final flowState = state.extra as PedidoFlowState?;
        return PedidoMesasPage(flowState: flowState);
      },
    ),
    GoRoute(
      path: '/pedido_menu',
      builder: (BuildContext context, GoRouterState state) {
        final flowState = state.extra as PedidoFlowState;
        return PedidoMenuPage(flowState: flowState);
      },
    ),
    GoRoute(
      path: '/pedido_resumen',
      builder: (BuildContext context, GoRouterState state) {
        final flowState = state.extra as PedidoFlowState;
        return PedidoResumenPage(flowState: flowState);
      },
    ),
    GoRoute(
      path: '/gestion_mesas',
      builder: (BuildContext context, GoRouterState state) =>
          const GestionMesasPage(),
    ),
    GoRoute(
      path: '/gestion_pedidos',
      builder: (BuildContext context, GoRouterState state) =>
          const GestionPedidosPage(),
    ),
    GoRoute(
      path: '/editar_pedido',
      builder: (BuildContext context, GoRouterState state) {
        final pedido = state.extra as Pedido;
        return EditarPedidoPage(
          pedido: pedido,
          onPedidoEditado: () => PedidosState().cargar(),
        );
      },
    ),
    GoRoute(
      path: '/notificaciones',
      builder: (BuildContext context, GoRouterState state) =>
          const NotificacionesPage(),
    ),
    GoRoute(
      path: '/configuracion',
      builder: (BuildContext context, GoRouterState state) =>
          const ConfiguracionPage(),
    ),
  ],
);

final themeProvider = ThemeProvider();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PusherBeams.instance.start('9a4bce4e-6ac6-450b-9928-29fa04dece9b');
  await NotificacionesState().init();
  await themeProvider.loadSavedTheme();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: scaffoldMessengerKey,
          routerConfig: router,

          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode, 
        );
      },
    );
  }
}