import 'package:cenicana_admin_app/src/model/tarea.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/AreaAdmin/AdminArea.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Data/DataBaseView.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Frames/LoadingIndicator.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Lobby/CustomListTileAdmin.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Lobby/TablaInfoAdmin.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Lobby/TablaLobbyAdmin.dart';
import 'package:cenicana_admin_app/src/view/LoginPage.dart';
import 'package:cenicana_admin_app/src/view/UserViews/LobbyUser/TablaInfoUser.dart';
import 'package:cenicana_admin_app/src/view/UserViews/LobbyUser/TablaLobbyUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cenicana_admin_app/src/model/Services/crud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LobbyAdmin extends StatefulWidget {
  final List referencia;
  final CrudConsultas crudConsultas;
  LobbyAdmin({this.referencia, this.crudConsultas});

  @override
  _LobbyState createState() => _LobbyState(referencia, crudConsultas);
}

class _LobbyState extends State<LobbyAdmin> {
  final List usuarioActual;
  final CrudConsultas consul;
  String cambiante = 'resumen';
  String info = "";
  _LobbyState(this.usuarioActual, this.consul);
  List<Tarea> listado;
  bool terminado = true;
  @override
  void initState() {
    super.initState();
    elegirMostrar();
  }

  elegirMostrar() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Ingenio')
        .doc('1')
        .collection('PlanSemanal')
        .get();
    if (usuarioActual[0]['charge'] == 'admin') {
      DateTime hoy = new DateTime.now();
      if (hoy.weekday == 1 && snapshot.docs.length == 0) {
        dynamic resultado = await consul.extraerycargarInformacionAdmin();
        setState(
          () {
            listado = resultado;
            terminado = false;
          },
        );
      } else if (snapshot.docs.length != 0) {
        dynamic resultado = await consul.traerInsumoDeFirebaseAdmin();
        setState(
          () {
            listado = resultado;
            terminado = false;
          },
        );
      } else if (snapshot.docs.length == 0) {
        dynamic resultado = await consul.extraerycargarInformacionAdmin();
        setState(
          () {
            listado = resultado;
            terminado = false;
          },
        );
      }
    } else if (usuarioActual[0]['charge'] == 'user') {
      if (snapshot.docs.length == 0) {
        setState(
          () {
            info = 'excel';
            terminado = false;
          },
        );
      } else if (snapshot.docs.length != 0) {
        setState(
          () {
            info = 'firebase';
            terminado = false;
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    while (terminado) {
      return Loading();
    }

    if (usuarioActual[0]['charge'] == 'admin') {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Ingenio')
            .doc('1')
            .collection('PlanSemanal')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          } else {
            return Scaffold(
              appBar: appBar(),
              body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TablaInformacion(snapshot),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        FlatButton(
                          onPressed: () {
                            setState(
                              () {
                                cambiante = 'resumen';
                              },
                            );
                          },
                          child: Row(
                            children: <Widget>[
                              Text('Ver resumen'),
                            ],
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            setState(() {
                              cambiante = 'tiempoReal';
                            });
                          },
                          child: Row(
                            children: <Widget>[
                              Text('Ver todo'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: TablaLobby(
                        snap: snapshot,
                        modificacion: cambiante,
                        traer: consul,
                      ),
                    ),
                  ],
                ),
              ),
              drawer:
                  Container(width: 200, child: menu(context, usuarioActual)),
            );
          }
        },
      );
    } else if (usuarioActual[0]['charge'] == 'user') {
      if (info == 'excel') {
        print('Entro al excel');
        return FutureBuilder<List<Tarea>>(
          future: consul.obtenerListadoDelExcelUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Loading();
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Scaffold(
                appBar: appBar(),
                body: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        TablaInformacionUser(snapshot.data),
                        Container(
                          child: TablaLobbyUser(snap: snapshot.data),
                        )
                      ],
                    ),
                  ),
                ),
                drawer:
                    Container(width: 200, child: menu(context, usuarioActual)),
              );
            }
          },
        );
      } else if (info == 'firebase') {
        return FutureBuilder<List<Tarea>>(
          future: consul.obtenerListadoDeFirebaseUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Loading();
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Scaffold(
                appBar: appBar(),
                body: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        TablaInformacionUser(snapshot.data),
                        Container(
                          child: TablaLobbyUser(snap: snapshot.data),
                        ),
                        FlatButton(
                          onPressed: () {
                            setState(() {
                              info = 'recargar';
                            });
                          },
                          child: Text('Recargar'),
                        )
                      ],
                    ),
                  ),
                ),
                drawer:
                    Container(width: 200, child: menu(context, usuarioActual)),
              );
            }
          },
        );
      } else if (info == 'recarga') {
        Future<List<Tarea>> resultado = consul.obtenerListadoDeFirebaseUser();
        return FutureBuilder<List<Tarea>>(
          future: resultado,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Loading();
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Scaffold(
                appBar: appBar(),
                body: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        TablaInformacionUser(snapshot.data),
                        Container(
                          child: TablaLobbyUser(snap: snapshot.data),
                        ),
                        FlatButton(
                          onPressed: () {
                            setState(() {
                              info = 'firebase';
                            });
                          },
                          child: Text('Recargar'),
                        )
                      ],
                    ),
                  ),
                ),
                drawer: Container(
                    width: 200,
                    child: usuarioActual[0] != null
                        ? menu(context, usuarioActual)
                        : Loading()),
              );
            }
          },
        );
      }
    }
  }

  Widget appBar() {
    Icon usIcon = Icon(Icons.search);
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      centerTitle: true,
      title: Text(
        'Tus haciendas',
        style: TextStyle(color: Colors.white),
      ),
      actions: <Widget>[
        IconButton(
          tooltip: 'search',
          icon: usIcon,
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.grass),
          onPressed: () {},
        )
      ],
      backgroundColor: Colors.green,
      elevation: 0.0,
    );
  }
}

Drawer menu(context, List usuarioActual) {
  return Drawer(
    child: ListView(
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.green),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 115,
                width: 120,
                child: Stack(
                  fit: StackFit.expand,
                  overflow: Overflow.visible,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage:
                          NetworkImage(usuarioActual[0]['urlfoto']),
                    ),
                  ],
                ),
              ),
              Text(usuarioActual[0]['name'],
                  style: TextStyle(color: Colors.black, fontSize: 15.0)),
            ],
          ),
        ),
        CustomListTileAdmin(
            Icons.assignment_ind,
            'Area admin',
            () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AdminArea()))
                }),
        CustomListTileAdmin(
            Icons.data_usage,
            'Database Offline',
            () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DatabaseInfo()))
                }),
        CustomListTileAdmin(
          Icons.power_settings_new,
          'Sign out',
          () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => LoginPage()));
          },
        )
      ],
    ),
  );
}
