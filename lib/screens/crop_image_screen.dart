import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';

class CropImageScreen extends StatefulWidget {
  static const routeName = '/cropImageScreen';
  @override
  _CropImageScreenState createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  final cropKey = GlobalKey<CropState>();

  @override
  Widget build(BuildContext context) {
    final File imageFile = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        child: Crop(
          key: cropKey,
          alwaysShowGrid: true,
          maximumScale: 1.0,
          onImageError: (exception, stackTrace) {
            DefaultDialogBox.errorDialog(
                context: context, content: 'Bad image file!');
          },
          image: FileImage(imageFile),
          aspectRatio: 1.0,
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FlatButton.icon(
            textColor: Colors.red,
            onPressed: () {
              cropKey.currentState.cancel();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.cancel),
            label: Text('CANCEL'),
          ),
          FlatButton.icon(
            onPressed: () async {
              final area = cropKey.currentState.area;
              final scale = cropKey.currentState.scale;
              if (area == null) {
                DefaultDialogBox.errorDialog(context: context);
                return;
              }
              final File image = await ImageCrop.cropImage(
                file: imageFile,
                area: area,
                scale: scale,
              );
              Navigator.of(context).pop(image);
            },
            icon: Icon(Icons.check),
            label: Text('DONE'),
          ),
        ],
      ),
    );
  }
}
