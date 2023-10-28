import 'dart:convert';
import 'package:app_meteo/model/temperature.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:geocoding_platform_interface/src/models/location.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as GeocoderLocation;
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String key = 'villes';
  late List<String> cities = [];
  String citySelected = '';
  String? longAddressSelected;
  String? latAddressSelected;
  //user location
  GeocoderLocation.Location? location;
  late GeocoderLocation.LocationData locationData;
  late Stream<GeocoderLocation.LocationData> stream;
  late Temperature temperature;

  @override
  void initState(){
    //TODO: implement initState
    super.initState();
    getCity();
    location = GeocoderLocation.Location();
    getFirstLocation();
    listenToStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.deepPurple,
          child: ListView.builder(
            itemCount: cities.length + 2,
            itemBuilder: (context, i){
              if (i == 0) {
                return DrawerHeader(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      textWithStyle("Mes villes", fontSize: 22.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 10.0),
                        onPressed: addCity,
                        child: textWithStyle("Ajouter une ville", color: Colors.deepPurple),
                      ),
                    ],
                  ),
                );
              } else if(i == 1) {
                return ListTile(
                  title: textWithStyle("Ma ville actuelle"),
                  onTap: (){
                    setState(() {
                      citySelected = '';
                      latAddressSelected = '';
                      longAddressSelected = '';
                      Navigator.pop(context);
                    });
                  },
                );
              } else {
                String city = cities[i-2];
                return ListTile(
                  title: textWithStyle(city),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: (() => deleteCity(city)),
                  ),
                  onTap: (){
                    setState(() {
                      citySelected = city;
                      coordsFormCity();
                      Navigator.pop(context);
                    });
                  },
                );
              }
            },
          ),
        ),
      ),
      body: Center(
        child: Text((citySelected == '') ? "ville actuelle": citySelected),
      ),
    );
  }

  Text textWithStyle(String data, {color = Colors.white, fontSize = 20.0, fontStyle = FontStyle.italic, textAlign = TextAlign.center}) {
    return Text(
      data,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontStyle: fontStyle,
        fontSize: fontSize,
      ),
    );
  }

  Future<void> addCity() async {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext buildcontext) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(20.0),
          title: textWithStyle("Ajoutez une ville", fontSize: 22.0, color: Colors.deepPurple),
          children: [
            TextField(
              decoration: InputDecoration(labelText: "ville: "),
              onSubmitted: (String str){
                ajouter(str);
                Navigator.pop(buildcontext);
              },
            )
          ],
        );
      },
    );
  }

  void getCity() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String>? list = await sharedPreferences.getStringList(key);
    if(list != null){
      setState(() {
        cities = list;
      });
    }
  }

  void ajouter (String str) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    cities.add(str);
    await sharedPreferences.setStringList(key, cities);
    getCity();
  }

  void deleteCity(String str) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    cities.remove(str);
    await sharedPreferences.setStringList(key, cities);
    getCity();
  }

//Location
  //get location once
  getFirstLocation() async {
    try{
      locationData = await location!.getLocation();
      print("Nouvelle position: ${locationData.latitude} / ${locationData.longitude}");
      locationToString();
    } catch (e) {
      print("Nous avons une erreur: $e");
    }
  }

  //get location for each changed position
  listenToStream(){
    stream = location!.onLocationChanged;
    stream.listen((newPosition) {

      if ((newPosition.longitude != locationData?.longitude) && (newPosition.latitude != locationData?.latitude)) {
        setState(() {
          locationData = newPosition;
          locationToString();
        });
        print("New => ${newPosition.latitude} ---- ${newPosition.longitude}");

      }
    });
  }

  //Geocoder
  locationToString() async {
    final cityName = await placemarkFromCoordinates(locationData.latitude!, locationData.longitude!);
    print("${cityName.first.locality}");
  }

  coordsFormCity() async {
    List<Location> addresses  = await locationFromAddress('$citySelected');
    print("$addresses");
    if (addresses.length > 0) {
      latAddressSelected = '${addresses.first.latitude}';
      longAddressSelected = '${addresses.first.longitude}';
      setState(() {
        //print('$longAddressSelected, $latAddressSelected');
        api();
      });

    }

  }

  api() async{
    late String? lat;
    late String? long;
    if ((latAddressSelected != null) && (longAddressSelected != null)){
      lat = latAddressSelected;
      long = longAddressSelected;
    } else if (locationData.longitude != null && locationData.latitude != null){
      latAddressSelected = locationData.latitude.toString();
      longAddressSelected = locationData.longitude.toString();
    }
    if ((lat != null) && (long != null)){
      const key = "&appid=89291277ba7cb8e7ee3f2afebf2a181d";
      String lang = "&lang=${Localizations.localeOf(context).languageCode}";
      String baseAPI = "http://api.openweathermap.org/data/2.5/forecast?";
      String coordString = "lat=$latAddressSelected&lon=$longAddressSelected";
      String units = "&units=metrics";
      String totalString = baseAPI+coordString+lang+key+units;

      final response = await http.get(Uri.parse(totalString));
      if (response.statusCode == 200){

        final map = json.decode(response.body);
        Temperature temps = new Temperature.fromJSON(map);
        print(temps);
        print('Main: ${temps.main}');
        print('Description: ${temps.description}');
        print('Temp: ${temps.temp}');
        print('Pressure: ${temps.pressure}');
        print('Humidity: ${temps.humidity}');
        print('Temp Min: ${temps.temp_min}');
        print('Temp Max: ${temps.temp_max}');
        setState(() {
          temperature = temps;
        });

      }
    }

  }

}