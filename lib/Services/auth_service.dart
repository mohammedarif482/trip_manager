import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isDriver;

  UserModel({required this.id, required this.name, required this.email, required this.isDriver});
}

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userRef = _firestore.collection('users').doc(user.uid);
        final userSnapshot = await userRef.get();

        late final bool isDriver;
        if (!userSnapshot.exists) {
          // New user, set default values
          isDriver = true;
          await userRef.set({
            'name': user.displayName,
            'email': user.email,
            'isDriver': isDriver,
          });
        } else {
          // Existing user, fetch isDriver status
          isDriver = userSnapshot.data()?['isDriver'] ?? false;
        }

        _currentUser = UserModel(
          id: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          isDriver: isDriver,
        );

        return _currentUser;
      }
    } catch (error) {
      print('Google Sign-In failed: $error');
      return null;
    }
    return null;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _currentUser = null;
  }

  Future<UserModel?> getCurrentUser() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final userSnapshot = await _firestore.collection('users').doc(user.uid).get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        _currentUser = UserModel(
          id: user.uid,
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          isDriver: userData['isDriver'] ?? false,
        );
        return _currentUser;
      }
    }
    return null;
  }

  Future<void> updateUserRole(String userId, bool isDriver) async {
    await _firestore.collection('users').doc(userId).update({'isDriver': isDriver});
    if (_currentUser != null && _currentUser!.id == userId) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        isDriver: isDriver,
      );
    }
  }
}