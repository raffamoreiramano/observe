import 'package:flutter/material.dart';

class ObserveColor extends Color {
  int _color;

  ObserveColor(this._color) : super(_color);

  operator [](int opacity) {
    return (opacity >= 0 && opacity <= 100) ? Color(_color).withOpacity(opacity / 100) : Color(_color);
  }
}


class ObserveColors {
  static ObserveColor get rose => ObserveColor(0xFFFF91AA);
  static ObserveColor get red => ObserveColor(0xFFC70039);
  static ObserveColor get aqua => ObserveColor(0xFF32AFC8);
  static ObserveColor get orange => ObserveColor(0xFFFF4B32);
  static ObserveColor get blue => ObserveColor(0xFF01579B);
  static ObserveColor get dark => ObserveColor(0xFF14192D);
}