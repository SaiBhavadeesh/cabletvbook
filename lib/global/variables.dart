import 'package:firebase_auth/firebase_auth.dart';
import 'package:cableTvBook/models/operator.dart';
import 'package:firebase_core/firebase_core.dart';

bool isGoogleUser = false;
FirebaseApp app;
User firebaseUser;
Operator operatorDetails;
List<AreaData> areas;
