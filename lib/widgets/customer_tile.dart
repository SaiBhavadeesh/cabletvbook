import 'dart:async';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/screens/customer_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomerTile extends StatefulWidget {
  final Customer customer;
  final int index;

  CustomerTile({
    @required this.customer,
    @required this.index,
  });

  @override
  _CustomerTileState createState() => _CustomerTileState();
}

class _CustomerTileState extends State<CustomerTile> {
  Timer _timer;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    Future(() async {
      _timer = Timer.periodic(
        Duration(
          milliseconds: widget.index * 100 + 150,
        ),
        (timer) async {
          setState(() {
            _show = true;
          });
          timer.cancel();
        },
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) _timer.cancel();
  }

  void gestureNavigator(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(
      CustomerDetailScreen.routeName,
      arguments: widget.customer,
    );
  }

  void copyAndShowSnackBar(BuildContext ctx, String copy, String text) {
    Clipboard.setData(ClipboardData(text: copy));
    HapticFeedback.vibrate();
    Scaffold.of(ctx).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        duration: Duration(milliseconds: 300),
        content: Text('$text copied to Clipboard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 500),
      opacity: _show ? 1.0 : 0.0,
      child: Card(
        color: Theme.of(context).primaryColor.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            width: 1,
            color: Theme.of(context).primaryColor,
          ),
        ),
        margin: EdgeInsets.only(top: 2, left: 5, right: 5),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 5),
          leading: GestureDetector(
            onTap: () => gestureNavigator(context),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/images/default_profile.jpg'),
            ),
          ),
          title: GestureDetector(
            onTap: () => gestureNavigator(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.customer.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          isThreeLine: true,
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                child: Card(
                  color: Colors.red[300],
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      '${widget.customer.accountNumber}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onTap: () => gestureNavigator(context),
                onLongPress: () => copyAndShowSnackBar(
                    context, widget.customer.accountNumber, 'Account number'),
              ),
              GestureDetector(
                child: Card(
                  color: Colors.teal,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      '${widget.customer.macId}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onTap: () => gestureNavigator(context),
                onLongPress: () => copyAndShowSnackBar(
                    context, widget.customer.macId, 'MAC-Id'),
              ),
            ],
          ),
          trailing: GestureDetector(
            onTap: () => gestureNavigator(context),
            child: Text(
              widget.customer.currentStatus,
              softWrap: true,
              style: TextStyle(
                color: widget.customer.currentStatus == 'Inactive'
                    ? Colors.red
                    : widget.customer.currentStatus == 'Active'
                        ? Colors.teal[700]
                        : Colors.yellow,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
