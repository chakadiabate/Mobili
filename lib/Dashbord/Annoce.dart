import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projet_fin/Dashbord/Profil.dart';

class DashbordAnnonce extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => DashbordProfile(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Annonces',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('car_listings').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print('Erreur Firestore : ${snapshot.error}');
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }

                  final annonces = snapshot.data?.docs ?? [];

                  if (annonces.isEmpty) {
                    return Center(child: Text('Aucune annonce trouvée.'));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Numéro')),
                        DataColumn(label: Text('NOM DE LA VOITURE')),
                        DataColumn(label: Text('ID PROPRIETAIRE')),
                        DataColumn(label: Text('PRIX')),
                        DataColumn(label: Text('DATE DE POSTE')),
                        DataColumn(label: Text('TYPE')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: annonces.asMap().entries.map((entry) {
                        int index = entry.key; // Index pour le numéro
                        var doc = entry.value;
                        final annonceData = doc.data() as Map<String, dynamic>;

                        return DataRow(cells: [
                          DataCell(Text((index + 1).toString())), // Afficher le numéro séquentiel
                          DataCell(Text(annonceData['Nom'] ?? 'N/A')),
                          DataCell(Text((index + 3).toString() ?? 'N/A')),
                          DataCell(Text(annonceData['price'] ?? 'N/A')),
                          DataCell(Text(_formatTimestamp(annonceData['created_at']))),
                          DataCell(Container(
                            decoration: BoxDecoration(
                              color: annonceData['listing_type'] == 'Location'
                                  ? Colors.yellow.shade100
                                  : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: Text(
                              annonceData['listing_type'],
                              style: TextStyle(
                                color: annonceData['listing_type'] == 'Location'
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                          )),
                          DataCell(IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, doc.id),
                          )),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(timestamp.toDate());
  }

  void _confirmDelete(BuildContext context, String listingId) {
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
                _deleteListing(context, listingId); // Supprimer l'annonce
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _deleteListing(BuildContext context, String listingId) async {
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