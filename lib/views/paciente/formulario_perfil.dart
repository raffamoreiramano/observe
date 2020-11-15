import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/classes/enums.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/widgets/input_decoration.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class FormularioPaciente extends StatefulWidget {
  final Usuario usuario;
  final Paciente paciente;

  FormularioPaciente({this.usuario, this.paciente});

  @override
  _FormularioPacienteState createState() => _FormularioPacienteState(usuario, paciente);
}

class _FormularioPacienteState extends State<FormularioPaciente> {
  Usuario _usuario;
  Paciente _paciente;
  final bool _novo;

  _FormularioPacienteState(this._usuario, this._paciente) : _novo = _paciente == null ? true : false;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _nascimentoCTRL = TextEditingController();
  TextEditingController _doencasCTRL = TextEditingController();
  TextEditingController _alergiasCTRL = TextEditingController();
  TextEditingController _remediosCTRL = TextEditingController();

  MaskTextInputFormatter _nascimentoFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: { "#": RegExp(r'[0-9]') },
    initialText: '00/00/0000'
  );
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: ObserveColors.dark,
            toolbarHeight: 80,
            leadingWidth: 70,
            leading: Container(
              margin: EdgeInsets.only(left: 15),
              child: CircleAvatar(
                backgroundColor: ObserveColors.aqua[30],
                foregroundColor: ObserveColors.aqua,
                child: Icon(
                  Icons.person_rounded,
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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: EdgeInsets.all(20),
                      child: TextFormField(
                        enabled: !_novo,
                        readOnly: !_novo,
                        initialValue: _usuario.nome,
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
                        readOnly: !_novo,
                        initialValue: _usuario.sobrenome,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        decoration: standardFormInput(label: 'SOBRENOME'),
                      ),
                    ),
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.all(20),
                        child: TextFormField(
                          enabled: _novo,
                          readOnly: _novo,
                          controller: _nascimentoCTRL,
                          keyboardType: TextInputType.datetime,
                          inputFormatters: [
                            _nascimentoFormatter,
                          ],
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Informe uma data válida!';
                            }

                            final _input = _nascimentoFormatter.getMaskedText();
                            
                            final DateTime _data = DateFormat('dd/MM/yyyy').parse(_input);

                            if (_data.isAfter(DateTime.now())) {
                              return 'Informe uma data válida';
                            }

                            if (_data.isBefore(DateTime(1900))) {
                              return 'Informe uma data válida';
                            }
                          },
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          decoration: standardFormInput(label: 'NASCIMENTO', hintText: '31/12/1999'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(20),
                        child: TextFormField(
                          minLines: 1,
                          maxLines: 3,
                          controller: _doencasCTRL,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            bool isValid = RegExp(
                              r"^[A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ., -]*$"
                            ).hasMatch(value);

                            if (isValid) {
                              return null;
                            } else {
                              return "Contém caractere inválido!";
                            }
                          },
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          decoration: standardFormInput(
                            label: 'DOENÇAS CRÔNICAS',
                            hintText: 'Separadas por vírgula...',
                            helperText: 'Ex.: Diabetes, Lupus'
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(20),
                        child: TextFormField(
                          minLines: 1,
                          maxLines: 3,
                          controller: _alergiasCTRL,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            bool isValid = RegExp(
                              r"^[A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ., -]*$"
                            ).hasMatch(value);

                            if (isValid) {
                              return null;
                            } else {
                              return "Contém caractere inválido!";
                            }
                          },
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          decoration: standardFormInput(
                            label: 'ALERGIAS',
                            hintText: 'Separadas por vírgula...',
                            helperText: 'Ex.: Benzetacil, Dipirona'
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(20),
                        child: TextFormField(
                          minLines: 1,
                          maxLines: 3,
                          controller: _remediosCTRL,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            bool isValid = RegExp(
                              r"^[A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ., -]*$"
                            ).hasMatch(value);

                            if (isValid) {
                              return null;
                            } else {
                              return "Contém caractere inválido!";
                            }
                          },
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          decoration: standardFormInput(
                            label: 'REMÉDIOS CONSUMIDOS REGULARMENTE',
                            hintText: 'Separados por vírgula...',
                            helperText: 'Ex.: Insulina, Cloridrato de nafazolina'
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30, bottom: 60),
                  child: FlatButton(
                    onPressed: () {

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
    );
  }
}