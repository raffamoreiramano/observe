import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:observe/classes/api_response.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/classes/enums.dart';
import 'package:observe/classes/tabela_alarme.dart';
import 'package:observe/classes/tabela_remedio.dart';
import 'package:observe/helpers/database.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/models/alarme.dart';
import 'package:observe/models/estado_do_paciente.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/receita.dart';
import 'package:observe/models/tratamento.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/repositories/receita_repository.dart';
import 'package:observe/services/auth.dart';
import 'package:observe/services/messenger.dart';
import 'package:observe/views/paciente/alarmes_page.dart';
import 'package:observe/views/paciente/ficha_medica.dart';
import 'package:observe/views/paciente/formulario_paciente.dart';
import 'package:observe/widgets/card_remedio.dart';
import 'package:observe/widgets/loader.dart';
import 'package:observe/widgets/retorno_paciente.dart';
import 'package:provider/provider.dart';
import 'package:observe/models/remedio.dart';

class RemediosPage extends StatefulWidget {
  final Usuario usuario;
  final Paciente paciente;
  
  RemediosPage({this.usuario, this.paciente});

  @override
  _RemediosPageState createState() => _RemediosPageState(usuario, paciente);
}

class _RemediosPageState extends State<RemediosPage> {
  final Usuario _usuario;
  final Paciente _paciente;
  final _db = LocalDatabase();
  CloudMessenger _messenger;
  FirebaseFirestore _firestore;
  final GlobalKey<State> _futureKey = GlobalKey<State>();
  bool _visible = true;

  _RemediosPageState(this._usuario, this._paciente);

  Future<List<Remedio>> fetchDatabase() async {
    List<Remedio> _lista = List<Remedio>.empty();

    await _db.defineTable(TabelaRemedio());

    _lista = await _db.read();
    
    _lista.sort((r1, r2) {
      final int h1 = r1.horario.hour;
      final int h2 = r2.horario.hour;
      final int m1 = r1.horario.minute;
      final int m2 = r2.horario.minute;

      return DateTime(0, 0, 0, h1, m1).compareTo(DateTime(0, 0, 0, h2, m2)) * -1;
    });

    return _lista;
  }

  fichaMedica() {
    Get.to(FichaMedica());
  }

  alarmes() {
    Get.to(AlarmsPage());
  }

  editarPerfil() {
    Get.to(
      FormularioPaciente(
        usuario: context.read<Preferences>().usuario,
        paciente: context.read<Preferences>().paciente,
      )
    ).then((retorno) {
      if (retorno is! APIResponse) {
        Get.showSnackbar(GetBar(
          backgroundColor: ObserveColors.dark,
          title: 'Ok',
          message: 'Fingiremos que nada aconteceu...',
          duration: Duration(seconds: 2),
        ));
      }
    });
  }

  trocarPerfil() {
    context.read<Preferences>().setPerfil(Perfil.usuario);
  }

