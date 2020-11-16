import 'package:observe/models/remedio.dart';

class Alarme {
  final Remedio remedio;
  int  id;
  int get horas => remedio.horario.hour;
  int get minutos => remedio.horario.minute;
  bool ligado;

  Alarme({this.remedio, this.ligado =  true});
}