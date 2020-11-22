import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:observe/classes/api_response.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/classes/enums.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/models/medico.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/repositories/medico_repository.dart';
import 'package:observe/repositories/usuario_repository.dart';
import 'package:observe/widgets/input_decoration.dart';
import 'package:observe/widgets/loader.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

class FormularioMedico extends StatefulWidget {
  final Usuario usuario;
  final Medico medico;

  FormularioMedico({this.usuario, this.medico});

  @override
  _FormularioMedicoState createState() => _FormularioMedicoState(usuario, medico);
}

class _FormularioMedicoState extends State<FormularioMedico> {
  Usuario _usuario;
  Medico _medico;
  bool _visible = false;
  final bool _novo;

  _FormularioMedicoState(this._usuario, this._medico) : _novo = _medico == null ? true : false;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _nomeCTRL = TextEditingController();
  TextEditingController _sobrenomeCTRL = TextEditingController();
  TextEditingController _crmCTRL = TextEditingController();
  
  @override
  void initState() {
    super.initState();

    initializeDateFormatting('pt_BR', null);

    _nomeCTRL.value = TextEditingValue(text: _usuario.nome);
    _sobrenomeCTRL.value = TextEditingValue(text: _usuario.sobrenome);
    _crmCTRL.value = TextEditingValue(text: _medico?.crm ?? '');
    
    _visible = true;
  }

  alerta(APIResponse erro) {
    Get.dialog(
      AlertDialog(
        title: Text('Ops...'),
        content: Text(
          'Não foi possível atualizar seu perfil!'
          '\n\n'
          'Código HTTP: '
          + erro.status.toString() +
          '\n'
          'Erro: '
          + erro.data
        ),        
        actions: [
          TextButton(
            onPressed: () {
              Get.back(closeOverlays: true);
            },
            child: Text(
              'Ok',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      )
    );
  }

  Future enviar() async {

    Medico medico = Medico(
      id: _novo ? null : _medico.id,
      uid: _usuario.id,
      crm: _novo ? _crmCTRL.text.trim() : null,
    );

    if (_novo) {
      final _repo = MedicoRepository();

      await _repo.createMedico(medico)
        .then((medico) {
          context.read<Preferences>().setMedico(medico);
        }).catchError((erro) {
          alerta(erro);
        });

      setState(() {
        _visible = true;
      });

      return;
    }

    final _usuarioRepo = UsuarioRepository();

    Usuario usuario = Usuario(
      id: _usuario.id,
      cid: _usuario.cid,
      nome: _nomeCTRL.text.trim(),
      sobrenome: _sobrenomeCTRL.text.trim(),
    );

    APIResponse _erro;

    await _usuarioRepo.updateUsuario(id: _usuario.id, data: usuario)
      .then((value) {
        context.read<Preferences>().setUsuario(value);
      }).catchError((erro) {
        _erro = erro is APIResponse ? erro : APIResponse(status: 500, data: 'Problema desconhecido');
      });

    if (_erro.isNullOrBlank) {
      Get.back(result: APIResponse(status: 204, data: 'Perfil atualizado'));
    } else {
      setState(() {
        _visible = true;
      });

      alerta(_erro);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Visibility(
        visible: _visible,
        replacement: Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: Loader(),            
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: ObserveColors.dark,
              toolbarHeight: 80,
              leadingWidth: 70,
              leading: Container(
                margin: EdgeInsets.only(left: 15),
                child: CircleAvatar(
                  backgroundColor: ObserveColors.orange[30],
                  foregroundColor: ObserveColors.orange,
                  child: Icon(
                    Icons.healing_rounded,
                    size: 30,
                  ),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_usuario.nome} ${_usuario.sobrenome}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    _novo ? 'CRIAR PERFIL' : 'EDITAR PERFIL',
                    style: TextStyle(
                      fontWeight: FontWeight.w100,
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              actions: [
                PopupMenuButton(
                  itemBuilder: (context) => <PopupMenuEntry<Opcoes>>[
                    PopupMenuItem(
                      value: Opcoes.config,
                      child: Text('Configurações'),
                    ),
                    PopupMenuItem(
                      value: Opcoes.trocar,
                      child: Text('Trocar de perfil'),
                    ),
                    PopupMenuItem(
                      value: Opcoes.sair,
                      child: Text('Desconectar'),
                    ),
                  ],
                  onSelected: (Opcoes opcoes) {
                    switch (opcoes) {
                      case Opcoes.config:
                        print('popup :: Configurações');
                        break;
                      case Opcoes.trocar:
                        print('popup :: Trocar de perfil');
                        break;
                      case Opcoes.sair:
                        context.read<Preferences>().setPerfil(Perfil.usuario);
                        break;
                    }
                  },
                )
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.all(20),
                          child: TextFormField(
                            enabled: !_novo,
                            readOnly: _novo,
                            controller: _nomeCTRL,
                            textCapitalization: TextCapitalization.words,
                            onEditingComplete: () => FocusScope.of(context).nextFocus(),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            style: TextStyle(
                              fontSize: 18,
                            ),
                            decoration: standardFormInput(label: 'NOME'),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(20),
                          child: TextFormField(
                            enabled: !_novo,
                            readOnly: _novo,
                            controller: _sobrenomeCTRL,
                            textCapitalization: TextCapitalization.words,
                            onEditingComplete: () => FocusScope.of(context).nextFocus(),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            style: TextStyle(
                              fontSize: 18,
                            ),
                            decoration: standardFormInput(label: 'SOBRENOME'),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(20),
                          child: TextFormField(
                            enabled: _novo,
                            readOnly: !_novo,
                            controller: _crmCTRL,
                            keyboardType: TextInputType.streetAddress,
                            textCapitalization: TextCapitalization.characters,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            autocorrect: false,                            
                            validator: (value) {
                              bool isValid = RegExp(
                                r"^[0-9]{4,10}\/[A-Z]{2}$"
                              ).hasMatch(value);

                              if (isValid) {
                                return null;
                              } else {
                                return "CRM inválido!";
                              }
                            },
                            style: TextStyle(
                              fontSize: 18,
                            ),
                            decoration: standardFormInput(label: 'CRM', hintText: '0000/UF'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 30, bottom: 60),
                    child: FlatButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            _visible = false;
                          });

                          enviar();
                        }
                      },
                      height: 50,
                      splashColor: ObserveColors.green,
                      highlightColor: Colors.white54,
                      color: ObserveColors.green[50],
                      child: Text(
                        'CONFIRMAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}