import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:projet_fin/moblie/screens/Navigation.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool inLoginProcess = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                // Logo centered at the top
                Center(
                  child: Image.asset(
                    'assets/lo.png', // Your logo image
                    height: 100, // Adjust as needed
                  ),
                ),
                SizedBox(height: 40),
                // "Bienvenue" and "Connectez-vous" Texts
                Text(
                  'Bienvenue.',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Connectez vous',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 30),
                // Email input field
                _buildTextField(_emailController, 'Email', Icons.email),
                SizedBox(height: 20),
                // Password input field
                _buildTextField(_passwordController, 'Mot de passe', Icons.lock, obscureText: true),
                SizedBox(height: 20),
                // "Terms and Conditions" Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                    ),
                    Text('J\'accepte les termes et conditions'),
                  ],
                ),
                SizedBox(height: 20),
                // "Se connecter" Button
                inLoginProcess
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                  width: double.infinity, // Full-width button
                  child: ElevatedButton(
                    onPressed: _acceptTerms ? signIn : null, // Only enable if terms are accepted
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.blue, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0), // Rounded button
                      ),
                    ),
                    child: Text(
                      'se connecter',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // "S'inscrire" Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => Register())); // Navigate to Register screen
                    },
                    child: Text(
                      'Vous n\'avez pas un compte ? S\'inscrire',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Text field builder with input decoration and icons
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded input fields
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0), // Padding inside the fields
      ),
    );
  }

  // Sign-in method (remains unchanged)
  Future<void> signIn() async {
    setState(() {
      inLoginProcess = true;
    });

    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      setState(() {
        inLoginProcess = false;
      });
      // Navigate to another page or show success message
    } catch (e) {
      setState(() {
        inLoginProcess = false;
      });
      String errorMessage = _handleError(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  String _handleError(e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'wrong-password':
          return 'Mot de passe incorrect.';
        case 'user-not-found':
          return 'Aucun utilisateur trouvé avec cet email.';
        default:
          return 'Erreur inconnue. Veuillez réessayer.';
      }
    } else {
      return 'Erreur : ${e.toString()}';
    }
  }
}

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  String nom = '';
  String email = '';
  String password = '';
  String phoneNumber = '';
  XFile? profileImage;
  XFile? idImage;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inscription'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.30,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/lo.png'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              _buildTextField('Nom', (value) => nom = value),
              SizedBox(height: 16),

              // Champ Téléphone (acceptant uniquement des entiers)
              _buildTextField(
                'Téléphone',
                    (value) => phoneNumber = value,
                inputType: TextInputType.number,  // Spécifie un clavier numérique
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],  // Accepte uniquement les chiffres
              ),

              SizedBox(height: 16),
              _buildTextField('Email', (value) => email = value),
              SizedBox(height: 16),
              _buildTextField('Mot de passe', (value) => password = value, obscureText: true),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => _pickImage(true),
                    child: Text('Choisir Image de Profil'),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickImage(false),
                    child: Text('Choisir ID'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signup,
                child: Text('S\'inscrire'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 16),
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour créer un champ de texte réutilisable
  Widget _buildTextField(String label, Function(String) onChanged, {bool obscureText = false, TextInputType inputType = TextInputType.text, List<TextInputFormatter>? inputFormatters}) {
    return TextField(
      onChanged: onChanged,
      keyboardType: inputType,  // Définit le type de clavier
      inputFormatters: inputFormatters,  // Définit les formateurs pour filtrer les entrées
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      obscureText: obscureText,  // Définit si le texte doit être caché (mot de passe)
    );
  }

  Future<void> _pickImage(bool isProfile) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          profileImage = pickedFile;
        } else {
          idImage = pickedFile;
        }
      });
    }
  }

  Future<void> _signup() async {
    try {
      // Création de l'utilisateur avec Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid; // UID unique de l'utilisateur

      // Téléchargement des images
      String profileImageUrl = await _uploadImage(profileImage!, 'profile_images/$uid');
      String idImageUrl = await _uploadImage(idImage!, 'id_images/$uid');

      // Enregistrement des informations dans Firestore avec l'UID
      await _firestore.collection('users').doc(uid).set({
        'uid': uid, // Ajout de l'UID de l'utilisateur
        'nom': nom,
        'email': email,
        'phone_number': phoneNumber,
        'profile_image': profileImageUrl,
        'id_image': idImageUrl,
        'create_at': FieldValue.serverTimestamp(),
      });

      // Affichage d'un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur enregistré avec succès !')),
      );

      // Attendre un court instant pour que le message soit visible
      await Future.delayed(Duration(seconds: 2));

      // Navigation vers la page de navigation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Navigation()),  // Remplacez `Navigation` par votre page de navigation
      );
    } catch (e) {
      // Affichage d'un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  Future<String> _uploadImage(XFile image, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(File(image.path));
    return await ref.getDownloadURL();
  }
}

