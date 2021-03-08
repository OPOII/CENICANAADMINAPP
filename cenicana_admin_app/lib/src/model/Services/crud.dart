import 'package:cenicana_admin_app/src/model/DataBase/DatabaseAdmin.dart';
import 'package:cenicana_admin_app/src/model/Services/authenticationService.dart';
import 'package:cenicana_admin_app/src/model/tarea.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/async.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class CrudConsultas {
  AuthenticationService service = new AuthenticationService();
  String planSemanal = 'PlanSemanal';
  Future obtenerUsuarioActual() async {
    List usuario = [];
    String idUser = service.currentUser.uid;
    await FirebaseFirestore.instance
        .collection('Ingenio')
        .doc('1')
        .collection('users')
        .get()
        .then(
      (value) {
        value.docs.forEach(
          (element) {
            if (element.id == idUser) {
              usuario.add(element);
            }
          },
        );
      },
    );
    return usuario;
  }

  Future<List<Tarea>> extraerycargarInformacionAdmin() async {
    List<Tarea> listados = List<Tarea>();
    var raw = await http.get(
        "https://script.google.com/macros/s/AKfycbxNlThMqfNAlppcG_MgWzqlKGTsLGiZeTb1LveQzTHTKSEh9EM/exec");
    var jsonFeedback = convert.jsonDecode(raw.body);
    jsonFeedback.forEach(
      (element) async {
        Tarea actual = new Tarea();
        actual.hdaste = element['hdaste'].toString();
        actual.area = element['area'].toString();
        actual.corte = element['corte'].toString();
        actual.edad = element['edad'].toString();
        actual.nombreActividad = element['nombre_actividad'].toString();
        actual.grupo = element['grupo'].toString();
        actual.distrito = element['distrito'].toString();
        actual.tipoCultivo = element['tipo_cultivo'].toString();
        actual.nombreHacienda = element['nombre_hacienda'].toString();
        actual.fecha = element['fecha'].toString();
        actual.hacienda = element['hacienda'].toString();
        actual.suerte = element['suerte'].toString();
        actual.programa = element['horas_programadas'].toString();
        actual.actividad = element['actividad'].toString();
        actual.ejecutable = element['ejecutable'].toString();
        double pendiente = double.tryParse(element['pendiente'].toString());
        String redondear = pendiente.toStringAsFixed(2);
        double fin = double.tryParse(redondear);
        actual.pendiente = fin.toString();
        actual.observacion = element['observacion'].toString();
        actual.encargado = element['encargado'].toString();
        actual.id = element['id'];
        listados.add(actual);
        await FirebaseFirestore.instance
            .collection('Ingenio')
            .doc('1')
            .collection('PlanSemanal')
            .doc(element['id'].toString())
            .set(element);
        await FirebaseFirestore.instance
            .collection('Ingenio')
            .doc('1')
            .collection('PlanSemanal')
            .doc(element['id'].toString())
            .update({'pendiente': fin});
      },
    );
    await DataBaseOffLine.instance.clearTable();
    await DataBaseOffLine.instance.llenarTabla(listados);
    return Future.value(listados);
  }

  Future<List<Tarea>> traerInsumoDeFirebaseAdmin() async {
    List<Tarea> listado = List<Tarea>();
    await FirebaseFirestore.instance
        .collection('Ingenio')
        .doc('1')
        .collection('PlanSemanal')
        .get()
        .then(
      (value) {
        value.docs.forEach(
          (element) {
            Tarea actual = new Tarea();
            actual.hdaste = element['hdaste'].toString();
            actual.area = element['area'].toString();
            actual.corte = element['corte'].toString();
            actual.edad = element['edad'].toString();
            actual.nombreActividad = element['nombre_actividad'].toString();
            actual.grupo = element['grupo'].toString();
            actual.distrito = element['distrito'].toString();
            actual.tipoCultivo = element['tipo_cultivo'].toString();
            actual.nombreHacienda = element['nombre_hacienda'].toString();
            actual.fecha = element['fecha'].toString();
            actual.hacienda = element['hacienda'].toString();
            actual.suerte = element['suerte'].toString();
            actual.programa = element['horas_programadas'].toString();
            actual.actividad = element['actividad'].toString();
            actual.ejecutable = element['ejecutable'].toString();
            actual.pendiente = element['pendiente'].toString();
            actual.observacion = element['observacion'].toString();
            actual.encargado = element['encargado'].toString();
            actual.id = element['id'];
            listado.add(actual);
          },
        );
      },
    );
    await DataBaseOffLine.instance.clearTable();
    await DataBaseOffLine.instance.llenarTabla(listado);
    return Future.value(listado);
  }

  ///Metodo que me devuelve el resumen de las actividades que se planearon
  Future<List<Tarea>> devolverResumenAdmin(
      AsyncSnapshot<QuerySnapshot> snap) async {
    List<String> mirar = [];
    List<Tarea> actuales = [];
    //Hago un primer barrido mirando cuales son las actividades que hay y las guardo en una lista de string
    snap.data.docs.forEach(
      (element) {
        if (!mirar.contains(element['actividad'].toString())) {
          mirar.add(element['actividad'].toString());
          Tarea n = Tarea.fromMap(element.data());
          actuales.add(n);
        }
      },
    );
    //Luego hago una doble pasara preguntando si la actividad actual coincide con la que guarde y asi se va actualizando en el indice para mostrar todo
    snap.data.docs.forEach(
      (element) {
        for (var i = 0; i < actuales.length; i++) {
          if (element.data()['actividad'].toString() == actuales[i].actividad) {
            if (element.data()['id'].toString() != actuales[i].id.toString()) {
              actuales[i].suerte += "," + element['suerte'].toString() + "\n";

              actuales[i].encargado +=
                  "," + element['encargado'].toString() + "\n";
              actuales[i].programa = (double.tryParse(actuales[i].programa) +
                      double.tryParse(element['horas_programadas'].toString()))
                  .toStringAsFixed(2);
              actuales[i].ejecutable =
                  (double.tryParse(actuales[i].ejecutable) +
                          double.tryParse(element['ejecutable'].toString()))
                      .toStringAsFixed(2);
              actuales[i].pendiente = (double.tryParse(actuales[i].programa) -
                      double.tryParse(actuales[i].ejecutable))
                  .toStringAsFixed(2);
            }
          }
        }
      },
    );
    actulizarsqflite();
    return actuales;
  }

  actulizarsqflite() async {
    String id = service.currentUser.uid;
    List<Tarea> listado = [];
    DocumentSnapshot referencia = await FirebaseFirestore.instance
        .collection('Ingenio')
        .doc('1')
        .collection('users')
        .doc(id)
        .get();
    await FirebaseFirestore.instance
        .collection('Ingenio')
        .doc('1')
        .collection(planSemanal)
        .get()
        .then(
      (value) {
        value.docs.forEach(
          (element) {
            Tarea n = Tarea.fromMap(element.data());
            listado.add(n);
          },
        );
      },
    );
    await DataBaseOffLine.instance.clearTable();
    await DataBaseOffLine.instance.llenarTabla(listado);
  }

  Future<List<Tarea>> devolverDetallesAdmin(
      AsyncSnapshot<QuerySnapshot> snap, String hacienda) async {
    List<Tarea> actuales = [];
    snap.data.docs.forEach(
      (element) {
        if (element['actividad'].toString() == hacienda) {
          Tarea n = Tarea.fromMap(element.data());
          actuales.add(n);
        }
      },
    );
    return actuales;
  }

  ///-----------------------------------------------------------------------------------------------------------///
  ///Consultas de los usuarios

  ///Metodo que me trae el listado de las tareas de firebase
  Future<List<Tarea>> obtenerListadoDeFirebaseUser() async {
    await DataBaseOffLine.instance.clearTable();
    String id = service.currentUser.uid;
    List<Tarea> listado = [];
    DocumentSnapshot referencia = await FirebaseFirestore.instance
        .collection('Ingenio')
        .doc('1')
        .collection('users')
        .doc(id)
        .get();
    await FirebaseFirestore.instance
        .collection('Ingenio')
        .doc('1')
        .collection(planSemanal)
        .get()
        .then(
      (value) {
        value.docs.forEach(
          (element) {
            if (referencia.data()['codigo_hacienda'] ==
                    element.data()['hacienda'].toString() &&
                referencia.data()['identificacion'].toString() ==
                    element.data()['encargado'].toString()) {
              Tarea n = Tarea.fromMap(element.data());
              listado.add(n);
            }
          },
        );
      },
    );
    //Si la base de datos sqflite esta en cero, significa que no ha sido creada, entonces se llena la tabla con el listado de firebase
    int n = await DataBaseOffLine.instance.verificarSiEstaVacia() as int;
    if (n == 0) {
      await DataBaseOffLine.instance.llenarTabla(listado);
    } else {
      //await DatabaseOffLine
      //await DataBaseOffLine.instance.llenarTabla(listado);
    }
    return Future.value(listado);
  }

  /// En caso de que los jefes de zona no hayan iniciado la aplicación para que se suba el excel a firebase, entonces se extraen los datos del insumo
  Future<List<Tarea>> obtenerListadoDelExcelUser() async {
    String id = service.currentUser.uid;
    DocumentSnapshot referencia = await FirebaseFirestore.instance
        .collection('Ingenio')
        .doc('1')
        .collection('users')
        .doc(id)
        .get();
    List<Tarea> listados = List<Tarea>();
    var raw = await http.get(
        "https://script.google.com/macros/s/AKfycbxNlThMqfNAlppcG_MgWzqlKGTsLGiZeTb1LveQzTHTKSEh9EM/exec");
    var jsonFeedback = convert.jsonDecode(raw.body);
    // ignore: unnecessary_statements
    jsonFeedback.forEach(
      (element) async {
        if (referencia.data()['hacienda'].toString() ==
                element['hacienda'].toString() &&
            referencia.data()['identificacion'].toString() ==
                element['encargado'].toString()) {
          Tarea actual = Tarea.fromMap(element.data());
          listados.add(actual);
        }
      },
    );
    int n = await DataBaseOffLine.instance.verificarSiEstaVacia() as int;
    if (n == 0) {
      await DataBaseOffLine.instance.llenarTabla(listados);
    } else {
      //await DatabaseOffLine
      //await DataBaseOffLine.instance.llenarTabla(listado);
    }
    return Future.value(listados);
  }
}
