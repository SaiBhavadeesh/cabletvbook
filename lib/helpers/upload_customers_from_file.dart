import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';

class PickFile {
  static Future<void> pickFileAndAddCustomers(BuildContext context) async {
    File file;
    int count = 0;
    List<List<String>> details = [];
    List<String> errors = [];
    Map<AreaData, int> containedAreas = {};
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('File format (.csv file)'),
        content: Text(
            'Please upload a csv file. \n\nThe format of file must be: \n\ncustomer name (max 30 characters), address (max 50 characters), phone number (10 numbers), account number (number), mac_id, area name, plan \n\nEach value must be seperated by a comma(\,)'),
        actions: <Widget>[
          IconButton(
            icon: Icon(FlutterIcons.check_circle_faw),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
    try {
      final pickedfile = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: FileType.custom,
          allowedExtensions: ['csv']);
      file = File(pickedfile.files.first.path);
    } catch (_) {}
    if (file != null) {
      try {
        Stream<List<int>> inputStream = file.openRead();
        inputStream
            .transform(utf8.decoder)
            .transform(new LineSplitter())
            .listen((String line) {
          final list = line.split(',');
          details.add(list);
          count += 1;
          if (list.length != 7)
            errors
                .add('${errors.length + 1} : Please check the format of file.');
          else {
            if (nameValidator(list.first) != null)
              errors.add('${errors.length + 1} : ' + nameValidator(list.first));
            if (addressValidator(list[1]) != null)
              errors.add('${errors.length + 1} : ' + addressValidator(list[1]));
            if (phoneValidator(list[2]) != null)
              errors.add('${errors.length + 1} : ' + phoneValidator(list[2]));
            if (defaultValidator(list[3]) != null)
              errors.add('${errors.length + 1} : ' + defaultValidator(list[3]));
            if (defaultValidator(list[4]) != null)
              errors.add('${errors.length + 1} : ' + defaultValidator(list[4]));
            if (!areas
                .any((element) => element.areaName.trim() == list[5].trim()))
              errors.add('${errors.length + 1} : Area not found!');
            if (!operatorDetails.plans
                .any((element) => element == double.parse(list[6])))
              errors.add('${errors.length + 1} : Plan not found');
          }
        }, onDone: () async {
          if (errors.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Bad file format !'),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: errors.length,
                    itemBuilder: (context, index) => Text(errors[index]),
                  ),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(FlutterIcons.check_circle_faw),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          }
          if (count <= 200 && errors.isEmpty) {
            try {
              DefaultDialogBox.loadingDialog(context,
                  blur: false,
                  title: 'Takes long time, Please do not quit app!',
                  loaderType: SelectLoader.ballSpinFadeLoader);
              List<Customer> customers = [];
              for (int i = 0; i < details.length; i++) {
                final area = areas
                    .firstWhere((element) => element.areaName == details[i][5]);
                customers.add(Customer(
                    id: null,
                    name: details[i][0],
                    macId: details[i][4],
                    areaId: area.id,
                    address: details[i][1],
                    currentPlan: double.parse(details[i][6]),
                    phoneNumber: details[i][2],
                    accountNumber: details[i][3],
                    runningYear: DateTime.now().year,
                    networkProviderId: operatorDetails.id));
              }
              final _instance = FirebaseFirestore.instance
                  .collection('users/${operatorDetails.id}/areas');
              count = 0;
              for (int i = 0; i < customers.length; i++) {
                final _newInst = _instance
                    .doc(customers[i].areaId)
                    .collection('customers')
                    .doc();
                final area = areas
                    .firstWhere((element) => element.id == customers[i].areaId);
                containedAreas.update(area, (value) => value + 1,
                    ifAbsent: () => 1);
                int newVal = area.totalAccounts + containedAreas[area];
                int newInVal = area.inActiveAccounts + containedAreas[area];
                await _newInst.set(customers[i].toJson()..['id'] = _newInst.id);
                await FirebaseFirestore.instance
                    .collection('users/${firebaseUser.uid}/areas')
                    .doc(customers[i].areaId)
                    .update({
                  'ta': newVal,
                  'iaa': newInVal
                });
                count += 1;
                if (count == 1)
                  Fluttertoast.showToast(msg: '$count customer added');
                else
                  Fluttertoast.showToast(msg: '$count customers added');
              }
              await Future.delayed(Duration(seconds: 3));
              Navigator.of(context).pushNamedAndRemoveUntil(
                  BottomTabsScreen.routeName, (route) => false);
            } on PlatformException catch (error) {
              await Future.delayed(Duration(seconds: 3));
              Navigator.of(context).pushNamedAndRemoveUntil(
                  BottomTabsScreen.routeName, (route) => false);
              DefaultDialogBox.errorDialog(context,
                  content: error.message + '\n\n$count successfully added!');
            } catch (_) {
              await Future.delayed(Duration(seconds: 3));
              Navigator.of(context).pushNamedAndRemoveUntil(
                  BottomTabsScreen.routeName, (route) => false);
              DefaultDialogBox.errorDialog(context,
                  content:
                      'Something went wrong!\n\n$count successfully added!');
            }
          } else if (count > 200) {
            DefaultDialogBox.errorDialog(context,
                title: 'Limit exceeded!',
                content:
                    'Maximu number of customer details is greater than 50');
          }
        }, onError: (e) {
          errors.add(e.toString());
          DefaultDialogBox.errorDialog(context,
              title: 'Bad file !', content: e.message);
        }, cancelOnError: true);
      } catch (_) {
        DefaultDialogBox.errorDialog(context);
      }
    }
  }
}
