import 'package:cattyled_app/providers/config.dart';
import 'package:cattyled_app/repository/mqtt.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  final configProvider = ConfigProvider();
  await configProvider.load();

  getIt.registerSingleton<ConfigProvider>(configProvider);
  getIt.registerSingleton<MqttRepository>(MqttRepository());
}
