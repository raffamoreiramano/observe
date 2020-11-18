import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:observe/classes/api_response.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/helpers/preferences.dart';
import 'package:observe/models/paciente.dart';
import 'package:observe/models/usuario.dart';
import 'package:observe/views/paciente/formulario_paciente.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class FichaMedica extends StatelessWidget {
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

class LinhaFicha extends StatelessWidget {
  final String label;
  final String texto;

  LinhaFicha({this.label, this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.grey[200],
          )
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w200,
            ),
          ),
          Text(
            texto,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class MultiLinhasFicha extends StatelessWidget {
  final String label;
  final List<String> linhas;

  MultiLinhasFicha({this.label, this.linhas});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.grey[200],
          )
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w200,
            ),
          ),
          linhas?.isEmpty ?? true
            ? Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                ' . . .',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w200,
                ),
              ),
            )
            : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 5),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: linhas.length,
              itemBuilder: (context, index) {
                final String texto = linhas[index];
                return Text.rich(
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                    ),
                    children: [
                      TextSpan(
                        text: ' $texto',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ]
                  ),
                );
              },        
            ),
        ],
      ),
    );
  }
}