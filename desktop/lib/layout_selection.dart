import 'package:flutter/material.dart';

class LayoutSelection extends StatefulWidget {
  const LayoutSelection({Key? key}) : super(key: key);

  @override
  LayoutSelectionState createState() => LayoutSelectionState();
}

class LayoutSelectionState extends State<LayoutSelection> {
  @override
  Widget build(BuildContext context) {
    double buttonSize = MediaQuery.of(context).size.width * 0.2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selection Screen'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('message');
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.text_format),
                    SizedBox(height: 8),
                    Text('Send Text Messages'),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('image');
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image),
                    SizedBox(height: 8),
                    Text('Send Images'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
