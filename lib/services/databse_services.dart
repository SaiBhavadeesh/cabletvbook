import 'dart:io';

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
    QuerySnapshot doc =
        await _firestoreInstance.collection('areas').getDocuments();
    areas = doc.documents.map((e) => AreaData.fromMap(e.data)).toList();
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
      try {
        final _ref = FirebaseStorage.instance
            .ref()
            .child('customerPictures')
            .child(operatorDetails.id)
            .child('profilePicture.png');
        await _ref.putFile(file).onComplete;
        url = await _ref.getDownloadURL();
      } on PlatformException catch (error) {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      } catch (_) {
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text('ERROR : picture upload failed !')));
      }
      final area = areas.firstWhere((element) => element.id == customer.areaId);
      final _firestoreInstance = Firestore.instance
          .collection('users')
          .document(operatorDetails.id)
          .collection('areas')
          .document(customer.areaId)
          .collection('customers')
          .document();
      await _firestoreInstance.setData(customer.toJson()
        ..['id'] = _firestoreInstance.documentID
        ..['profileImageUrl'] = url);
      await _firestoreInstance
          .collection(DateTime.now().year.toString())
          .document()
          .setData(recharge.toJson());
      await Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .collection('areas')
          .document(customer.areaId)
          .updateData({'totalAccounts': area.totalAccounts + 1});
      await getuserData();
      Navigator.of(context).pushNamedAndRemoveUntil(
          BottomTabsScreen.routeName, (route) => false);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      Navigator.pop(context);
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('ERROR : something went wrong !')));
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
          .child('profilePictures')
          .child(operatorDetails.id)
          .child('profilePicture.png');
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
      key.currentState.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      Navigator.pop(context);
      key.currentState.showSnackBar(
          SnackBar(content: Text('ERROR : picture upload failed !')));
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
      key.currentState.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      Navigator.pop(context);
      key.currentState.showSnackBar(
          SnackBar(content: Text('ERROR : something went wrong !')));
    }
  }

  static Future<void> addArea(
      BuildContext context, GlobalKey<ScaffoldState> key,
      {@required Map<String, dynamic> data}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      final _firestoreInstance = Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .collection('areas')
          .document();
      await _firestoreInstance
          .setData(data..['id'] = _firestoreInstance.documentID);
      await getuserData();
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      key.currentState.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      Navigator.pop(context);
      key.currentState.showSnackBar(
          SnackBar(content: Text('ERROR : something went wrong !')));
    }
  }

  static Future<void> updateArea(
      BuildContext context, GlobalKey<ScaffoldState> key,
      {@required Map<String, dynamic> data}) async {
    DefaultDialogBox.loadingDialog(context,
        loaderType: SelectLoader.ballRotateChase);
    try {
      await Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .collection('areas')
          .document(data['id'])
          .updateData(data);
      await getuserData();
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      if (key != null)
        key.currentState.showSnackBar(SnackBar(content: Text(error.message)));
      else
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      Navigator.pop(context);
      if (key != null)
        key.currentState.showSnackBar(
            SnackBar(content: Text('ERROR : something went wrong !')));
      else
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text('ERROR : something went wrong !')));
    }
  }
}
