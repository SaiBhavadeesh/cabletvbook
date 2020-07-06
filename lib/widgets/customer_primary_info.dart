import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomerPrimaryInfo extends StatelessWidget {
  final String phoneNumber;
  final String accountNumber;
  final String macId;
  final bool moreInfo;

  CustomerPrimaryInfo({
    @required this.phoneNumber,
    @required this.accountNumber,
    @required this.macId,
    @required this.moreInfo,
  });

  final moreInfoController = TextEditingController();

  void copyTextOnLongTap(
    BuildContext ctx,
    String copy,
    String text,
  ) {
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: moreInfo ? width * 0.38 : width * 0.28,
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        isThreeLine: true,
        title: Padding(
          padding: const EdgeInsets.all(4.0),
          child: RichText(
            text: TextSpan(
              text: 'Phone : ',
              style: TextStyle(fontSize: width * 0.05, color: Colors.black54),
              children: [
                TextSpan(
                  text: phoneNumber,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () =>
                  copyTextOnLongTap(context, accountNumber, 'Account number'),
              child: Card(
                color: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Account no : ',
                      children: [
                        TextSpan(
                          text: accountNumber,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => copyTextOnLongTap(context, macId, 'MAC-Id'),
              child: Card(
                color: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'MAC Id : ',
                      children: [
                        TextSpan(
                          text: macId,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: moreInfo ? width * 0.10 : 0,
              padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
              child: TextFormField(
                controller: moreInfoController,
                enabled: moreInfo,
                decoration: InputDecoration(
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow),
                  ),
                  labelText: moreInfo ? 'Temperory Info' : null,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.call,
            size: height * 0.05,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}
