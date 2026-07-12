import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

const aluEmailDomains = ['alustudent.com', 'alueducation.com'];

/// Thrown when a signed-in Google account isn't an ALU address (the user is
/// already signed back out by this point).
class NotAluEmailException implements Exception {
  final String email;
  const NotAluEmailException(this.email);
}

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  GoogleSignIn? _googleSignInInstance;
  // Lazy — constructing this eagerly crashes on web (it asserts without a
  // web OAuth client id), even though the web sign-in flow never uses it.
  GoogleSignIn get _googleSignIn =>
      _googleSignInInstance ??= GoogleSignIn(scopes: ['email']);
  final _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool isAluEmail(String? email) {
    if (email == null) return false;
    final domain = email.split('@').last.toLowerCase();
    return aluEmailDomains.contains(domain);
  }

  /// Signs in with Google and enforces the ALU email domain. Returns null if
  /// cancelled; throws [NotAluEmailException] if the account isn't ALU.
  Future<User?> signInWithGoogle() async {
    final userCredential = kIsWeb
        ? await _signInWithGooglePopup()
        : await _signInWithGoogleNative();
    if (userCredential == null) return null;

    final email = userCredential.user?.email;
    if (!isAluEmail(email)) {
      await signOut();
      throw NotAluEmailException(email ?? '');
    }

    return userCredential.user;
  }

  Future<UserCredential?> _signInWithGooglePopup() async {
    try {
      return await _auth.signInWithPopup(GoogleAuthProvider());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        return null;
      }
      rethrow;
    }
  }

  Future<UserCredential?> _signInWithGoogleNative() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), if (!kIsWeb) _googleSignIn.signOut()]);
  }
}
