
class Temperature {
  late String name;
  late String main;
  late String description;
  late String icon;
  var temp;
  var pressure;
  var humidity;
  var temp_min;
  var temp_max;

  Temperature();

  void fromJSON(Map map) {
    this.name = map["name"];

    List weather = map["weather"];
    Map mapWeather = weather[0];
    this.main = mapWeather["main"];
    this.description = mapWeather["description"];
    Map main = map["main"];
    this.temp = main["temp"];
    this.pressure = main["pressure"];
    this.humidity = main["humidity"];
    this.temp_min = main["temp_min"];
    this.temp_max = main["temp_max"];
    pressure: map['pressure'];
  }
}