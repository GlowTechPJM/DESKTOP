import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/io.dart';

enum ConnectionStatus {
  disconnected,
  disconnecting,
  connecting,
  connected,
}

class AppData extends ChangeNotifier {
  IOWebSocketChannel? socketClient;
  List<String> messages = [];
  List<String> imagesBase64 = [];
  TextEditingController messageController = TextEditingController();
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;
  String loginResult = "invalid";

  void onMessage(String message, BuildContext context) {
    final data = jsonDecode(message);
    print(data);

    if (data.containsKey('android') && data.containsKey('desk')) {
      showConnectedClientsPopup(context, data['android'], data['desk']);
    } else if (data.containsKey('type') &&
        data.containsKey('user') &&
        data.containsKey('action')) {
      String user = data['user'];
      String action = data['action'];

      switch (action) {
        case 'connect':
          showCustomToast(context, "$user has connected to the server.");
          break;
        case 'disconnect':
          showCustomToast(context, "$user has disconnected from the server.");
          break;
        case 'message':
          showCustomToast(context, "$user has sent a message.");
          break;
        default:
          break;
      }
    } else if (data.containsKey('validacion')) {
      Navigator.pop(context);
      switch (data['validacion']) {
        case 'correcto':
          loginResult = "valid";
          break;
        case 'incorrecto':
          loginResult = "invalid";
          break;
        default:
          loginResult = "invalid";
          break;
      }
    } else {
      print('Received message: $message');
    }
  }

  void showCustomToast(BuildContext context, String message) {
    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 16.0,
        right: 16.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(overlay);

    Future.delayed(const Duration(seconds: 2), () {
      overlay.remove();
    });
  }

  Future<void> connectToServer(
      String ip, int port, BuildContext context) async {
    connectionStatus = ConnectionStatus.connecting;

    try {
      socketClient = IOWebSocketChannel.connect("ws://$ip:$port");
      await Future.delayed(const Duration(seconds: 2));
      Map<String, dynamic> jsonMessage = {
        'platform': 'desktop',
      };
      String encodedMessage = jsonEncode(jsonMessage);
      socketClient!.sink.add(encodedMessage);

      socketClient!.stream.listen(
        (message) {
          onMessage(message, context);
        },
        onDone: () {
          connectionStatus = ConnectionStatus.disconnected;
          notifyListeners();
        },
        onError: (error) {
          connectionStatus = ConnectionStatus.disconnected;
          notifyListeners();
        },
      );

      connectionStatus = ConnectionStatus.connected;
    } catch (e) {
      connectionStatus = ConnectionStatus.disconnected;
    }
    notifyListeners();
  }

  void onConnectionComplete(BuildContext context) {
    notifyListeners();
  }

  void sendMessage(String trim) {
    String messageText = messageController.text.trim();
    if (messageText.isNotEmpty && socketClient != null) {
      Map<String, dynamic> jsonMessage = {
        'msgPlatform': 'desktop',
        'message': messageText,
      };
      String encodedMessage = jsonEncode(jsonMessage);
      socketClient!.sink.add(encodedMessage);
      bool messageExists = messages.contains(messageText);

      if (messageExists) {
        messages.removeWhere((msg) => msg == messageText);
      }

      String currentDate =
          DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
      String formattedMessage = '$currentDate - $messageText';

      messages.insert(0, formattedMessage);
      messages.sort((a, b) {
        DateTime dateA = DateFormat('dd/MM/yyyy HH:mm:ss')
            .parse(a.substring(0, a.lastIndexOf('-')).trim());
        DateTime dateB = DateFormat('dd/MM/yyyy HH:mm:ss')
            .parse(b.substring(0, b.lastIndexOf('-')).trim());
        return dateB.compareTo(dateA);
      });
      messageController.clear();
      saveListToFile();
      notifyListeners();
    }
  }

  void resendMessage(String message) {
    if (socketClient != null) {
      Map<String, dynamic> jsonMessage = {
        'msgPlatform': 'desktop',
        'message': message,
      };
      String encodedMessage = jsonEncode(jsonMessage);
      socketClient!.sink.add(encodedMessage);
    }
  }

  void sendImage(File imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      Map<String, String> jsonImage = {
        'imgPlatform': 'desktop',
        'imagen': base64Image,
      };
      socketClient!.sink.add(jsonEncode(jsonImage));

      imagesBase64.add(base64Image);

      saveImageGalleryToFile();

      notifyListeners();
    } catch (e) {
      print('Error sending image: $e');
    }
  }

  void resendImage(String base64Image) {
    Map<String, dynamic> jsonMessage = {
      'imgPlatform': 'desktop',
      'imagen': base64Image,
    };

    String encodedMessage = jsonEncode(jsonMessage);
    socketClient?.sink.add(encodedMessage);
    notifyListeners();
  }

  Future<String> checkLogin(
      String username, String password, BuildContext context) async {
    String result = "invalid";
    Map<String, dynamic> loginData = {
      'userPlatform': 'desktop',
      'user': username,
      'password': password,
    };

    String encodedLoginData = jsonEncode(loginData);
    socketClient!.sink.add(encodedLoginData);
    await Future.delayed(const Duration(seconds: 2));
    return loginResult;
  }

  void loadList() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String filePath = '${documentsDirectory.path}/message_list.json';
      File file = File(filePath);
      if (file.existsSync()) {
        String fileContent = await file.readAsString();
        messages = List<String>.from(jsonDecode(fileContent));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading list from file: $e');
    }
  }

  void saveListToFile() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String filePath = '${documentsDirectory.path}/message_list.json';
      File file = File(filePath);
      await file.writeAsString(jsonEncode(messages));
    } catch (e) {
      print('Error saving list to file: $e');
    }
  }

  void saveImageGalleryToFile() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String filePath = '${documentsDirectory.path}/image_gallery.json';
      File file = File(filePath);
      await file.writeAsString(jsonEncode(imagesBase64));
    } catch (e) {
      print('Error saving image gallery to file: $e');
    }
  }

  void loadImageGallery() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String filePath = '${documentsDirectory.path}/image_gallery.json';
      File file = File(filePath);
      if (file.existsSync()) {
        String fileContent = await file.readAsString();
        imagesBase64 = List<String>.from(jsonDecode(fileContent));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading image gallery from file: $e');
    }
  }

  List<String> getImageGallery() {
    return imagesBase64;
  }

  Future<void> sendConnectedMessage(BuildContext context) async {
    try {
      Map<String, dynamic> jsonMessage = {
        'cntPlatform': 'desktop',
        'connected': '',
      };
      socketClient!.sink.add(jsonEncode(jsonMessage));
    } catch (e) {
      print('Error sending "connected" message: $e');
    }
  }

  void showConnectedClientsPopup(
    BuildContext context,
    String androidUsers,
    String desktopUsers,
  ) {
    List<String> androidIds = androidUsers.split(';');
    List<String> desktopIds = desktopUsers.split(';');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connected Clients Information'),
          content: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Android Users:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    ),
                    for (var androidId in androidIds) Text(androidId),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Desktop Users:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    ),
                    for (var desktopId in desktopIds) Text(desktopId),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
