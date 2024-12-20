import 'package:cattyled_app/config/loader.dart';
import 'package:cattyled_app/repository/mqtt.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setup(Config config) async {
  getIt.registerSingleton<Config>(config);
  getIt.registerSingleton<MqttRepository>(MqttRepository(config));
}
