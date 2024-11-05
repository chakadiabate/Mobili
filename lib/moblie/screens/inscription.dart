import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'accueil_screen.dart';
 // Assurez-vous que le chemin est correct

class Inscription extends StatefulWidget {
  @override
  _InscriptionState createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String motDePasse = '';
  bool accepterTermes = false;
  bool motDePasseVisible = false;
  bool estEnChargement = false;

  // Fonction de connexion
  void seConnecter() async {
    if (_formKey.currentState!.validate() && accepterTermes) {
      setState(() {
        estEnChargement = true;
      });

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: motDePasse,
        );
        print('Connexion réussie : ${userCredential.user!.email}');
        // Navigation vers l'écran d'accueil après une connexion réussie
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Accueil()),
        );
      } on FirebaseAuthException catch (e) {
        print('Erreur de connexion : $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion : ${e.message}')),
        );
      } finally {
        setState(() {
          estEnChargement = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.20,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/lo.png'),
                  )
                ),
              ),
              Text(
                'Bienvenue.',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text(
                'Connectez-vous',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                obscureText: !motDePasseVisible,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      motDePasseVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        motDePasseVisible = !motDePasseVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    motDePasse = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: accepterTermes,
                    onChanged: (value) {
                      setState(() {
                        accepterTermes = value!;
                      });
                    },
                  ),
                  Text("J'accepte les termes et conditions"),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: estEnChargement ? null : seConnecter,
                child: estEnChargement
                    ? CircularProgressIndicator(
                  color: Colors.white,
                )
                    : Text('Se connecter'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 16),
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Vous n'avez pas de compte ? "),
                  GestureDetector(
                    onTap: () {
                      // Naviguer vers l'écran d'inscription (remplacer AccueilScreen si nécessaire)
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Accueil()),
                      );
                    },

                    child: Text(
                      "S'inscrire",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
