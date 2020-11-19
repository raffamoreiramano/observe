import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:observe/classes/api_response.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/classes/enums.dart';
import 'package:observe/classes/tabela_tratamento.dart';
import 'package:observe/helpers/database.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/tratamento.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/services/auth.dart';
import 'package:observe/services/messenger.dart';
import 'package:observe/views/medico/formulario_medico.dart';
import 'package:observe/widgets/card_tratamento.dart';
import 'package:observe/widgets/loader.dart';
import 'package:provider/provider.dart';
import 'package:observe/views/paciente/ficha_medica.dart';

class TratamentosPage extends StatefulWidget {
  final Usuario usuario;
  final Paciente paciente;
  
  TratamentosPage({this.usuario, this.paciente});

  @override
  _TratamentosPageState createState() => _TratamentosPageState(usuario, paciente);
}

class _TratamentosPageState extends State<TratamentosPage> {
  final Usuario _usuario;
  final Paciente _paciente;
  final _db = LocalDatabase();
  final messenger = CloudMessenger();
  final GlobalKey<State> _futureKey = GlobalKey<State>();
  bool _visible = true;

  _TratamentosPageState(this._usuario, this._paciente);

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

/*
  salvarReceita(Receita receita) async {
    await _db.defineTable(TabelaRemedio());

    await _db.clear();

    List<Remedio> receitas = receita.Receitas;
    
    receitas.map((remedio) async {
      remedio.id = receitas.indexOf(remedio);
      await _db.create(remedio);
    });

    List<Alarme> alarmes = receitas.map((remedio) {
      return Alarme(
        id: Receitas.indexOf(remedio),
        ligado: false,
        remedio: remedio
      );
    }).toList();

    await _db.defineTable(TabelaAlarme());

    await _db.clear();

    alarmes.map((alarme) async {
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
*/

  @override
  void initState() {
    super.initState();
    messenger.initialize(
      onMessage: (notification) async {
        if (notification.type == 'receita') {
          final payload = json.decode(notification.payload);

          // return await confirmarReceita(payload['rid']);
        }

        return null;
      },
      onLaunch: (notification) async {
        if (notification.type == 'receita') {
          final payload = json.decode(notification.payload);

          // return await confirmarReceita(payload['rid']);
        }

        return null;
      },
      onResume: (notification) async {
        if (notification.type == 'receita') {
          final payload = json.decode(notification.payload);

          // return await confirmarReceita(payload['rid']);
        }

        return null;
      },
    );

    messenger.salvarTokenMedico(_paciente.id);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        child: Icon(Icons.add_circle_outline_outlined),
      ),
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
                          return CardTratamento();
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
    );
  }
}