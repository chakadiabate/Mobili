import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:projet_fin/Dashbord/Profil.dart'; // Pour formater les dates

class Utilisateur extends StatefulWidget {
  @override
  _UtilisateurState createState() => _UtilisateurState();
}

class _UtilisateurState extends State<Utilisateur> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
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
              'Utilisateur',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Rechercher par nom ou email',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print('Erreur Firestore : ${snapshot.error}');
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }

                  final users = snapshot.data?.docs ?? [];
                  final filteredUsers = users.where((doc) {
                    final utilisateur = doc.data() as Map<String, dynamic>;
                    final name = utilisateur['nom']?.toLowerCase() ?? '';
                    final email = utilisateur['email']?.toLowerCase() ?? '';
                    return name.contains(_searchQuery) || email.contains(_searchQuery);
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return Center(child: Text('Aucun utilisateur trouvé.'));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Numéro')),
                        DataColumn(label: Text('Nom de l\'UTILISATEUR')),
                        DataColumn(label: Text('EMAIL UTILISATEUR')),
                        DataColumn(label: Text('TELEPHONE')),
                        DataColumn(label: Text('Date D\'INSCRIPTION')),
                      ],
                      rows: filteredUsers.asMap().entries.map((entry) {
                        int index = entry.key; // Index pour le numéro
                        var doc = entry.value;
                        final utilisateur = doc.data() as Map<String, dynamic>;

                        return DataRow(
                          cells: [
                            DataCell(Text((index + 1).toString())), // Afficher le numéro (1, 2, 3, ...)
                            DataCell(Text(utilisateur['nom'] ?? 'N/A')),
                            DataCell(Text(utilisateur['email'] ?? 'N/A')),
                            DataCell(Text(utilisateur['phone_number'] ?? 'N/A')),
                            DataCell(Text(_formatTimestamp(utilisateur['create_at']))),
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
}