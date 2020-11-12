import 'package:firebase_auth/firebase_auth.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/repositories/usuario_repository.dart';
import 'package:observe/services/auth.dart';
import 'package:observe/widgets/loader.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class VerificationPage extends StatefulWidget {
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool _visible = false;

  Future saveDisplayName() async {
    final User user = Provider.of<User>(context, listen: false);
    final UsuarioRepository repo = UsuarioRepository();

    await repo.readUsuario(cid: user.uid)
      .then((usuario) async {
        await user.updateProfile(
          displayName: usuario.nome,
        );
      }).catchError((erro) {
        print(erro.toString());
      });
  }

  Future load() async {
    await Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _visible = true;
      });
      
      saveDisplayName();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_visible) {
      load();
    }
    Provider.of<User>(context, listen: false).reload();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<User>().reload();

    return Scaffold(
      backgroundColor: ObserveColors.dark,
      body: Center(
        child: Visibility(
          visible: _visible,
          replacement: Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: Loader(),            
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: AlertDialog(
              title: Text('Verifique seu email'),
              content: Text('Espere alguns segundos após a verificação ou confirme para sair...'),
              actions: [
                TextButton(
                  onPressed: () async {
                    context.read<AuthMethods>().signOut();
                  },
                  child: Text('Ok'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}