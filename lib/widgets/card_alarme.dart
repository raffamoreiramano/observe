import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/models/alarme.dart';

class CardAlarme extends StatefulWidget {
  final int index;
  final Alarme alarme;
  final Function callback;
  CardAlarme({this.index, this.alarme, this.callback});

  @override
  _CardAlarmeState createState() => _CardAlarmeState(this.alarme.horas, this.alarme.minutos, this.alarme.ligado);
}

class _CardAlarmeState extends State<CardAlarme> {
  int _horas;
  int _minutos;
  bool _ligado;

  _CardAlarmeState(this._horas, this._minutos, this._ligado);

  ligar() {
    setState(() {
      _ligado = !_ligado;
    });
  }

  @override
  Widget build(BuildContext context) {
    final horas = _horas < 10 ? '0' + _horas.toString() : _horas.toString();
    final minutos = _minutos < 10 ? '0' + _minutos.toString() : _minutos.toString();

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Slidable(
        key: Key(widget.index.toString()),                    
        actionPane: SlidableScrollActionPane(),
        actions: [
          IconSlideAction(
            closeOnTap: true,
            foregroundColor: Colors.white,
            icon: Icons.auto_delete_rounded,
            caption: 'Remover',
            color: Colors.deepOrangeAccent[700],
          ),
          IconSlideAction(
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
                color: _ligado ? Colors.lightBlue[200] : Colors.blueGrey[200],
                width: 5,
              )
            )
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            title: Text(
              widget.alarme.remedio.nome,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: Colors.blueGrey,
              ),
            ),
            subtitle: Text(
              '$horas:$minutos',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w200
              ),
            ),
            trailing: Container(
              padding: EdgeInsets.only(
                top: 0,
                bottom: 3,
                right: 5,
                left: 5,
              ),
              child: Icon(
                _ligado ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
                size: 30,
                color: _ligado ? Colors.lightBlue[200] : Colors.blueGrey[200],
              ),
            ),
            onTap: () {
              ligar();
            },
          ),
        ),
      ),
    );
  }
}