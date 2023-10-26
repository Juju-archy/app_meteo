import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Initialise la liaison Flutter
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Météo app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Coda Météo'),
    );
  }
}

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
  //late Coordinates coordCitySelected;

  //user location
  late Location location;
  late LocationData locationData;
  late Stream<LocationData> stream;

  static const MethodChannel _channel = MethodChannel('github.com/aloisdeniel/geocoder');

  @override
  void initState(){
    //TODO: implement initState
    super.initState();
    getCity();
    location = Location();
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
                      //coordsFormCity(citySelected);
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

  void ajouter(String str) async {
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
      locationData = await location.getLocation();
      print("Nouvelle position: ${locationData.latitude} / ${locationData.longitude}");
      locationToString();
    } catch (e) {
      print("Nous avons une erreur: $e");
    }
  }

  //get location for each changed position
  listenToStream(){
    stream = location.onLocationChanged;
    stream.listen((newPosition) {

      if ((newPosition.longitude != locationData.longitude) && (newPosition.latitude != locationData.latitude)) {
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



}
