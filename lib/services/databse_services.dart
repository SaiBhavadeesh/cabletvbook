import 'dart:io';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DatabaseService {
  static Future<void> getuserData() async {
    DocumentSnapshot document = await Firestore.instance
        .collection('users')
        .document(firebaseUser.uid)
        .get();
    operatorDetails = Operator.fromMap(document.data);
  }

  static Future<void> addNewCustomer(
      BuildContext context, GlobalKey<ScaffoldState> key,
      {@required Customer customer, @required File file}) async {
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
          SnackBar(content: Text('ERROR : picture upload failed !')));
    }
  }
}
