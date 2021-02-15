import 'package:cenicana_admin_app/src/model/Services/crud.dart';
import 'package:cenicana_admin_app/src/model/tarea.dart';
import 'package:cenicana_admin_app/src/view/Frames/LoadingIndicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TablaLobby extends StatefulWidget {
  final AsyncSnapshot<QuerySnapshot> snap;
  String modificacion;
  CrudConsultas traer;
  TablaLobby({this.snap, this.modificacion, this.traer});

  @override
  _TablaLobby createState() => _TablaLobby();
}

class _TablaLobby extends State<TablaLobby> {
  String resumen = "";
  bool color = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.modificacion == 'tiempoReal') {
      widget.traer.devolverResumen(widget.snap);
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                allInfoTable(),
                Text('Estas en la tabla: ' + widget.modificacion)
              ],
            ),
          ),
          //FlatButton(onPressed: () {}, child: Icon(Icons.add_circle))
        ],
      );
    } else if (widget.modificacion == 'resumen') {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: FutureBuilder<List<Tarea>>(
          future: widget.traer.devolverResumen(widget.snap),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Loading();
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                List<Tarea> data = snapshot.data;
                return Column(
                  children: [
                    resumeDataTable(data),
                    Text('Estas en la tabla: ' + widget.modificacion)
                  ],
                );
              } else if (!snapshot.hasData) {}
            }
          },
        ),
      );
    } else if (widget.modificacion == 'detalles') {
      print('Va a entrar');
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: FutureBuilder<List<Tarea>>(
          future: widget.traer.devolverDetalles(widget.snap, resumen),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Loading();
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                List<Tarea> data = snapshot.data;
                return Column(
                  children: <Widget>[
                    detailsTable(data),
                    Text('Estas en la tabla: ' + widget.modificacion),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          if (color == false) {
                            color = true;
                          } else if (color == true) {
                            color = false;
                          }
                        });
                      },
                      child: Text('Ver terminadas'),
                    )
                  ],
                );
              } else if (!snapshot.hasData) {}
            }
          },
        ),
      );
    }
  }

  DataTable allInfoTable() {
    return DataTable(
      columns: [
        DataColumn(
          label: Text("ID"),
          numeric: false,
          tooltip: "ID",
        ),
        DataColumn(
          label: Text("Hacineda"),
          numeric: false,
          tooltip: "Hacienda",
        ),
        DataColumn(
          label: Text("Suerte"),
          numeric: false,
          tooltip: "Suerte",
        ),
        DataColumn(
          label: Text("  Hectareas \nprogramadas"),
          numeric: false,
          tooltip: "programa",
        ),
        DataColumn(
          label: Text("Actividad"),
          numeric: false,
          tooltip: "Actividad",
        ),
        DataColumn(
          label: Text("Hectareas \nejecutadas"),
          numeric: false,
          tooltip: "Ejecutable",
        ),
        DataColumn(
          label: Text("Pendiente"),
          numeric: false,
          tooltip: "Pendiente",
        ),
        DataColumn(
          label: Text("Observacion"),
          numeric: false,
          tooltip: "Observacion",
        ),
      ],
      rows: widget.snap.data.docs
          .map(
            (epa) => DataRow(
              cells: [
                DataCell(
                  Center(child: Text(epa['id'].toString())),
                ),
                DataCell(
                  Center(child: Text(epa['hacienda'].toString())),
                ),
                DataCell(
                  Center(child: Text(epa['suerte'].toString())),
                ),
                DataCell(
                  Center(child: Text(epa['horas_programadas'].toString())),
                ),
                DataCell(
                  Center(child: Text(epa['actividad'].toString())),
                ),
                DataCell(
                  Center(child: Text(epa['ejecutable'].toString())),
                ),
                DataCell(
                  Center(child: Text(epa['pendiente'].toString())),
                ),
                DataCell(
                  Center(child: Text(epa['observacion'].toString())),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  DataTable resumeDataTable(List<Tarea> data) {
    return DataTable(
      columns: [
        DataColumn(
          label: Text("Actividad"),
          numeric: false,
          tooltip: "Actividad",
        ),
        DataColumn(
          label: Text("  Hectareas \nprogramadas"),
          numeric: false,
          tooltip: "programa",
        ),
        DataColumn(
          label: Text("Hectareas \nejecutadas"),
          numeric: false,
          tooltip: "Ejecutable",
        ),
        DataColumn(
          label: Text("Pendiente"),
          numeric: false,
          tooltip: "Pendiente",
        ),
        DataColumn(
          label: Text("Ver detalles"),
          numeric: false,
          tooltip: "Ver detalles",
        ),
      ],
      rows: data
          .map(
            (epa) => DataRow(
              cells: [
                DataCell(
                  Center(child: Text(epa.actividad)),
                ),
                DataCell(
                  Center(child: Text(epa.programa.toString())),
                ),
                DataCell(
                  Center(child: Text(epa.ejecutable)),
                ),
                DataCell(
                  Center(child: Text(epa.pendiente)),
                ),
                DataCell(
                    Center(
                      child: FlatButton(
                        onPressed: () {
                          setState(
                            () {
                              widget.modificacion = 'detalles';
                              resumen = epa.actividad;
                              print(resumen);
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[Icon(Icons.add_circle)],
                        ),
                      ),
                    ),
                    onTap: null),
              ],
            ),
          )
          .toList(),
    );
  }

  DataTable detailsTable(List<Tarea> snapshot) {
    return DataTable(
      columns: [
        DataColumn(
          label: Text("ID"),
          numeric: false,
          tooltip: "ID",
        ),
        DataColumn(
          label: Text("Hacineda"),
          numeric: false,
          tooltip: "Hacienda",
        ),
        DataColumn(
          label: Text("Suerte"),
          numeric: false,
          tooltip: "Suerte",
        ),
        DataColumn(
          label: Text("  Hectareas \nprogramadas"),
          numeric: false,
          tooltip: "programa",
        ),
        DataColumn(
          label: Text("Actividad"),
          numeric: false,
          tooltip: "Actividad",
        ),
        DataColumn(
          label: Text("Hectareas \nejecutadas"),
          numeric: false,
          tooltip: "Ejecutable",
        ),
        DataColumn(
          label: Text("Pendiente"),
          numeric: false,
          tooltip: "Pendiente",
        ),
        DataColumn(
          label: Text("Encargado"),
          numeric: false,
          tooltip: "Encargado",
        ),
      ],
      rows: snapshot
          .map(
            (epa) => DataRow(
              color: MaterialStateColor.resolveWith(
                (states) {
                  double pendiente = double.tryParse(epa.pendiente);
                  if (color == true) {
                    if (pendiente == 0) {
                      return Colors.green[200];
                    } else if (pendiente != 0) {
                      return Colors.red[100];
                    }
                  } else {
                    return Colors.white70;
                  }
                },
              ),
              cells: [
                DataCell(Center(
                  child: Text(epa.id.toString()),
                )),
                DataCell(
                  Center(child: Text(epa.hacienda)),
                ),
                DataCell(
                  Center(child: Text(epa.suerte)),
                ),
                DataCell(
                  Center(child: Text(epa.programa)),
                ),
                DataCell(
                  Center(child: Text(epa.actividad)),
                ),
                DataCell(
                  Center(child: Text(epa.ejecutable)),
                ),
                DataCell(Center(
                  child: Text(epa.pendiente),
                )),
                DataCell(
                  Center(
                    child: Text(epa.encargado),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
