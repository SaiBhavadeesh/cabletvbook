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
    final _firestoreInstance =
        FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid);
    try {
      DocumentSnapshot document = await _firestoreInstance.get();
      operatorDetails = Operator.fromMap(document.data());
    } on PlatformException catch (error) {
      Fluttertoast.showToast(msg: error.message);
    } catch (_) {
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> addNewCustomer(BuildContext context,
      {@required Customer customer, @required File file}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      String url;
      final area = areas.firstWhere((element) => element.id == customer.areaId);
      final _firestoreInstance = FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/customers')
          .doc();
      if (file != null)
        try {
          final _ref = FirebaseStorage.instance.ref().child(
              'customerPictures/${operatorDetails.id}/${_firestoreInstance.id}/profilePicture.png');
          await _ref.putFile(file).onComplete;
          url = await _ref.getDownloadURL();
          Fluttertoast.showToast(msg: 'Profile picture uploaded!');
        } on PlatformException catch (error) {
          Fluttertoast.showToast(msg: error.message);
        } catch (_) {
          Fluttertoast.showToast(msg: 'ERROR : picture upload failed!');
        }
      await _firestoreInstance.set(customer.toJson()
        ..['id'] = _firestoreInstance.id
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
      await FirebaseFirestore.instance
          .collection('users/${firebaseUser.uid}/areas')
          .doc(customer.areaId)
          .update(data);
      Navigator.of(context).pushNamedAndRemoveUntil(
          BottomTabsScreen.routeName, (route) => false);
      Fluttertoast.showToast(msg: 'Customer successfully added!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message);
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> updateCustomerData(BuildContext context,
      {@required Map<String, dynamic> data,
      @required String customerId}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      await FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/customers')
          .doc(customerId)
          .update(data);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Successfully updated!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message);
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> updateCustomerPicture(BuildContext context,
      {@required File file, @required String customerId}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      final _ref = FirebaseStorage.instance.ref().child(
          'customerPictures/${operatorDetails.id}/$customerId/profilePicture.png');
      await _ref.putFile(file).onComplete;
      final url = await _ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/customers')
          .doc(customerId)
          .update({'piUrl': url});
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Profile picture updated!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message);
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : picture upload failed!');
    }
  }

  static Future<void> uploadProfilePicture(BuildContext context,
      {@required File file}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      final _ref = FirebaseStorage.instance
          .ref()
          .child('profilePictures/${operatorDetails.id}/profilePicture.png');
      await _ref.putFile(file).onComplete;
      final url = await _ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(operatorDetails.id)
          .update({'pil': url});
      await getuserData();
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Profile picture updated!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message);
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : picture upload failed!');
    }
  }

  static Future<void> updateData(BuildContext context,
      {@required Map<String, dynamic> data}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(operatorDetails.id)
          .update(data);
      await getuserData();
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Successfully updated!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message);
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> addArea(BuildContext context,
      {@required Map<String, dynamic> data}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      final _firestoreInstance = FirebaseFirestore.instance
          .collection('users/${firebaseUser.uid}/areas')
          .doc();
      await _firestoreInstance.set(data..['id'] = _firestoreInstance.id);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'New area created successfully!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message);
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> deleteArea(BuildContext context, String areaId) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      final _instance = FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/areas')
          .doc(areaId);
      await _instance.delete();
      final _customerInstance = FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/customers');
      final doc =
          await _customerInstance.where('areaId', isEqualTo: areaId).get();
      for (int i = 0; i < doc.docs.length; i++) {
        await _customerInstance.doc(doc.docs[i].id).delete();
      }
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Area successfully deleted!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message);
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> updateArea(BuildContext context,
      {@required Map<String, dynamic> data}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      await FirebaseFirestore.instance
          .collection('users/${firebaseUser.uid}/areas')
          .doc(data['id'])
          .update(data);
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message);
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> rechargeCustomer(BuildContext context,
      {@required String customerId,
      @required String areaId,
      @required double plan,
      @required String status,
      @required int term,
      @required bool billPay,
      @required int unPaidNo}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      final _ref = FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/customers')
          .doc(customerId);
      final docs = await _ref.collection('recharges').orderBy('ymRec').get();
      Recharge recent;
      int monthCode = DateTime.now().month;
      int rechargeYear = DateTime.now().year;
      if (docs.docs.isNotEmpty) {
        recent = Recharge.fromMap(docs.docs.last);
        if (recent.ymRec.year > rechargeYear) {
          rechargeYear = recent.ymRec.year;
          monthCode = recent.ymRec.month + 1;
        } else if (recent.ymRec.year == rechargeYear &&
            recent.ymRec.month >= monthCode) monthCode = recent.ymRec.month + 1;
      }
      for (int i = 0; i < term; i++) {
        if (monthCode % 13 == 0) {
          monthCode = 1;
          rechargeYear += 1;
        }
        final _rechargeRef = _ref.collection('recharges').doc();
        final activeRecharge = Recharge(
                id: _rechargeRef.id,
                status: true,
                addInfo: null,
                date: null,
                ymRec: DateTime(rechargeYear, monthCode),
                billPay: billPay,
                plan: plan.toString())
            .toJson()
              ..['date'] = FieldValue.serverTimestamp();
        await _rechargeRef.set(activeRecharge);
        monthCode += 1;
      }
      await _ref.update({
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
          'iaa': area.inActiveAccounts - 1
        });
      }
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Activation successful!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message);
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> deactivateCustomer(BuildContext context,
      {@required String customerId,
      @required String areaId,
      @required String year}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      final _ref = FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/customers')
          .doc(customerId);
      final docs = await _ref.collection('recharges').orderBy('ymRec').get();
      final recent = Recharge.fromMap(docs.docs.last);
      if (recent.ymRec.year == DateTime.now().year &&
          recent.ymRec.month <= DateTime.now().month) {
        await _ref.collection('recharges').doc(recent.id).update({
          'addInfo':
              'DC: ${DateFormat('dd, MMMM / yyyy').format(DateTime.now())}'
        });
        await _ref.update({'curSts': 'Inactive'});
        final area = areas.firstWhere((element) => element.id == areaId);
        await updateArea(context, data: {
          'id': areaId,
          'aa': area.activeAccounts - 1,
          'iaa': area.inActiveAccounts + 1
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
      Fluttertoast.showToast(msg: error.message);
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<void> billPaid(
    BuildContext context, {
    @required String customerId,
    @required String year,
    @required String rechargeId,
    @required int unpaidBillno,
  }) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      final _ref = FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/customers');
      await _ref.doc(customerId).update({'noOfPenBil': unpaidBillno - 1});
      await _ref
          .doc(customerId)
          .collection('recharges')
          .doc(rechargeId)
          .update({'billPay': true});
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message);
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }

  static Future<bool> deleteRecharge(BuildContext context,
      {@required String customerId,
      @required String areaId,
      @required Recharge recharge,
      @required int unPaidNo}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    int updateYear = DateTime.now().year;
    try {
      String status = 'Inactive';
      int month = 0;
      final _ref = FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/customers');
      await _ref
          .doc(customerId)
          .collection('recharges')
          .doc(recharge.id)
          .delete();
      if (recharge.billPay != null && !recharge.billPay)
        await _ref.doc(customerId).update({'noOfPenBil': unPaidNo - 1});
      final docs = await _ref
          .doc(customerId)
          .collection('recharges')
          .orderBy('ymRec')
          .get();
      if (docs.docs.isNotEmpty) {
        final recent = Recharge.fromMap(docs.docs.last);
        updateYear = recent.ymRec.year;
        status = recent.status ? 'Active' : 'Inactive';
        month = recent.ymRec.month;
      }
      await FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/customers')
          .doc(customerId)
          .update({'runYear': updateYear, 'curSts': status, 'expMon': month});
      if (status == 'Inactive') {
        final area = areas.firstWhere((element) => element.id == areaId);
        if (area.activeAccounts > 0)
          await updateArea(context, data: {
            'id': areaId,
            'aa': area.activeAccounts - 1,
            'iaa': area.inActiveAccounts + 1
          });
      }
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message);
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
    return recharge.ymRec.year != updateYear ? true : false;
  }

  static Future<void> deleteCustomer(BuildContext context,
      {@required String areaId,
      @required String customerId,
      @required bool isActive,
      @required int totalCount,
      @required int otherCount}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      final _custInst = FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/customers')
          .doc(customerId);
      final _areaInst = FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/areas')
          .doc(areaId);
      final key = isActive ? 'aa' : 'iaa';
      await _custInst.delete();
      await _areaInst.update({
        'ta': totalCount - 1,
        key: otherCount - 1,
      });
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Customer successfully deleted!');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: error.message);
    } catch (_) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'ERROR : something went wrong!');
    }
  }
}
