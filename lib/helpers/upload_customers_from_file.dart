import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';

class PickFile {
  static Future<void> pickFileAndAddCustomers(BuildContext context) async {
    File? file;
    int count = 0;
    List<List<String>> details = [];
    List<String> errors = [];
    Map<AreaData, int> containedAreas = {};
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('File format (.csv file)'),
        content: const Text(
            'Please upload a csv file. \n\nThe format of file must be: \n\ncustomer name (max 30 characters), address (max 50 characters), phone number (10 numbers), account number (number), mac_id, area name, plan \n\nEach value must be separated by a comma (,)'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check_circle),
            color: Theme.of(ctx).primaryColor,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
    try {
      final pickedfile = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (pickedfile != null && pickedfile.files.isNotEmpty && pickedfile.files.first.path != null) {
        file = File(pickedfile.files.first.path!);
      }
    } catch (_) {}

    if (file == null) return;

    try {
      Stream<List<int>> inputStream = file.openRead();
      inputStream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((String line) {
        final list = line.split(',');
        details.add(list);
        count += 1;
        if (list.length != 7) {
          errors.add('${errors.length + 1} : Please check the format of file.');
        } else {
          final nVal = nameValidator(list.first);
          if (nVal != null) errors.add('${errors.length + 1} : $nVal');
          final aVal = addressValidator(list[1]);
          if (aVal != null) errors.add('${errors.length + 1} : $aVal');
          final pVal = phoneValidator(list[2]);
          if (pVal != null) errors.add('${errors.length + 1} : $pVal');
          final dVal1 = defaultValidator(list[3]);
          if (dVal1 != null) errors.add('${errors.length + 1} : $dVal1');
          final dVal2 = defaultValidator(list[4]);
          if (dVal2 != null) errors.add('${errors.length + 1} : $dVal2');
          if (!areas.any((element) => element.areaName.trim() == list[5].trim())) {
            errors.add('${errors.length + 1} : Area not found!');
          }
          final planParsed = double.tryParse(list[6]);
          if (planParsed == null ||
              operatorDetails?.plans.any((element) => element == planParsed) != true) {
            errors.add('${errors.length + 1} : Plan not found');
          }
        }
      }, onDone: () async {
        if (errors.isNotEmpty) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Bad file format !'),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: errors.length,
                  itemBuilder: (context, index) => Text(errors[index]),
                ),
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.check_circle),
                  color: Theme.of(ctx).primaryColor,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          );
        }
        if (count <= 200 && errors.isEmpty) {
          try {
            DefaultDialogBox.loadingDialog(
              context,
              blur: false,
              title: 'Takes long time, Please do not quit app!',
            );
            List<Customer> customers = [];
            final op = operatorDetails;
            final user = firebaseUser;
            if (op == null || user == null) throw Exception('User not ready');

            for (int i = 0; i < details.length; i++) {
              final area = areas
                  .firstWhere((element) => element.areaName.trim() == details[i][5].trim());
              customers.add(Customer(
                id: '',
                name: details[i][0].trim(),
                macId: details[i][4].trim(),
                areaId: area.id,
                address: details[i][1].trim(),
                currentPlan: double.parse(details[i][6].trim()),
                phoneNumber: details[i][2].trim(),
                accountNumber: details[i][3].trim(),
                runningYear: DateTime.now().year,
                networkProviderId: op.id,
              ));
            }
            final instance = FirebaseFirestore.instance
                .collection('users/${op.id}/areas');
            count = 0;
            for (int i = 0; i < customers.length; i++) {
              final newInst = instance
                  .doc(customers[i].areaId)
                  .collection('customers')
                  .doc();
              final area = areas
                  .firstWhere((element) => element.id == customers[i].areaId);
              containedAreas.update(area, (value) => value + 1,
                  ifAbsent: () => 1);
              int newVal = area.totalAccounts + (containedAreas[area] ?? 0);
              int newInVal = area.inActiveAccounts + (containedAreas[area] ?? 0);
              await newInst.set(customers[i].toJson()..['id'] = newInst.id);
              await FirebaseFirestore.instance
                  .collection('users/${user.uid}/areas')
                  .doc(customers[i].areaId)
                  .update({
                'ta': newVal,
                'iaa': newInVal,
              });
              count += 1;
              if (count == 1) {
                Fluttertoast.showToast(msg: '$count customer added');
              } else {
                Fluttertoast.showToast(msg: '$count customers added');
              }
            }
            await Future.delayed(const Duration(seconds: 3));
            Navigator.of(context).pushNamedAndRemoveUntil(
                BottomTabsScreen.routeName, (route) => false);
          } on PlatformException catch (error) {
            await Future.delayed(const Duration(seconds: 3));
            Navigator.of(context).pushNamedAndRemoveUntil(
                BottomTabsScreen.routeName, (route) => false);
            DefaultDialogBox.errorDialog(context,
                content: '${error.message}\n\n$count successfully added!');
          } catch (_) {
            await Future.delayed(const Duration(seconds: 3));
            Navigator.of(context).pushNamedAndRemoveUntil(
                BottomTabsScreen.routeName, (route) => false);
            DefaultDialogBox.errorDialog(context,
                content: 'Something went wrong!\n\n$count successfully added!');
          }
        } else if (count > 200) {
          DefaultDialogBox.errorDialog(
            context,
            title: 'Limit exceeded!',
            content: 'Maximum number of customer details is greater than 200',
          );
        }
      }, onError: (e) {
        errors.add(e.toString());
        DefaultDialogBox.errorDialog(context,
            title: 'Bad file !', content: e.toString());
      }, cancelOnError: true);
    } catch (_) {
      DefaultDialogBox.errorDialog(context);
    }
  }
}
