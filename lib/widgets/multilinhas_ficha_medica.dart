import 'package:flutter/material.dart';

class MultiLinhasFicha extends StatelessWidget {
  final String label;
  final List<String> linhas;

  MultiLinhasFicha({this.label, this.linhas});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.grey[300],
          )
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w200,
            ),
          ),
          linhas?.isEmpty ?? true
            ? Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                ' . . .',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w200,
                ),
              ),
            )
            : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 5),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: linhas.length,
              itemBuilder: (context, index) {
                final String texto = linhas[index];
                return Text.rich(
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                    ),
                    children: [
                      TextSpan(
                        text: ' $texto',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ]
                  ),
                );
              },        
            ),
        ],
      ),
    );
  }
}