import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/screens/signin_screen.dart';
import 'package:cableTvBook/screens/register_screen.dart';
import 'package:cableTvBook/services/databse_services.dart';
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
            final _firestoreInstance = Firestore.instance
                .collection('users')
                .document(firebaseUser.uid);
            await _firestoreInstance.setData(operatorDetails.toJson());
            final _areaInstance =
                _firestoreInstance.collection('areas').document();
            await _areaInstance.setData(
                areas.first.toJson()..['id'] = _areaInstance.documentID);
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
      final _firestoreInstance =
          Firestore.instance.collection('users').document(firebaseUser.uid);
      await _firestoreInstance.setData(operatorDetails.toJson());
      final _areaInstance = _firestoreInstance.collection('areas').document();
      await _areaInstance
          .setData(areas.first.toJson()..['id'] = _areaInstance.documentID);
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
      print(error);
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

  static void changePassword(BuildContext context,
      {@required String password}) async {
    Navigator.pop(context);
    DefaultDialogBox.loadingDialog(context);
    try {
      firebaseUser = await FirebaseAuth.instance.currentUser();
      await firebaseUser.updatePassword(password);
      await Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .updateData({'password': password});
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      if (error.code == 'ERROR_REQUIRES_RECENT_LOGIN')
        await DefaultDialogBox.errorDialog(context,
            title: error.message,
            content: 'Do you want to proceed wih this action?',
            function: () => signout(context));
      else
        DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static void changeEmailAddress(BuildContext context,
      {@required String email}) async {
    Navigator.pop(context);
    DefaultDialogBox.loadingDialog(context);
    try {
      firebaseUser = await FirebaseAuth.instance.currentUser();
      await firebaseUser.updateEmail(email);
      firebaseUser = await FirebaseAuth.instance.currentUser();
      await Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .updateData({'email': firebaseUser.email});
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      if (error.code == 'ERROR_REQUIRES_RECENT_LOGIN')
        await DefaultDialogBox.errorDialog(context,
            title: error.message,
            content: 'Do you want to proceed wih this action?',
            function: () => signout(context));
      else
        DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static void changePhoneNumber(BuildContext context,
      {@required String phoneNumber}) async {
    try {
      firebaseUser = await FirebaseAuth.instance.currentUser();
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (phoneAuthCredential) async {
          DefaultDialogBox.loadingDialog(context);
          await firebaseUser.updatePhoneNumberCredential(phoneAuthCredential);
          firebaseUser = await FirebaseAuth.instance.currentUser();
          await Firestore.instance
              .collection('users')
              .document(firebaseUser.uid)
              .updateData({'phoneNumber': firebaseUser.phoneNumber});
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
    } on PlatformException catch (error) {
      Navigator.pop(context);
      if (error.code == 'ERROR_REQUIRES_RECENT_LOGIN')
        await DefaultDialogBox.errorDialog(context,
            title: error.message,
            content: 'Do you want to proceed wih this action?',
            function: () => signout(context));
      else
        DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static void changeNumberWithOtp(BuildContext context,
      {@required String otp}) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      firebaseUser = await FirebaseAuth.instance.currentUser();
      _phoneCredential = PhoneAuthProvider.getCredential(
          verificationId: _phoneVerificationId, smsCode: otp);
      await firebaseUser.updatePhoneNumberCredential(_phoneCredential);
      firebaseUser = await FirebaseAuth.instance.currentUser();
      await Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .updateData({'phoneNumber': firebaseUser.phoneNumber});
      Navigator.pop(context);
      Navigator.pop(context);
    } on PlatformException catch (error) {
      Navigator.pop(context);
      if (error.code == 'ERROR_REQUIRES_RECENT_LOGIN')
        await DefaultDialogBox.errorDialog(context,
            title: error.message,
            content: 'Do you want to proceed wih this action?',
            function: () => signout(context));
      else
        DefaultDialogBox.errorDialog(context, content: error.message);
    } catch (_) {
      Navigator.pop(context);
      DefaultDialogBox.errorDialog(context);
    }
  }

  static void sendEmailVerificationMail(BuildContext context) async {
    DefaultDialogBox.loadingDialog(context);
    try {
      firebaseUser = await FirebaseAuth.instance.currentUser();
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
