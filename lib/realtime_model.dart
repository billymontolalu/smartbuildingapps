import 'dart:convert';

RealtimeModel realtimeModelFromJson(String str) =>
    RealtimeModel.fromJson(json.decode(str));

String realtimeModelToJson(RealtimeModel data) => json.encode(data.toJson());

class RealtimeModel {
  RealtimeModel({
    this.power,
    this.voltage,
    this.current,
    this.switchValue,
  });

  String power;
  String voltage;
  String current;
  String switchValue;

  factory RealtimeModel.fromJson(Map<String, dynamic> json) => RealtimeModel(
        power: json["power"],
        voltage: json["voltage"],
        current: json["current"],
        switchValue: json["switchValue"],
      );

  Map<String, dynamic> toJson() => {
        "power": power,
        "voltage": voltage,
        "current": current,
        "switchValue": switchValue,
      };
}
