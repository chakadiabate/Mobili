import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Inscription avec email et mot de passe
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Erreur lors de l\'inscription: ${e.toString()}');
      return null;
    }
  }

  // Connexion avec email et mot de passe
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Erreur lors de la connexion: ${e.toString()}');
      throw e; // Relancer l'erreur pour la gestion dans Login
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Erreur lors de la déconnexion: ${e.toString()}');
    }
  }

  // Récupération du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Erreur lors de la récupération du mot de passe: ${e.toString()}');
    }
  }

  // Obtenir l'utilisateur actuellement connecté
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // L'état de l'utilisateur en temps réel
  Stream<User?> get user => _auth.authStateChanges();
}
