import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/screens/customer_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomerTile extends StatelessWidget {
  final Customer customer;

  CustomerTile({
    @required this.customer,
  });

  void gestureNavigator(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(
      CustomerDetailScreen.routeName,
      arguments: customer,
    );
  }

  void copyAndShowSnackBar(BuildContext ctx, String copy, String text) {
    Clipboard.setData(ClipboardData(text: copy));
    HapticFeedback.vibrate();
    Scaffold.of(ctx).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        duration: Duration(milliseconds: 300),
        content: Text('$text copied to Clipboard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
              customer.name,
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
                    '${customer.accountNumber}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              onTap: () => gestureNavigator(context),
              onLongPress: () => copyAndShowSnackBar(
                  context, customer.accountNumber, 'Account number'),
            ),
            GestureDetector(
              child: Card(
                color: Colors.teal,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '${customer.macId}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              onTap: () => gestureNavigator(context),
              onLongPress: () =>
                  copyAndShowSnackBar(context, customer.macId, 'MAC-Id'),
            ),
          ],
        ),
        trailing: GestureDetector(
          onTap: () => gestureNavigator(context),
          child: Text(
            customer.currentStatus,
            softWrap: true,
            style: TextStyle(
              color: customer.currentStatus == 'Inactive'
                  ? Colors.red
                  : customer.currentStatus == 'Active'
                      ? Colors.teal[700]
                      : Colors.yellow,
            ),
          ),
        ),
      ),
    );
  }
}
