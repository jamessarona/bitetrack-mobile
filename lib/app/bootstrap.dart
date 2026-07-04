import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bitetrack/core/config/env_config.dart';
import 'package:bitetrack/core/di/injection.dart';

Future<void> bootstrap(Future<void> Function() run) async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.load();
  await Hive.initFlutter();

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  configureInjection();

  await run();
}
