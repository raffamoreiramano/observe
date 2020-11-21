import 'package:flutter/material.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/classes/enums.dart';
import 'package:observe/classes/tabela_remedio.dart';
import 'package:observe/helpers/database.dart';
import 'package:observe/models/remedio.dart';

class CardRemedio extends StatefulWidget {
  final Remedio _remedio;

  CardRemedio(this._remedio);

  @override
  _CardRemedioState createState() => _CardRemedioState(this._remedio);
}

class _CardRemedioState extends State<CardRemedio> {
  EstadoRemedio _estado =  EstadoRemedio.adiantado;
  Remedio _remedio;

  _CardRemedioState(this._remedio);
  

  String _dosagem() {
    String medida = _remedio.medida;
    double quantia = _remedio.quantia;

    if (medida == 'unidade') {
      medida += _remedio.quantia.ceil() >= 2 ? 's' : '';
    }

    return quantia.toStringAsFixed(quantia.truncateToDouble() == quantia ? 0 :  1) + ' $medida';
  }

  String _horario() {
    final horas = _remedio.horario.hour < 10 ? '0' + _remedio.horario.hour.toString() : _remedio.horario.hour.toString();
    final minutos = _remedio.horario.minute < 10 ? '0' + _remedio.horario.minute.toString() : _remedio.horario.minute.toString();

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

  marcar() async {
    _remedio.tomado = !_remedio.tomado;

    final LocalDatabase _db = LocalDatabase();

    await _db.defineTable(TabelaRemedio());

    await _db.update(_remedio)
      .then((value) {
        print('deu certo');
        setState(() {});
      }).catchError((erro) {
        _remedio.tomado = !_remedio.tomado;
      });
  }

  @override
  Widget build(BuildContext context) {
    int horas = TimeOfDay.now().hour;
    int minutos = TimeOfDay.now().minute;
    bool _atrasado = DateTime(0, 0, 0, horas, minutos).isAfter(DateTime(0, 0, 0, _remedio.horario.hour, _remedio.horario.minute));    

    if (_remedio.tomado) {
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