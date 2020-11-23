import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:observe/classes/api_response.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/repositories/paciente_repository.dart';
import 'package:observe/repositories/usuario_repository.dart';
import 'package:observe/widgets/input_decoration.dart';
import 'package:observe/widgets/loader.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
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
  bool _visible = false;
  final bool _novo;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  _FormularioPacienteState(this._usuario, this._paciente) : _novo = _paciente == null ? true : false;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _nomeCTRL = TextEditingController();
  TextEditingController _sobrenomeCTRL = TextEditingController();
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
  void initState() {
    super.initState();

    initializeDateFormatting('pt_BR', null);

    final _data = _paciente?.nascimento ?? DateTime(1999, 12, 31);

    _nomeCTRL.value = TextEditingValue(text: _usuario.nome);
    _sobrenomeCTRL.value = TextEditingValue(text: _usuario.sobrenome);
    _nascimentoCTRL.value = TextEditingValue(text: _dateFormat .format(_data));
    _doencasCTRL.value = TextEditingValue(text: _paciente?.doencas?.join(', ') ?? '');
    _alergiasCTRL.value = TextEditingValue(text: _paciente?.alergias?.join(', ') ?? '');
    _remediosCTRL.value = TextEditingValue(text: _paciente?.remedios?.join(', ') ?? '');
    
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
    List<String> doencas = _doencasCTRL.text.split(',').map((e) => e.trim()).toList();
    List<String> alergias = _alergiasCTRL.text.split(',').map((e) => e.trim()).toList();
    List<String> remedios = _remediosCTRL.text.split(',').map((e) => e.trim()).toList();

    Paciente paciente = Paciente(
      id: _novo ? null : _paciente.id,
      uid: _usuario.id,
      nascimento: _novo ? _dateFormat.parse(_nascimentoCTRL.text.trim()) : null,
      doencas: doencas.isEmpty ? null : doencas,
      alergias: alergias.isEmpty ? null : alergias,
      remedios: remedios.isEmpty ? null : remedios,
    );

    if (_novo) {
      final _repo = PacienteRepository();

      await _repo.createPaciente(paciente)
        .then((paciente) {
          context.read<Preferences>().setPaciente(paciente);
        }).catchError((erro) {
          alerta(erro);
        });

      setState(() {
        _visible = true;
      });

      return;
    }

    final _usuarioRepo = UsuarioRepository();
    final _pacienteRepo = PacienteRepository();

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

    await _pacienteRepo.updatePaciente(id: _paciente.id, data: paciente)
      .then((value) {
        context.read<Preferences>().setPaciente(value);
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
                            controller: _novo ? _nascimentoCTRL : null,
                            initialValue: _novo ? null : _nascimentoCTRL.text,
                            keyboardType: TextInputType.datetime,
                            onEditingComplete: () => FocusScope.of(context).nextFocus(),
                            inputFormatters: _novo ? [_nascimentoFormatter] : null,
                            validator: (value) {
                              if (!_novo) {
                                return null;
                              }

                              if (value.isEmpty) {
                                return 'Informe uma data válida!';
                              }

                              final _input = _nascimentoFormatter.getMaskedText();
                              
                              final DateTime _data = _dateFormat.parse(_input);

                              if (_data.isAfter(DateTime.now())) {
                                return 'Informe uma data válida';
                              }

                              if (_data.isBefore(DateTime(1900))) {
                                return 'Informe uma data válida';
                              }

                              return null;
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
                            textCapitalization: TextCapitalization.words,
                            onEditingComplete: () => FocusScope.of(context).nextFocus(),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              bool isValid = RegExp(
                                r"^[0-9A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ., -]*$"
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
                            textCapitalization: TextCapitalization.words,
                            keyboardType: TextInputType.name,
                            onEditingComplete: () => FocusScope.of(context).nextFocus(),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              bool isValid = RegExp(
                                r"^[0-9A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ., -]*$"
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
                            textCapitalization: TextCapitalization.words,
                            keyboardType: TextInputType.name,
                            onEditingComplete: () => FocusScope.of(context).nextFocus(),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              bool isValid = RegExp(
                                r"^[0-9A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ., -]*$"
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