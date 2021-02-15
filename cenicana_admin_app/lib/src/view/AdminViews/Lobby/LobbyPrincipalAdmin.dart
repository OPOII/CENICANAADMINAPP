import 'package:cenicana_admin_app/src/model/tarea.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/AreaAdmin/AdminArea.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Data/DataBaseView.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Frames/LoadingIndicator.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Lobby/CustomListTileAdmin.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Lobby/TablaInfoAdmin.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Lobby/TablaLobbyAdmin.dart';
import 'package:cenicana_admin_app/src/view/LoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cenicana_admin_app/src/model/Services/crud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LobbyAdmin extends StatefulWidget {
  final DocumentReference referencia;
  final CrudConsultas crudConsultas;
  LobbyAdmin({this.referencia, this.crudConsultas});

  @override
  _LobbyState createState() => _LobbyState(referencia, crudConsultas);
}

class _LobbyState extends State<LobbyAdmin> {
  final DocumentReference ref;
  final CrudConsultas consul;
  String cambiante = 'resumen';
  _LobbyState(this.ref, this.consul);
  List<Tarea> listado;
  bool terminado = true;
  @override
  void initState() {
    super.initState();
    elegirMostrar();
  }

  elegirMostrar() async {
    DateTime hoy = new DateTime.now();
    final snapshot = await FirebaseFirestore.instance
        .collection('Ingenio')
        .doc('1')
        .collection('PlanSemanal')
        .get();
    if (hoy.weekday == 1 && snapshot.docs.length == 0) {
      print('Esta al 6');
      dynamic resultado = await consul.extraerycargarInformacion();
      setState(
        () {
          listado = resultado;
          terminado = false;
        },
      );
    } else if (snapshot.docs.length != 0) {
      dynamic resultado = await consul.traerInsumoDeFirebase();
      setState(
        () {
          listado = resultado;
          terminado = false;
        },
      );
    } else if (snapshot.docs.length == 0) {
      dynamic resultado = await consul.extraerycargarInformacion();
      setState(
        () {
          listado = resultado;
          terminado = false;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    while (terminado) {
      return Loading();
    }
    if (listado.isEmpty) {
      return Scaffold(
        appBar: appBar(),
        drawer: Container(width: 200, child: menu(context)),
      );
    } else if (!listado.isEmpty) {
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
              drawer: Container(width: 200, child: menu(context)),
            );
          }
        },
      );
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

Drawer menu(context) {
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
                      backgroundImage: NetworkImage(
                          "https://www.decideo.com/photo/art/default/42090343-35199053.jpg?v=1579807427"),
                    ),
                  ],
                ),
              ),
              Text("Juanito",
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
