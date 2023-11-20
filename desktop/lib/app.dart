import 'package:desktop/layout_image.dart';
import 'package:desktop/layout_selection.dart';
import 'package:flutter/material.dart';
import 'layout_intro.dart';
import 'layout_message.dart';
import 'layout_login.dart';

// Main application widget
class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  AppState createState() => AppState();
}

// Main application state
class AppState extends State<App> {
  // Definir el contingut del widget 'App'
  @override
  Widget build(BuildContext context) {
    // Farem servir la base 'Cupertino'
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LayoutIntro(),
      routes: {
        'intro': (context) => const LayoutIntro(),
        'login': (context) => const LayoutLogin(),
        'selection': (context) => const LayoutSelection(),
        'message': (context) => const LayoutMessage(),
        'image': (context) => const LayoutImage(),
      },
    );
  }
}
