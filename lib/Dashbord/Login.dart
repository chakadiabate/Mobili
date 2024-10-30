import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_fin/Dashbord/NagivationDash.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool inLoginProcess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left side of the screen (can be an image or logo)
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/lo.png', width: 100,
                      height: 50,
                      alignment: Alignment.topLeft),
                  SizedBox(height: 20),
                  Image.asset('assets/mobil.png', width: 200),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Right side (Login Form)
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bienvenue Sur MOBILIKO',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(_emailController, 'Email', Icons.email),
                  SizedBox(height: 20),
                  _buildTextField(
                      _passwordController, 'Mot de passe', Icons.lock,
                      obscureText: true),
                  SizedBox(height: 20),

                  inLoginProcess
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: signIn,
                    child: Text(
                        'Se connecter', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
        obscureText: obscureText,
      ),
    );
  }

  Future<void> signIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez remplir tous les champs.')));
      return;
    }

    setState(() {
      inLoginProcess = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
      setState(() {
        inLoginProcess = false;
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => Sidebar()));
    } catch (e) {
      setState(() {
        inLoginProcess = false;
      });
      String errorMessage = _handleError(e);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)));
    }
  }



  String _handleError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'wrong-password':
          return 'Mot de passe incorrect.';
        case 'user-not-found':
          return 'Aucun utilisateur trouvé avec cet email.';
        default:
          return 'Erreur inconnue. Veuillez réessayer.';
      }
    } else if (e is Exception) {
      return 'Erreur : ${e.toString()}';
    } else {
      return 'Erreur inconnue. Veuillez réessayer.';
    }
  }
}
