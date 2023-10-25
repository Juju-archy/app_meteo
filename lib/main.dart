import 'package:flutter/material.dart';

void main() {
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

  List<String> cities = ["Paris", "Toulouse", "Marseilles"];
  String citySelected = '';

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
                return const DrawerHeader(child: Text('test'));
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
                  onTap: (){
                    setState(() {
                      citySelected = city;
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
}
