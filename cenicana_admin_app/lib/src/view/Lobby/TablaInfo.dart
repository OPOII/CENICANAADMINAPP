import 'package:cenicana_admin_app/src/view/Frames/LoadingIndicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class TablaInformacion extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot> snap;
  TablaInformacion(this.snap);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Tabla1(),
        SizedBox(
          height: 20,
        ),
        Container(
          width: 350,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder.all(width: 2, color: Colors.black),
            children: [
              TableRow(
                children: <Widget>[
                  TableCell(
                    child: Container(
                      color: Colors.yellow,
                      child: Center(
                        child: Text(
                          'Labores (Has)',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        Tabla2(snap: snap),
        SizedBox(
          height: 20,
        ),
        Container(
          width: 350,
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: percentIndicator(snap)),
        ),
      ],
    );
  }
}

class Tabla2 extends StatelessWidget {
  const Tabla2({
    Key key,
    @required this.snap,
  }) : super(key: key);

  final AsyncSnapshot<QuerySnapshot> snap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      child: Row(
        children: [
          Container(
            width: 155,
            child: Table(
              border: TableBorder.all(width: 2, color: Colors.black),
              children: [
                TableRow(
                  children: <Widget>[
                    TableCell(
                      child: Container(
                        color: Colors.blue,
                        child: Center(
                          child: Text('Programadas',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: <Widget>[
                    TableCell(
                      child: Center(
                        child: Text(snap.data.docs.length.toString(),
                            style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Container(
              width: 155,
              child: Table(
                border: TableBorder.all(width: 2, color: Colors.black),
                children: [
                  TableRow(
                    children: <Widget>[
                      TableCell(
                        child: Container(
                          color: Colors.green,
                          child: Center(
                            child: Text(
                              'Realizadas',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: <Widget>[
                      TableCell(
                        child: Center(
                          child: buildRealizadas(),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Text buildRealizadas() {
    int realizadas = 0;
    snap.data.docs.forEach(
      (element) {
        if (element.data()['pendiente'] == 0) {
          realizadas++;
        }
      },
    );
    return Text(
      realizadas.toString(),
      style: TextStyle(fontSize: 20),
    );
  }
}

class Tabla1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.all(width: 2, color: Colors.black),
        children: [
          TableRow(
            children: <Widget>[
              TableCell(
                child: Container(
                  color: Colors.yellow,
                  child: Center(
                    child: Text('Semana', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            ],
          ),
          TableRow(
            children: <Widget>[
              TableCell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text('Semana',
                        style:
                            TextStyle(color: Colors.yellow[700], fontSize: 20)),
                    Text(
                      'Calendario',
                      style: TextStyle(color: Colors.yellow[700], fontSize: 20),
                    )
                  ],
                ),
              )
            ],
          ),
          TableRow(
            children: <Widget>[
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      semana(),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: diaInicioDiaFin(),
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

Text semana() {
  int dayYear = int.parse(DateFormat("D").format(DateTime.now()));
  DateTime date = new DateTime.now();
  int semana = ((dayYear - date.weekday + 10) / 7).floor();
  initializeDateFormatting();
  return Text(
    semana.toString(),
    style: TextStyle(fontSize: 30),
  );
}

Column diaInicioDiaFin() {
  DateTime hoy = DateTime.now();
  DateTime viernes = DateTime.now();
  DateTime lunes = DateTime.now();
  if (hoy.weekday >= 1 && hoy.weekday <= 5) {
    while (lunes.weekday != 1) {
      lunes = lunes.subtract(Duration(days: 1));
    }
    while (viernes.weekday != 5) {
      viernes = viernes.add(Duration(days: 1));
    }
  } else {
    while (lunes.weekday != 1) {
      lunes = lunes.subtract(Duration(days: 1));
    }
    while (viernes.weekday != 5) {
      viernes = viernes.subtract(Duration(days: 1));
    }
  }
  String viernesEstatico = DateFormat('MMMMEEEEd').format(viernes);
  String lunesEstatico = DateFormat('MMMMEEEEd').format(lunes);
  return Column(
    children: [Text(lunesEstatico), Text('To'), Text(viernesEstatico)],
  );
}

Widget percentIndicator(AsyncSnapshot<QuerySnapshot> snap) {
  int terminadas = 0;
  snap.data.docs.forEach(
    (element) {
      if (element.data()['pendiente'] == 0.0) {
        terminadas++;
      }
    },
  );

  double porcentaje = terminadas / snap.data.docs.length;
  if (porcentaje.isNaN) {
    return Loading();
  } else {
    return LinearPercentIndicator(
      progressColor: progreso(porcentaje),
      animation: true,
      animationDuration: 3000,
      lineHeight: 20.0,
      percent: porcentaje / 100,
      backgroundColor: Colors.grey,
      animateFromLastPercent: true,
      center: Text(porcentaje.toStringAsFixed(1) + "%"),
    );
  }
}

Color progreso(double porcentaje) {
  Color devolver = Colors.white;
  if (porcentaje >= 0 && porcentaje < 30.0) {
    devolver = Colors.red[900];
  } else if (porcentaje >= 30 && porcentaje < 50.0) {
    devolver = Colors.red[100];
  } else if (porcentaje >= 50.0 && porcentaje < 75.0) {
    devolver = Colors.green[100];
  } else if (porcentaje >= 75.0 && porcentaje < 85.0) {
    devolver = Colors.red[200];
  } else if (porcentaje >= 85 && porcentaje < 99.9) {
    devolver = Colors.green[400];
  } else if (porcentaje == 100.0) {
    devolver = Colors.green[900];
  }
  return devolver;
}
