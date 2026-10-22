import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';

class PickFile {
  static List<String> _parseCsvLine(String line) {
    final List<String> result = [];
    final StringBuffer current = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString().trim());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString().trim());
    return result;
  }

  static Future<void> pickFileAndAddCustomers(BuildContext context) async {
    File? file;
    int count = 0;
    List<List<String>> details = [];
    List<String> errors = [];
    bool isLoadingDialogShown = false;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('File format (.csv file)'),
        content: const Text(
          'Please upload a CSV file.\n\nThe format must be:\n\n'
          'customer name (max 30 chars), address (max 50 chars), phone number (10 digits), account number, mac_id, area name, plan\n\n'
          'Values can be comma-separated or quoted.',
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

    try {
      final pickedFiles = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (pickedFiles.isNotEmpty && pickedFiles.first.path != null) {
        file = File(pickedFiles.first.path!);
      }
    } catch (_) {}

    if (file == null) return;

    try {
      final lines = await file
          .openRead()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .toList();

      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        final list = _parseCsvLine(line);
        count += 1;
        details.add(list);

        if (list.length != 7) {
          errors.add('Row $count: Invalid column count (expected 7, got ${list.length}).');
        } else {
          final nVal = nameValidator(list.first);
          if (nVal != null) errors.add('Row $count: $nVal');
          final aVal = addressValidator(list[1]);
          if (aVal != null) errors.add('Row $count: $aVal');
          final pVal = phoneValidator(list[2]);
          if (pVal != null) errors.add('Row $count: $pVal');
          final dVal1 = defaultValidator(list[3]);
          if (dVal1 != null) errors.add('Row $count: Account number error - $dVal1');
          final dVal2 = defaultValidator(list[4]);
          if (dVal2 != null) errors.add('Row $count: Mac ID error - $dVal2');

          final areaExists =
              areas.any((element) => element.areaName.trim() == list[5].trim());
          if (!areaExists) {
            errors.add('Row $count: Area "${list[5]}" not found');
          }

          final planParsed = double.tryParse(list[6]);
          final planValid = planParsed != null &&
              operatorDetails?.plans.any((element) => element == planParsed) ==
                  true;
          if (!planValid) {
            errors.add('Row $count: Plan "${list[6]}" not configured in network');
          }
        }
      }

      if (errors.isNotEmpty) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Validation Errors in CSV'),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: errors.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      errors[index],
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
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
        return;
      }

      if (count > 200) {
        if (context.mounted) {
          DefaultDialogBox.errorDialog(
            context,
            title: 'Limit exceeded!',
            content: 'Maximum allowed records per upload is 200 (found $count).',
          );
        }
        return;
      }

      if (details.isEmpty) {
        Fluttertoast.showToast(msg: 'No records found in CSV file');
        return;
      }

      final op = operatorDetails;
      if (op == null) throw Exception('Operator not initialized');

      if (context.mounted) {
        isLoadingDialogShown = true;
        DefaultDialogBox.loadingDialog(
          context,
          blur: false,
          title: 'Importing $count customers, please wait...',
        );
      }

      final customersCollection =
          FirebaseFirestore.instance.collection('users/${op.id}/customers');
      final areasCollection =
          FirebaseFirestore.instance.collection('users/${op.id}/areas');

      final batch = FirebaseFirestore.instance.batch();
      final Map<String, int> areaCounts = {};

      for (int i = 0; i < details.length; i++) {
        final row = details[i];
        final area =
            areas.firstWhere((a) => a.areaName.trim() == row[5].trim());

        final customerDoc = customersCollection.doc();
        final customer = Customer(
          id: customerDoc.id,
          name: row[0].trim(),
          address: row[1].trim(),
          phoneNumber: row[2].trim().startsWith('+91')
              ? row[2].trim()
              : '+91${row[2].trim()}',
          accountNumber: row[3].trim(),
          macId: row[4].trim(),
          areaId: area.id,
          currentPlan: double.parse(row[6].trim()),
          runningYear: DateTime.now().year,
          networkProviderId: op.id,
          currentStatus: 'Inactive',
        );

        batch.set(customerDoc, customer.toJson());
        areaCounts[area.id] = (areaCounts[area.id] ?? 0) + 1;
      }

      // Update area counts atomically using FieldValue.increment
      for (final entry in areaCounts.entries) {
        batch.update(areasCollection.doc(entry.key), {
          'ta': FieldValue.increment(entry.value),
          'iaa': FieldValue.increment(entry.value),
        });
      }

      await batch.commit();

      // Refresh in-memory area counts
      await DatabaseService.getuserData();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          BottomTabsScreen.routeName,
          (route) => false,
        );
        Fluttertoast.showToast(msg: '$count customers successfully imported!');
      }
    } on PlatformException catch (error) {
      if (context.mounted) {
        if (isLoadingDialogShown && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        DefaultDialogBox.errorDialog(
          context,
          content: '${error.message ?? "Platform error occurred"}\n\n$count imported.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        if (isLoadingDialogShown && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        DefaultDialogBox.errorDialog(
          context,
          content: 'Something went wrong while importing CSV.\n\n$e',
        );
      }
    }
  }
}
