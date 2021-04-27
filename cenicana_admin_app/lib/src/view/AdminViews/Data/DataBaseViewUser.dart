import 'dart:async';
import 'dart:io';

import 'package:cenicana_admin_app/src/model/DataBase/DatabaseAdmin.dart';
import 'package:cenicana_admin_app/src/model/Services/crud.dart';
import 'package:cenicana_admin_app/src/model/tarea.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Frames/LoadingIndicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class DatabaseInfoUser extends StatefulWidget {
  @override
  DatabaseView createState() => DatabaseView();
}

///Clase donde se va a visualizar la data de sqflite
class DatabaseView extends State<DatabaseInfoUser> {
  ///Constante del path de la base de datos de firebase
  static final coleccionBasesDatos = "PlanSemanal";

  ///Listaod de mapa donde contiene la información de las tareas
  List<Map<String, dynamic>> listado;

  ///Lista de las tareas
  List<Tarea> tarea;

  ///Controlador del input de donde se ponen las hectareas ejecutables
  TextEditingController ejecutableController = new TextEditingController();

  ///Stream que revisa la conectividad a internet
  StreamSubscription connectivityStream;

  ///Resultado anterior de la conectividad
  ConnectivityResult oldres;

  ///Instancia a la clase consultas
  CrudConsultas consultas = new CrudConsultas();

  ///boolean que me indica si se debe de mostrar el dialogo acerca de la perdida de conectividad
  bool dialogshown = false;

  ///Entero que representa la fila donde se debe de actualizar la celda del SQFLITE
  int idActualizar = 0;

  ///booleano que me indica si ya termino de procesar el estado inicial del widget
  bool termino = true;

  ///String que sera como se manejaran los estados
  String tipo = 'normal';

