import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';

class DatabaseService {
  static Future<void> getuserData() async {
    final user = firebaseUser;
    if (user == null) return;
    final firestoreInstance =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    try {
      DocumentSnapshot document = await firestoreInstance.get();
      if (document.exists && document.data() != null) {
        operatorDetails =
            Operator.fromMap(document.data() as Map<String, dynamic>);
      }
    } on PlatformException catch (error) {
      Fluttertoast.showToast(msg: error.message ?? 'Error getting user data');
    } catch (_) {
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> addNewCustomer(
    BuildContext context, {
    required Customer customer,
    File? file,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      String? url;
      final area = areas.firstWhere((element) => element.id == customer.areaId);
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');

      final firestoreInstance = FirebaseFirestore.instance
          .collection('users/${op.id}/customers')
          .doc();

      if (file != null) {
        try {
          final ref = FirebaseStorage.instance.ref().child(
              'customerPictures/${op.id}/${firestoreInstance.id}/profilePicture.png');
          final uploadTask = await ref.putFile(file);
          url = await uploadTask.ref.getDownloadURL();
          Fluttertoast.showToast(msg: 'Profile picture uploaded!');
        } on PlatformException catch (error) {
          Fluttertoast.showToast(
              msg: error.message ?? 'Picture upload failed');
        } catch (_) {
          Fluttertoast.showToast(msg: 'ERROR : picture upload failed!');
        }
      }

      await firestoreInstance.set(customer.toJson()
        ..['id'] = firestoreInstance.id
        ..['piUrl'] = url);

      final data = {
        'ta': area.totalAccounts + 1,
        'aa': customer.currentStatus == 'Active'
            ? area.activeAccounts + 1
            : area.activeAccounts,
        'iaa': customer.currentStatus == 'Active'
            ? area.inActiveAccounts
            : area.inActiveAccounts + 1,
      };

      final user = firebaseUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users/${user.uid}/areas')
            .doc(customer.areaId)
            .update(data);
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
          BottomTabsScreen.routeName, (route) => false);
      Fluttertoast.showToast(msg: 'Customer successfully added!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Error adding customer');
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> updateCustomerData(
    BuildContext context, {
    required Map<String, dynamic> data,
    required String customerId,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      await FirebaseFirestore.instance
          .collection('users/${op.id}/customers')
          .doc(customerId)
          .update(data);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Successfully updated!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Update failed');
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> updateCustomerPicture(
    BuildContext context, {
    required File file,
    required String customerId,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      final ref = FirebaseStorage.instance.ref().child(
          'customerPictures/${op.id}/$customerId/profilePicture.png');
      final task = await ref.putFile(file);
      final url = await task.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users/${op.id}/customers')
          .doc(customerId)
          .update({'piUrl': url});
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Profile picture updated!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Update picture failed');
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : picture upload failed!');
    }
  }

  static Future<void> uploadProfilePicture(
    BuildContext context, {
    required File file,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      final ref = FirebaseStorage.instance
          .ref()
          .child('profilePictures/${op.id}/profilePicture.png');
      final task = await ref.putFile(file);
      final url = await task.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(op.id)
          .update({'pil': url});
      await getuserData();
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Profile picture updated!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Picture upload failed');
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : picture upload failed!');
    }
  }

  static Future<void> updateData(
    BuildContext context, {
    required Map<String, dynamic> data,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(op.id)
          .update(data);
      await getuserData();
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Successfully updated!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Update failed');
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> addArea(
    BuildContext context, {
    required Map<String, dynamic> data,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final user = firebaseUser;
      if (user == null) throw Exception('User not logged in');
      final firestoreInstance = FirebaseFirestore.instance
          .collection('users/${user.uid}/areas')
          .doc();
      await firestoreInstance.set(data..['id'] = firestoreInstance.id);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'New area created successfully!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Add area failed');
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> deleteArea(BuildContext context, String areaId) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      final instance = FirebaseFirestore.instance
          .collection('users/${op.id}/areas')
          .doc(areaId);
      await instance.delete();
      final customerInstance = FirebaseFirestore.instance
          .collection('users/${op.id}/customers');
      final doc =
          await customerInstance.where('areaId', isEqualTo: areaId).get();
      for (int i = 0; i < doc.docs.length; i++) {
        await customerInstance.doc(doc.docs[i].id).delete();
      }
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Area successfully deleted!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Delete area failed');
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> updateArea(
    BuildContext context, {
    required Map<String, dynamic> data,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final user = firebaseUser;
      if (user == null) throw Exception('User not logged in');
      await FirebaseFirestore.instance
          .collection('users/${user.uid}/areas')
          .doc(data['id'])
          .update(data);
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Update area failed');
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> rechargeCustomer(
    BuildContext context, {
    required String customerId,
    required String areaId,
    required double plan,
    required String status,
    required int term,
    required bool billPay,
    required int unPaidNo,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      final ref = FirebaseFirestore.instance
          .collection('users/${op.id}/customers')
          .doc(customerId);
      final docs = await ref.collection('recharges').orderBy('ymRec').get();
      Recharge? recent;
      int monthCode = DateTime.now().month;
      int rechargeYear = DateTime.now().year;
      if (docs.docs.isNotEmpty) {
        recent = Recharge.fromMap(docs.docs.last.data());
        if (recent.ymRec.year > rechargeYear) {
          rechargeYear = recent.ymRec.year;
          monthCode = recent.ymRec.month + 1;
        } else if (recent.ymRec.year == rechargeYear &&
            recent.ymRec.month >= monthCode) {
          monthCode = recent.ymRec.month + 1;
        }
      }
      for (int i = 0; i < term; i++) {
        if (monthCode > 12) {
          monthCode = 1;
          rechargeYear += 1;
        }
        final rechargeRef = ref.collection('recharges').doc();
        final activeRecharge = Recharge(
          id: rechargeRef.id,
          status: true,
          addInfo: null,
          date: null,
          ymRec: DateTime(rechargeYear, monthCode),
          billPay: billPay,
          plan: plan.toString(),
        ).toJson()
          ..['date'] = FieldValue.serverTimestamp();
        await rechargeRef.set(activeRecharge);
        monthCode += 1;
      }
      await ref.update({
        'curSts': 'Active',
        'runYear': rechargeYear,
        'expMon': monthCode - 1,
        'noOfPenBil': billPay ? unPaidNo : unPaidNo + term,
      });
      if (status != 'Active') {
        final area = areas.firstWhere((element) => element.id == areaId);
        await updateArea(context, data: {
          'id': areaId,
          'aa': area.activeAccounts + 1,
          'iaa': area.inActiveAccounts - 1,
        });
      }
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Activation successful!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Activation failed');
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> deactivateCustomer(
    BuildContext context, {
    required String customerId,
    required String areaId,
    required String year,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      final ref = FirebaseFirestore.instance
          .collection('users/${op.id}/customers')
          .doc(customerId);
      final docs = await ref.collection('recharges').orderBy('ymRec').get();
      if (docs.docs.isEmpty) {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'No recharges found');
        return;
      }
      final recent = Recharge.fromMap(docs.docs.last.data());
      final now = DateTime.now();
      if (recent.ymRec.year == now.year && recent.ymRec.month <= now.month) {
        await ref.collection('recharges').doc(recent.id).update({
          'addInfo': 'DC: ${DateFormat('dd, MMMM / yyyy').format(DateTime.now())}'
        });
        await ref.update({'curSts': 'Inactive'});
        final area = areas.firstWhere((element) => element.id == areaId);
        await updateArea(context, data: {
          'id': areaId,
          'aa': area.activeAccounts - 1,
          'iaa': area.inActiveAccounts + 1,
        });
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'Deactivation successful!');
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg:
                'Deactivation not possible!\nPlease delete the future recharges');
      }
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Deactivation failed');
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> billPaid(
    BuildContext context, {
    required String customerId,
    required String year,
    required String rechargeId,
    required int unpaidBillno,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      final ref = FirebaseFirestore.instance
          .collection('users/${op.id}/customers');
      await ref.doc(customerId).update({'noOfPenBil': unpaidBillno - 1});
      await ref
          .doc(customerId)
          .collection('recharges')
          .doc(rechargeId)
          .update({'billPay': true});
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Bill payment failed');
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<bool> deleteRecharge(
    BuildContext context, {
    required String customerId,
    required String areaId,
    required Recharge recharge,
    required int unPaidNo,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    int updateYear = DateTime.now().year;
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      String status = 'Inactive';
      int month = 0;
      final ref = FirebaseFirestore.instance
          .collection('users/${op.id}/customers');
      await ref
          .doc(customerId)
          .collection('recharges')
          .doc(recharge.id)
          .delete();
      if (recharge.billPay != null && !recharge.billPay!) {
        await ref.doc(customerId).update({'noOfPenBil': unPaidNo - 1});
      }
      final docs = await ref
          .doc(customerId)
          .collection('recharges')
          .orderBy('ymRec')
          .get();
      if (docs.docs.isNotEmpty) {
        final recent = Recharge.fromMap(docs.docs.last.data());
        updateYear = recent.ymRec.year;
        status = recent.status ? 'Active' : 'Inactive';
        month = recent.ymRec.month;
      }
      await FirebaseFirestore.instance
          .collection('users/${op.id}/customers')
          .doc(customerId)
          .update({'runYear': updateYear, 'curSts': status, 'expMon': month});
      if (status == 'Inactive') {
        final area = areas.firstWhere((element) => element.id == areaId);
        if (area.activeAccounts > 0) {
          await updateArea(context, data: {
            'id': areaId,
            'aa': area.activeAccounts - 1,
            'iaa': area.inActiveAccounts + 1,
          });
        }
      }
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Delete recharge failed');
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
    return recharge.ymRec.year != updateYear;
  }

  static Future<void> deleteCustomer(
    BuildContext context, {
    required String areaId,
    required String customerId,
    required bool isActive,
    required int totalCount,
    required int otherCount,
  }) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final op = operatorDetails;
      if (op == null) throw Exception('Operator details missing');
      final custInst = FirebaseFirestore.instance
          .collection('users/${op.id}/customers')
          .doc(customerId);
      final areaInst = FirebaseFirestore.instance
          .collection('users/${op.id}/areas')
          .doc(areaId);
      final key = isActive ? 'aa' : 'iaa';
      await custInst.delete();
      await areaInst.update({
        'ta': totalCount - 1,
        key: otherCount - 1,
      });
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Customer successfully deleted!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message ?? 'Delete customer failed');
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }
}
