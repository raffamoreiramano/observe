import 'dart:math';
import 'package:observe/models/alarme.dart';
import 'package:observe/widgets/card_alarme.dart';
import 'package:flutter/material.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/models/remedio.dart';

class AlarmsPage extends StatefulWidget {
  @override
  _AlarmsPageState createState() => _AlarmsPageState();
}

class _AlarmsPageState extends State<AlarmsPage> {
  List<Remedio> _listaTeste = List<Remedio>.generate(10, (index) {
    var rng = Random();
    return Remedio(
      nome: 'Remédio nº ${rng.nextInt(100).toString()}',
      horario: TimeOfDay(hour: rng.nextInt(24), minute: rng.nextInt(24)),
      medida: rng.nextBool() ? 'unidade' : 'ml',
      quantia: (rng.nextDouble() * 10),
    );
  });

  @override
  void initState() {
    super.initState();
    _listaTeste.sort((r1, r2) {
      final int h1 = r1.horario.hour;
      final int h2 = r2.horario.hour;
      final int m1 = r1.horario.minute;
      final int m2 = r2.horario.minute;

      return DateTime(0, 0, 0, h1, m1).compareTo(DateTime(0, 0, 0, h2, m2)) * -1;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Paciente _paciente = context.select<Preferences, Paciente>((preferences) => preferences.paciente);
    // Usuario _usuario = context.select<Preferences, Usuario>((preferences) => preferences.usuario);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            forceElevated: true,
            floating: true,
            backgroundColor: ObserveColors.dark,
            toolbarHeight: 80,
            leadingWidth: 70,
            leading: Container(
              margin: EdgeInsets.only(left: 15),
              child: CircleAvatar(
                backgroundColor: ObserveColors.aqua[30],
                foregroundColor: ObserveColors.aqua,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 2.5),
                  child: Icon(
                    Icons.alarm,
                    size: 30,
                  ),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [                
                Text(
                  'ALARMES',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Ajuda',
                onPressed: () {

                },
                icon: Icon(
                  Icons.help_outline_rounded,
                  size: 30,
                ),
              ),
              IconButton(
                tooltip: 'Recuperar alarmes',
                onPressed: () {

                },
                icon: Icon(
                  Icons.history_rounded,
                  size: 30,
                ),
              ),
              PopupMenuButton(
                tooltip: 'Mostrar menu',
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text('Editar ficha')
                  ),
                ],
                onSelected: (_) {
                  
                },
              )
            ],
          ),
          SliverToBoxAdapter(
            child: ListView.builder(
              padding: EdgeInsets.only(
                top: 10,
                right: 10,
                bottom: 130,
                left: 10,
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _listaTeste.length,
              itemBuilder: (context, index) {
                return CardAlarme(
                  index: index,
                  alarme: Alarme(
                    remedio: _listaTeste[index],
                  ),
                  callback: () {

                  },
                );
              },
            ),
          )
        ],
      ),      
    );
  }
}