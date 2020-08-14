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

  void gestureNavigator(BuildContext ctx, Customer customer) {
    Navigator.of(ctx)
        .pushNamed(CustomerDetailScreen.routeName, arguments: customer);
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
            onTap: () => gestureNavigator(context, widget.customer),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: widget.customer.profileImageUrl == null
                  ? AssetImage('assets/images/default_profile.jpg')
                  : NetworkImage(widget.customer.profileImageUrl),
            ),
          ),
          title: GestureDetector(
            onTap: () => gestureNavigator(context, widget.customer),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  widget.customer.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          isThreeLine: true,
          subtitle: FittedBox(
            fit: BoxFit.contain,
            child: Row(
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
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  onTap: () => gestureNavigator(context, widget.customer),
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
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  onTap: () => gestureNavigator(context, widget.customer),
                  onLongPress: () => copyAndShowSnackBar(
                      context, widget.customer.macId, 'MAC-Id'),
                ),
              ],
            ),
          ),
          trailing: GestureDetector(
            onTap: () => gestureNavigator(context, widget.customer),
            child: Text(
              widget.customer.currentStatus,
              softWrap: true,
              style: TextStyle(
                fontSize: 16,
                color: widget.customer.currentStatus == 'Inactive'
                    ? Colors.orange[900]
                    : Colors.yellow,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
