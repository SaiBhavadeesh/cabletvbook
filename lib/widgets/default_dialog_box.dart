import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:loading_indicator/loading_indicator.dart';

enum SelectLoader {
  ballClipRotateMultiple,
  ballScaleRippleMultiple,
  ballSpinFadeLoader,
  ballRotateChase,
}

class DefaultDialogBox {
  static Future<dynamic> errorDialog(
      {@required BuildContext context,
      String title = 'Failed !',
      String content = 'Something went wrong !\nPlease try again.'}) {
    return showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            IconButton(
              icon: Icon(FlutterIcons.check_circle_faw),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  static Future<dynamic> loadingDialog(
      {@required BuildContext context, SelectLoader loaderType, String title}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WillPopScope(
        onWillPop: () async => Future.value(false),
        child: AlertDialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: title == null ? null : Text(title),
          content: SizedBox(
            height: 100,
            width: 100,
            child: LoadingIndicator(
              indicatorType: loaderType == SelectLoader.ballClipRotateMultiple
                  ? Indicator.ballClipRotateMultiple
                  : loaderType == SelectLoader.ballScaleRippleMultiple
                      ? Indicator.ballScaleRippleMultiple
                      : loaderType == SelectLoader.ballRotateChase
                          ? Indicator.ballRotateChase
                          : loaderType == SelectLoader.ballSpinFadeLoader
                              ? Indicator.ballSpinFadeLoader
                              : Indicator.lineSpinFadeLoader,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
