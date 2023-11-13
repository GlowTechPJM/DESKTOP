import 'package:flutter/material.dart';

class LayoutMessage extends StatefulWidget {
  const LayoutMessage({Key? key}) : super(key: key);

  @override
  LayoutMessageState createState() => LayoutMessageState();
}

class LayoutMessageState extends State<LayoutMessage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Led panel connection')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 0),
            Image.asset(
              'assets/images/logo.png',
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
