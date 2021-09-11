//import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loginPage/notes/NotesEditPage.dart';
import 'package:loginPage/notes/NotesHomePage.dart';


import 'dart:developer';


import 'package:firebase_core/firebase_core.dart';
import 'package:universal_io/io.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //home: MyLoginPage(),
      routes: <String, WidgetBuilder>{
        //default: should be _mainScreen()
      //'/': (BuildContext context) => AlbumCategory(),
      '/': (BuildContext context) => NotesHomePage(),
    }
    );
  }
}
