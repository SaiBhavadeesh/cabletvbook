import 'package:flutter/material.dart';
import 'package:cableTvBook/global/box_decoration.dart';

enum SelectLoader {
  ballClipRotateMultiple,
  ballScaleRippleMultiple,
  ballSpinFadeLoader,
  ballRotateChase,
}

class DefaultDialogBox {
  static Future<dynamic> errorDialog(
    BuildContext context, {
    String title = 'Failed !',
    String content = 'Something went wrong !\nPlease try again.',
    VoidCallback? function,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check_circle),
            color: Theme.of(ctx).primaryColor,
            onPressed: function ?? () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  static Future<dynamic> loadingDialog(
    BuildContext context, {
    SelectLoader? loaderType,
    String? title,
    bool blur = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: title != null
              ? Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  decoration: defaultBoxDecoration(context, true),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : null,
          content: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
