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
  static Future<dynamic> errorDialog(BuildContext context,
      {String title = 'Failed !',
      String content = 'Something went wrong !\nPlease try again.'}) {
    return showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
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

  static Future<dynamic> loadingDialog(BuildContext context,
      {SelectLoader loaderType, String title}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2,sigmaY: 2),
              child: WillPopScope(
          onWillPop: () async => Future.value(false),
          child: AlertDialog(
            elevation: 0,
            contentPadding: EdgeInsets.all(
                loaderType == SelectLoader.ballClipRotateMultiple
                    ? MediaQuery.of(context).size.width * 0.2
                    : MediaQuery.of(context).size.width * 0.3),
            backgroundColor: Colors.transparent,
            title: title == null ? null : Text(title),
            content: LoadingIndicator(
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
