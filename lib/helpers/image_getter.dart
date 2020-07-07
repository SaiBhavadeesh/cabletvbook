import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';

class ImageGetter {
  static Future<File> getImageFromDevice(BuildContext ctx) async {
    final _imagePicker = ImagePicker();
    File selectedImageFile;
    await showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FlatButton.icon(
              onPressed: () async {
                final pickedImage = await _imagePicker.getImage(
                  source: ImageSource.camera,
                  maxHeight: 720,
                  maxWidth: 720,
                );
                try {
                  selectedImageFile = File(pickedImage.path);
                } catch (error) {}
                Navigator.of(c).pop();
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
                  maxHeight: 720,
                  maxWidth: 720,
                );
                try {
                  selectedImageFile = File(pickedImage.path);
                } catch (error) {}
                Navigator.of(c).pop();
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
    );
    return selectedImageFile;
  }
}
