import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TablaLobby extends StatefulWidget {
  final AsyncSnapshot<QuerySnapshot> snap;
  TablaLobby({this.snap});

  @override
  _TablaLobby createState() => _TablaLobby();
}

class _TablaLobby extends State<TablaLobby> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
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
            label: Text("Ejecutable"),
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
      ),
    );
  }

  Text buildText(QueryDocumentSnapshot epa) {
    double horasProgramadas =
        double.tryParse(epa['horas_programadas'].toString());
    double ejecutable = double.tryParse(epa['ejecutable'].toString());
    double respuesta = horasProgramadas - ejecutable;
    if (respuesta < 0) {
      return Text("");
    } else {
      return Text(respuesta.toStringAsFixed(2));
    }
  }
}
