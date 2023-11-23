import 'dart:convert';
import 'dart:io';
import 'package:desktop/app_data.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class LayoutImage extends StatefulWidget {
  const LayoutImage({Key? key}) : super(key: key);

  @override
  LayoutImageState createState() => LayoutImageState();
}

class LayoutImageState extends State<LayoutImage> {
  File? selectedImage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    bool isSendButtonEnabled = selectedImage != null;

    return ChangeNotifierProvider.value(
      value: appData,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Send Images'),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        pickImage();
                      },
                      child: const Text('Select Image'),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: selectedImage != null
                          ? Image.file(
                              selectedImage!,
                              fit: BoxFit.contain,
                            )
                          : Container(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isSendButtonEnabled
                          ? () {
                              appData.sendImage(selectedImage!);
                            }
                          : null,
                      child: const Text('Send Image'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: ImageGallery(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageGallery extends StatelessWidget {
  const ImageGallery({super.key});

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    List<String> imageGallery = appData.getImageGallery();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: imageGallery.length,
      itemBuilder: (context, index) {
        String base64Image = imageGallery[index];

        return GestureDetector(
          onTap: () {
            appData.resendImage(base64Image);
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Image.memory(base64Decode(base64Image)),
          ),
        );
      },
    );
  }
}
