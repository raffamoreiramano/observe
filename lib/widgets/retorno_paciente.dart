import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/classes/enums.dart';
import 'package:observe/models/estado_do_paciente.dart';
import 'package:provider/provider.dart';
import 'emoji.dart';

class BotaoRetorno extends StatelessWidget {
  final Function(double estado) callback;
  final double nivel;
 
  BotaoRetorno({this.nivel, this.callback});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: 90,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: Colors.lightBlue[300],
          width: 2,
        )
      ),
      child: RawMaterialButton(
        onPressed: () {
          Get.dialog(
            ChangeNotifierProvider<EstadoNotifier>(
              create: (context) => EstadoNotifier(nivel),
              child: ModalRetorno(
                nivel: nivel,
                callback: callback,
              ),
            )
          ).then((value) => context.read<EstadoNotifier>().mudarNivel(value));
        },
        shape: CircleBorder(),
        highlightColor: ObserveColors.aqua[30],
        splashColor: ObserveColors.aqua[30],
        child: Container(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Emoji(size: 70, estado: context.watch<EstadoNotifier>().estado),
        ),
      ),
    );
  }
}

class ModalRetorno extends StatefulWidget {
  final double nivel;
  final Function(double) callback;

  ModalRetorno({this.nivel, this.callback});

  @override
  _ModalRetornoState createState() => _ModalRetornoState(nivel, callback);
}

class _ModalRetornoState extends State<ModalRetorno> {
  double _nivel;
  Estado _estado;
  final Function _callback;


  _ModalRetornoState(this._nivel, this._callback);
  
  @override
  Widget build(BuildContext context) {
    _estado = context.watch<EstadoNotifier>().estado;
    _nivel = context.watch<EstadoNotifier>().nivel;

    return AlertDialog(
      title: Text('Como se sente hoje?'),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Emoji(size: 70, estado: _estado),
            Slider(
              min: 1,
              max: 5,
              value: _nivel,
              onChanged: (nivel) {
                context.read<EstadoNotifier>().mudarNivel(nivel);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(result: _nivel);
          },
          child: Text(
            'CANCELAR',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            _callback.call(_nivel);
            Get.back(result: _nivel);
          },
          child: Text(
            'CONFIRMAR',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}