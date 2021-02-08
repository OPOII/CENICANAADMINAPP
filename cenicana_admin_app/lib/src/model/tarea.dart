class Tarea {
  // ignore: non_constant_identifier_names
  String hdaste;
  String area; //doublle
  String corte; //int
  String edad; //double
  String nombreActividad;
  String grupo;
  String distrito;
  String tipoCultivo;
  String nombreHacienda;
  String fecha; //DateTime
  String hacienda; //int
  String suerte;
  String programa; //double
  String actividad; //int
  String ejecutable; //double
  String pendiente; //double
  String observacion;
  String encargado;
  int id;
  Tarea({
    this.hdaste,
    this.area,
    this.corte,
    this.edad,
    this.nombreActividad,
    this.grupo,
    this.distrito,
    this.tipoCultivo,
    this.nombreHacienda,
    this.fecha,
    this.hacienda,
    this.suerte,
    this.programa,
    this.actividad,
    this.ejecutable,
    this.pendiente,
    this.observacion,
    this.encargado,
    this.id,
  });
  factory Tarea.fromJson(dynamic json) {
    return Tarea(
      hdaste: "${json['hdaste'].toString()}",
      area: "${json['area'].toString()}",
      corte: "${json['corte'].toString()}",
      edad: "${json['edad'].toString()}",
      nombreActividad: "${json['nombreActividad'].toString()}",
      grupo: "${json['grupo'].toString()}",
      distrito: "${json['distrito'].toString()}",
      tipoCultivo: "${json['tipoCultivo'].toString()}",
      nombreHacienda: "${json['nombreHacienda'].toString()}",
      fecha: "${json['fecha'].toString()}",
      hacienda: "${json['hacienda'].toString()}",
      suerte: "${json['suerte'].toString()}",
      programa: "${json['programa'].toString()}",
      actividad: "${json['actividad'].toString()}",
      ejecutable: "${json['ejecutable'].toString()}",
      pendiente: "${json['pendiente'].toString()}",
      observacion: "${json['observacion'].toString()}",
      encargado: "${json['encargado'].toString()}",
      id: "${json['id']}" as int,
    );
  }

  // Method to make GET parameters.
  Map toJson() => {
        'hdaste': hdaste,
        'area': area,
        'corte': corte,
        'edad': edad,
        'nombreActividad': nombreActividad,
        'grupo': grupo,
        'distrito': distrito,
        'tipoCultivo': tipoCultivo,
        'nombreHacienda': nombreHacienda,
        'fecha': fecha,
        'hacienda': hacienda,
        'suerte': suerte,
        'programa': programa,
        'actividad': actividad,
        'ejecutable': ejecutable,
        'pendiente': pendiente,
        'observacion': observacion,
        'encargado': encargado,
        'id': id,
      };
  Map<String, dynamic> toMap() {
    return {
      "hdaste": hdaste,
      "area": area,
      "corte": corte,
      "edad": edad,
      "nombreActividad": nombreActividad,
      "grupo": grupo,
      "distrito": distrito,
      "tipoCultivo": tipoCultivo,
      "nombreHacienda": nombreHacienda,
      "fecha": fecha,
      "hacienda": hacienda,
      "suerte": suerte,
      "programa": programa,
      "actividad": actividad,
      "ejecutable": ejecutable,
      "pendiente": pendiente,
      "observacion": observacion,
      "encargado": encargado,
      "id": id,
    };
  }

  Tarea.fromMap(Map<String, dynamic> map) {
    hdaste = map['hdaste'].toString();
    area = map['area'].toString(); //doublle
    corte = map['corte'].toString(); //int
    edad = map['edad'].toString(); //double
    nombreActividad = map['actividad'].toString();
    grupo = map['grupo'].toString();
    distrito = map['distrito'].toString();
    tipoCultivo = map['tipo_cultivo'].toString();
    nombreHacienda = map['nombre_hacienda'].toString();
    fecha = map['fecha'].toString(); //DateTime
    hacienda = map['hacienda'].toString(); //int
    suerte = map['suerte'].toString();
    programa = map['horas_programadas'].toString(); //double
    actividad = map['actividad'].toString(); //int
    ejecutable = map['ejecutable'].toString(); //double
    pendiente = map['pendiente'].toString(); //double
    observacion = map['observacion'].toString();
    encargado = map['encargado'].toString();
    id = map['id'];
  }
}
