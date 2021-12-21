import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart'; //Importa a biblioteca de design dos materiais
import '../ui/doclist.dart'; //É o arquivo que conterá a lógica para exbir uma lista de documentos

void main() => runApp(DocExpiryApp());

//extends é que nem os dois pontos ":", os dois se referem a herança
class DocExpiryApp extends StatelessWidget {
  //const DocExpireApp({Key? key}) : super(key: key); //

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DocExpire',
        theme: new ThemeData (primarySwatch: Colors.indigo),
        home: DocList());
  }
}
