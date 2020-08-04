import 'package:flutter/material.dart';
import 'package:cableTvBook/global/box_decoration.dart';

Widget defaultbutton(
    {@required BuildContext context,
    @required Function function,
    @required String title,
    IconData icon,
    double width = 45,
    double height = 16}) {
  return FloatingActionButton.extended(
    onPressed: function,
    isExtended: false,
    elevation: 0,
    label: Container(
      padding: EdgeInsets.symmetric(horizontal: width, vertical: height),
      decoration: defaultBoxDecoration(context, true),
      child: Row(
        children: <Widget>[
          if (icon != null) Icon(icon,color: Colors.white),
          if (icon != null) SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    ),
  );
}
