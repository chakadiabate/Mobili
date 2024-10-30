import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Reservation extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Action pour revenir en arrière
          },
        ),
        title: Text(
          'Réservations',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ReservationCollection')
            .where('UserId', isEqualTo: _auth.currentUser?.uid)
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

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index].data() as Map<String, dynamic>;
              final reservationId = reservations[index].id;
              final carId = reservation['listingId']; // Assurez-vous que carId est défini dans la réservation

              String startDate = _formatTimestamp(reservation['startDate']);
              String endDate = _formatTimestamp(reservation['endDate']);

              dynamic imageUrls = reservation['imageUrls'];
              List<String> images = [];

              if (imageUrls is String) {
                images.add(imageUrls);
              } else if (imageUrls is List<dynamic>) {
                images = List<String>.from(imageUrls);
              }

              return _buildCarCard(
                context,
                reservationId, // Passer l'ID de la réservation
                carId, // Passer l'ID de la voiture
                reservation['UserId'] ?? 'ID PROPRIÉTAIRE',
                reservation['carName'] ?? 'Nom de la voiture',
                reservation['availability_date'] ?? 'Disponibilité',
                reservation['price'] ?? 'Prix',
                reservation['phone'] ?? 'PHONE',
                reservation['owner'] ?? 'Propriétaire',
                endDate,
                startDate,
                images,
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat('dd/MM/yyyy').format(timestamp.toDate());
  }

  Widget _buildCarCard(
      BuildContext context,
      String reservationId, // Ajouter l'ID de la réservation ici
      String carId, // Passer l'ID de la voiture
      String userId,
      String carName,
      String availability_date,
      String price,
      String phone,
      String owner,
      String endDate,
      String startDate,
      List<String> imageUrls) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrls.isNotEmpty
                  ? imageUrls[0]
                  : 'https://via.placeholder.com/200',
              fit: BoxFit.cover,
              height: 180,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      carName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _confirmDelete(context, reservationId, carId); // Appel de la fonction de suppression avec carId
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE9D7FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Supprimer',
                        style: TextStyle(color: Color(0xFF6A67CE)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.date_range, size: 18, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(availability_date, style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.money, size: 18, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(price, style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 18, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              'Propriétaires',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text('Abdoulaye Koita', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(startDate, style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(endDate, style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String reservationId, String carId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer cette réservation ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _deleteReservation(context, reservationId, carId); // Supprimer l'annonce
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _deleteReservation(BuildContext context, String reservationId, String carId) async {
    try {
      // Mettre à jour le champ 'available' dans la collection 'car_listings'
      await FirebaseFirestore.instance
          .collection('car_listings')
          .doc(carId)
          .update({'available': false});

      // Supprimer la réservation
      await FirebaseFirestore.instance
          .collection('ReservationCollection')
          .doc(reservationId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Réservation supprimée avec succès.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    }
  }
}
