import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FlixQuestAuthService {
  FlixQuestAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.toLowerCase().trim(),
      password: password.trim(),
    );
  }

  Future<UserCredential> signInAnonymously() {
    return _auth.signInAnonymously();
  }

  Future<UserCredential> createAccount({
    required String fullName,
    required String email,
    required String username,
    required String password,
    required int profileId,
    bool verified = false,
  }) async {
    final normalizedUsername = username.toLowerCase().trim();
    final usernameReference =
        _firestore.collection('usernames').doc(normalizedUsername);
    if ((await usernameReference.get()).exists) {
      throw FirebaseAuthException(
        code: 'username-already-in-use',
        message: 'That username is already in use.',
      );
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.toLowerCase().trim(),
      password: password.trim(),
    );
    final user = credential.user!;
    final batch = _firestore.batch();
    batch.set(_firestore.collection('users').doc(user.uid), <String, Object>{
      'id': user.uid,
      'name': fullName.trim(),
      'email': email.toLowerCase().trim(),
      'profileId': profileId,
      'username': normalizedUsername,
      'verified': verified,
      'joinedAt': DateTime.now().toString(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(usernameReference, <String, Object>{
      'uname': normalizedUsername,
      'uid': user.uid,
    });
    batch.set(
      _firestore.collection('bookmarks-v2.0').doc(user.uid),
      <String, Object>{
        'movies': <Object>[],
        'tvShows': <Object>[],
      },
    );
    await batch.commit();
    return credential;
  }
}
