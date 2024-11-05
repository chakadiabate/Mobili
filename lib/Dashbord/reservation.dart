import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashbordReservation extends StatelessWidget {
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
            onPressed: () {
              // Naviguer vers le profil
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Réservations',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ReservationCollection')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }

                  final reservations = snapshot.data?.docs ?? [];

                  if (reservations.isEmpty) {
                    return Center(child: Text('Aucune réservation trouvée.'));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Nom du Voiture')),
                        DataColumn(label: Text('ID Propriétaire')),
                        DataColumn(label: Text('Téléphone')),
                        DataColumn(label: Text('Date de Début')),
                        DataColumn(label: Text('Date de Fin')),
                        DataColumn(label: Text('Confirmation')),
                      ],
                      rows: reservations.asMap().entries.map((entry) {
                        int index = entry.key;
                        var doc = entry.value;
                        final reservation = doc.data() as Map<String, dynamic>;

                        return DataRow(
                          cells: [
                            DataCell(Text((index + 1).toString())),
                            DataCell(Text(reservation['carName'] ?? 'N/A')),
                            DataCell(Text((index + 2).toString())),
                            //DataCell(Text(reservation['UserId'] ?? 'N/A')), // ID de l'utilisateur
                            DataCell(Text(reservation['phone'] ?? 'N/A')),
                            DataCell(Text(_formatTimestamp(reservation['startDate']))),
                            DataCell(Text(_formatTimestamp(reservation['endDate']))),
                            DataCell(
                              ElevatedButton(
                                onPressed: () async {
                                  await _confirmReservation(
                                      context, reservation['UserId'], doc.id, reservation['carName']);
                                },
                                child: Text('Confirmer'),
                              ),
                            ),
                          ],
                        );
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

  // Fonction pour confirmer la réservation et envoyer une notification
  Future<void> _confirmReservation(
      BuildContext context, String UserId, String reservationId, String carName) async {
    try {
      // Mettre à jour l'état de la réservation dans Firestore
      await FirebaseFirestore.instance
          .collection('ReservationCollection')
          .doc(reservationId)
          .update({'status': 'confirmed'});

      // Envoyer une notification à l'utilisateur concerné
      await FirebaseFirestore.instance.collection('Notifications').add({
        'UserId': UserId,
        'carName': carName,
        'message': 'Votre réservation du ${carName} a été confirmée.',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Réservation confirmée et notification envoyée à l'utilisateur $UserId.")),
      );
    } catch (e) {
      // Afficher un message d'erreur si l'opération échoue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la confirmation: $e")),
      );
      print("Erreur lors de la confirmation: $e");
    }
  }
}
