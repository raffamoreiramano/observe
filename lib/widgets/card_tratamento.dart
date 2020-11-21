import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/models/tratamento.dart';

class CardTratamento extends StatelessWidget {
  final int index;
  final Tratamento tratamento;
  Color _cor;
  IconData _icone;
  String _estado;

  CardTratamento({this.index, this.tratamento}) {
    switch(tratamento.estado.round()) {
      case 1:
        _cor = ObserveColors.red;
        _icone = Icons.sick_outlined;
        _estado = 'muito mal';
        break;
      case 2:
        _cor = Colors.amber;
        _icone = Icons.mood_bad;
        _estado = 'mal';
        break;
      case 3:
        _cor = Colors.blueGrey[300];
        _icone = Icons.sentiment_neutral_rounded;
        _estado = 'normal';
        break;
      case 4:
        _cor = Colors.lightBlue[200];
        _icone = Icons.sentiment_satisfied_alt_rounded;
        _estado = 'bem';
        break;
      case 5:
        _cor = ObserveColors.green;
        _icone = Icons.sentiment_very_satisfied_rounded;
        _estado = 'muito bem';
        break;
      default:
        _cor = Colors.blueGrey[300];
        _icone = Icons.sentiment_neutral_rounded;
        _estado = 'normal';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Slidable(
        key: Key(index.toString()),                    
        actionPane: SlidableScrollActionPane(),
        actions: [
          IconSlideAction(
            onTap: () {

            },
            closeOnTap: true,
            foregroundColor: Colors.white,
            icon: Icons.auto_delete_rounded,
            caption: 'Remover',
            color: Colors.deepOrangeAccent[700],
          ),
          IconSlideAction(
            onTap: () {

            },
            closeOnTap: true,
            foregroundColor: Colors.white,
            icon: Icons.av_timer_rounded,
            caption: 'Editar',
            color: ObserveColors.aqua,
          ),
        ],
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: _cor,
                width: 5,
              )
            )
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            title: Text(
              tratamento.paciente,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: Colors.blueGrey,
              ),
            ),
            subtitle: Text(
              'ID: ${tratamento.pid}',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w200
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(_icone),
                Text(
                  _estado,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _cor,
                  ),
                ),
              ],
            ),
            onTap: () {

            },
          ),
        ),
      ),
    );
  }
}