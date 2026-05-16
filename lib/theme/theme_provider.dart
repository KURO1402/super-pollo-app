import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider extends ChangeNotifier {
  static const _storageKey = 'theme_mode';
  final _storage = const FlutterSecureStorage();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isSystem => _themeMode == ThemeMode.system;
  bool get isLight  => _themeMode == ThemeMode.light;
  bool get isDark   => _themeMode == ThemeMode.dark;

  Future<void> loadSavedTheme() async {
    final saved = await _storage.read(key: _storageKey);
    _themeMode = _fromString(saved);
  }

  /// Cambia el tema y persiste la elección.
  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _storage.write(key: _storageKey, value: _toString(mode));
    notifyListeners();
  }

  /// Alterna entre claro y oscuro (útil para un toggle rápido).
  Future<void> toggleLightDark() async {
    final next = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setTheme(next);
  }

  // ── Helpers privados ─────────────────────────
  static String _toString(ThemeMode m) => switch (m) {
        ThemeMode.light  => 'light',
        ThemeMode.dark   => 'dark',
        ThemeMode.system => 'system',
      };

  static ThemeMode _fromString(String? s) => switch (s) {
        'light'  => ThemeMode.light,
        'dark'   => ThemeMode.dark,
        _        => ThemeMode.system, // default si es null o desconocido
      };
}