  ///Metodo que revisa si hay conección a internet
  // ignore: missing_return
  Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return Future.value(true);
      }
    } on SocketException catch (_) {
      return Future.value(false);
    }
  }

  ///Estado inicial que tomara el view al entrar en el, donde se revisara constantemente si hay conección a internet
  @override
  void initState() {
    super.initState();
    connectivityStream =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult resu) {
      if (resu == ConnectivityResult.none) {
        dialogshown = true;
      } else if (oldres == ConnectivityResult.none) {
        checkInternet().then((result) {
          if (result == true) {
            if (dialogshown == true) {
              dialogshown = false;
            }
          }
        });
      }
      oldres = resu;
    });
    convertir();
  }

  ///Estado que tomara el widget al salir de el
  @override
  void dispose() {
    super.dispose();
    connectivityStream.cancel();
  }

  ///Metodo que llama a la base de datos sqflite para recorrerla toda y traer un listado de las tareas
  convertir() async {
    dynamic resultado = await DataBaseOffLine.instance.queryAll();
    setState(() {
      tarea = resultado;
      termino = false;
    });
  }

  ///Widget que representa a la clase Database
  @override
  Widget build(BuildContext context) {
    //Mientras no haya terminado de procesar el estado, se mostrara la pantalla de carga
    while (termino) {
      return Loading();
    }
    //Como no hay una opción de poder actualizar o redibujar un widget sin usar un isolate, opte por hacer una especie de "cambio de estado" en el que
    //al saber que el isolate en el que corre el main principal siempre esta escuchando los cambios, se volvera a dibujar automaticamente en este if
    //donde se repintara la tabla para mostrar los cambios que sucedieron
    if (tipo == 'normal') {
      return buildScaffold(context);
    } else if (tipo == 'diferente') {
      return buildScaffold(context);
    }
  }

  ///Metodo que construye la tabla y la muestra en la vista
  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Base de datos offline"),
        centerTitle: true,
      ),
      //Para evitar que haya un overflow, lo primero que se debe de hacer es
      //atrapar todo el widget container para que scrollee hacia abajo como algo normal
      //Luego, en el container meto la tabla y de ahi atrapo el container con el scroll
      //para poder scrollear de manera vertical
      body: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                child: Column(
                  children: [
                    DataTable(
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
                      rows: tarea
                          .map(
                            (epa) => DataRow(
                              cells: [
                                DataCell(
                                  Text(epa.id.toString()),
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
                                DataCell(
                                  Center(child: Text(epa.ejecutable)),
                                  onTap: () {
                                    ///Al undir esta celda, se abrira un dialogo donde le preguntara cuantas hectareas realizo para que queden registradas
                                    showDialog(
                                      context: context,
                                      builder: (context) => SimpleDialog(
                                        title: Text(
                                            'Inserte el número de hectareas realizadas hasta ahora \n este numero debe de ser el acumulado de las hectareas realizadas \n puesto que se reemplazara el anterior con el numero actual, no se adicionara con las hectareas ralizadas hoy'),
                                        children: <Widget>[
                                          TextFormField(
                                            keyboardType: TextInputType.number,
                                            controller: ejecutableController,
                                            validator: (input) {
                                              ///Validar que el input a la tabla no tenga un vacio
                                              if (input.isEmpty) {
                                                return 'Por favor no deje el campo vacio';
                                              }
                                              return null;
                                            },
                                          ),
                                          Center(
                                            child: TextButton(
                                              child: Text('Guardar'),
                                              onPressed: () {
                                                if (ejecutableController.text ==
                                                    "") {
                                                  return "No se puede ingresar un campo vacio";
                                                } else {
                                                  setState(
                                                    () {
                                                      ///Invoca al metodo de actualizar la celda
                                                      updateRow(
                                                          ejecutableController
                                                              .text,
                                                          epa);
                                                      idActualizar = epa.id;
                                                    },
                                                  );
                                                  ejecutableController.text =
                                                      '';
                                                }
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                DataCell(
                                  Center(child: buildText(epa)),
                                ),
                                DataCell(
                                  Center(child: Text(epa.observacion)),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [buildFlatButton(), borrarTabla()],
            ),
          ],
        ),
      ),
    );
  }

  ///Boton que permite actualizar la tabla en la base de datos de firebase en caso de que tenga conectividad
  TextButton buildFlatButton() {
    if (dialogshown == false) {
      return TextButton(
        child: Text('Actualizar'),
        onPressed: () {
          //Llama al metodo que actualizara la tabla
          enviarYActualizarTabla();
        },
      );
    } else {
      //En caso de que no haya conectividad, no se podra pulsar el boton de actualizar
      return TextButton(child: Text('Actualizar'), onPressed: null);
    }
  }

  ///Metodo que permite al usuario borrar la tabla para poder guardar los nuevos datos del nuevo insumo de firebase o del excel
  TextButton borrarTabla() {
    DateTime viernes = new DateTime.now();
    if (viernes.weekday == 5 && dialogshown == false) {
      return TextButton(
        child: Text('Borrar Tabla'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => SimpleDialog(
              title: Text(
                  'Al borrar la tabla perdera todo lo que haya realizado sin actualizar, ¿Desea continuar? \n Si la borro por error, puede volver a recuperarla cuando haya internet al undirle recargar en la tabla principal'),
              children: <Widget>[
                /*TextFormField(
                  keyboardType: TextInputType.number,
                  controller: ejecutableController,
                  validator: (input) {
                    if (input.isEmpty) {
                      return 'Por favor no deje el campo vacio';
                    }
                    return null;
                  },
                ),
                */
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                        child: Text('SI'),
                        onPressed: () async {
                          await DataBaseOffLine.instance.clearTable();
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }),
                    TextButton(
                        child: Text('No'),
                        onPressed: () {
                          Navigator.pop(context);
                        })
                  ],
                ),
              ],
            ),
          );
        },
      );
    } else {
      return TextButton(child: Text('Borrar Tabla'), onPressed: null);
    }
  }

  ///Metodo que envia y actualiza las tablas, tando de SQFLITE como la de firebase
  enviarYActualizarTabla() async {
    for (var i = 0; i < tarea.length; i++) {
      DataBaseOffLine.instance.update({
        DataBaseOffLine.columnId: tarea[i].id,
        DataBaseOffLine.columnejecutable: tarea[i].ejecutable,
        DataBaseOffLine.columnpendiente: tarea[i].pendiente
      });
      DocumentReference ref = FirebaseFirestore.instance
          .collection('Ingenio')
          .doc('1')
          .collection(coleccionBasesDatos)
          .doc(tarea[i].id.toString());
      ref.update({'ejecutable': double.tryParse(tarea[i].ejecutable)});
      ref.update({'pendiente': double.tryParse(tarea[i].pendiente)});
    }
  }

  ///Metodo que actualiza una linea especifica de SQFLITE
  ///@param String referencia, se refiere al valor que se va a actualizar
  ///@Param Tarea tasks, se refiere a la tarea actual que se va a actualizar
  updateRow(String referencia, Tarea epa) {
    double respuesta =
        (double.tryParse(epa.programa) - double.tryParse(epa.ejecutable));

    String n = respuesta.toStringAsFixed(2);
    epa.pendiente = n;
    DataBaseOffLine.instance.update({
      DataBaseOffLine.columnId: epa.id,
      DataBaseOffLine.columnejecutable: referencia,
      DataBaseOffLine.columnpendiente: epa.pendiente
    });
    //Aqui se realiza el "cambio de estado" para que la tabla se re dibuje
    if (tipo == 'normal') {
      setState(
        () {
          convertir();
          tipo = 'diferente';
        },
      );
    } else if (tipo == 'diferente') {
      setState(
        () {
          convertir();
          tipo = 'normal';
        },
      );
    }
    Navigator.pop(context);
  }

  ///Metodo que muestra la diferencia entre las hectareas programadas y las ejecutadas
  Text buildText(Tarea epa) {
    double ejecutable = double.tryParse(epa.ejecutable);
    double programadas = double.tryParse(epa.programa);
    double respuesta = programadas - ejecutable;
    respuesta.toStringAsFixed(2);
    if (respuesta < 0) {
      return Text("");
    } else {
      epa.pendiente = respuesta.toStringAsFixed(2);

      return Text(respuesta.toStringAsFixed(2));
    }
  }
}
