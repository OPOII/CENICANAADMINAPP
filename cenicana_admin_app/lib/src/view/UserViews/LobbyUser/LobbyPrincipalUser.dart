import 'dart:async';
import 'dart:io';

import 'package:cenicana_admin_app/src/model/Services/crud.dart';
import 'package:cenicana_admin_app/src/model/tarea.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Data/DataBaseView.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Frames/LoadingIndicator.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Lobby/CustomListTileAdmin.dart';
import 'package:cenicana_admin_app/src/view/LoginPage.dart';
import 'package:cenicana_admin_app/src/view/UserViews/LobbyUser/TablaInfoUser.dart';
import 'package:cenicana_admin_app/src/view/UserViews/LobbyUser/TablaLobbyUser.dart';
import 'package:cenicana_admin_app/src/view/UserViews/LobbyUser/UserInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Lobby extends StatefulWidget {
  final List referencia;
  final CrudConsultas crudConsultas;
  Lobby({this.referencia, this.crudConsultas});

  @override
  _LobbyState createState() => _LobbyState(crudConsultas);
}

/// Lobby princiapl de la aplicación
class _LobbyState extends State<Lobby> {
  ///Stream que verificara la conectividad a internet
  StreamSubscription connectivityStream;

  ///Resultado de la conectividad
  ConnectivityResult oldres;

  ///boolean que me indica si se debe de mostrar el dialogo acerca de la perdida de conectividad
  bool dialogshown = false;

  ///Referencia del documento de firebase donde esta almacenada la información del usuario que se loguea
  List usuario = [];

  ///Instancia de las consultas para no tener que estar inicializando nuevamente esta parte
  final CrudConsultas consul;

  ///Manejador del estado de la tabla
  String cambiante = 'resumen';

  ///Cosntructor de la clase
  _LobbyState(this.consul);

  ///Manejador del estado que decidira si se obtiene la información del insumo del excel o de la base de datos en caso de que ya hayan datos ahí
  String info = "";

  ///boolean que indica si ya termino de procesar el estado inicial del widget
  bool terminado = true;

  ///Metodo que revisa si hay conección a internet
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
    obtenerUsuario();
    elegirMostrar();
    connectivityStream =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult resu) {
      if (resu == ConnectivityResult.none) {
        dialogshown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          child: AlertDialog(
            title: Text('Error'),
            content: Text('No Data Connection Available'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DatabaseInfo())),
                  //SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                },
                child: Text('Ir al modo OffLine'),
              )
            ],
          ),
        );
      } else if (oldres == ConnectivityResult.none) {
        checkInternet().then((result) {
          if (result == true) {
            if (dialogshown == true) {
              dialogshown = false;
              Navigator.pop(context);
            }
          }
        });
      }
      oldres = resu;
    });
  }

  ///Estado que tomara el widget al salir de el
  @override
  void dispose() {
    super.dispose();
    connectivityStream.cancel();
  }

  ///Metodo que revisa cual de los dos insumos usara para la obtención de los datos
  elegirMostrar() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Ingenio')
        .doc('1')
        .collection('PlanSemanal')
        .get();
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

  obtenerUsuario() async {
    dynamic resultado = await consul.obtenerUsuarioActual();
    setState(() {
      usuario = resultado;
    });
  }

  ///Widget que se encargara de la construcción del lobby princial
  @override
  Widget build(BuildContext context) {
    while (terminado) {
      return Loading();
    }

    //En caso de que no hayan datos en la base de datos, entonces pondra el listado de excel
    if (info == 'excel') {
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
                  Container(width: 200, child: menu(context, consul, usuario)),
            );
          }
        },
      );
    }
    //En caso de que ya hayan datos en firebase, entocnes se usaran los datos de firebase
    else if (info == 'firebase') {
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
                  Container(width: 200, child: menu(context, consul, usuario)),
            );
          }
        },
      );
    }

    //Tercer estado para poder ver los cambios realizados en la base de datos
    else if (info == 'recargar') {
      print('Entro');
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
                  child: usuario[0] != null
                      ? menu(context, consul, usuario)
                      : Loading()),
            );
          }
        },
      );
    }
  }

  ///Widget que construye la appbar
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

///Widget que construye el menu deslizante
Drawer menu(context, CrudConsultas consul, List usuario) {
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
                      backgroundImage: NetworkImage(usuario[0]['urlfoto']),
                    ),
                  ],
                ),
              ),
              Text(usuario[0]['name'],
                  style: TextStyle(color: Colors.black, fontSize: 15.0)),
            ],
          ),
        ),
        CustomListTileAdmin(
          Icons.data_usage,
          'Database Offline',
          () => {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DatabaseInfo()))
          },
        ),
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
        ),
        CustomListTileAdmin(
          Icons.settings,
          'Información',
          () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserView(consul: usuario),
              ),
            ),
          },
        ),
      ],
    ),
  );
}
