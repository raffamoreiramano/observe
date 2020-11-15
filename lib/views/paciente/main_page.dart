import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/classes/enums.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/models/estado_do_paciente.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/repositories/paciente_repository.dart';
import 'package:observe/repositories/usuario_repository.dart';
import 'package:observe/views/paciente/formulario_perfil.dart';
import 'package:observe/widgets/retorno_paciente.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

class PacienteMainPage extends StatefulWidget {
  @override
  _PacienteMainPageState createState() => _PacienteMainPageState();
}

class _PacienteMainPageState extends State<PacienteMainPage> {
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
  void initState() {
    super.initState();
    // _nascimentoCTRL.value = TextEditingValue(text: '31/12/1999');
    initializeDateFormatting('pt_BR', null);
  }

  Future verificarPerfil() async {
    final PacienteRepository _repo = PacienteRepository();

    await _repo.readPaciente(cid: context.watch<User>().uid)
      .then((paciente) {
        context.read<Preferences>().setPaciente(paciente);
      }).catchError((erro) {
        context.read<Preferences>().setPaciente();
      });    
  }

  @override
  Widget build(BuildContext context) {
    Paciente _paciente = context.select<Preferences, Paciente>((preferences) => preferences.paciente);
    Usuario _usuario = context.select<Preferences, Usuario>((preferences) => preferences.usuario);

    if (_paciente.isEmpty) {
      return FormularioPaciente(usuario: _usuario);
    }

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

                    },
                    padding: EdgeInsets.only(right: 40),                    
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

                    },
                    padding: EdgeInsets.only(left: 40),
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
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ChangeNotifierProvider<EstadoNotifier>(
        create: (context) => EstadoNotifier(),
        child: BotaoRetorno(),
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
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),                      
                    ),
                    title: Text(
                      'Remedio nº $index',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.blueGrey,
                      ),
                    ),
                    subtitle: Text(
                      '10 ml',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300
                      ),
                    ),
                    trailing: Text(
                      '17:00',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w100
                      ),
                    ),
                    onTap: () {
                      
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}