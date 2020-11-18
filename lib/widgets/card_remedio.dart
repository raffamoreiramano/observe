import 'package:flutter/material.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/classes/enums.dart';
import 'package:observe/models/remedio.dart';

class CardRemedio extends StatefulWidget {
  final Remedio _remedio;
  final Function callback;
  CardRemedio(this._remedio, {this.callback});

  @override
  _CardRemedioState createState() => _CardRemedioState(this._remedio.horario.hour, this._remedio.horario.minute, this._remedio.tomado);
}

class _CardRemedioState extends State<CardRemedio> {
  EstadoRemedio _estado =  EstadoRemedio.adiantado;
  int _horas;
  int _minutos;
  bool _tomado;

  _CardRemedioState(this._horas, this._minutos, this._tomado);
  

  String _dosagem() {
    String medida = widget._remedio.medida;
    double quantia = widget._remedio.quantia;

    if (medida == 'unidade') {
      medida += widget._remedio.quantia.ceil() >= 2 ? 's' : '';
    }

    return quantia.toStringAsFixed(quantia.truncateToDouble() == quantia ? 0 :  1) + ' $medida';
  }

  String _horario() {
    final horas = _horas < 10 ? '0' + _horas.toString() : _horas.toString();
    final minutos = _minutos < 10 ? '0' + _minutos.toString() : _minutos.toString();

    return '$horas:$minutos';
  }

  ObserveColor _cor() {
    switch(_estado) {
      case EstadoRemedio.tomado:
        return ObserveColors.green;
        break;
      case EstadoRemedio.atrasado:
        return ObserveColors.red;
        break;
      default:
        return ObserveColors.aqua;
        break;
    }
  }

  marcar() {
    setState(() {
      _tomado = !_tomado;
      widget.callback.call(_tomado);
    });
  }

  @override
  Widget build(BuildContext context) {
    int horas = TimeOfDay.now().hour;
    int minutos = TimeOfDay.now().minute;
    bool _atrasado = DateTime(0, 0, 0, horas, minutos).isAfter(DateTime(0, 0, 0, _horas, _minutos));    

    if (_tomado) {
      _estado = EstadoRemedio.tomado;
    } else {
      _estado = _atrasado ? EstadoRemedio.atrasado : EstadoRemedio.adiantado;
    }

    return  Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: _cor(),
              width: 5,
            )
          )
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          title: Text(
            widget._remedio.nome,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
              color: Colors.blueGrey,
            ),
          ),
          subtitle: Text(
            _dosagem(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300
            ),
          ),
          trailing: Text(
            _horario(),
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w100
            ),
          ),
          onTap: () {
            marcar();            
          },
        ),
      ),
    );
  }
}