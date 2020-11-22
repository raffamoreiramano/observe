import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/classes/tabela_alarme.dart';
import 'package:observe/helpers/database.dart';
import 'package:observe/models/alarme.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';

class CardAlarme extends StatefulWidget {
  final int index;
  final Alarme alarme;
  final Function callback;
  CardAlarme({this.index, this.alarme, this.callback});

  @override
  _CardAlarmeState createState() => _CardAlarmeState(alarme);
}

class _CardAlarmeState extends State<CardAlarme> {
  Alarme _alarme;

  _CardAlarmeState(this._alarme);

  Future<void> ligar() async {
    _alarme.ligado = !_alarme.ligado;
    if (_alarme.ligado) {
      final agora = tz.TZDateTime.now(tz.getLocation('America/Sao_Paulo'));
      final dia = agora.hour + agora.minute > _alarme.horas + _alarme.minutos ? agora.day + 1 : agora.day;
      tz.TZDateTime _data = tz.TZDateTime(tz.getLocation('America/Sao_Paulo'), agora.year, agora.month, dia, _alarme.horas, _alarme.minutos);

      final AndroidNotificationDetails notificationDetails = AndroidNotificationDetails(
        'alarme', 'canal de alarme', 'notifica o paciente sobre o horário do remédio',
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
        _alarme.id, _alarme.titulo, _alarme.texto, _data, NotificationDetails(android: notificationDetails), 
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: _alarme.remedio.toString(),
      ).then((_) async {
        final LocalDatabase _db = LocalDatabase();

        await _db.defineTable(TabelaAlarme());

        await _db.update(_alarme).then((value) {
          setState(() {
            _alarme.ligado = true;
          });
        });
      }).catchError((erro) => print(erro.toString()));
    } else {
      await context.read<FlutterLocalNotificationsPlugin>().cancel(
        _alarme.id
      ).then((_) => setState(() {
        _alarme.ligado = false;
      })).catchError((erro) => print(erro.toString()));
    }

    return;
  }

  @override
  Widget build(BuildContext context) {
    final horas = _alarme.horas < 10 ? '0' + _alarme.horas.toString() : _alarme.horas.toString();
    final minutos = _alarme.minutos < 10 ? '0' + _alarme.minutos.toString() : _alarme.minutos.toString();

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
                color: _alarme.ligado ? Colors.lightBlue[200] : Colors.blueGrey[200],
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
                _alarme.ligado ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
                size: 30,
                color: _alarme.ligado ? Colors.lightBlue[200] : Colors.blueGrey[200],
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