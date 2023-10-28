import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_meteo/widgets/my_app.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Initialise la liaison Flutter
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}




