
import 'package:flutter/material.dart';

class Temperature {
  var main;
  var description;
  var icon;
  var temp;
  var pressure;
  var humidity;
  var temp_min;
  var temp_max;

  Temperature();

  factory Temperature.fromJSON(Map map) {
    debugPrint('map $map');

    var temperature = Temperature();

    if (map.containsKey("list") && map["list"] is List && map["list"].isNotEmpty) {
      Map mainData = map["list"][0]["main"];
      List weatherData = map["list"][0]["weather"];

      if (mainData != null && mainData is Map && weatherData != null && weatherData is List) {
        temperature.temp = mainData["temp"];
        temperature.pressure = mainData["pressure"];
        temperature.humidity = mainData["humidity"];
        temperature.temp_min = mainData["temp_min"];
        temperature.temp_max = mainData["temp_max"];

        if (weatherData.isNotEmpty) {
          temperature.main = weatherData[0]["main"];
          temperature.description = weatherData[0]["description"];
        }
      }
    }
    return temperature;
  }
}
