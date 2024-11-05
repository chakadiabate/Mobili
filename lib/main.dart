import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Pour kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projet_fin/Dashbord/Login.dart';
import 'package:projet_fin/Dashbord/NagivationDash.dart';
import 'package:provider/provider.dart';
import 'package:projet_fin/service/authentification.dart'; // Service d'authentification
import 'moblie/screens/Launch.dart'; // Page de réservation

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // Initialisation Firebase pour Web
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: "AIzaSyAfiascNILBlkXUHMizDh-EIzylf1IC3Kc",
          authDomain: "projetfin-7981d.firebaseapp.com",
          projectId: "projetfin-7981d",
          storageBucket: "projetfin-7981d.appspot.com",
          messagingSenderId: "852392045117",
          appId: "1:852392045117:android:06d28a74a527c5c38a5854",
        ),
      );
    } else {
      // Initialisation Firebase pour Mobile
      await Firebase.initializeApp();
    }
  } catch (e) {
    print('Erreur lors de l\'initialisation de Firebase: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        StreamProvider.value(
          initialData: null,
          value: AuthService().user, // Écoute l'état de l'utilisateur connecté
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MOBILIKO',
      routes: {
        '/LoginPage': (context) => LoginPage(), // Déclarez la route pour LoginPage
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber, // Couleur principale
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme), // Google Fonts
      ),
      home: LoginPage(), // Vérification de l'état d'authentification pour la navigation
    );
  }
}
