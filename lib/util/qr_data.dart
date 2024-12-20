import 'package:cattyled_app/config/config.dart';
import 'package:cattyled_app/store/lamp_settings/store.dart';

class QueryData {
  final String mqttHost;
  final int mqttPort;
  final String mqttPrefix;
  final bool mqttHasCreds;
  final String? mqttUser;
  final String? mqttPassword;
  final String mqttLocalId;
  final String mqttRemoteId;

  QueryData({
    required this.mqttHost,
    required this.mqttPort,
    required this.mqttPrefix,
    required this.mqttHasCreds,
    required this.mqttUser,
    required this.mqttPassword,
    required this.mqttLocalId,
    required this.mqttRemoteId,
  });

  factory QueryData.fromLampState(LampSettingsState state) {
    return QueryData(
      mqttHost: state.mqttHost,
      mqttPort: state.mqttPort,
      mqttPrefix: state.mqttPrefix,
      mqttHasCreds: state.mqttHasCreds,
      mqttUser: state.mqttUser,
      mqttPassword: state.mqttPassword,
      mqttLocalId: state.mqttLocalId,
      mqttRemoteId: state.mqttRemoteId,
    );
  }

  factory QueryData.fromConfig(Config config) {
    return QueryData(
      mqttHost: config.mqttHost,
      mqttPort: config.mqttPort,
      mqttPrefix: config.lampPrefix,
      mqttHasCreds: config.mqttUseCredentials,
      mqttUser: config.mqttUser,
      mqttPassword: config.mqttPassword,
      mqttLocalId: config.lampLocalName,
      mqttRemoteId: config.lampRemoteName,
    );
  }
}

String stringifyData(QueryData state, {bool invertIds = false}) {
  final List<dynamic> data = [
    state.mqttHost,
    state.mqttPort,
    state.mqttPrefix,
    state.mqttHasCreds,
    state.mqttUser,
    state.mqttPassword,
    invertIds ? state.mqttLocalId : state.mqttRemoteId,
    invertIds ? state.mqttRemoteId : state.mqttLocalId,
  ];
  final String query = data.map((item) => item.toString()).join("&");
  return "cattyled:$query";
}

QueryData parseData(String query) {
  if (!query.startsWith("cattyled:")) throw const FormatException();
  query = query.substring(9);
  final List<String> parts = query.split("&");
  return QueryData(
    mqttHost: parts[0],
    mqttPort: int.parse(parts[1]),
    mqttPrefix: parts[2],
    mqttHasCreds: bool.parse(parts[3]),
    mqttUser: parts[4],
    mqttPassword: parts[5],
    mqttRemoteId: parts[6],
    mqttLocalId: parts[7],
  );
}
