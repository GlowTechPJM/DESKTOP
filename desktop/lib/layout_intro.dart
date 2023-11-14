import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class LayoutIntro extends StatefulWidget {
  const LayoutIntro({Key? key}) : super(key: key);

  @override
  LayoutIntroState createState() => LayoutIntroState();
}

class LayoutIntroState extends State<LayoutIntro> {
  final TextEditingController ipController = TextEditingController();
  bool isLoading = false;

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
            ElevatedButton(
              onPressed: () {
                connectionPopup(context);
              },
              child: const Text('Connect to panel'),
            ),
          ],
        ),
      ),
    );
  }

  void connectionPopup(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Enter the IP of the controller:')),
          content: SizedBox(
            height: 100.0,
            width: 120.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: ipController,
                  decoration: const InputDecoration(
                    hintText: 'Type IP here...',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                    TextButton(
                      onPressed: () {
                        showLoadingScreen(context);
                        appData.connectToServer(ipController.text, 8080);

                        Future.delayed(const Duration(seconds: 2), () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed('message');
                          if (appData.connectionStatus ==
                              ConnectionStatus.connected) {
                            appData.onConnectionComplete(context);
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Connection Error'),
                                  content: const Text(
                                      'Unable to connect to the server.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        });
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showLoadingScreen(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Loading...'),
          content: SizedBox(
            height: 100.0,
            width: 150.0,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    ipController.dispose();
    super.dispose();
  }
}
