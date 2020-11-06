import 'package:firebase_auth/firebase_auth.dart';
class AuthMethods {
  final FirebaseAuth _auth;

  AuthMethods(this._auth);

  Stream<User> get authState => _auth.authStateChanges();

  Future<String> signIn({String email, String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> signUp({String name, String lastname, String email, String password}) async {
    try {
      // DatabaseMethods databaseMethods = DatabaseMethods();
      UserCredential credentials = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Usuario usuario = Usuario(
      //   uid: credentials.user.uid,
      //   nome: nome,
      //   sobrenome: sobrenome,
      //   email: email,
      // );

      // await databaseMethods.createUser(
      //   uid: usuario.uid,
      //   data: usuario.toMap(),
      // );

      await credentials.user.sendEmailVerification();

      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> signOut() async {
    try {
      await _auth.signOut();

      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      rethrow;
    }
  }
}