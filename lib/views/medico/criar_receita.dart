import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:observe/classes/api_response.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/classes/enums.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/models/medico.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/remedio.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/repositories/medico_repository.dart';
import 'package:observe/repositories/paciente_repository.dart';
import 'package:observe/repositories/usuario_repository.dart';
import 'package:observe/widgets/input_decoration.dart';
import 'package:observe/widgets/linha_ficha_medica.dart';
import 'package:observe/widgets/loader.dart';
import 'package:observe/widgets/multilinhas_ficha_medica.dart';
import 'package:observe/widgets/remedio_controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class CriarReceita extends StatefulWidget {
  final Medico medico;
  final Paciente paciente;

  CriarReceita({this.medico, this.paciente});

  @override
  _CriarReceitaState createState() => _CriarReceitaState(medico, paciente);
}

class _CriarReceitaState extends State<CriarReceita> {
  Usuario _usuario;
  Medico _medico;
  Paciente _paciente;
  bool _visible = false;
  final bool _novo;
  List<Remedio> _remedios = List<Remedio>.empty(growable: true);
  GlobalKey _listKey = GlobalKey(); 

  DateFormat _dateFormat;

  _CriarReceitaState([this._medico, this._paciente]) : _novo = _paciente == null ? true : false;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _pidCTRL = TextEditingController();

  enviar() {

  }

  adicionarRemedio() {

  }

  buscar() async {
    PacienteRepository _pacienteRepo = PacienteRepository();
    UsuarioRepository _usuarioRepo = UsuarioRepository();

    await _pacienteRepo.readPaciente(id: int.parse(_pidCTRL.text))
      .then((paciente) async {
        _paciente = paciente;
      }).catchError((erro) {
        _paciente = Paciente();
      });

    _paciente.doencas.removeWhere((e) => e.isEmpty);
    _paciente.alergias.removeWhere((e) => e.isEmpty);
    _paciente.remedios.removeWhere((e) => e.isEmpty);

    if (_paciente.isNotEmpty) {
      await _usuarioRepo.readUsuario(id: _paciente.uid)
        .then((usuario) async {
          _usuario = usuario;
        }).catchError((erro) {
          _usuario = Usuario();
        });

    }

    setState(() {
      _visible = true;
    });
  }
  
  @override
  void initState() {
    super.initState();

    _pidCTRL.value = TextEditingValue(text: _paciente?.id?.toString() ?? '');
    
    _visible = true;

    if (_novo) {
      _paciente = Paciente();
    } else {
      buscar();
    }

    initializeDateFormatting('pt_BR', null);
    _dateFormat = DateFormat('dd/MM/yyyy');
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
              title: Text(
                'CRIAR RECEITA',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 20,
                ),
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
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: ObserveColors.dark[5],
                              border: Border(
                                bottom: BorderSide(
                                  color: ObserveColors.aqua[50],
                                )
                              )
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  children: [
                                    TextFormField(
                                      controller: _pidCTRL,
                                      onEditingComplete: () => FocusScope.of(context).nextFocus(),
                                      keyboardType: TextInputType.numberWithOptions(
                                        decimal: false,
                                        signed: false
                                      ),
                                      validator: (value) {
                                        bool isValid = RegExp(
                                          r"^[0-9]*$"
                                        ).hasMatch(value);

                                        if (isValid) {
                                          return null;
                                        } else {
                                          return "Formato de ID inválido!";
                                        }
                                      },
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                      decoration: standardFormInput(label: 'ID DO PACIENTE'),
                                    ),
                                    _novo
                                      ? Align(
                                        alignment: Alignment.bottomRight,
                                        child: RawMaterialButton(
                                          onPressed: () {
                                            setState(() {
                                              _visible = false;
                                            });
                                            buscar();
                                          },
                                          child: Container(
                                            height: 62,
                                            width: 100,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: ObserveColors.dark[5],
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(5)
                                              )
                                            ),
                                            child: Text(
                                              'BUSCAR',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                color: ObserveColors.aqua,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      : Container()
                                  ],
                                ),
                                _paciente.isEmpty
                                  ? Container()
                                  : Container(
                                    padding: EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        LinhaFicha(
                                          label: 'ID',
                                          texto: _paciente?.id?.toString(),
                                        ),
                                        LinhaFicha(
                                          label: 'NOME',
                                          texto: _usuario?.nome,
                                        ),
                                        LinhaFicha(
                                          label: 'SOBRENOME',
                                          texto: _usuario?.sobrenome,
                                        ),
                                        LinhaFicha(
                                          label: 'DATA DE NASCIMENTO',
                                          texto: _dateFormat.format(_paciente?.nascimento ?? DateTime.now()),
                                        ),
                                        MultiLinhasFicha(
                                          label: 'DOENÇAS CRÔNICAS',
                                          linhas: _paciente?.doencas,
                                        ),
                                        MultiLinhasFicha(
                                          label: 'ALERGIAS',
                                          linhas: _paciente?.alergias,
                                        ),
                                        MultiLinhasFicha(
                                          label: 'REMÉDIOS CONSUMIDOS',
                                          linhas: _paciente?.remedios,
                                        ),
                                      ],
                                    ),
                                  ),
                                ListView.builder(
                                  key: _listKey,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _remedios.length + 1,
                                  itemBuilder: _remedios.isEmpty
                                    ? (context, index) {
                                      return RemedioController(
                                        Remedio(),
                                        adicionar: (Remedio remedio) {
                                          setState(() {
                                            _remedios.add(remedio);
                                          });
                                        },
                                        atualizar: (Remedio remedio) {
                                          print('#################### ::: $index');
                                          setState(() {
                                            _remedios.insert(index, remedio);
                                          });
                                        },
                                      );
                                    }
                                    : (context, index) {
                                      final _ultimo = _remedios.length - 1;
                                      Remedio _remedio = Remedio();
                                      Function _adicionar = (Remedio remedio) {
                                        setState(() {
                                          _remedios.add(remedio);
                                        });
                                      };
                                      Function _atualizar = (Remedio remedio) {
                                        print('#################### ::: $index');

                                        setState(() {
                                          _remedios.insert(index, remedio);
                                        });
                                      };

                                      if (index <= _ultimo) {
                                        _remedio = _remedios.elementAt(index);
                                      }

                                      return RemedioController(
                                        _remedio,
                                        adicionar: _adicionar,
                                        atualizar: _atualizar,
                                      );
                                  },
                                ),
                              ],
                            ),
                          )
                        ],                    
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 30, bottom: 60),
                    child: FlatButton(
                      onPressed: () {
                        _remedios.printInfo();
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