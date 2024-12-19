import 'package:cattyled_app/store/lamp_settings/store.dart';

String stringifyData(LampSettingsState state, {bool invertIds = false}) {
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
