import 'dart:math';

import 'package:desktop/layout_message.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

enum ConnectionStatus {
  disconnected,
  disconnecting,
  connecting,
  connected,
}

class LayoutIntro extends StatefulWidget {
  LayoutIntro({Key? key}) : super(key: key);

  @override
  LayoutIntroState createState() => LayoutIntroState();
}

class LayoutIntroState extends State<LayoutIntro> {
  final TextEditingController ipController = TextEditingController();
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;
  bool isLoading = false;
  late IOWebSocketChannel socketClient;

  Future<void> connectToServer(String ip, int port) async {
    setState(() {
      isLoading = true;
      connectionStatus = ConnectionStatus.connecting;
    });

    await Future.delayed(const Duration(seconds: 4));

    try {
      socketClient = IOWebSocketChannel.connect("ws://$ip:$port");
      setState(() {
        connectionStatus = ConnectionStatus.connected;
        isLoading = false;
      });
      if (connectionStatus == ConnectionStatus.connected) {
        onConnectionComplete();
      } else {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Connection Error'),
              content: const Text('Unable to connect to the server: $e'),
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
    } catch (e) {
      setState(() {
        connectionStatus = ConnectionStatus.disconnected;
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Connection Error'),
            content: Text('Unable to connect to the server: $e'),
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
  }

  void onConnectionComplete() {
    // Navigate to the layout for successful connection
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LayoutMessage()),
    );
  }

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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Enter the IP of the controller:')),
          content: TextField(
            controller: ipController,
            decoration: const InputDecoration(
              hintText: 'Type IP here...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                showLoadingScreen(context);
                connectToServer(ipController.text, 8080);
                Future.delayed(const Duration(seconds: 4), () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('message');
                });
              },
              child: const Text('Submit'),
            ),
          ],
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
          content: Center(
            child: CircularProgressIndicator(),
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
