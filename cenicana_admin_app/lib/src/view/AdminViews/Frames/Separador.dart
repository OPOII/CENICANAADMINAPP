import 'package:cenicana_admin_app/src/model/Services/crud.dart';
import 'package:cenicana_admin_app/src/view/AdminViews/Frames/LoadingIndicator.dart';
import 'package:flutter/cupertino.dart';

class Separador extends StatefulWidget {
  final CrudConsultas consul;
  Separador({this.consul});
  @override
  _SeparadorState createState() => _SeparadorState();
}

class _SeparadorState extends State<Separador> {
  List usuario = [];

  @override
  void initState() {
    super.initState();
  }

  obtenerUsuario() async {
    dynamic resultado = await widget.consul.obtenerUsuarioActual();
    setState(() {
      usuario = resultado;
    });
    print(usuario.length.toString() + "En el separador");
  }

  @override
  Widget build(BuildContext context) {
    return Loading();
  }
}
