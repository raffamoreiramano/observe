import 'package:flutter/material.dart';
import 'package:observe/classes/enums.dart';

class EstadoNotifier extends ChangeNotifier {
  double _nivel = 3;
  double get nivel => _nivel;
  Estado _estado = Estado.normal;
  Estado get estado => _estado;

  EstadoNotifier([double nivel]) {
    final int division = nivel?.round() ?? 3;

    switch(division) {
      case 1:
        _estado = Estado.muitoMal;
        break;
      case 2:
        _estado = Estado.mal;
        break;
      case 3:
        _estado = Estado.normal;
        break;
      case 4:
        _estado = Estado.bem;
        break;
      case 5:
        _estado = Estado.muitoBem;
        break;
      default:
        _estado = Estado.normal;
        break;
    }

    if (division > 0 && division <= 5) {
      _nivel = nivel;
    }
  }

  mudarNivel(double nivel) {
    if (nivel < 0 || nivel > 5) {
      return false;
    }

    int division = nivel.round();

    if (division == 1) {
      _estado = Estado.muitoMal;
    }

    if (division == 2) {
      _estado = Estado.mal;
    }

    if (division == 3) {
      _estado = Estado.normal;
    }

    if (division == 4) {
      _estado = Estado.bem;
    }

    if (division == 5) {
      _estado = Estado.muitoBem;
    }

    _nivel = nivel;

    notifyListeners();   
  }

  mudarEstado(Estado estado) {
    _estado = estado;
    notifyListeners();
  }
}