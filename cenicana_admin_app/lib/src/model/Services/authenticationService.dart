import 'package:cenicana_admin_app/src/model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String usuarioUID;

  Usuario _userFromFirebaseUser(User fbUsuario) {
    return fbUsuario != null ? Usuario(id: fbUsuario.uid) : null;
  }

  Future signEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User usuario = result.user;
      return _userFromFirebaseUser(usuario);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  User get currentUser {
    return _auth.currentUser;
  }

  Stream<Usuario> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
    // .map((User user) => _userFromFirebaseUser(user));
  }

  Stream<User> get usuario {
    return _auth.authStateChanges();
  }

  String get uid {
    if (_auth.currentUser != null) {
      return _auth.currentUser.uid.toString();
    } else {
      return "vacio";
    }
  }

  void signOut() async {
    await _auth.signOut();
  }

  Future agregarUsuario(String contra, String email) async {
    String retorno = "";
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: contra)
          .then((value) {
        usuarioUID = value.user.uid;
        retorno = value.user.uid;
      });
      return retorno;
    } catch (e) {
      print(e.toString());
    }
  }
}
