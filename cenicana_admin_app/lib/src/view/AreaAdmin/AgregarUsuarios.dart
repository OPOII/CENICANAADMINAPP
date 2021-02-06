import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cenicana_admin_app/src/model/Services/authenticationService.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class AgregarUsuarios extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UsersState();
}

class _UsersState extends State<AgregarUsuarios> {
  ConnectivityResult oldres;
  StreamSubscription connectivityStream;
  bool dialogshown = false;
  final formKey = GlobalKey<FormState>();
  //final _scaffoldKey = GlobalKey<ScaffoldState>();
  AuthenticationService service = new AuthenticationService();
  String name,
      telephone,
      email,
      cargo,
      hacienda,
      url,
      codigoHacienda,
      identificacion;
  String uid;
  DateTime fecha;
  final nameController = TextEditingController();
  final telephoneController = TextEditingController();
  final emailController = TextEditingController();
  final cargoController = TextEditingController();
  final birthdayController = TextEditingController();
  final cedulaController = TextEditingController();
  final haciendaController = TextEditingController();
  final identificacionController = TextEditingController();
  final format = DateFormat("dd-MM-yyyy");
  List _charges = ["", "admin", "user"];
  String _currentCharge;
  List<DropdownMenuItem<String>> _dropDownMenuItems;
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
    _dropDownMenuItems = getDropDownMenuItems();
    _currentCharge = _dropDownMenuItems[0].value;
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
                  // Navigator.push(context,
                  //   MaterialPageRoute(builder: (context) => DatabaseInfo())),
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

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String cargos in _charges) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(new DropdownMenuItem(value: cargos, child: new Text(cargos)));
    }
    return items;
  }

  @override
  void dispose() {
    super.dispose();
    connectivityStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          backgroundColor: Colors.green,
          centerTitle: true,
          title: Text('Agregar Usuarios',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: buildPadding());
  }

  Padding buildPadding() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
              onSaved: (value) {
                name = value;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return "Este campo no debe de estar vacio";
                }
                return null;
              },
            ),
            TextFormField(
              controller: cedulaController,
              decoration: InputDecoration(labelText: 'Cedula'),
              keyboardType: TextInputType.number,
              onSaved: (value) {
                name = value;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return "Este campo no debe de estar vacio";
                } else if (int.tryParse(value.toString()) == null) {
                  return "Este campo solo admite numeros";
                }
                return null;
              },
            ),
            TextFormField(
              controller: telephoneController,
              decoration: InputDecoration(labelText: 'Telefono'),
              keyboardType: TextInputType.phone,
              onSaved: (value) {
                telephone = value;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return "Este campo no debe de estar vacio";
                }
                return null;
              },
            ),
            TextFormField(
              controller: haciendaController,
              decoration: InputDecoration(labelText: 'Codigo Hacienda'),
              onSaved: (value) {
                codigoHacienda = value;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return "Este campo no debe de estar vacio";
                }
                return null;
              },
            ),
            TextFormField(
              controller: identificacionController,
              decoration: InputDecoration(labelText: 'Identificación'),
              onSaved: (value) {
                identificacion = value;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return "Este campo no debe de estar vacio";
                }
                return null;
              },
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              onSaved: (value) {
                email = value;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return "Este campo no debe de estar vacio";
                } else if (!(value.contains("@"))) {
                  return "Debes de agregar un correo electronico";
                }
                return null;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Cargo:", style: TextStyle(fontSize: 20)),
                DropdownButton(
                  value: _currentCharge,
                  items: _dropDownMenuItems,
                  onChanged: changedDropDownItems,
                ),
              ],
            ),
            DateTimeField(
              controller: birthdayController,
              decoration: InputDecoration(labelText: 'Fecha Nacimiento'),
              format: format,
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                    context: context,
                    initialDate: currentValue ?? DateTime.now(),
                    firstDate: DateTime(1920),
                    lastDate: DateTime(2030));
              },
              onSaved: (value) {
                fecha = value;
              },
              validator: (value) {
                if (value.toString().isEmpty) {
                  return "Debes de elegir una fecha de nacimiento";
                }
                return null;
              },
            ),
            RaisedButton(
              child: Text('Add new User'),
              onPressed: () {
                if (formKey.currentState.validate()) {
                  addNewUser(cedulaController.text, emailController.text);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void clearData() {
    nameController.text = "";
    telephoneController.text = "";
    emailController.text = "";
    cargoController.text = "";
    birthdayController.text = "";
    cedulaController.text = "";
    _currentCharge = "";
    haciendaController.text = "";
    identificacionController.text = "";
  }

  void saveAndSendData(String tokenUsuario) async {
    Map<String, dynamic> infoUsuario = new Map<String, dynamic>();
    infoUsuario['birthday'] = birthdayController.text;
    infoUsuario['charge'] = _currentCharge;
    infoUsuario['email'] = emailController.text;
    infoUsuario['name'] = nameController.text;
    infoUsuario['telephone'] = telephoneController.text;
    infoUsuario['haciendasResponsables'] = new List<String>();
    infoUsuario['codigo_hacienda'] = haciendaController.text;
    infoUsuario['identificacion'] = identificacionController.text;
    infoUsuario['cedula'] = cedulaController.text;
    infoUsuario['urlfoto'] =
        "https://image.freepik.com/vector-gratis/perfil-empresario-dibujos-animados_18591-58479.jpg";
    infoUsuario['id_user'] = tokenUsuario;
    print(infoUsuario);
    await FirebaseFirestore.instance
        .collection('Ingenio')
        .doc('1')
        .collection('users')
        .doc(tokenUsuario)
        .set(infoUsuario);
  }

  void addNewUser(String contra, String email) async {
    String resulta = "";
    // ignore: await_only_futures
    dynamic resultado = await service.agregarUsuario(contra, email);
    setState(() {
      resulta = resultado;
      saveAndSendData(resulta);
    });
  }

  void changedDropDownItems(String charge) {
    setState(() {
      _currentCharge = charge;
    });
  }
}
