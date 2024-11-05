import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projet_fin/service/Ajout_annonce.dart';

import 'accueil_screen.dart';


class AnnonceDashboard extends StatefulWidget {
  @override
  _AnnonceDashboardState createState() => _AnnonceDashboardState();
}

class _AnnonceDashboardState extends State<AnnonceDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser; // Get the currently logged-in user
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileAndButton(context),
            SizedBox(height: 20),
            _buildOverviewSection(),
            SizedBox(height: 20),
            Expanded(child: _buildCarListings()),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text('Annoncer'),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    );
  }

  Row _buildProfileAndButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            ),
            icon: Icon(Icons.add, color: Colors.white),
            label: Text('Créer une annonce'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6A67CE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 40),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('car_listings')
          .where('user_id', isEqualTo: user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Aucune annonce trouvée.'));
        }

        List<QueryDocumentSnapshot> userCarListings = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aperçu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildOverviewCard('Total Annonces', userCarListings.length.toString()),
                _buildOverviewCard('Nombre de clic', '11'),
              ],
            ),
          ],
        );
      },
    );
  }

  StreamBuilder<QuerySnapshot> _buildCarListings() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('car_listings')
          .where('user_id', isEqualTo: user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Aucune annonce trouvée.'));
        }

        List<QueryDocumentSnapshot> userCarListings = snapshot.data!.docs;

        return ListView.separated(
          itemCount: userCarListings.length,
          itemBuilder: (context, index) {
            var voiture = userCarListings[index];
            return _buildCarCard(
              nom: voiture['Nom'] ?? 'Nom inconnu',
              imageUrl: (voiture['image_urls'] is List && voiture['image_urls'].isNotEmpty)
                  ? voiture['image_urls'][0]
                  : 'URL de l\'image indisponible',
              availability_date: voiture['availability_date']?.toString() ?? 'Date inconnue',
              price: voiture['price']?.toString() ?? 'Prix inconnu',
              transmission: voiture['transmission'] ?? 'Transmission inconnue',
              listingId: voiture.id, // Passer l'ID de l'annonce
            );
          },
          separatorBuilder: (context, index) => Divider(),
        );
      },
    );
  }

  Widget _buildOverviewCard(String nom, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(nom, style: TextStyle(color: Colors.grey, fontSize: 14)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCarCard({
    required String nom,
    required String imageUrl,
    required String availability_date,
    required String price,
    required String transmission,
    required String listingId, // Ajouter cet argument
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: Image.network(
          imageUrl,
          width: 100,
          fit: BoxFit.cover,
        ),
        title: Text(nom, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(availability_date),
            Row(
              children: [
                Text(price),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                transmission,
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDelete(listingId), // Appel de la fonction de confirmation
        ),
      ),
    );
  }

  void _confirmDelete(String listingId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer cette annonce ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _deleteListing(listingId); // Supprimer l'annonce
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _deleteListing(String listingId) async {
    try {
      await _firestore.collection('car_listings').doc(listingId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Annonce supprimée avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: ${e.toString()}')),
      );
    }
  }
}
