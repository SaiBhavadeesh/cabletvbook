import 'dart:io';
import 'dart:ui';

import 'package:cableTvBook/screens/crop_image_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';

class ImageGetter {
  static Future<File> getImageFromDevice(BuildContext ctx) async {
    final _imagePicker = ImagePicker();
    File selectedImageFile;
    await showDialog(
      context: ctx,
      builder: (c) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FlatButton.icon(
                onPressed: () async {
                  final pickedImage = await _imagePicker.getImage(
                    source: ImageSource.camera,
                  );
                  try {
                    selectedImageFile = File(pickedImage.path);
                    Navigator.of(ctx)
                        .pushNamed(CropImageScreen.routeName,
                            arguments: File(pickedImage.path))
                        .then((value) {
                      selectedImageFile = value;
                      if (selectedImageFile != null) Navigator.of(c).pop();
                    });
                  } catch (error) {}
                },
                icon: Icon(
                  FlutterIcons.ios_camera_ion,
                  size: 36,
                ),
                label: Text(
                  'Take Image',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              FlatButton.icon(
                onPressed: () async {
                  final pickedImage = await _imagePicker.getImage(
                    source: ImageSource.gallery,
                  );
                  try {
                    selectedImageFile = File(pickedImage.path);
                    Navigator.of(ctx)
                        .pushNamed(CropImageScreen.routeName,
                            arguments: File(pickedImage.path))
                        .then((value) {
                      selectedImageFile = value;
                      if (selectedImageFile != null) Navigator.of(c).pop();
                    });
                  } catch (error) {}
                },
                icon: Icon(
                  FlutterIcons.ios_images_ion,
                  size: 36,
                ),
                label: Text(
                  'Select Image',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return selectedImageFile;
  }
}
