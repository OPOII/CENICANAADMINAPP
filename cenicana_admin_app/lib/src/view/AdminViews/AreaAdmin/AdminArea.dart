import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'AgregarUsuarios.dart';

class AdminArea extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AreaAdmins();
}

class _AreaAdmins extends State<AdminArea> {
  ConnectivityResult oldres;
  StreamSubscription connectivityStream;
  bool dialogshown = false;

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

  @override
  void initState() {
    super.initState();
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
                  //Navigator.push(context,
                  //  MaterialPageRoute(builder: (context) => DatabaseInfo())),
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(
          "Area de administradores",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        child: Grids(),
      ),
    );
  }
}

class Grids extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GridsState();
}

class _GridsState extends State<Grids> {
  final grids = [
    {
      "titulo": "Agregar usuarios",
      "imagen": "assets/img/adduser.png",
    },
    {
      "titulo": "Agregar tareas",
      "imagen": "assets/img/addtask.png",
    },
    {
      "titulo": "Ver tareas",
      "imagen": "assets/img/viewtask.png",
    },
    {
      "titulo": "Ver usuarios",
      "imagen": "assets/img/viewuser.png",
    }
  ];
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: grids.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (BuildContext context, int index) {
          return Cards(
            name: grids[index]['titulo'],
            url: grids[index]['imagen'],
          );
        });
  }
}

class Cards extends StatelessWidget {
  final name;
  final url;
  Cards({this.name, this.url});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Hero(
          tag: name,
          child: Material(
            child: InkWell(
              onTap: () => {
                if (name == "Agregar usuarios")
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AgregarUsuarios()))
                  }
                /* else if (name == "Agregar tareas")
                  {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                TareaView(title: 'Agregar Tarea')))
                  }
                else if (name == "Ver usuarios")
                  {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Allusers()))
                  }
                else if (name == "Ver tareas")
                  {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AllTasks()))
                  }
                  */
              },
              child: GridTile(
                footer: Container(
                  color: Colors.black12,
                  child: ListTile(
                    leading: Text(
                      name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                ),
                child: Image.asset(
                  url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )),
    );
  }
}
