class Config {
  final String mqttHost;
  final int mqttPort;
  final bool mqttUseCredentials;
  final String? mqttUser;
  final String? mqttPassword;

  final String lampId;
  final String lampLocalName;
  final String lampRemoteName;

  String get localTopic => "/$lampId/CattyLED_/$lampLocalName";
  String get remoteTopic => "/$lampId/CattyLED_/$lampRemoteName";

  Config({
    required this.mqttHost,
    required this.lampId,
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
      lampId: "",
      lampLocalName: "",
      lampRemoteName: "",
    );
  }
}
