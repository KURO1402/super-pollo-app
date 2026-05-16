import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/services/usuario_service.dart';
import 'package:super_pollo_app/models/usuario_detail_model.dart';
import 'package:super_pollo_app/main.dart';
import 'package:super_pollo_app/theme/app_colors.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  bool _notificationsEnabled = true;
  late Future<UsuarioDetailModel> _usuario;

  @override
  void initState() {
    super.initState();
    _usuario = UsuarioService().obtenerUsuario();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => GoRouter.of(context).canPop()
              ? GoRouter.of(context).pop()
              : GoRouter.of(context).go('/'),
        ),
        title: const Text('Configuración'),
      ),
      body: FutureBuilder<UsuarioDetailModel>(
        future: _usuario,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(color: colorScheme.primary)
                .let((w) => Center(child: w));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final usuario = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(usuario, colorScheme, textTheme, isDark),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Información Personal', textTheme),
                  _buildInfoCard(isDark, [
                    _buildInfoField('Nombres', usuario.nombreUsuario, textTheme),
                    _buildDivider(isDark),
                    _buildInfoField('Apellidos', usuario.apellidoUsuario, textTheme),
                    _buildDivider(isDark),
                    _buildInfoField('Correo', usuario.correoUsuario, textTheme),
                    _buildDivider(isDark),
                    _buildInfoField('Teléfono', usuario.telefonoUsuario, textTheme),
                  ]),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Historial de Roles', textTheme),
                  _buildRolesList(usuario.roles, colorScheme, textTheme, isDark),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Preferencias', textTheme),
                  _buildInfoCard(isDark, [
                    _buildPreferenceItem(
                      icon: Icons.notifications_none_rounded,
                      text: 'Notificaciones',
                      isDark: isDark,
                      trailing: Switch.adaptive(
                        value: _notificationsEnabled,
                        activeColor: colorScheme.primary,
                        onChanged: (v) =>
                            setState(() => _notificationsEnabled = v),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Apariencia', textTheme),
                  _buildThemeSelector(colorScheme, textTheme, isDark),

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

  Widget _buildHeader(
    UsuarioDetailModel usuario,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: colorScheme.primary.withOpacity(0.12),
                child: Icon(Icons.person_rounded,
                    size: 50, color: colorScheme.primary),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${usuario.nombreUsuario} ${usuario.apellidoUsuario}',
            style: textTheme.titleLarge?.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 4),
          Text(
            usuario.nombreRol.toUpperCase(),
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(
      ColorScheme colorScheme, TextTheme textTheme, bool isDark) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.navyCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.navyLight
                  : AppColors.grey100,
            ),
          ),
          child: Column(
            children: [
              _buildThemeOption(
                icon: Icons.brightness_auto_rounded,
                label: 'Seguir al dispositivo',
                subtitle: 'Cambia según el sistema',
                mode: ThemeMode.system,
                colorScheme: colorScheme,
                textTheme: textTheme,
                isDark: isDark,
                isLast: false,
              ),
              _buildThemeOptionDivider(isDark),
              _buildThemeOption(
                icon: Icons.light_mode_rounded,
                label: 'Modo claro',
                subtitle: 'Siempre claro',
                mode: ThemeMode.light,
                colorScheme: colorScheme,
                textTheme: textTheme,
                isDark: isDark,
                isLast: false,
              ),
              _buildThemeOptionDivider(isDark),
              _buildThemeOption(
                icon: Icons.dark_mode_rounded,
                label: 'Modo oscuro',
                subtitle: 'Siempre oscuro',
                mode: ThemeMode.dark,
                colorScheme: colorScheme,
                textTheme: textTheme,
                isDark: isDark,
                isLast: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required ThemeMode mode,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required bool isDark,
    required bool isLast,
  }) {
    final isSelected = themeProvider.themeMode == mode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => themeProvider.setTheme(mode),
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(16),
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: isLast ? const Radius.circular(16) : Radius.zero,
            ),
          ),
          child: Row(
            children: [
              // Ícono con fondo
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withOpacity(0.15)
                      : (isDark
                          ? AppColors.navyLight
                          : AppColors.grey100),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected ? colorScheme.primary : AppColors.grey500,
                ),
              ),
              const SizedBox(width: 14),
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? colorScheme.primary : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Check
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelected
                    ? Icon(Icons.check_circle_rounded,
                        key: const ValueKey('check'),
                        color: colorScheme.primary,
                        size: 22)
                    : Icon(Icons.radio_button_unchecked,
                        key: const ValueKey('uncheck'),
                        color: AppColors.grey300,
                        size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOptionDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: isDark ? AppColors.navyLight : AppColors.grey100,
    );
  }

  // ── Helpers de UI reutilizables ─────────────────────────────────────────────
  Widget _buildSectionTitle(String title, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: textTheme.titleMedium,
      ),
    );
  }

  Widget _buildInfoCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.navyLight : AppColors.grey100,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: isDark ? AppColors.navyLight : AppColors.grey100,
    );
  }

  Widget _buildInfoField(String label, String value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(label, style: textTheme.bodySmall?.copyWith(fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesList(
    List<RolModel> roles,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isDark,
  ) {
    if (roles.isEmpty) return const Text('Sin historial');

    return Column(
      children: roles.map((rol) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.navyCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.navyLight : AppColors.grey100,
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.work_outline_rounded,
                  color: colorScheme.primary),
            ),
            title: Text(rol.nombreRol,
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  _buildDateBadge(rol.fechaInicio, AppColors.success),
                  const Icon(Icons.arrow_right_alt,
                      size: 16, color: AppColors.grey300),
                  _buildDateBadge(rol.fechaFin, AppColors.warning),
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
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        date,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String text,
    required Widget trailing,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey500, size: 22),
      title: Text(text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: trailing,
    );
  }
}

extension _WidgetLet on Widget {
  Widget let(Widget Function(Widget w) fn) => fn(this);
}