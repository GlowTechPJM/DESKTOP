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

  Future<void> connectToServer(String ip, int port) async {
    connectionStatus = ConnectionStatus.connecting;

    try {
      socketClient = IOWebSocketChannel.connect("ws://$ip:$port");
      await Future.delayed(const Duration(seconds: 2));
      Map<String, dynamic> jsonMessage = {
        'platform': 'desktop',
      };
      String encodedMessage = jsonEncode(jsonMessage);
      socketClient!.sink.add(encodedMessage);
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

    try {
      socketClient!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          Navigator.pop(context);
          switch (data['validacion']) {
            case 'correcto':
              result = "valid";
              break;
            case 'incorrecto':
              result = "invalid";
              break;
            default:
              result = "invalid";
              break;
          }
        },
      );
      return result;
    } catch (e) {
      Navigator.pop(context);
      return "invalid";
    }
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
      socketClient!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          if (data.containsKey('connected')) {
            showConnectedClientsPopup(context, data['connected']);
          }
        },
      );
    } catch (e) {
      print('Error sending "connected" message: $e');
    }
  }

  void showConnectedClientsPopup(
      BuildContext context, List<dynamic> connectedClients) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connected Clients Information'),
          content: Column(
            children: [
              for (var clientInfo in connectedClients)
                ListTile(
                  title: Text(clientInfo['name']),
                  subtitle: Text(clientInfo['status']),
                ),
            ],
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
