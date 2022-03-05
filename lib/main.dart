import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Flutter Demo PokeApi'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic> dataMap = new Map();
  bool recupDataBool = false;
  int id = 0;

  void recupData() async {
    await recupDataJson();
    if (mounted) {
      setState(() {
        recupDataJson;
      });
    }
  }

  Future<void> recupDataJson() async {
    String url = "https://pokeapi.co/api/v2/pokemon/" + this.id.toString();
    var reponse = await http.get(Uri.parse(url));
    if (reponse.statusCode == 200) {
      dataMap = convert.jsonDecode(reponse.body);
      recupDataBool = true;
    }
  }

  Widget afficheData() {
    Column contenu = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.empty(growable: true),
    );
    if (recupDataBool) {
      Map<String, dynamic> spritesData = dataMap['sprites'];
      contenu.children.add(Image.network(spritesData['front_default'].toString()));
      //contenu.children.add(Image.network(spritesData['other']['official-artwork']['front_default'].toString()));
      List<dynamic> formsData = dataMap['forms'];
      contenu.children.add(Text("Name: " + formsData[0]['name'].toString()));
      contenu.children.add(Text("Height: " + dataMap['height'].toString()));
      contenu.children.add(Text("Weight: " + dataMap['weight'].toString()));

      recupDataBool = false;
    }
    return contenu;
  }

  Widget attente() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        Text('En attente des données', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        //CircularProgressIndicator(),
      ],
    );
  }

  bool isNumeric(String s) {
    bool isnum = false;
    try {
      double.parse(s);
      isnum = true;
    } catch (e) {}
    return isnum;
  }

  @override
  Widget build(BuildContext context) {
    if (!recupDataBool) {
      recupData();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextField(
          decoration: const InputDecoration(labelText: "N° du Pokémon", hintText: "Saisir l'id d'un Pokémon"),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), LengthLimitingTextInputFormatter(3)],
          onSubmitted: (value) {
            setState(() {
              if (value != null && value.isNotEmpty && value != "") {
                if (isNumeric(value)) {
                  id = int.parse(value);
                }
              } else {
                id = 0;
                recupDataBool = false;
              }
            });
          },
        ),
        const Padding(padding: EdgeInsets.only(top: 20)),
        recupDataBool ? afficheData() : attente(),
      ]),
    );
  }
}
