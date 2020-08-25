import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        Firestore.instance.collection('users').document(firebaseUser.uid);
    DocumentSnapshot document = await _firestoreInstance.get();
    operatorDetails = Operator.fromMap(document.data);
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
      final _firestoreInstance = Firestore.instance
          .collection(
              'users/${operatorDetails.id}/areas/${customer.areaId}/customers')
          .document();
      if (file != null)
        try {
          final _ref = FirebaseStorage.instance.ref().child(
              'customerPictures/${operatorDetails.id}/${customer.areaId}/${_firestoreInstance.documentID}/profilePicture.png');
          await _ref.putFile(file).onComplete;
          url = await _ref.getDownloadURL();
        } on PlatformException catch (error) {
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text(error.message)));
        } catch (_) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('ERROR : picture upload failed !')));
        }
      await _firestoreInstance.setData(customer.toJson()
        ..['id'] = _firestoreInstance.documentID
        ..['profileImageUrl'] = url);
      if (customer.currentStatus == 'Active') {
        final _rechargeInstance = _firestoreInstance
            .collection(DateTime.now().year.toString())
            .document();
        recharge.id = _rechargeInstance.documentID;
        await _rechargeInstance.setData(
            recharge.toJson()..['date'] = FieldValue.serverTimestamp());
      }
      final data = {
        'totalAccounts': area.totalAccounts + 1,
        'activeAccounts': customer.currentStatus == 'Active'
            ? area.activeAccounts + 1
            : area.activeAccounts,
        'inActiveAccounts': customer.currentStatus == 'Active'
            ? area.inActiveAccounts
            : area.inActiveAccounts + 1,
      };
      await Firestore.instance
          .collection('users/${firebaseUser.uid}/areas')
          .document(customer.areaId)
          .updateData(data);
      Navigator.of(context).pushNamedAndRemoveUntil(
          BottomTabsScreen.routeName, (route) => false);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(error.message),
        duration: Duration(seconds: 1),
      ));
    } catch (_) {
      Navigator.pop(context);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('ERROR : something went wrong !'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  static Future<void> updateCustomerData(
      BuildContext context, GlobalKey<ScaffoldState> key,
      {@required Map<String, dynamic> data,
      @required String customerId,
      @required areaId}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      await Firestore.instance
          .collection('users/${operatorDetails.id}/areas/$areaId/customers')
          .document(customerId)
          .updateData(data);
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(
        content: Text(error.message),
        duration: Duration(seconds: 1),
      ));
    } catch (_) {
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(
        content: Text('ERROR : picture upload failed !'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  static Future<void> updateCustomerPicture(
      BuildContext context, GlobalKey<ScaffoldState> key,
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
      await Firestore.instance
          .collection('users/${operatorDetails.id}/areas/$areaId/customers')
          .document(customerId)
          .updateData({'profileImageUrl': url});
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(
        content: Text(error.message),
        duration: Duration(seconds: 1),
      ));
    } catch (_) {
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(
        content: Text('ERROR : picture upload failed !'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  static Future<void> uploadProfilePicture(
      BuildContext context, GlobalKey<ScaffoldState> key,
      {@required File file}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      final _ref = FirebaseStorage.instance
          .ref()
          .child('profilePictures/${operatorDetails.id}/profilePicture.png');
      await _ref.putFile(file).onComplete;
      final url = await _ref.getDownloadURL();
      await Firestore.instance
          .collection('users')
          .document(operatorDetails.id)
          .updateData({'profileImageLink': url});
      await getuserData();
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(
        content: Text(error.message),
        duration: Duration(seconds: 1),
      ));
    } catch (_) {
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(
        content: Text('ERROR : picture upload failed !'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  static Future<void> updateData(
      BuildContext context, GlobalKey<ScaffoldState> key,
      {@required Map<String, dynamic> data}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      await Firestore.instance
          .collection('users')
          .document(operatorDetails.id)
          .updateData(data);
      await getuserData();
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(
        content: Text(error.message),
        duration: Duration(seconds: 1),
      ));
    } catch (_) {
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(
        content: Text('ERROR : something went wrong !'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  static Future<void> addArea(
      BuildContext context, GlobalKey<ScaffoldState> key,
      {@required Map<String, dynamic> data}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      final _firestoreInstance = Firestore.instance
          .collection('users/${firebaseUser.uid}/areas')
          .document();
      await _firestoreInstance
          .setData(data..['id'] = _firestoreInstance.documentID);
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(
        content: Text(error.message),
        duration: Duration(seconds: 1),
      ));
    } catch (_) {
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(
        content: Text('ERROR : something went wrong !'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  static Future<void> deleteArea(
      BuildContext context, GlobalKey<ScaffoldState> key, String areaId) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      final _instance = Firestore.instance
          .collection('users/${operatorDetails.id}/areas')
          .document(areaId);
      await _instance.delete();
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(
        content: Text(error.message),
        duration: Duration(seconds: 1),
      ));
    } catch (_) {
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(
        content: Text('ERROR : something went wrong !'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  static Future<void> updateArea(
      BuildContext context, GlobalKey<ScaffoldState> key,
      {@required Map<String, dynamic> data}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      await Firestore.instance
          .collection('users/${firebaseUser.uid}/areas')
          .document(data['id'])
          .updateData(data);
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      if (key != null)
        key.currentState.showSnackBar(SnackBar(
          content: Text(error.message),
          duration: Duration(seconds: 1),
        ));
      else
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(error.message),
          duration: Duration(seconds: 1),
        ));
    } catch (_) {
      Navigator.pop(context);
      if (key != null)
        key.currentState.showSnackBar(SnackBar(
          content: Text('ERROR : something went wrong !'),
          duration: Duration(seconds: 1),
        ));
      else
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('ERROR : something went wrong !'),
          duration: Duration(seconds: 1),
        ));
    }
  }

  static Future<void> rechargeCustomer(
      BuildContext context, GlobalKey<ScaffoldState> key,
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
      final _ref = Firestore.instance
          .collection('users/${operatorDetails.id}/areas/$areaId/customers')
          .document(customerId);
      final docs = await _ref.collection(year).orderBy('code').getDocuments();
      Recharge recent;
      if (docs.documents.isNotEmpty) {
        recent = Recharge.fromMap(docs.documents.last);
        if (recent != null) {
          if (recent.date.year == DateTime.now().year)
            for (int i = recent.code + 1; i < DateTime.now().month; i++) {
              final _rechargeRef =
                  _ref.collection(DateTime.now().year.toString()).document();
              final inactiveRecharge =
                  Recharge(id: _rechargeRef.documentID, status: false, code: i)
                      .toJson()
                        ..['date'] = FieldValue.serverTimestamp();
              await _rechargeRef.setData(inactiveRecharge);
            }
          else if (recent.date.year < DateTime.now().year) {
            for (int i = recent.code + 1; i <= 12; i++) {
              final _rechargeRef =
                  _ref.collection(recent.date.year.toString()).document();
              final inactiveRecharge =
                  Recharge(id: _rechargeRef.documentID, status: false, code: i)
                      .toJson()
                        ..['date'] = FieldValue.serverTimestamp();
              await _rechargeRef.setData(inactiveRecharge);
            }
            for (int i = 1; i < DateTime.now().month; i++) {
              final _rechargeRef =
                  _ref.collection(DateTime.now().year.toString()).document();
              final inactiveRecharge =
                  Recharge(id: _rechargeRef.documentID, status: false, code: i)
                      .toJson()
                        ..['date'] = FieldValue.serverTimestamp();
              await _rechargeRef.setData(inactiveRecharge);
            }
          }
        }
      }
      int monthCode = DateTime.now().month;
      int rechargeYear = DateTime.now().year;
      if (int.parse(year) > rechargeYear) rechargeYear = int.parse(year);
      if (docs.documents.isNotEmpty) {
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
        final _rechargeRef =
            _ref.collection(rechargeYear.toString()).document();
        final activeRecharge = Recharge(
                id: _rechargeRef.documentID,
                status: true,
                code: monthCode,
                billPay: billPay,
                plan: plan.toString())
            .toJson()
              ..['date'] = FieldValue.serverTimestamp();
        await _rechargeRef.setData(activeRecharge);
        monthCode += 1;
      }
      if (!billPay)
        await _ref.updateData({'noOfPendingBills': unPaidNo + term});
      await _ref
          .updateData({'currentStatus': 'Active', 'runningYear': rechargeYear});
      if (status != 'Active') {
        final area = areas.firstWhere((element) => element.id == areaId);
        await updateArea(context, key, data: {
          'id': areaId,
          'activeAccounts': area.activeAccounts + 1,
          'inActiveAccounts': area.inActiveAccounts - 1
        });
      }
      Navigator.pop(context);
    } on PlatformException catch (error) {
      print(error.message);
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      print(error.toString());
      Navigator.pop(context);
      key.currentState.showSnackBar(
          SnackBar(content: Text('ERROR : something went wrong !')));
    }
  }

  static Future<void> deactivateCustomer(
      BuildContext context, GlobalKey<ScaffoldState> key,
      {@required String customerId,
      @required String areaId,
      @required String year}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      final _ref = Firestore.instance
          .collection('users/${operatorDetails.id}/areas/$areaId/customers')
          .document(customerId);
      final docs = await _ref.collection(year).orderBy('code').getDocuments();
      final recent = Recharge.fromMap(docs.documents.last.data);
      await _ref.collection(year).document(recent.id).updateData({
        'addInfo': 'DC: ${DateFormat('dd, MMMM / yyyy').format(DateTime.now())}'
      });
      await _ref.updateData({'currentStatus': 'Inactive'});
      final area = areas.firstWhere((element) => element.id == areaId);
      await updateArea(context, key, data: {
        'id': areaId,
        'activeAccounts': area.activeAccounts - 1,
        'inActiveAccounts': area.inActiveAccounts + 1
      });
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(
        content: Text(error.message),
        duration: Duration(seconds: 1),
      ));
    } catch (_) {
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(
        content: Text('ERROR : something went wrong !'),
        duration: Duration(seconds: 1),
      ));
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
      final _ref = Firestore.instance
          .collection('users/${operatorDetails.id}/areas/$areaId/customers');
      await _ref
          .document(customerId)
          .updateData({'noOfPendingBills': unpaidBillno - 1});
      await _ref
          .document(customerId)
          .collection(year)
          .document(rechargeId)
          .updateData({'billPay': true});
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<bool> deleteRecharge(
      BuildContext context, GlobalKey<ScaffoldState> key,
      {@required String customerId,
      @required String areaId,
      @required String year,
      @required String startYear,
      @required bool prevRecharge,
      @required Recharge recharge,
      @required int unPaidNo}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    bool changed = false;
    Recharge _prev;
    try {
      final _ref = Firestore.instance
          .collection('users/${operatorDetails.id}/areas/$areaId/customers');
      await _ref
          .document(customerId)
          .collection(year)
          .document(recharge.id)
          .delete();
      if (recharge.code > 1)
        _prev = Recharge.fromMap((await _ref
                .document(customerId)
                .collection(year)
                .where('code', isEqualTo: recharge.code - 1)
                .getDocuments())
            .documents
            .first);
      if (recharge.billPay != null && !recharge.billPay)
        await _ref
            .document(customerId)
            .updateData({'noOfPendingBills': unPaidNo - 1});
      int updateYear = int.parse(year);
      String status = 'Inactive';
      if (recharge.code == 1) {
        if (int.parse(startYear) < int.parse(year)) {
          updateYear = int.parse(year) - 1;
        } else
          updateYear = int.parse(startYear);
        changed = true;
        final temp = (await _ref
                .document(customerId)
                .collection(updateYear.toString())
                .getDocuments())
            .documents;
        if (temp.isNotEmpty) _prev = Recharge.fromMap(temp.last);
      }
      if (_prev != null) status = _prev.status ? 'Active' : 'Inactive';
      await Firestore.instance
          .collection('users/${operatorDetails.id}/areas/$areaId/customers')
          .document(customerId)
          .updateData({'runningYear': updateYear, 'currentStatus': status});
      if (status == 'Inactive') {
        final area = areas.firstWhere((element) => element.id == areaId);
        if (area.activeAccounts > 0)
          await updateArea(context, key, data: {
            'id': areaId,
            'activeAccounts': area.activeAccounts - 1,
            'inActiveAccounts': area.inActiveAccounts + 1
          });
      }
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(
        content: Text(error.message),
      ));
    } catch (e) {
      print(e.toString());
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(
        content: Text('ERROR : something went wrong !'),
      ));
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
      final _areaInst = Firestore.instance
          .collection('users/${operatorDetails.id}/areas')
          .document(areaId);
      await _areaInst.collection('customers').document(customerId).delete();
      final key = isActive ? 'activeAccounts' : 'inActiveAccounts';
      _areaInst.updateData({
        'totalAccounts': totalCount - 1,
        key: otherCount - 1,
      });
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(error.message),
        duration: Duration(seconds: 1),
      ));
    } catch (_) {
      Navigator.pop(context);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('ERROR : something went wrong !'),
        duration: Duration(seconds: 1),
      ));
    }
  }
}
