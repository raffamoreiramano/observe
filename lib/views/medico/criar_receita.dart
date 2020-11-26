import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/models/medico.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/receita.dart';
import 'package:observe/models/remedio.dart';
import 'package:observe/models/tratamento.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/repositories/paciente_repository.dart';
import 'package:observe/repositories/receita_repository.dart';
import 'package:observe/repositories/usuario_repository.dart';
import 'package:observe/widgets/input_decoration.dart';
import 'package:observe/widgets/linha_ficha_medica.dart';
import 'package:observe/widgets/loader.dart';
import 'package:observe/widgets/multilinhas_ficha_medica.dart';
import 'package:observe/widgets/remedio_controller.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class CriarReceita extends StatefulWidget {
  final Usuario usuarioMedico;
  final Medico medico;
  final Paciente paciente;

  CriarReceita({this.medico, this.usuarioMedico, this.paciente});

  @override
  _CriarReceitaState createState() => _CriarReceitaState(medico, usuarioMedico, paciente);
}

class _CriarReceitaState extends State<CriarReceita> {
  Usuario _usuario;
  final Usuario _usuarioMedico;
  Medico _medico;
  Paciente _paciente;
  bool _visible = false;
  final bool _novo;
  List<Remedio> _remedios = List<Remedio>.empty(growable: true);
  GlobalKey _listKey = GlobalKey(); 

  DateFormat _dateFormat;

  _CriarReceitaState([this._medico, this._usuarioMedico, this._paciente]) : _novo = _paciente == null ? true : false;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _pidCTRL = TextEditingController();

  enviar() async {
    if (_paciente.isEmpty) {
      Get.dialog(
        AlertDialog(
          title: Text('Paciente não identificado...'),
          content: Text('Busque o paciente pelo ID antes de confirmar a receita!'),
          actions: [
            TextButton(
              onPressed: () {
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
        )
      );

      setState(() {
        _visible = true;
      });

      return;
    }
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    final ReceitaRepository _repo = ReceitaRepository();

    final Receita _receita = Receita(
      mid: _medico.id,
      pid: _paciente.id,
      remedios: _remedios
    );

    final snapshot = await _firestore
      .collection('tratamentos')
      .where('pid', isEqualTo: _paciente.id)
      .where('mid', isEqualTo: _medico.id)
      .orderBy(FieldPath.documentId)
      .get();

    snapshot.docs.forEach((element) async {
      final id = element.id;

      await _firestore.doc('/tratamentos/$id').delete();
      await _repo.deleteReceita(int.parse(id));
    });

    await _repo.createReceita(_receita)
      .then((receita) async {
        final Tratamento _tratamento = Tratamento(
          id: receita.id,
          mid: receita.mid,
          pid: receita.pid,
          medico: _usuarioMedico.nome,
          paciente: _usuario.nome,
          inicio: DateTime.now(),
          retorno: DateTime.now(),
          estado: 3,
        );

        
        await _firestore
          .collection('tratamentos')
          .doc('${_tratamento.id}')
          .set(_tratamento.toMap())
          .then((value) {
            Get.dialog(
              AlertDialog(
                title: Text('Prontinho!'),
                content: Text(
                  'Sua receita já foi criada e enviada ao paciente...'
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
          })
          .catchError((erro) {
            Get.dialog(
              AlertDialog(
                title: Text('Ops...'),
                content: Text(
                  'Não foi possível criar a receita...'
                  '\n\n'
                  'Tente mais tarde!'
                ),
                actions: [
                  TextButton(
                    onPressed: () {
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
              )
            );
          });

      }).catchError((erro) {
        Get.dialog(
          AlertDialog(
            title: Text('Ops...'),
            content: Text(
              'Não foi possível criar a receita...'
              '\n\n'
              'Tente mais tarde!'
            ),
            actions: [
              TextButton(
                onPressed: () {
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
          )
        );
      });

      setState(() {
        _visible = true;
      });
  }

  Future buscar() async {
    PacienteRepository _pacienteRepo = PacienteRepository();
    UsuarioRepository _usuarioRepo = UsuarioRepository();

    if (_formKey.currentState.validate()) {
      await _pacienteRepo.readPaciente(id: int.parse(_pidCTRL.text))
        .then((paciente) async {
          _paciente = paciente;
        }).catchError((erro) {
          _paciente = Paciente();
        });


      if (_paciente.isNotEmpty) {
        _paciente.doencas.removeWhere((e) => e.isEmpty);
        _paciente.alergias.removeWhere((e) => e.isEmpty);
        _paciente.remedios.removeWhere((e) => e.isEmpty);

        await _usuarioRepo.readUsuario(id: _paciente.uid)
          .then((usuario) async {
            _usuario = usuario;
          }).catchError((erro) {
            _usuario = Usuario();
          });
      }
    }

    return;
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
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey[200],
                                      offset: Offset(0, 0.5),
                                      blurRadius: 0.5,
                                      spreadRadius: 0.5,
                                    )
                                  ],
                                ),
                                child: Stack(
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
                                            buscar().whenComplete(() => setState(() => _visible = true));
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
                              ),
                              _paciente.isEmpty
                                ? Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Text(
                                    'Nenhum paciente selecionado...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                )
                                : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey[200],
                                        offset: Offset(0, 0.5),
                                        blurRadius: 0.5,
                                        spreadRadius: 0.5,
                                      )
                                    ],
                                  ),
                                  padding: EdgeInsets.all(20),
                                  margin: EdgeInsets.only(top: 20),
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
                                    return Dismissible(                                      
                                      key: Key('$index'),
                                      confirmDismiss: (direction) {
                                        if (_remedios.length == index) {
                                          return Future(() {
                                            return false;
                                          });
                                        } else {
                                          _remedios.removeAt(index);
                                          return Future(() {
                                            return true;
                                          });
                                        }
                                      },
                                      child: RemedioController(
                                        Remedio(),
                                        adicionar: (Remedio remedio) {
                                          setState(() {
                                            print('ADICIONAR :: $index');
                                            _remedios.add(remedio);
                                          });
                                        },
                                        atualizar: (Remedio remedio) {
                                          setState(() {
                                            _remedios[index] = remedio;
                                            print('ATUALIZAR :: $index');
                                          });
                                        },
                                      ),
                                    );
                                  }
                                  : (context, index) {
                                    final _ultimo = _remedios.length - 1;
                                    Remedio _remedio = Remedio();
                                    Function _adicionar = (Remedio remedio) {
                                      setState(() {
                                        print('ADICIONAR :: $index');
                                        _remedios.add(remedio);
                                      });
                                    };
                                    Function _atualizar = (Remedio remedio) {
                                      setState(() {
                                        print('ATUALIZAR :: $index');
                                        _remedios[index] = remedio;
                                      });
                                    };

                                    if (index <= _ultimo) {
                                      _remedio = _remedios.elementAt(index);
                                    }

                                    return Dismissible(
                                      key: Key('$index'),
                                      confirmDismiss: (direction) {
                                        if (_remedios.length == index) {
                                          return Future(() {
                                            return false;
                                          });
                                        } else {
                                          _remedios.removeAt(index);
                                          return Future(() {
                                            return true;
                                          });
                                        }
                                      },
                                      child: RemedioController(
                                        _remedio,
                                        adicionar: _adicionar,
                                        atualizar: _atualizar,
                                      ),
                                    );
                                },
                              ),
                            ],
                          ),
                        ],                    
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15, bottom: 60),
                    child: FlatButton(
                      onPressed: () {
                        enviar();
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