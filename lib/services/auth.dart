import 'package:firebase_auth/firebase_auth.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/repositories/usuario_repository.dart';
import 'package:observe/services/api.dart';
class AuthMethods {
  final FirebaseAuth _auth;
  final ObserveAPI _api = ObserveAPI();

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
      UsuarioRepository _repo = UsuarioRepository();
      UserCredential credentials = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      Usuario usuario = Usuario(
        cid: credentials.user.uid,
        nome: name,
        sobrenome: lastname
      );

      await _repo.createUsuario(usuario)
        .then((value) async {
          await credentials.user.sendEmailVerification();
        }).catchError((error) async {
          await credentials.user.delete();
        });


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