  desconectar() {
    Get.dialog(
      AlertDialog(
        title: Text('Desconectar...'),
        content: Text(
          'Tem certeza que deseja desconectar da sua conta?'
        ),        
        actions: [
          TextButton(
            onPressed: () {
              context.read<Preferences>().clear();
              context.read<AuthMethods>().signOut();
            },
            child: Text(
              'SIM',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'NÃO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      )
    );
  }

  salvarReceita(Receita receita) async {
    await _db.defineTable(TabelaRemedio());

    await _db.clear();

    List<Remedio> remedios = receita.remedios;
    
    remedios.forEach((remedio) async {
      remedio.id = remedios.indexOf(remedio);
      await _db.create(remedio);
    });

    List<Alarme> alarmes = remedios.map((remedio) {
      return Alarme(
        id: remedios.indexOf(remedio),
        ligado: false,
        remedio: remedio
      );
    }).toList();

    await _db.defineTable(TabelaAlarme());

    await _db.clear();

    alarmes.forEach((alarme) async {
      await _db.create(alarme);
    });

    setState(() {
      _visible = true;
    });

    _futureKey.currentState.reassemble();
  }

  fetchAPI(int rid) async {
    final ReceitaRepository _repo = ReceitaRepository();

    await _repo.readReceita(rid)
      .then((receita) {
        salvarReceita(receita);
      }).catchError((erro) {
        print(erro);
      });
  }

  Future<void> fetchFirestore() async {
    final snapshot = await _firestore
      .collection('tratamentos')
      .where('pid', isEqualTo: _paciente.id)
      .orderBy(FieldPath.documentId)
      .limitToLast(1)
      .get();
    
    List<Tratamento> tratamentos = snapshot
      .docs
      .map((doc) => Tratamento.fromMap(doc.data()))
      .toList();
    
    if (tratamentos.isEmpty) {
      return;
    }

    await fetchAPI(tratamentos.single.id);
  }

  confirmarReceita(int rid) {
    Get.dialog(
      AlertDialog(
        title: Text('Nova receita recebida!'),
        content: Text(
          'Ao confirmar o recebimento da receita '
          'o aplicativo irá gerar uma nova lista '
          'de remédios e alarmes de acordo com a lista da receita.'
          '\n\n'
          'Deseja confirmar?'
        ),        
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _visible = false;
              });

              fetchAPI(rid);

              Get.back();
            },
            child: Text(
              'SIM',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'NÃO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _messenger = CloudMessenger(_firestore);
    _messenger.initialize(
      onMessage: (notification) async {
        if (notification.type == 'receita') {
          final payload = json.decode(notification.payload);

          return await confirmarReceita(payload['rid']);
        }

        return null;
      },
      onLaunch: (notification) async {
        if (notification.type == 'receita') {
          final payload = json.decode(notification.payload);

          return await confirmarReceita(payload['rid']);
        }

        return null;
      },
      onResume: (notification) async {
        if (notification.type == 'receita') {
          final payload = json.decode(notification.payload);

          return await confirmarReceita(payload['rid']);
        }

        return null;
      },
    );

    _messenger.salvarTokenMedico(_paciente.id);

    fetchFirestore();
  }

  Future prontificarRetorno(List<Remedio> remedios, bool tomado) async {
    final tomados = remedios.map((remedio) => remedio.tomado).toList();

    if (remedios.length == tomados.length) {
      context.read<Preferences>().setTomado(tomado);
    }
  }

  Future resetarTabela() async {
    final remedios = await fetchDatabase();

    await _db.defineTable(TabelaRemedio());

    remedios.forEach((remedio) async {
      remedio.tomado = false;

      await _db.update(remedio);
    });    
  }

  enviarRetorno() async {
    final estado = context.read<Preferences>().getEstado();

    final snapshot = await _firestore
      .collection('tratamentos')
      .where('pid', isEqualTo: _paciente.id)
      .orderBy(FieldPath.documentId)
      .limitToLast(1)
      .get();
    
    List<Tratamento> tratamentos = snapshot
      .docs
      .map((doc) => Tratamento.fromMap(doc.data()))
      .toList();

    
    if (tratamentos.isEmpty) {
      return;
    }

    Tratamento tratamento = tratamentos.single;

    tratamento.retorno = DateTime.now();
    tratamento.estado = estado;
    
    await _firestore
      .doc('/tratamentos/${tratamento.id}')
      .set(tratamento.toMap());
  }
  
  @override
  Widget build(BuildContext context) {
    bool _tomado = context.select<Preferences, bool>((preferences) => preferences.tomado);
    double _nivel = context.select<Preferences, double>((preferences) => preferences.estado);

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: BottomAppBar(
        clipBehavior: Clip.hardEdge,
        notchMargin: 5,
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 70,
          width: MediaQuery.of(context).size.width,
          child: Row(            
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                  height: 70,
                  child: RawMaterialButton(
                    onPressed: () {
                      fichaMedica();
                    },
                    padding: EdgeInsets.only(right: _tomado ? 40 : 0),                    
                    child: Icon(
                      Icons.assignment_outlined,
                      color: Colors.blueGrey,
                      size: 30,
                    ),
                    highlightColor: ObserveColors.aqua[30],
                    splashColor: ObserveColors.aqua[30],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 70,
                  child: RawMaterialButton(
                    onPressed: () {
                      alarmes();
                    },
                    padding: EdgeInsets.only(left: _tomado ? 40 : 0),
                    child: Icon(
                      Icons.alarm,
                      color: Colors.blueGrey,
                      size: 30,
                    ),
                    highlightColor: ObserveColors.aqua[30],
                    splashColor: ObserveColors.aqua[30],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _tomado 
        ? ChangeNotifierProvider<EstadoNotifier>(
          create: (context) => EstadoNotifier(_nivel),
          child: BotaoRetorno(
            nivel: _nivel,
            callback: (estado) {
              context.read<Preferences>().setTomado(false);
              context.read<Preferences>().setEstado(estado);
              resetarTabela();
              enviarRetorno();
            },
          ),
        )
        : null,
      body: RefreshIndicator(
        onRefresh: () {
          return fetchFirestore();
        },
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
                    'ID: ${_paciente.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.w100,
                      color: Colors.white70,
                      fontSize: 18,
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
                        editarPerfil();
                        break;
                      case Opcoes.trocar:
                        trocarPerfil();
                        break;
                      case Opcoes.sair:
                        desconectar();
                        break;
                    }
                  },
                )
              ],
            ),
            SliverToBoxAdapter(
              child:  Visibility(
                visible: _visible,
                replacement: Container(
                  height: MediaQuery.of(context).size.height - 160,
                  alignment: Alignment.center,
                  child: Loader(),            
                ),
                child: FutureBuilder<List<Remedio>>(
                  key: _futureKey,
                  future: fetchDatabase(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Remedio> _lista = snapshot.data;

                      if (_lista.isNotEmpty) {
                        return ListView.builder(
                          padding: EdgeInsets.only(
                            top: 10,
                            right: 10,
                            bottom: 130,
                            left: 10,
                          ),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _lista.length,              
                          itemBuilder: (context, index) {
                            return CardRemedio(
                              _lista[index],
                              callback: (tomado) {
                                prontificarRetorno(_lista, tomado);
                              },
                            );
                          },
                        );
                      }

                      return Padding(
                        padding: EdgeInsets.all(50),
                        child: Text(
                          'Parece que você ainda não tem nenhuma receita disponível...'
                          '\n\n'
                          'Solicite ao seu médico que mande a receita para o seu ID!',
                          style: TextStyle(
                            color: Colors.blueGrey,
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        height: MediaQuery.of(context).size.height - 160,
                        alignment: Alignment.center,
                        child: Loader(),            
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}