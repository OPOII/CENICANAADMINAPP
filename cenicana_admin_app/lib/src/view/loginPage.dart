import 'dart:async';
import 'dart:io';
import 'package:cenicana_admin_app/src/model/Services/authenticationService.dart';
import 'package:cenicana_admin_app/src/model/Services/crud.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Frames/LoadingIndicator.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Frames/Separador.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Lobby/LobbyPrincipalAdmin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  StreamSubscription connectivityStream;
  ConnectivityResult oldres;
  bool dialogshown = false;
  CrudConsultas consultas = new CrudConsultas();
  List usuario = [];
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

  String email, password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthenticationService _authenticationService = AuthenticationService();
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 63,
            ),
            Container(
              child: Image.asset("assets/img/logo.png"),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Text(
                'Para Administradores',
                style: TextStyle(fontSize: 20),
              ),
            ),
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: buildColumn(),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: Color(0xFFF5F6F9),
              onPressed: () async {
                final formatState = _formKey.currentState;
                if (formatState.validate()) {
                  setState(() => loading = true);
                  formatState.save();
                  dynamic result = await _authenticationService
                      .signEmailPassword(email, password);
                  if (result == null) {
                    loading = true;
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Usuario no valido'),
                        content: Text(
                            'El usuario con el que esta intentando acceder no se encuentra en nuestra base de datos, por favor ingrese con un usuario valido'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    );
                  } else if (_authenticationService.currentUser != null) {
                    dynamic resultado = await consultas.obtenerUsuarioActual();
                    setState(() {
                      usuario = resultado;
                    });
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LobbyAdmin(
                                referencia: usuario,
                                crudConsultas: consultas)));
                    /* Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Separador(consul: consultas)));
                    */

                    /*Navigator.of(context).push(
                      MaterialPageRoute(
                        settings: RouteSettings(name: '/Lobby'),
                        builder: (context) => LobbyAdmin(
                          referencia: ref,
                          crudConsultas: consultas,
                        ),
                      ),
                    );
                      */
                  }
                }
              },
              child: Text('Login'),
            )
          ],
        ),
      ),
    );
  }

  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        TextFormField(
          validator: (input) {
            if (input.isEmpty) {
              return 'Por favor inserte un email';
            } else if (!input.contains("@")) {
              return 'Por favor, ingrese un correo';
            }
          },
          onSaved: (input) => email = input,
          decoration: InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(
          height: 30,
        ),
        TextFormField(
          validator: (input) {
            if (input.length < 6) {
              return 'You have to enter at least 6 characters';
            }
          },
          onSaved: (input) => password = input,
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
      ],
    );
  }
}
