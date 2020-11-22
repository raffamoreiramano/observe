import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:observe/classes/api_response.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/classes/enums.dart';
import 'package:observe/classes/tabela_tratamento.dart';
import 'package:observe/helpers/database.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/models/medico.dart';
import 'package:observe/models/tratamento.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/services/auth.dart';
import 'package:observe/services/messenger.dart';
import 'package:observe/views/medico/criar_receita.dart';
import 'package:observe/views/medico/formulario_medico.dart';
import 'package:observe/widgets/card_tratamento.dart';
import 'package:observe/widgets/loader.dart';
import 'package:provider/provider.dart';
import 'package:observe/views/paciente/ficha_medica.dart';

class TratamentosPage extends StatefulWidget {
  final Usuario usuario;
  final Medico medico;
  
  TratamentosPage({this.usuario, this.medico});

  @override
  _TratamentosPageState createState() => _TratamentosPageState(usuario, medico);
}

class _TratamentosPageState extends State<TratamentosPage> {
  final Usuario _usuario;
  final Medico _medico;
  final _db = LocalDatabase();
  final GlobalKey<State> _futureKey = GlobalKey<State>();
  FirebaseFirestore _firestore;
  CloudMessenger _messenger;
  bool _visible = true;

  _TratamentosPageState(this._usuario, this._medico);

  Future<List<Tratamento>> fetchDatabase() async {
    List<Tratamento> _lista = List<Tratamento>.empty();

    await _db.defineTable(TabelaTratamento());

    _lista = await _db.read();
    
    _lista.sort((t1, t2) {
      final DateTime h1 = t1.retorno;
      final DateTime h2 = t2.retorno;

      return h1.compareTo(h2) * -1;
    });

    return _lista;
  }

  fichaMedica() {
    Get.to(FichaMedica());
  }

  editarPerfil() {
    Get.to(
      FormularioMedico(
        usuario: context.read<Preferences>().usuario,
        medico: context.read<Preferences>().medico,
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

  Future<void> salvarTratamentos(List<Tratamento> tratamentos) async {
    await _db.defineTable(TabelaTratamento());

    await _db.clear();

    tratamentos.forEach((tratamento) async {
      await _db.create(tratamento);
    });


    setState(() {
      _visible = true;
    });
  }

  Future<void> fetchFirestore() async {
    final snapshot = await _firestore
      .collection('tratamentos')
      .where('mid', isEqualTo: _medico.id)
      .get();
    
    List<Tratamento> tratamentos = snapshot
      .docs
      .map((doc) => Tratamento.fromMap(doc.data()))
      .toList();

    await salvarTratamentos(tratamentos);
  }

  visualizarRetorno() {
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

              fetchFirestore();

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

  Future<void> criarReceita() async {
    Get.to(CriarReceita(
      medico: _medico,
      usuarioMedico: _usuario,
    ));
  }


  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _messenger = CloudMessenger(_firestore);
    _messenger.initialize(
      onMessage: (notification) async {
        if (notification.type == 'retorno') {
          // final payload = json.decode(notification.payload);

          // return await visualizarRetorno(payload['rid']);
        }

        return null;
      },
      onLaunch: (notification) async {
        if (notification.type == 'retorno') {
          // final payload = json.decode(notification.payload);

          // return await visualizarRetorno(payload['rid']);
        }

        return null;
      },
      onResume: (notification) async {
        if (notification.type == 'retorno') {
          // final payload = json.decode(notification.payload);

          // return await visualizarRetorno(payload['rid']);
        }

        return null;
      },
    );

    _messenger.salvarTokenMedico(_medico.id);

    fetchFirestore();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: Container(
        margin: EdgeInsets.all(10),
        height: 90,
        width: 90,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: Colors.lightBlue[300],
            width: 2,
          )
        ),
        child: RawMaterialButton(
          onPressed: () {
            criarReceita();
          },
          shape: CircleBorder(),
          highlightColor: Colors.lightBlue[100],
          splashColor: Colors.lightBlue[300],
          child: Container(
            height: 90,
            width: 90,
            padding: EdgeInsets.only(
              left: 7,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.playlist_add, size: 30, color: Colors.blueGrey[300]),
          ),
        ),
      ),
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
                    'CRM: ${_medico.crm}',
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
                child: FutureBuilder<List<Tratamento>>(
                  key: _futureKey,
                  future: fetchDatabase(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Tratamento> _lista = snapshot.data;

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
                            return CardTratamento(
                              index: index,
                              tratamento: _lista[index],
                            );
                          },
                        );
                      }

                      return Padding(
                        padding: EdgeInsets.all(50),
                        child: Text(
                          'Parece que você ainda não acompanha nenhum tratamento...',
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