import 'package:observe/classes/colors.dart';
import 'package:observe/services/auth.dart';
import 'package:observe/widgets/input_decoration.dart';
import 'package:observe/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  SignIn(this.toggle);
  
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _visible = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailCTRL = TextEditingController();
  TextEditingController _passwordCTRL = TextEditingController();
  bool _passwordVisibility = true;

  @override
  void initState() {
    _visible = true;
    super.initState();
  }

  signIn() async {
    String result = await context.read<AuthMethods>().signIn(
      email: _emailCTRL.text.trim(),
      password: _passwordCTRL.text.trim(),
    );

    if (result != 'success') {
      setState(() {
        _visible = true;
        _emailCTRL.text = '';
        _passwordCTRL.text = '';                                              
      });

      Get.dialog(
        AlertDialog(
          title: Text('Ops...'),
          content: Text(
            result == 'wrong-password' || result == 'user-not-found'
              ? 'Email ou senha inválidos :('
              : 'Erro desconhecido :( Tente mais tarde.'
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _visible = true;
                });
                Get.back();
              },
              child: Text(
                'Ok',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ObserveColors.dark,
      body: Center(
        child: SingleChildScrollView(
          child: Visibility(
            visible: _visible,
            replacement: Container(
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: Loader(),            
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    bottom: 35,
                    right: 7.5,
                  ),
                  child: FlutterLogo(
                    size: 100,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        child: TextFormField(
                          controller: _emailCTRL,
                          decoration: roundedFormInput('Email'),
                          style: TextStyle(
                            color: Colors.white
                          ),
                          validator: (value) {
                            bool isEmailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
                            ).hasMatch(value);

                            if (isEmailValid) {
                              return null;
                            } else {
                              return "Email inválido!";
                            }
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,                          
                        ),
                        child: Stack(
                          children: [
                            TextFormField(
                              controller: _passwordCTRL,
                              decoration: roundedFormInput('Senha'),
                              obscureText: _passwordVisibility,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              validator: (value) {
                                bool isPasswordValid = RegExp(
                                  r'^(?=.*[0-9]+.*)(?=.*[a-zA-Z]+.*)[0-9a-zA-Z!@#\$&*~]{6,18}$'
                                ).hasMatch(value);

                                if (isPasswordValid) {
                                  return null;
                                } else {
                                  return "Senha inválida!";
                                }
                              },
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                width: 59,
                                height: 59,
                                child: IconButton(
                                  splashRadius: 28,
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisibility = !_passwordVisibility;
                                    });
                                  },
                                  icon: Icon(
                                    _passwordVisibility 
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                    color: Colors.white38,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 15,
                          bottom: 30,
                        ),
                        child: RawMaterialButton(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                _visible = false;
                              });
                              
                              await signIn();
                            }
                          },
                          child: Text(
                            'ENTRAR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          fillColor: ObserveColors.blue,
                          padding: EdgeInsets.symmetric(
                            horizontal: 75,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    widget.toggle();
                  },
                  child: Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(10),
                    color: Colors.transparent,
                    child: Text(
                      'Não tenho conta',
                      style: TextStyle(
                        color: ObserveColors.aqua,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Text(
                  'ou',
                  style: TextStyle(
                    color: Colors.white24,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print('teste');
                  },
                  child: Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(10),
                    color: Colors.transparent,
                    child: Text(
                      'Não consigo entrar :(',
                      style: TextStyle(
                        color: ObserveColors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}