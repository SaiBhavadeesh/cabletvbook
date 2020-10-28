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
      {@required Customer customer,
      Recharge recharge,
      @required File file}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      String url;
      final area = areas.firstWhere((element) => element.id == customer.areaId);
      final _firestoreInstance = FirebaseFirestore.instance
          .collection(
              'users/${operatorDetails.id}/areas/${customer.areaId}/customers')
          .doc();
      if (file != null)
        try {
          final _ref = FirebaseStorage.instance.ref().child(
              'customerPictures/${operatorDetails.id}/${customer.areaId}/${_firestoreInstance.id}/profilePicture.png');
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
        ..['pil'] = url);
      if (customer.currentStatus == 'Active') {
        final _rechargeInstance =
            _firestoreInstance.collection(DateTime.now().year.toString()).doc();
        recharge.id = _rechargeInstance.id;
        await _rechargeInstance
            .set(recharge.toJson()..['date'] = FieldValue.serverTimestamp());
      }
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
      @required String customerId,
      @required areaId}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      await FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/areas/$areaId/customers')
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
      {@required File file,
      @required String customerId,
      @required String areaId}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      final _ref = FirebaseStorage.instance.ref().child(
          'customerPictures/${operatorDetails.id}/$areaId/$customerId/profilePicture.png');
      await _ref.putFile(file).onComplete;
      final url = await _ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/areas/$areaId/customers')
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
      @required String year,
      @required int unPaidNo}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      final _ref = FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/areas/$areaId/customers')
          .doc(customerId);
      final docs = await _ref.collection(year).orderBy('code').get();
      Recharge recent;
      if (docs.docs.isNotEmpty) recent = Recharge.fromMap(docs.docs.last);
      int monthCode = DateTime.now().month;
      int rechargeYear = DateTime.now().year;
      if (int.parse(year) > rechargeYear) rechargeYear = int.parse(year);
      if (docs.docs.isNotEmpty) {
        if (recent.date.year > DateTime.now().year)
          monthCode = recent.code + 1;
        else if (recent.date.year == DateTime.now().year &&
            recent.code >= monthCode) monthCode = recent.code + 1;
      }
      for (int i = 0; i < term; i++) {
        if (monthCode % 13 == 0) {
          monthCode = 1;
          rechargeYear += 1;
        }
        final _rechargeRef = _ref.collection(rechargeYear.toString()).doc();
        final activeRecharge = Recharge(
                id: _rechargeRef.id,
                status: true,
                code: monthCode,
                billPay: billPay,
                plan: plan.toString())
            .toJson()
              ..['date'] = FieldValue.serverTimestamp();
        await _rechargeRef.set(activeRecharge);
        monthCode += 1;
      }
      if (!billPay) await _ref.update({'noOfPenBil': unPaidNo + term});
      await _ref.update({
        'curSts': 'Active',
        'runYear': rechargeYear,
        'expMon': monthCode - 1
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
          .collection('users/${operatorDetails.id}/areas/$areaId/customers')
          .doc(customerId);
      final docs = await _ref.collection(year).orderBy('code').get();
      final recent = Recharge.fromMap(docs.docs.last.data);
      await _ref.collection(year).doc(recent.id).update({
        'addInfo': 'DC: ${DateFormat('dd, MMMM / yyyy').format(DateTime.now())}'
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
    @required String areaId,
    @required String year,
    @required String rechargeId,
    @required int unpaidBillno,
  }) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      final _ref = FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/areas/$areaId/customers');
      await _ref.doc(customerId).update({'noOfPenBil': unpaidBillno - 1});
      await _ref
          .doc(customerId)
          .collection(year)
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
      @required String year,
      @required String startYear,
      @required Recharge recharge,
      @required int unPaidNo}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    bool changed = false;
    Recharge _prev;
    try {
      int updateYear = int.parse(year);
      String status = 'Inactive';
      final _ref = FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/areas/$areaId/customers');
      await _ref.doc(customerId).collection(year).doc(recharge.id).delete();
      if (recharge.billPay != null && !recharge.billPay)
        await _ref.doc(customerId).update({'noOfPenBil': unPaidNo - 1});
      if (recharge.code > 1) {
        final QuerySnapshot prevDoc = await _ref
            .doc(customerId)
            .collection(year)
            .where('code', isEqualTo: recharge.code - 1)
            .get();
        if (prevDoc.docs.isNotEmpty)
          _prev = Recharge.fromMap(prevDoc.docs.first);
      }
      if (recharge.code == 1) {
        if (int.parse(startYear) < int.parse(year)) {
          updateYear = int.parse(year) - 1;
        } else
          updateYear = int.parse(startYear);
        changed = true;
        final QuerySnapshot prevDocs =
            await _ref.doc(customerId).collection(updateYear.toString()).get();
        if (prevDocs.docs.isNotEmpty &&
            Recharge.fromMap(prevDocs.docs.last).code == 12)
          _prev = Recharge.fromMap(prevDocs.docs.last);
      }
      if (_prev != null) status = _prev.status ? 'Active' : 'Inactive';
      await FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/areas/$areaId/customers')
          .doc(customerId)
          .update({
        'runYear': updateYear,
        'curSts': status,
        'expMon': recharge.code > 1 ? recharge.code - 1 : 12
      });
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
    return changed;
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
      final _areaInst = FirebaseFirestore.instance
          .collection('users/${operatorDetails.id}/areas')
          .doc(areaId);
      await _areaInst.collection('customers').doc(customerId).delete();
      final key = isActive ? 'aa' : 'iaa';
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
