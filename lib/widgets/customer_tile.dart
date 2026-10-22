import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:cableTvBook/screens/customer_detail_screen.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/helpers/avatar_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomerTile extends StatefulWidget {
  final Customer customer;
  final int index;

  const CustomerTile({super.key, required this.customer, required this.index});

  @override
  _CustomerTileState createState() => _CustomerTileState();
}

class _CustomerTileState extends State<CustomerTile> {
  void gestureNavigator(BuildContext ctx) {
    Navigator.of(ctx)
        .pushNamed(CustomerDetailScreen.routeName, arguments: widget.customer)
        .then((value) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (ctx) => const BottomTabsScreen(index: 1)),
          (route) => false,
        );
      }
    });
  }

  void copyAndShowSnackBar(BuildContext ctx, String copy, String text) {
    Clipboard.setData(ClipboardData(text: copy));
    HapticFeedback.vibrate();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        duration: const Duration(milliseconds: 300),
        content: Text('$text copied to Clipboard'),
      ),
    );
  }

  Future<void> deleteCustomer(BuildContext ctx) async {
    return showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete customer'),
        content: const Text('Are you sure?'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check_circle),
            color: Theme.of(ctx).primaryColor,
            onPressed: () async {
              final area = areas.firstWhere(
                  (element) => element.id == widget.customer.areaId);
              await DatabaseService.deleteCustomer(
                ctx,
                areaId: area.id,
                customerId: widget.customer.id,
                isActive: widget.customer.currentStatus == 'Active',
                totalCount: area.totalAccounts,
                otherCount: widget.customer.currentStatus == 'Active'
                    ? area.activeAccounts
                    : area.inActiveAccounts,
              );
              if (mounted) {
                Navigator.of(ctx).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (c) => const BottomTabsScreen(index: 1)),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.cancel,
                color: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(dialogCtx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primaryColor = Theme.of(context).primaryColor;
    return Card(
      key: ValueKey(widget.customer.id),
      color: primaryColor.withAlpha(178),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          width: 1,
          color: primaryColor,
        ),
      ),
      margin: const EdgeInsets.only(top: 2, left: 5, right: 5),
      child: ListTile(
        onTap: () => gestureNavigator(context),
        onLongPress: () => deleteCustomer(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 5),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: getAvatarImageProvider(widget.customer.profileImageUrl),
        ),
        title: SizedBox(
          height: size.height * 0.0455,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.contain,
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.005),
              child: Text(
                widget.customer.name,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
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
                        widget.customer.accountNumber,
                        style: const TextStyle(
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
                        widget.customer.macId,
                        softWrap: true,
                        style: const TextStyle(
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
