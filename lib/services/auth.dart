import 'package:firebase_auth/firebase_auth.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/repositories/usuario_repository.dart';

class AuthMethods {
  final FirebaseAuth _auth;

  AuthMethods(this._auth);

  Stream<User> get authState => _auth.authStateChanges();

  Future<String> signIn({String email, String password}) async {
    try {
      UsuarioRepository _repo = UsuarioRepository();
      await _auth.signInWithEmailAndPassword(email: email, password: password)
        .then((credentials) async {
          var response = await _repo.readUsuario(cid: credentials.user.uid);
          print(response.toString());
        }).catchError((e) {
          throw e;
        });

      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> signUp({String name, String lastname, String email, String password}) async {
    try {
      UsuarioRepository _repo = UsuarioRepository();

      await _auth.createUserWithEmailAndPassword(email: email, password: password)
        .then((credentials) async {
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
        }).catchError((e) {
          throw e;
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