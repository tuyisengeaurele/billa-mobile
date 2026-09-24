import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/firebase_auth_service.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) => FirebaseAuthService());
