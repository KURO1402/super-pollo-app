import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/services/pedidos_service.dart';
import 'package:super_pollo_app/state/pedido_flow_state.dart';
import 'package:super_pollo_app/widgets/pedido_stepper.dart';
import 'package:super_pollo_app/theme/app_colors.dart';

class PedidoResumenPage extends StatefulWidget {
  final PedidoFlowState flowState;
  const PedidoResumenPage({super.key, required this.flowState});

  @override
  State<PedidoResumenPage> createState() => _PedidoResumenPageState();
}

class _PedidoResumenPageState extends State<PedidoResumenPage> {
  bool _isLoading = false;

  double get _total => widget.flowState.productos.fold<double>(
        0,
        (sum, p) => sum + ((p['precio'] ?? 0) * (p['cantidad'] ?? 0)),
      );

  Future<void> _confirmarPedido() async {
    setState(() => _isLoading = true);
    try {
      await PedidosService().insertarPedido(
        mesas: widget.flowState.mesas.map((m) => {'idMesa': m.idMesa}).toList(),
        productos: widget.flowState.productos,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido registrado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/menu_principal');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar el pedido: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToStep(int stepIndex) {
    switch (stepIndex) {
      case 0:
        context.push('/pedido_mesas', extra: widget.flowState);
        break;
      case 1:
        context.push('/pedido_menu', extra: widget.flowState);
        break;
      case 2:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    final horizontalPadding = screenWidth < 360 ? 16.0 : 20.0;
    final cardPadding = isSmallScreen ? 12.0 : 16.0;
    final bottomBarBg = isDark ? AppColors.navyCard : Colors.white;
    final dividerColor = isDark ? AppColors.navyLight : AppColors.grey300;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => GoRouter.of(context).canPop()
              ? GoRouter.of(context).pop()
              : GoRouter.of(context).go('/menu_principal'),
        ),
        centerTitle: true,
        title: const Text('Nuevo Pedido'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: PedidoStepper(
            currentStep: 2,
            completedSteps: widget.flowState.completedSteps,
            onStepTapped: _navigateToStep,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Contenido ──────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  _buildSectionHeader('Mesas', colorScheme),
                  const SizedBox(height: 12),
                  _buildMesasCard(cardPadding, isSmallScreen, isDark, colorScheme),

                  const SizedBox(height: 24),
                  Divider(color: dividerColor),
                  const SizedBox(height: 16),

                  _buildSectionHeader('Resumen', colorScheme),
                  const SizedBox(height: 16),

                  ...widget.flowState.productos.map((p) {
                    final subtotal = ((p['precio'] ?? 0) * (p['cantidad'] ?? 0)) as double;
                    return _buildProductoItem(
                      nombre: p['nombre'] ?? 'Producto',
                      cantidad: p['cantidad'] ?? 0,
                      subtotal: subtotal,
                      isSmallScreen: isSmallScreen,
                      isDark: isDark,
                      colorScheme: colorScheme,
                    );
                  }),

                  const SizedBox(height: 20),
                  Divider(color: isDark ? AppColors.navyLight : AppColors.grey500.withOpacity(0.4)),
                  const SizedBox(height: 14),

                  _buildTotal(isSmallScreen, colorScheme),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Botón confirmar ────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              12,
              horizontalPadding,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: bottomBarBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              // ElevatedButton hereda el estilo completo del AppTheme
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmarPedido,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Confirmar Pedido',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header de sección ────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
        ),
      ],
    );
  }

  // ── Card de mesas ────────────────────────────────────────────────────────────
  Widget _buildMesasCard(
    double cardPadding,
    bool isSmallScreen,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final cardBg = isDark ? AppColors.navyCard : Colors.white;
    final borderColor = isDark ? AppColors.navyLight : AppColors.grey300;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mesasText = widget.flowState.mesas.map((m) => m.nombre).join(', ');
          final nameStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: constraints.maxWidth < 300 ? 14 : 15,
              );

          if (constraints.maxWidth < 300) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mesasText, style: nameStyle),
                const SizedBox(height: 12),
                _buildCambiarButton(colorScheme),
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(mesasText,
                    style: nameStyle, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 12),
              _buildCambiarButton(colorScheme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCambiarButton(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => _navigateToStep(0),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.primary.withOpacity(0.4)),
        ),
        child: Text(
          'Cambiar',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  // ── Item de producto ─────────────────────────────────────────────────────────
  Widget _buildProductoItem({
    required String nombre,
    required int cantidad,
    required double subtotal,
    required bool isSmallScreen,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    final cardBg = isDark ? AppColors.navyCard : Colors.white;
    final borderColor = isDark ? AppColors.navyLight : AppColors.grey100;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 14,
        vertical: isSmallScreen ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final precioText = 'S/ ${subtotal.toStringAsFixed(2)}';
          final precioStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: isSmallScreen ? 14 : 15,
                fontWeight: FontWeight.w700,
              );
          final nombreStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: isSmallScreen ? 14 : 15,
                fontWeight: FontWeight.w500,
              );

          if (constraints.maxWidth < 280) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildCantidadBadge(cantidad, colorScheme),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(nombre,
                          style: nombreStyle,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(precioText, style: precioStyle),
                ),
              ],
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    _buildCantidadBadge(cantidad, colorScheme),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(nombre,
                          style: nombreStyle,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(precioText, style: precioStyle),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCantidadBadge(int cantidad, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '×$cantidad',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  // ── Total ────────────────────────────────────────────────────────────────────
  Widget _buildTotal(bool isSmallScreen, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
        ),
        Flexible(
          child: Text(
            'S/ ${_total.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}