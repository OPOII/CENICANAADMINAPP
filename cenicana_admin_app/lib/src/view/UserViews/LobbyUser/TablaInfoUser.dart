import 'package:cenicana_admin_app/src/model/tarea.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Frames/LoadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

///Clase de las tablas iniciales donde aparecen información relevante para el mayordomo
class TablaInformacionUser extends StatelessWidget {
  ///Lista de las tareas
  final List<Tarea> snap;
  TablaInformacionUser(this.snap);

  ///Widget que construira la tabla
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

///Clase donde se construira la segunda tabla que es de las labores realizadas y las programadas para revisar cuantas hay y cuales se han realizado
class Tabla2 extends StatelessWidget {
  const Tabla2({
    Key key,
    @required this.snap,
  }) : super(key: key);

  ///Listado de las tareas
  final List<Tarea> snap;

  ///Widget que se encargara de construir esa tabla
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
                        child: Text(snap.length.toString(),
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

  ///Metodo que devolvera en texto las tareas realizadas
  Text buildRealizadas() {
    int realizadas = 0;
    for (var i = 0; i < snap.length; i++) {
      double n = double.tryParse(snap[i].pendiente);
      if (n == 0.0) {
        realizadas++;
      }
    }

    return Text(
      realizadas.toString(),
      style: TextStyle(fontSize: 20),
    );
  }
}

///Clase donde se construira la tabla 1, donde se mostraran la semana en la que estan y el dia lunes al viernes
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

///Metodo que devuelve el texto con la semana en la que se encuentran
Text semana() {
  int dayYear = int.parse(DateFormat("D").format(DateTime.now()));
  DateTime date = new DateTime.now();
  //Esta es la forma de calcular la semana en la que se encuentran
  int semana = ((dayYear - date.weekday + 10) / 7).floor();
  initializeDateFormatting();
  return Text(
    semana.toString(),
    style: TextStyle(fontSize: 30),
  );
}

///Metodo que calcula cual es el día inicio(lunes) y el día fin(viernes) de la semana, con su respectivo número
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

///Metodo que calcula cuantas tareas ha terminado
Widget percentIndicator(List<Tarea> snap) {
  int terminadas = 0;
  for (var i = 0; i < snap.length; i++) {
    double n = double.tryParse(snap[i].pendiente);
    if (n == 0.0) {
      terminadas++;
    }
  }
//metodo que calcula el procentaje que lleva el mayordomo de tareas realizada hasta ahora
  double porcentaje = (terminadas / snap.length) * 100;
  if (porcentaje.isNaN) {
    //En caso de que se demore la obtención de datos, entonces se procedera a realizar el widget de espera
    return Loading();
  } else {
    //cuando tengan los datos, se podra poner una barra de progreso
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

///Metodo que devuelve el tipo de color que tiene la barra de carga dependiendo del porcentaje en el que se encuentren
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
