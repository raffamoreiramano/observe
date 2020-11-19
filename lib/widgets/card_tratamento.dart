import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/models/alarme.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';

class CardTratamento extends StatefulWidget {
  final int index;
  final Alarme alarme;
  final Function callback;
  CardTratamento({this.index, this.alarme, this.callback});

  @override
  _CardTratamentoState createState() => _CardTratamentoState(this.alarme.horas, this.alarme.minutos, this.alarme.ligado);
}

class _CardTratamentoState extends State<CardTratamento> {
  int _horas;
  int _minutos;
  bool _ligado;

  _CardTratamentoState(this._horas, this._minutos, this._ligado);

  Future<void> ligar() async {
    _ligado = !_ligado;
    if (_ligado) {
      final agora = tz.TZDateTime.now(tz.getLocation('America/Sao_Paulo'));
      tz.TZDateTime _data = tz.TZDateTime(tz.getLocation('America/Sao_Paulo'), agora.year, agora.month, agora.day, _horas, _minutos);

      final AndroidNotificationDetails notificationDetails = AndroidNotificationDetails(
        'Observe Paciente', 'Canal do paciente', 'Notificações locais para o paciente',
        priority: Priority.max,
        importance: Importance.max,
        channelShowBadge: true,
        enableLights: true,
        onlyAlertOnce: false,
        enableVibration: true,
        fullScreenIntent: true,
        playSound: true,
        ticker: 'ticker',
        ongoing: true,
        showWhen: true,
        category: 'alarm',
        sound: RawResourceAndroidNotificationSound('cradles_medium'),
      );

      await context.read<FlutterLocalNotificationsPlugin>().zonedSchedule(
        widget.alarme.id, widget.alarme.titulo, widget.alarme.texto, _data, NotificationDetails(android: notificationDetails), 
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'Teste',              
      ).then((_) => setState(() {
        _ligado = true;
      })).catchError((erro) => print(erro.toString()));
    } else {
      context.read<FlutterLocalNotificationsPlugin>().cancel(
        widget.alarme.id
      ).then((_) => setState(() {
        _ligado = false;
      })).catchError((erro) => print(erro.toString()));
    }

    return;
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