import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppSkin { classic, neo }

class AppSkinCubit extends Cubit<AppSkin> {
  static const _key = 'app_skin';

  AppSkinCubit() : super(AppSkin.classic) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'neo') emit(AppSkin.neo);
  }

  Future<void> switchTo(AppSkin skin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, skin.name);
    emit(skin);
  }

  bool get isNeo => state == AppSkin.neo;
}
