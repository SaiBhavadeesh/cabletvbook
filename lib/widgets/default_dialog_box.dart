import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class DefaultDialogBox {
  static errorDialog(BuildContext ctx, String title, String content) {
    return showDialog(
      context: ctx,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5,sigmaY: 5),
              child: AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            IconButton(
              icon: Icon(FlutterIcons.check_circle_faw),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
