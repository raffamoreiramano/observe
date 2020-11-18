import 'package:flutter/material.dart';
import 'package:observe/classes/enums.dart';

class EstadoNotifier extends ChangeNotifier {
  double _nivel = 3;
  double get nivel => _nivel;
  Estado _estado = Estado.normal;
  Estado get estado => _estado;

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