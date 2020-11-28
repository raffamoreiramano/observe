import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:observe/classes/api_response.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/views/paciente/formulario_paciente.dart';
import 'package:observe/widgets/linha_ficha_medica.dart';
import 'package:observe/widgets/multilinhas_ficha_medica.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class FichaMedica extends StatelessWidget {
  editarPerfil(Usuario usuario, Paciente paciente) {
    Get.to(
      FormularioPaciente(
        usuario: usuario,
        paciente: paciente,
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

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pt_BR', null);
    DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
    Paciente _paciente = context.select<Preferences, Paciente>((preferences) => preferences.paciente);
    Usuario _usuario = context.select<Preferences, Usuario>((preferences) => preferences.usuario);
    
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
                  'FICHA MÉDICA',
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
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text('Editar ficha')
                  ),
                ],
                onSelected: (_) {
                  editarPerfil(_usuario, _paciente);
                },
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(10),
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
              child: Column(
                children: [
                  LinhaFicha(
                    label: 'ID',
                    texto: _paciente.id.toString(),
                  ),
                  LinhaFicha(
                    label: 'NOME',
                    texto: _usuario.nome,
                  ),
                  LinhaFicha(
                    label: 'SOBRENOME',
                    texto: _usuario.sobrenome,
                  ),
                  LinhaFicha(
                    label: 'DATA DE NASCIMENTO',
                    texto: _dateFormat.format(_paciente.nascimento),
                  ),
                  MultiLinhasFicha(
                    label: 'DOENÇAS CRÔNICAS',
                    linhas: _paciente.doencas,
                  ),
                  MultiLinhasFicha(
                    label: 'ALERGIAS',
                    linhas: _paciente.alergias,
                  ),
                  MultiLinhasFicha(
                    label: 'REMÉDIOS CONSUMIDOS REGULARMENTE',
                    linhas: _paciente.remedios,
                  ),
                ],
              ),
            )
          ),
        ],
      ),      
    );
  }
}