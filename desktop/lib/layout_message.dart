import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class LayoutMessage extends StatefulWidget {
  const LayoutMessage({Key? key}) : super(key: key);

  @override
  LayoutMessageState createState() => LayoutMessageState();
}

class LayoutMessageState extends State<LayoutMessage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    appData.loadList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Sending'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await appData.sendConnectedMessage(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Get Connected Clients'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: appData.messageController,
                decoration: const InputDecoration(labelText: 'Enter Message'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  appData.sendMessage(appData.messageController.text.trim());
                },
                child: const Text('Send'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: appData.messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(appData.messages[index]),
                      onTap: () {
                        String message = appData.messages[index].substring(
                            appData.messages[index].indexOf('-') + 2);
                        appData.resendMessage(message);
                      },
                    );
                  },
                ),
              ),
            ]),
      ),
    );
  }
}
