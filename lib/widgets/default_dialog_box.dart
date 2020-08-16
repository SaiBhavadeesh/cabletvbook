import 'dart:ui';

import 'package:cableTvBook/global/box_decoration.dart';
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
      String content = 'Something went wrong !\nPlease try again.',
      Function function}) {
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
              onPressed:
                  function != null ? function : () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  static Future<dynamic> loadingDialog(BuildContext context,
      {SelectLoader loaderType, String title, bool blur = true}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter:
            blur ? ImageFilter.blur(sigmaX: 2, sigmaY: 2) : ImageFilter.blur(),
        child: WillPopScope(
          onWillPop: () async => Future.value(false),
          child: AlertDialog(
            elevation: 0,
            contentPadding: EdgeInsets.all(
                loaderType == SelectLoader.ballClipRotateMultiple
                    ? MediaQuery.of(context).size.width * 0.2
                    : MediaQuery.of(context).size.width * 0.3),
            backgroundColor: Colors.transparent,
            title: title == null
                ? null
                : Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    decoration: defaultBoxDecoration(context, true),
                    child: Text(title,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white))),
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
