import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/screens/signin_screen.dart';
import 'package:cableTvBook/screens/register_screen.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/screens/bottom_tabs_screen.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';
import 'package:cableTvBook/Payment%20Gateway/razor_pay_screen.dart';

AuthCredential _googleCredential, _phoneCredential;
UserCredential _authResult;
String _phoneVerificationId;

class Authentication {
  static Future<void> signinWithEmailAndPassword(BuildContext context,
      {@required String email, @required String password}) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      _authResult = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      firebaseUser = _authResult.user;
      await DatabaseService.getuserData();
      if (operatorDetails.isSubscribed) {
        await DatabaseService.getuserData();
        Navigator.of(context).pushNamedAndRemoveUntil(
            BottomTabsScreen.routeName, (route) => false);
      } else if (firebaseUser.phoneNumber == null)
        Navigator.of(context).pushNamedAndRemoveUntil(
            RegisterScreen.routeName, (route) => false);
      else {
        await DatabaseService.getuserData();
        Navigator.of(context).pushNamedAndRemoveUntil(
            RazorPayScreen.routeName, (route) => false);
      }
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> signinWithGoogle(BuildContext context) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      final GoogleSignIn _googleSignin =
          GoogleSignIn(scopes: ['email'], clientId: "", hostedDomain: "");
      final GoogleSignInAccount googleAccount = await _googleSignin.signIn();
      final GoogleSignInAuthentication googleAuthentication =
          await googleAccount.authentication;
      _googleCredential = GoogleAuthProvider.credential(
          idToken: googleAuthentication.idToken,
          accessToken: googleAuthentication.accessToken);
      _authResult =
          await FirebaseAuth.instance.signInWithCredential(_googleCredential);
      firebaseUser = _authResult.user;
      isGoogleUser = true;
      _googleSignin.signOut();
      if (firebaseUser.phoneNumber == null)
        Navigator.of(context).pushNamedAndRemoveUntil(
            RegisterScreen.routeName, (route) => false,
            arguments: {'email': firebaseUser.email, 'password': null});
      else {
        await DatabaseService.getuserData();
        if (operatorDetails != null && operatorDetails.isSubscribed)
          Navigator.of(context).pushNamedAndRemoveUntil(
              BottomTabsScreen.routeName, (route) => false);
        else
          Navigator.of(context).pushNamedAndRemoveUntil(
              RazorPayScreen.routeName, (route) => false);
      }
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> verifyPhoneNumberAndRegister(
      {@required BuildContext context,
      @required String phoneNumber,
      @required String email,
      @required String password}) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 49),
        verificationCompleted: (phoneAuthCredential) async {
          try {
            DefaultDialogBox.loadingDialog(context);
            _phoneCredential = phoneAuthCredential;
            if (isGoogleUser)
              try {
                _authResult = await FirebaseAuth.instance.currentUser
                    .linkWithCredential(_phoneCredential);
              } catch (error) {
                throw error;
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
            final _firestoreInstance = FirebaseFirestore.instance
                .collection('users')
                .doc(firebaseUser.uid);
            await _firestoreInstance.set(operatorDetails.toJson());
            final _areaInstance = _firestoreInstance.collection('areas').doc();
            await _areaInstance
                .set(areas.first.toJson()..['id'] = _areaInstance.id);
            await DatabaseService.getuserData();
            Navigator.of(context).pushNamedAndRemoveUntil(
                RazorPayScreen.routeName, (route) => false);
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
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      try {
        await _authResult.user.delete();
      } catch (_) {}
      Navigator.of(context)
          .pushNamedAndRemoveUntil(SigninScreen.routeName, (route) => false);
      DefaultDialogBox.errorDialog(context, content: error.message);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      try {
        await _authResult.user.delete();
      } catch (_) {}
      Navigator.of(context)
          .pushNamedAndRemoveUntil(SigninScreen.routeName, (route) => false);
      DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (_) {
      Navigator.pop(context);
      try {
        await _authResult.user.delete();
        Navigator.of(context)
            .pushNamedAndRemoveUntil(SigninScreen.routeName, (route) => false);
      } catch (_) {}
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> verifyOTPAndRegister(
      {@required BuildContext context,
      @required String otp,
      @required String email,
      @required String password}) async {
    try {
      DefaultDialogBox.loadingDialog(context);
      _phoneCredential = PhoneAuthProvider.credential(
          verificationId: _phoneVerificationId, smsCode: otp);
      if (isGoogleUser)
        try {
          _authResult = await FirebaseAuth.instance.currentUser
              .linkWithCredential(_phoneCredential);
        } catch (error) {
          throw error;
        }
      else {
        _authResult = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        _authResult =
            await _authResult.user.linkWithCredential(_phoneCredential);
      }
      firebaseUser = _authResult.user;
      operatorDetails.id = firebaseUser.uid;
      final _firestoreInstance =
          FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid);
      await _firestoreInstance.set(operatorDetails.toJson());
      final _areaInstance = _firestoreInstance.collection('areas').doc();
      await _areaInstance.set(areas.first.toJson()..['id'] = _areaInstance.id);
      await DatabaseService.getuserData();
      Navigator.of(context)
          .pushNamedAndRemoveUntil(RazorPayScreen.routeName, (route) => false);
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      if (error.code != 'invalid-verification-code') {
        try {
          await _authResult.user.delete();
        } catch (_) {}
        Navigator.of(context)
            .pushNamedAndRemoveUntil(SigninScreen.routeName, (route) => false);
      }
      DefaultDialogBox.errorDialog(context, content: error.message);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      try {
        await _authResult.user.delete();
      } catch (_) {}
      Navigator.of(context)
          .pushNamedAndRemoveUntil(SigninScreen.routeName, (route) => false);
      DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (error) {
      Navigator.pop(context);
      try {
        await _authResult.user.delete();
        Navigator.of(context)
            .pushNamedAndRemoveUntil(SigninScreen.routeName, (route) => false);
      } catch (_) {}
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> signout(BuildContext context) async {
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

  static Future<void> changePassword(BuildContext context,
      {@required String password}) async {
    Navigator.pop(context);
    DefaultDialogBox.loadingDialog(context);
    try {
      firebaseUser = FirebaseAuth.instance.currentUser;
      await firebaseUser.updatePassword(password);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .update({'password': password});
      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      if (error.code == 'requires-recent-login')
        await DefaultDialogBox.errorDialog(context,
            title: error.message,
            content: 'Do you want to proceed wih this action?',
            function: () => signout(context));
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> changeEmailAddress(BuildContext context,
      {@required String email}) async {
    Navigator.pop(context);
    DefaultDialogBox.loadingDialog(context);
    try {
      firebaseUser = FirebaseAuth.instance.currentUser;
      await firebaseUser.updateEmail(email);
      firebaseUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .update({'email': firebaseUser.email});
      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      if (error.code == 'requires-recent-login')
        await DefaultDialogBox.errorDialog(context,
            title: error.message,
            content: 'Do you want to proceed wih this action?',
            function: () => signout(context));
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> changePhoneNumber(BuildContext context,
      {@required String phoneNumber}) async {
    try {
      firebaseUser = FirebaseAuth.instance.currentUser;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (phoneAuthCredential) async {
          DefaultDialogBox.loadingDialog(context);
          await firebaseUser.updatePhoneNumber(phoneAuthCredential);
          firebaseUser = FirebaseAuth.instance.currentUser;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .update({'phoneNumber': firebaseUser.phoneNumber});
          Navigator.pop(context);
          Navigator.pop(context);
        },
        verificationFailed: (error) {
          Navigator.pop(context);
          DefaultDialogBox.errorDialog(context, content: error.message);
        },
        codeSent: (verificationId, [forceResendingToken]) {
          _phoneVerificationId = verificationId;
          // _phoneForceResendingToken = forceResendingToken;
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      if (error.code == 'requires-recent-login')
        await DefaultDialogBox.errorDialog(context,
            title: error.message,
            content: 'Do you want to proceed wih this action?',
            function: () => signout(context));
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> changeNumberWithOtp(BuildContext context,
      {@required String otp}) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      firebaseUser = FirebaseAuth.instance.currentUser;
      _phoneCredential = PhoneAuthProvider.credential(
          verificationId: _phoneVerificationId, smsCode: otp);
      await firebaseUser.updatePhoneNumber(_phoneCredential);
      firebaseUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .update({'phoneNumber': firebaseUser.phoneNumber});
      Navigator.pop(context);
      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      Navigator.pop(context);
      if (error.code == 'requires-recent-login')
        await DefaultDialogBox.errorDialog(context,
            title: error.message,
            content: 'Do you want to proceed wih this action?',
            function: () => signout(context));
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static Future<void> sendEmailVerificationMail(BuildContext context) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      firebaseUser = FirebaseAuth.instance.currentUser;
      await firebaseUser.sendEmailVerification();
      Navigator.pop(context);
      await DefaultDialogBox.errorDialog(context,
          title: 'Email successfully sent !',
          content:
              'Please check your mail, and click on the link provided to verify and restart the app !');
    } on PlatformException catch (error) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }
}
