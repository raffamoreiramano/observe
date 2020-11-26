import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:observe/classes/colors.dart';
import 'package:observe/models/remedio.dart';
import 'package:observe/widgets/input_decoration.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class RemedioController extends StatefulWidget {
  final Remedio remedio;
  final Function adicionar;
  final Function atualizar;


  RemedioController(
    this.remedio,
    {
      this.adicionar,
      this.atualizar,
    }
  );

  @override
  _RemedioControllerState createState() => _RemedioControllerState(
    remedio,
    adicionar,
    atualizar,
  );
}

class _RemedioControllerState extends State<RemedioController> {
  final Function adicionar;
  final Function atualizar;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _remedioCTRL = TextEditingController();
  final TextEditingController _quantiaCTRL = TextEditingController();
  final TextEditingController _horarioCTRL = TextEditingController();
  String _medida = 'unidade';

  final MaskTextInputFormatter _horarioFormatter = MaskTextInputFormatter(
    mask: '##:##',
    filter: { "#": RegExp(r'[0-9]') },
    initialText: '00:00'
  );
  
  Remedio remedio;
  bool expanded = false;
  bool _gravado = false;

  _RemedioControllerState(
    this.remedio,
    this.adicionar,
    this.atualizar,
  );

  @override
  void initState() {
    super.initState();

    if (remedio.isNotEmpty) {
      _remedioCTRL.text = remedio.nome;
      _medida = remedio.medida; 
      _quantiaCTRL.text = remedio.quantia.toString();
      _horarioCTRL.text = '${remedio.horario.hour}:${remedio.horario.minute}';
    }
  }

  gravar() {
    initializeDateFormatting('pt_BR', null);
    final DateFormat _format = DateFormat('HH:mm');
    final _dateTime = _format.parse(_horarioCTRL.text);
    final _timeOfDay = TimeOfDay.fromDateTime(_dateTime);

    remedio.nome = _remedioCTRL.text;
    remedio.medida = _medida;
    remedio.quantia = double.parse(_quantiaCTRL.text);
    remedio.horario = _timeOfDay;

    _gravado ? atualizar.call(remedio) : adicionar.call(remedio);

    setState(() {
      _gravado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200],
              offset: Offset(0, 0.5),
              blurRadius: 0.5,
              spreadRadius: 0.5,
            )
          ],
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 20),
          childrenPadding: EdgeInsets.symmetric(horizontal: 20),
          trailing: Container(
            width: 30,
            height: 80,
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Icon(
                expanded 
                  ? Icons.remove
                  : Icons.add,
              ),
            ),
          ),
          onExpansionChanged: (_expanded) {
            setState(() {
              expanded = _expanded;
            });
          },
          title: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: TextFormField(
              controller: _remedioCTRL,
              textCapitalization: TextCapitalization.words,
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
              validator: (value) {
                bool isValid = RegExp(
                  r"^([0-9A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ.-]+)( {1,1}[0-9A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ.-]+)*$"
                ).hasMatch(value);

                if (isValid) {
                  return null;
                } else {
                  return "Nome inválido!";
                }
              },
              style: TextStyle(
                fontSize: 18,
              ),
              decoration: standardFormInput(label: expanded ? 'REMÉDIO' : 'ADICIONAR REMÉDIO'),
            ),
          ),
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: TextFormField(
                controller: _quantiaCTRL,
                textCapitalization: TextCapitalization.words,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  bool isValid = RegExp(
                    r"^[1-9]+[0-9]*$|^0{1}\.[0-9]*$|^[1-9]+[0-9]*\.[0-9]*$"
                  ).hasMatch(value);

                  return isValid ? null : 'Quantia inválida!';
                },
                style: TextStyle(
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  suffixIcon: RawMaterialButton(
                    onPressed: () {
                      setState(() {
                        if (_medida == 'unidade') {
                          _medida = 'ml';
                        } else {
                          _medida = 'unidade';
                        }
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      height: 62,
                      child: Text(
                        _medida == 'unidade' 
                          ? _medida + 's'
                          : _medida
                      ),
                      decoration: BoxDecoration(
                        color: ObserveColors.dark[5],
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5)
                        )
                      ),
                    ),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'QUANTIA',
                  filled: true,
                  fillColor: ObserveColors.dark[5],
                  labelStyle: TextStyle(
                    color: ObserveColors.dark[50],
                    fontSize: 18,
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: ObserveColors.aqua[50]
                    ),
                  ),
                  disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: ObserveColors.dark[25],
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Colors.lightBlue,
                    ),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: ObserveColors.red,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: TextFormField(
                controller: _horarioCTRL,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters: [_horarioFormatter],
                keyboardType: TextInputType.number,
                validator: (value) {
                  bool isValid = RegExp(
                    r"^([0-1][0-9]|20|21|22|23):([0-5][0-9])$"
                  ).hasMatch(value);

                  if (isValid) {
                    return null;
                  } else {
                    return "Horário inválido!";
                  }
                },
                style: TextStyle(
                  fontSize: 18,
                ),
                decoration: standardFormInput(label: 'HORÁRIO'),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30, bottom: 40),
              child: FlatButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    gravar();
                  }
                },
                height: 50,
                splashColor: ObserveColors.green,
                highlightColor: Colors.white54,
                color: _gravado ? ObserveColors.aqua[50] : ObserveColors.green[50],
                child: Text(
                  _gravado ? 'ATUALIZAR' : 'ADICIONAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
              ),
            )
          ]
        ),
      ),
    );
  }
}