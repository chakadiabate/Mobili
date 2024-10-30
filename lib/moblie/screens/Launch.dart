import 'package:flutter/material.dart';
import 'package:projet_fin/Wrapper.dart';


class Launch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo du Parking
            SizedBox(height: 50),
            // Image de la voiture
            Image.asset(
              'assets/lo.png', // Assurez-vous d'ajouter votre image ici
              height: 50,
            ),
            SizedBox(height: 50),
            // Image de la voiture
            Image.asset(
              'assets/voiture.png', // Assurez-vous d'ajouter votre image ici
              height: 200,
            ),
            SizedBox(height: 20),
            // Texte de localisation
            Text(
              'Location dioro bana',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 40),
            // Bouton pour découvrir les voitures
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, 
                    MaterialPageRoute(builder: (context)=> Wrapper()));// Action pour découvrir les voitures
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Découvrez vos voitures',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}