import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/theme_config.dart';

class ThemeCubit extends Cubit<ThemeConfig> {
  ThemeCubit() : super(ThemeConfig.presets[0]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('app_theme_id') ?? 'teal';
    final config = ThemeConfig.presets.firstWhere(
      (t) => t.id == id,
      orElse: () => ThemeConfig.presets[0],
    );
    emit(config);
  }

  Future<void> setTheme(ThemeConfig config) async {
    emit(config);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme_id', config.id);
  }
}
