import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LayoutMessage extends StatefulWidget {
  const LayoutMessage({Key? key}) : super(key: key);

  @override
  LayoutMessageState createState() => LayoutMessageState();
}

class LayoutMessageState extends State<LayoutMessage> {
  List<String> messages = [];

  TextEditingController messageController = TextEditingController();

  void sendMessage() {
    String messageText = messageController.text.trim();
    if (messageText.isNotEmpty) {
      String currentDate =
          DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
      String formattedMessage = '$messageText - $currentDate';
      setState(() {
        messages.add(formattedMessage);
        messages.sort((a, b) => b.compareTo(a));
        messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Enter Message'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                sendMessage();
              },
              child: const Text('Send'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
