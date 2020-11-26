import 'package:observe/classes/tabela_alarme.dart';
import 'package:observe/helpers/database.dart';
import 'package:observe/models/alarme.dart';
import 'package:observe/widgets/card_alarme.dart';
import 'package:flutter/material.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/widgets/loader.dart';

class AlarmsPage extends StatefulWidget {
  @override
  _AlarmsPageState createState() => _AlarmsPageState();
}

class _AlarmsPageState extends State<AlarmsPage> {
  final _db = LocalDatabase();

  Future<List<Alarme>> fetchDatabase() async {
    List<Alarme> _lista;

    await _db.defineTable(TabelaAlarme());

    _lista = await _db.read();

    _lista.sort((r1, r2) {
      final int h1 = r1.horas;
      final int h2 = r2.horas;
      final int m1 = r1.minutos;
      final int m2 = r2.minutos;

      return DateTime(0, 0, 0, h1, m1).compareTo(DateTime(0, 0, 0, h2, m2)) * -1;
    });

    return _lista;
  }

  // @override
  // void initState() {
  //   super.initState();
  //   fetchDatabase();    
  // }
  
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
                    child: Text('. . .')
                  ),
                ],
                onSelected: (_) {
                  
                },
              )
            ],
          ),
          SliverToBoxAdapter(
            child:  FutureBuilder<List<Alarme>>(
              future: fetchDatabase(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Alarme> _lista = snapshot.data;

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
                        return CardAlarme(
                          index: index,
                          alarme: _lista[index],
                        );
                      },
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.all(50),
                    child: Text(
                      'Parece que você não tem nenhum alarme configurado...'
                      '\n\n'
                      'Já tentou sincronizar com o servidor?'
                      '\n'
                      'É o botãozinho ali de cima!',
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
        ],
      ),      
    );
  }
}