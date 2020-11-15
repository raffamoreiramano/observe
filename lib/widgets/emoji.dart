import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:observe/classes/enums.dart';

class Emoji extends StatelessWidget {
  final Estado estado;
  final double size;
  final String _path = 'lib/assets/images/observe_emojis';
  String _image;

  Emoji({this.size, this.estado}) {
    switch (estado) {
      case Estado.muitoMal:
        _image = 'very_sick.svg';
        break;
      case Estado.mal:
        _image = 'sick.svg';
        break;
      case Estado.normal:
        _image = 'neutral.svg';
        break;
      case Estado.bem:
        _image = 'healthy.svg';
        break;
      case Estado.muitoBem:
        _image = 'very_healthy.svg';
        break;
      default:
        _image = 'neutral.svg';
        break;
    }
  }

  Emoji.verySick({this.size}) : estado = Estado.muitoMal;
  Emoji.sick({this.size}) : estado = Estado.mal;
  Emoji.neutral({this.size}) : estado = Estado.normal;
  Emoji.healthy({this.size}) : estado = Estado.bem;
  Emoji.veryHealthy({this.size}) : estado = Estado.muitoBem;


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      alignment: Alignment.center,      
      child: SvgPicture.asset(
        '$_path/$_image',
        height: size,
        width: size,
      ),
    );
  }
}