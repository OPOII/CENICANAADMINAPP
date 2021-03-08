import 'package:cenicana_admin_app/src/model/DataBase/DatabaseAdmin.dart';
import 'package:cenicana_admin_app/src/model/tarea.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TablaLobbyUser extends StatefulWidget {
  final List<Tarea> snap;
  TablaLobbyUser({this.snap});

  @override
  _TablaLobby createState() => _TablaLobby();
}

/// Clase tabla donde se mostraran los datos que de la base de datos Firebase
class _TablaLobby extends State<TablaLobbyUser> {
  ///Controlador de las hectareas realziadas
  TextEditingController ejecutableController = new TextEditingController();

  ///id de la fila a actualizar
  int idActualizar = 0;

  ///Path de la coleccion de la base de datos de Firebase donde se actualizara
  String coleccionBasesDatos = 'PlanSemanal';
  @override
  void initState() {
    super.initState();
  }

  ///Widget que construira la tabla
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              allInfoTable(),
            ],
          ),
        ),
        //FlatButton(onPressed: () {}, child: Icon(Icons.add_circle))
      ],
    );
  }

  ///Tabla de las tareas
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
      rows: widget.snap
          .map(
            (epa) => DataRow(
              cells: [
                DataCell(
                  Center(child: Text(epa.id.toString())),
                ),
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
                DataCell(Center(child: Text(epa.ejecutable)), onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: Text(
                          'Inserte el número de hectareas realizadas hasta ahora, debe tener en cuenta las hectareas pasadas realizadas y sumarle las que acaba de realizar para poder poner las que lleva hasta ahora'),
                      children: <Widget>[
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: ejecutableController,
                          validator: (input) {
                            if (input.isEmpty) {
                              return 'Por favor no deje el campo vacio';
                            }
                            return null;
                          },
                        ),
                        Center(
                          child: FlatButton(
                            child: Text('Guardar'),
                            onPressed: () {
                              if (ejecutableController.text == "") {
                                return "No se puede ingresar un campo vacio";
                              } else {
                                double input =
                                    double.tryParse(ejecutableController.text);
                                double programada =
                                    double.tryParse(epa.programa);
                                if (input > programada) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => SimpleDialog(
                                      title: Text(
                                          'No se puede agregar mas hectareas de las que se les fue impuestas, revise que no haya cometido un error'),
                                      children: <Widget>[
                                        FlatButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Entendido'))
                                      ],
                                    ),
                                  );
                                } else {
                                  print('Entro al condicional sin problema');
                                  setState(
                                    () {
                                      updateRow(ejecutableController.text, epa);
                                      idActualizar = epa.id;
                                    },
                                  );
                                  //actualizar(epa, ejecutableController.text);
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                DataCell(
                  Center(child: buildText(epa)),
                ),
                DataCell(
                    Center(
                      child: Text(epa.observacion),
                    ),
                    onTap: () {}),
              ],
            ),
          )
          .toList(),
    );
  }

  ///Metodo que actualizara la tabla de SQFLite y la base de datos de firebase para tener ambas sincronizadas
  updateRow(String referencia, Tarea epa) async {
    epa.ejecutable = referencia;

    double respuesta =
        (double.tryParse(epa.programa) - double.tryParse(epa.ejecutable));

    String n = respuesta.toStringAsFixed(2);
    epa.pendiente = n;

    await DataBaseOffLine.instance.update({
      DataBaseOffLine.columnId: epa.id,
      DataBaseOffLine.columnejecutable: referencia,
      DataBaseOffLine.columnpendiente: epa.pendiente
    });
    DocumentReference ref = FirebaseFirestore.instance
        .collection('Ingenio')
        .doc('1')
        .collection('PlanSemanal')
        .doc(epa.id.toString());
    ref.update({'ejecutable': double.tryParse(epa.ejecutable)});
    ref.update({'pendiente': double.tryParse(epa.pendiente)});
    Navigator.pop(context);
  }
}

///Metodo que devolvera la diferencias de las hectareas programadas menos las hectareas realizadas
Text buildText(Tarea epa) {
  double hectareasProgramadas = double.tryParse(epa.programa.toString());
  double ejecutable = double.tryParse(epa.ejecutable);
  double respuesta = hectareasProgramadas - ejecutable;
  if (respuesta < 0) {
    return Text("");
  } else {
    epa.pendiente = respuesta.toStringAsFixed(2);
    return Text(respuesta.toStringAsFixed(2));
  }
}
