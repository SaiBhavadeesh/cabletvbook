import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settingsScreen';

  Widget getTitle(BuildContext context, String title) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget getdetailText(BuildContext context, String text, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Divider(
            indent: 0,
            endIndent: size.width * 0.9,
            thickness: 2,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('General Settings'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          getTitle(
            context,
            'Account Settings',
          ),
          getdetailText(
            context,
            'Change Email',
            size,
          ),
          getdetailText(
            context,
            'Change Phone number',
            size,
          ),
          getTitle(
            context,
            'Privacy Settings',
          ),
          getdetailText(
            context,
            'Change Security pin',
            size,
          ),
          getdetailText(
            context,
            'Change Password',
            size,
          ),
        ],
      ),
    );
  }
}


                // () => showDialog(
                //   context: context,
                //   builder: (ctx) {
                //     final formKey = GlobalKey<FormState>();
                //     String phoneNumber;
                //     return AlertDialog(
                //       content: Form(
                //         key: formKey,
                //         child: TextFormField(
                //           initialValue: operatorDetails.phoneNumber.substring(4),
                //           keyboardType: TextInputType.phone,
                //           validator: (value) {
                //             if (!validator.isNumeric(value)) {
                //               return 'Phone number is Invalid!';
                //             }
                //             return null;
                //           },
                //           decoration: InputDecoration(
                //             labelText: 'Edit Phone number',
                //             prefixText: '+ 91 ',
                //           ),
                //           onSaved: (value) {
                //             phoneNumber = '+ 91 ' + value;
                //           },
                //         ),
                //       ),
                //       actions: <Widget>[
                //         FlatButton(
                //           onPressed: () => Navigator.of(ctx).pop(),
                //           child: Text('Cancel'),
                //         ),
                //         FlatButton(
                //           onPressed: () {
                //             if (formKey.currentState.validate()) {
                //               formKey.currentState.save();
                //               setState(() {
                //                 operatorDetails.phoneNumber = phoneNumber;
                //               });
                //               Navigator.of(context).pop();
                //             }
                //           },
                //           child: Text('Save'),
                //         ),
                //       ],
                //     );
                //   },
                // ),
