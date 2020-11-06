import 'package:observe/classes/colors.dart';
import 'package:observe/services/auth.dart';
import 'package:observe/widgets/input_decoration.dart';
import 'package:observe/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  SignUp(this.toggle);
  
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _visible = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameCTRL = TextEditingController();
  TextEditingController _lastnameCTRL = TextEditingController();
  TextEditingController _emailCTRL = TextEditingController();
  TextEditingController _passwordCTRL = TextEditingController();
  TextEditingController _vpasswordCTRL = TextEditingController();
  bool _passwordVisibility = true;
  bool _vpasswordVisibility = true;

  @override
  void initState() {
    _visible = true;
    super.initState();
  }

  signUp() async {
    String result = await context.read<AuthMethods>().signUp(
      name: _nameCTRL.text.trim(),
      lastname: _lastnameCTRL.text.trim(),
      email: _emailCTRL.text.trim(),
      password: _passwordCTRL.text.trim(),
    );

    if (result != 'success') {
      print(result);

      Get.dialog(
        AlertDialog(
          title: Text('Ops...'),
          content: Text('Não foi possível criar conta :('),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('Ok')
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 20, 25, 45),
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
                          controller: _nameCTRL,
                          keyboardType: TextInputType.name,
                          decoration: roundedFormInput('Nome'),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          validator: (value) {
                            bool isValid = RegExp(
                              r"^([A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ.-]+)( {1,1}[A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ.-]+)*$"
                            ).hasMatch(value);

                            if (isValid) {
                              return null;
                            } else {
                              return "Nome inválido!";
                            }
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        child: TextFormField(
                          controller: _lastnameCTRL,
                          keyboardType: TextInputType.name,
                          decoration: roundedFormInput('Sobreome'),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          validator: (value) {
                            bool isValid = RegExp(
                              r"^([A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ.-]+)( {1,1}[A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ.-]+)*$"
                            ).hasMatch(value);

                            if (isValid) {
                              return null;
                            } else {
                              return "Sobrenome inválido!";
                            }
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        child: TextFormField(
                          controller: _emailCTRL,
                          decoration: roundedFormInput('Email'),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          validator: (value) {
                            bool isValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
                            ).hasMatch(value);

                            if (isValid) {
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
                        margin: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        child: Stack(
                          children: [
                            TextFormField(
                              controller: _vpasswordCTRL,
                              decoration: roundedFormInput('Confirmar senha'),
                              obscureText: _vpasswordVisibility,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              validator: (value) {
                                if (_vpasswordCTRL.text == _passwordCTRL.text) {
                                  return null;
                                } else {
                                  return "Senhas não coincidem!";
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
                                      _vpasswordVisibility = !_vpasswordVisibility;
                                    });
                                  },
                                  icon: Icon(
                                    _vpasswordVisibility 
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
                        margin: EdgeInsets.symmetric(vertical: 15),
                        child: RawMaterialButton(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                _visible = false;
                              });
                              
                              signUp();
                            }
                          },
                          child: Text(
                            'ENVIAR',
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
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.all(15),
                    color: Colors.transparent,
                    child: Text(
                      'Já tenho conta :)',
                      style: TextStyle(
                        color: ObserveColors.aqua,
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