import 'package:cableTvBook/screens/signin_screen.dart';
import 'package:cableTvBook/services/databse_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/screens/register_screen.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';

AuthCredential _googleCredential, _phoneCredential;
AuthResult _authResult;
String _phoneVerificationId;

class Authentication {
  static void signinWithEmailAndPassword(BuildContext context,
      {@required String email, @required String password}) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      _authResult = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      firebaseUser = _authResult.user;
      await DatabaseService.getuserData();
      Navigator.of(context).pushNamedAndRemoveUntil(
          BottomTabsScreen.routeName, (route) => false);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static void signinWithGoogle(BuildContext context) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final GoogleSignIn _googleSignin =
          GoogleSignIn(scopes: ['email'], clientId: "", hostedDomain: "");
      final GoogleSignInAccount googleAccount = await _googleSignin.signIn();
      final GoogleSignInAuthentication googleAuthentication =
          await googleAccount.authentication;
      _googleCredential = GoogleAuthProvider.getCredential(
          idToken: googleAuthentication.idToken,
          accessToken: googleAuthentication.accessToken);
      _authResult =
          await FirebaseAuth.instance.signInWithCredential(_googleCredential);
      firebaseUser = _authResult.user;
      isGoogleUser = true;
      if (firebaseUser.phoneNumber != null) {
        await DatabaseService.getuserData();
        Navigator.of(context).pushNamedAndRemoveUntil(
            BottomTabsScreen.routeName, (route) => false);
      } else
        Navigator.of(context).pushNamedAndRemoveUntil(
            RegisterScreen.routeName, (route) => false,
            arguments: {'email': firebaseUser.email, 'password': null});
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static void verifyPhoneNumberAndRegister(
      {@required BuildContext context,
      @required String phoneNnumber,
      @required String email,
      @required String password}) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNnumber,
        timeout: Duration(seconds: 49),
        verificationCompleted: (phoneAuthCredential) async {
          try {
            DefaultDialogBox.loadingDialog(context);
            _phoneCredential = phoneAuthCredential;
            if (isGoogleUser)
              try {
                _authResult =
                    await _authResult.user.linkWithCredential(_phoneCredential);
              } catch (error) {
                try {
                  _authResult =
                      await firebaseUser.linkWithCredential(_phoneCredential);
                } catch (error) {
                  throw error;
                }
              }
            else {
              _authResult = await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                      email: email, password: password);
              _authResult =
                  await _authResult.user.linkWithCredential(_phoneCredential);
            }
            firebaseUser = _authResult.user;
            operatorDetails.id = firebaseUser.uid;
            await Firestore.instance
                .collection('users')
                .document(firebaseUser.uid)
                .setData(operatorDetails.toJson()
                  ..['startDate'] = FieldValue.serverTimestamp());
            await DatabaseService.getuserData();
            Navigator.of(context).pushNamedAndRemoveUntil(
                BottomTabsScreen.routeName, (route) => false);
          } on PlatformException catch (error) {
            Navigator.pop(context);
            DefaultDialogBox.errorDialog(context, content: error.message);
            try {
              await _authResult.user.delete();
            } catch (_) {}
          } catch (error) {
            Navigator.pop(context);
            DefaultDialogBox.errorDialog(context);
            try {
              await _authResult.user.delete();
            } catch (_) {}
          }
        },
        verificationFailed: (error) async {
          Navigator.pop(context);
          DefaultDialogBox.errorDialog(context, content: error.message);
        },
        codeSent: (verificationId, [forceResendingToken]) {
          _phoneVerificationId = verificationId;
          // _phoneForceResendingToken = forceResendingToken;
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message);
      try {
        await _authResult.user.delete();
      } catch (_) {}
    } catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
      try {
        await _authResult.user.delete();
      } catch (_) {}
    }
  }

  static void verifyOTPAndRegister(
      {@required BuildContext context,
      @required String otp,
      @required String email,
      @required String password}) async {
    try {
      DefaultDialogBox.loadingDialog(context);
      _phoneCredential = PhoneAuthProvider.getCredential(
          verificationId: _phoneVerificationId, smsCode: otp);
      if (isGoogleUser)
        try {
          _authResult =
              await _authResult.user.linkWithCredential(_phoneCredential);
        } catch (error) {
          try {
            _authResult =
                await firebaseUser.linkWithCredential(_phoneCredential);
          } catch (error) {
            throw error;
          }
        }
      else {
        _authResult = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        _authResult =
            await _authResult.user.linkWithCredential(_phoneCredential);
      }
      firebaseUser = _authResult.user;
      operatorDetails.id = firebaseUser.uid;
      await Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .setData(operatorDetails.toJson()
            ..['startDate'] = FieldValue.serverTimestamp());
      await DatabaseService.getuserData();
      Navigator.of(context).pushNamedAndRemoveUntil(
          BottomTabsScreen.routeName, (route) => false);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message);
      try {
        await _authResult.user.delete();
      } catch (_) {}
    } catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
      try {
        await _authResult.user.delete();
      } catch (_) {}
    }
  }

  static void signout(BuildContext context) async {
    try {
      DefaultDialogBox.loadingDialog(context);
      await FirebaseAuth.instance.signOut();
      firebaseUser = null;
      isGoogleUser = false;
      operatorDetails = null;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(SigninScreen.routeName, (route) => false);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }
}
