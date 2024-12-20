import 'package:cattyled_app/util/qr_data.dart';

class Config {
  final String mqttHost;
  final int mqttPort;
  final bool mqttUseCredentials;
  final String? mqttUser;
  final String? mqttPassword;

  final String lampPrefix;
  final String lampLocalName;
  final String lampRemoteName;

  String get localTopic => "$lampPrefix$lampLocalName";
  String get remoteTopic => "$lampPrefix$lampRemoteName";

  Config({
    required this.mqttHost,
    required this.lampPrefix,
    required this.lampLocalName,
    required this.lampRemoteName,
    this.mqttPort = 1883,
    this.mqttUseCredentials = false,
    this.mqttUser,
    this.mqttPassword,
  });

  factory Config.placeholder() {
    return Config(
      mqttHost: "",
      lampPrefix: "",
      lampLocalName: "",
      lampRemoteName: "",
    );
  }

  factory Config.fromQuery(QueryData data) {
    return Config(
      mqttHost: data.mqttHost,
      mqttPort: data.mqttPort,
      lampPrefix: data.mqttPrefix,
      lampLocalName: data.mqttLocalId,
      lampRemoteName: data.mqttRemoteId,
      mqttUseCredentials: data.mqttHasCreds,
      mqttUser: data.mqttUser,
      mqttPassword: data.mqttPassword,
    );
  }
}
