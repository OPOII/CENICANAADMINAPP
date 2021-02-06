import 'package:cenicana_admin_app/src/model/tarea.dart';
import 'package:cenicana_admin_app/src/view/AreaAdmin/AdminArea.dart';
import 'package:cenicana_admin_app/src/view/LoadingIndicator.dart';
import 'package:cenicana_admin_app/src/view/Lobby/CustomListTile.dart';
import 'package:cenicana_admin_app/src/view/Lobby/TablaInfo.dart';
import 'package:cenicana_admin_app/src/view/Lobby/tablaLobby.dart';
import 'package:cenicana_admin_app/src/view/loginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cenicana_admin_app/src/model/Services/crud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Lobby extends StatefulWidget {
  final DocumentReference referencia;
  final CrudConsultas crudConsultas;
  Lobby({this.referencia, this.crudConsultas});

  @override
  _LobbyState createState() => _LobbyState(referencia, crudConsultas);
}

class _LobbyState extends State<Lobby> {
  final DocumentReference ref;
  final CrudConsultas consul;
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
    if (hoy.weekday == 6) {
      print('Esta al 6');
      dynamic resultado = await consul.extraerycargarInformacion();
      setState(
        () {
          listado = resultado;
          terminado = false;
        },
      );
    } else if (hoy.weekday != 1 && snapshot.docs.length != 0) {
      print('Entro aqui');
      dynamic resultado = await consul.traerInsumoDeFirebase();
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
                    Container(child: TablaLobby(snap: snapshot))
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
        CustomListTile(
            Icons.assignment_ind,
            'Area admin',
            () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AdminArea()))
                }),
        CustomListTile(Icons.data_usage, 'Database Offline', () => {}),
        CustomListTile(
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
