import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageGetter {
  static Future<File?> getImageFromDevice(BuildContext ctx) async {
    final imagePicker = ImagePicker();
    File? selectedImageFile;
    await showDialog(
      context: ctx,
      builder: (c) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextButton.icon(
                onPressed: () async {
                  final pickedImage = await imagePicker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );
                  if (pickedImage != null) {
                    selectedImageFile = File(pickedImage.path);
                    if (ctx.mounted) Navigator.of(c).pop();
                  }
                },
                icon: const Icon(
                  Icons.camera_alt,
                  size: 32,
                ),
                label: const Text(
                  'Take Image',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final pickedImage = await imagePicker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );
                  if (pickedImage != null) {
                    selectedImageFile = File(pickedImage.path);
                    if (ctx.mounted) Navigator.of(c).pop();
                  }
                },
                icon: const Icon(
                  Icons.photo_library,
                  size: 32,
                ),
                label: const Text(
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
