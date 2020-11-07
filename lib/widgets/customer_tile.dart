import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:cableTvBook/screens/customer_detail_screen.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';

class CustomerTile extends StatefulWidget {
  final Customer customer;
  final int index;

  CustomerTile({@required this.customer, @required this.index});

  @override
  _CustomerTileState createState() => _CustomerTileState();
}

class _CustomerTileState extends State<CustomerTile> {
  void gestureNavigator(BuildContext ctx) {
    Navigator.of(ctx)
        .pushNamed(CustomerDetailScreen.routeName, arguments: widget.customer)
        .then((value) => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (ctx) => BottomTabsScreen(index: 1)),
            (route) => false));
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

  Future<void> deleteCustomer(BuildContext ctx) async {
    return showDialog(
        context: ctx,
        builder: (ctx) => AlertDialog(
              title: Text('Delete customer'),
              content: Text('Are you sure?'),
              actions: <Widget>[
                IconButton(
                    icon: Icon(FlutterIcons.check_circle_faw),
                    onPressed: () async {
                      final area = areas.firstWhere(
                          (element) => element.id == widget.customer.areaId);
                      await DatabaseService.deleteCustomer(ctx,
                          areaId: area.id,
                          customerId: widget.customer.id,
                          isActive: widget.customer.currentStatus == 'Active'
                              ? true
                              : false,
                          totalCount: area.totalAccounts,
                          otherCount: widget.customer.currentStatus == 'Active'
                              ? area.activeAccounts
                              : area.inActiveAccounts);
                      Navigator.of(ctx).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (ctx) => BottomTabsScreen(index: 1)),
                          (route) => false);
                    }),
                SizedBox(width: 10),
                IconButton(
                    icon: Icon(FlutterIcons.cancel_mdi,
                        color: Theme.of(context).errorColor),
                    onPressed: () => Navigator.pop(ctx))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Card(
      key: ValueKey(widget.customer.id),
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
        onTap: () => gestureNavigator(context),
        onLongPress: () => deleteCustomer(context),
        contentPadding: EdgeInsets.symmetric(horizontal: 5),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: widget.customer.profileImageUrl == null
              ? AssetImage('assets/images/default_profile.jpg')
              : NetworkImage(widget.customer.profileImageUrl),
        ),
        title: SizedBox(
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.contain,
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.005),
                child: Text(
                  widget.customer.name,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            height: size.height * 0.0455),
        subtitle: SizedBox(
          height: size.height * 0.0575,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.contain,
            child: Row(
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
                  onDoubleTap: () => copyAndShowSnackBar(
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
                  onDoubleTap: () => copyAndShowSnackBar(
                      context, widget.customer.macId, 'MAC-Id'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
