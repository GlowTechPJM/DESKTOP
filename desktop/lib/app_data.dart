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
  TextEditingController messageController = TextEditingController();
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;

  Future<void> connectToServer(String ip, int port) async {
    connectionStatus = ConnectionStatus.connecting;

    await Future.delayed(const Duration(seconds: 2));

    try {
      socketClient = IOWebSocketChannel.connect("ws://$ip:$port");
      connectionStatus = ConnectionStatus.connected;
      print("connectToServer connected");
    } catch (e) {
      connectionStatus = ConnectionStatus.disconnected;
      print("connectToServer disconnected:" + e.toString());
    }
    notifyListeners();
  }

  void onConnectionComplete(BuildContext context) {
    notifyListeners();
  }

  void sendMessage(String messageText) {
    print(socketClient);
    if (messageText.isNotEmpty && socketClient != null) {
      broadcastMessage(messageText);
      String currentDate =
          DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
      String formattedMessage = '$messageText - $currentDate';
      messages.add(formattedMessage);
      messages.sort((a, b) => b.compareTo(a));
      messageController.clear();
      saveListToFile();
      notifyListeners();
      print(messages); //remove after check
    }
  }

  void broadcastMessage(String msg) {
    final message = {
      'type': 'broadcast',
      'value': msg,
    };
    socketClient!.sink.add(jsonEncode(message));
  }

  void downloadList() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String filePath = '${documentsDirectory.path}/message_list.json';
      File file = File(filePath);
      await file.writeAsString(jsonEncode(messages));
    } catch (e) {
      print('Error downloading list: $e');
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
}
