import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      alignment: Alignment.center,      
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 125,
            height: 125,
            child: CircularProgressIndicator(
              strokeWidth: 1,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue[300]),
              backgroundColor: Colors.lightBlue[700],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              right: 7.5,
            ),
            child: FlutterLogo(
              size: 50,
            ),
          ),          
        ],
      ),
    );
  }
}