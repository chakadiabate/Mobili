import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projet_fin/moblie/screens/FaireAchat.dart';

import 'FaireReservation.dart'; // Assurez-vous d'importer ce fichier

class DetailsVoiture extends StatelessWidget {
  final String nom;
  final String availability_date;
  final String price;
  final String description;
  final List<dynamic> imageUrls;
  final String email;
  final String listingId; // ID de l'annonce
  final String listing_type; // Ajoute le type d'annonce (Location ou Vente)

  const DetailsVoiture({
    Key? key,
    required this.nom,
    required this.availability_date,
    required this.price,
    required this.description,
    required this.imageUrls,
    required this.email,
    required this.listingId, // ID de l'annonce
    required this.listing_type, // Type de listing ajouté ici
  }) : super(key: key);

  // Fonction pour récupérer l'email du propriétaire depuis Firestore
  Future<String> getemail(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        return userDoc['email'] ?? 'Utilisateur inconnu';
      } else {
        return 'Utilisateur inconnu';
      }
    } catch (e) {
      return 'Erreur lors du chargement';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image de la voiture
              Image.network(
                imageUrls.isNotEmpty ? imageUrls[0] : 'https://via.placeholder.com/200',
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10),

              // Bouton "Réserver" ou "Acheter" en fonction du listing_type
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (listing_type == 'Location') {
                      // Action pour réserver
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservationScreen(
                            carName: nom,
                            listingId: listingId,
                            imageUrls: imageUrls,
                            price: price,
                            availability_date: availability_date,
                          ),
                        ),
                      );
                    } else if (listing_type == 'Vente') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AchatScreen(
                            carName: nom,
                            listingId: listingId,
                            imageUrls: imageUrls,
                            price: price,
                            availability_date: availability_date,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    listing_type == 'Location' ? 'Réserver' : 'Acheter', // Affiche le texte approprié
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Détails de la voiture
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        nom,
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined, color: Colors.grey),
                        SizedBox(width: 5),
                        Text(availability_date),
                        SizedBox(width: 20),
                        Icon(Icons.monetization_on_outlined, color: Colors.grey),
                        SizedBox(width: 5),
                        Text(price),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Informations sur le propriétaire
                    Row(
                      children: [
                        Icon(Icons.person_outline, color: Colors.grey),
                        SizedBox(width: 10),
                        Text('Propriétaire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Spacer(),
                        FutureBuilder<String>(
                          future: getemail(email),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Text('Chargement...');
                            } else if (snapshot.hasError) {
                              return Text('Erreur');
                            } else {
                              return Text(snapshot.data ?? 'Inconnu');
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(),

                    // Détails de la voiture
                    buildCarDetailField('Nom', nom),
                    buildCarDetailField('Description', description, isMultiLine: true),
                    buildCarDetailField('Prix', price),
                    buildCarDetailField('Date de disponibilité', availability_date),

                    SizedBox(height: 20),

                    // Autres images (galerie)
                    Text('Autres images', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: imageUrls.map((url) => buildGalleryImage(url)).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour les détails de la voiture
  Widget buildCarDetailField(String label, String value, {bool isMultiLine = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 5),
        TextFormField(
          initialValue: value,
          maxLines: isMultiLine ? null : 1,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  // Widget pour afficher les images dans la galerie
  Widget buildGalleryImage(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Image.network(
        imageUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
    );
  }
}
