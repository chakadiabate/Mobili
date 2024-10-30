import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Pour Firestore
import 'package:projet_fin/Dashbord/Annoce.dart';
import 'package:projet_fin/Dashbord/Profil.dart';
import 'package:projet_fin/Dashbord/reservation.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DashbordProfile()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Utilisation de StreamBuilder pour le nombre d'utilisateurs
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return StatCard(
                        title: 'Nombre d\'utilisateur',
                        value: 'Chargement...', // Indicateur de chargement
                        icon: Icons.person,
                        color: Colors.cyan.shade100,
                      );
                    }
                    if (snapshot.hasError) {
                      return StatCard(
                        title: 'Nombre d\'utilisateur',
                        value: 'Erreur',
                        icon: Icons.error,
                        color: Colors.red.shade100,
                      );
                    }

                    // Récupérer le nombre d'utilisateurs
                    final int utilisateurCount = snapshot.data?.docs.length ?? 0;

                    return StatCard(
                      title: 'Nombre d\'utilisateur',
                      value: utilisateurCount.toString(),
                      icon: Icons.person,
                      color: Colors.cyan.shade100,
                    );
                  },
                ),

                // StreamBuilder pour les réservations
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('ReservationCollection').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return StatCard(
                        title: 'Réservation',
                        value: 'Chargement...', // Indicateur de chargement
                        icon: Icons.insert_drive_file,
                        color: Colors.purple.shade100,
                      );
                    }
                    if (snapshot.hasError) {
                      return StatCard(
                        title: 'Réservation',
                        value: 'Erreur',
                        icon: Icons.error,
                        color: Colors.red.shade100,
                      );
                    }

                    // Récupérer le nombre de réservations
                    final int reservationCount = snapshot.data?.docs.length ?? 0;

                    return StatCard(
                      title: 'Réservation',
                      value: reservationCount.toString(),
                      icon: Icons.insert_drive_file,
                      color: Colors.purple.shade100,
                    );
                  },
                ),

                // StreamBuilder pour le nombre d'annonces
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('car_listings').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return StatCard(
                        title: 'Nombre d\'annonce',
                        value: 'Chargement...', // Indicateur de chargement
                        icon: Icons.campaign,
                        color: Colors.red.shade100,
                      );
                    }
                    if (snapshot.hasError) {
                      return StatCard(
                        title: 'Nombre d\'annonce',
                        value: 'Erreur',
                        icon: Icons.error,
                        color: Colors.red.shade100,
                      );
                    }

                    // Récupérer le nombre d'annonces
                    final int annonceCount = snapshot.data?.docs.length ?? 0;

                    return StatCard(
                      title: 'Nombre d\'annonce',
                      value: annonceCount.toString(),
                      icon: Icons.campaign,
                      color: Colors.red.shade100,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statistique',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Expanded(
                      child: StatistiqueGraph(), // Ajout du graphique ici
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  StatCard(
      {required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40.0, color: Colors.black),
              const SizedBox(height: 8.0),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatistiqueGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 10),
              FlSpot(1, 20),
              FlSpot(2, 15),
              FlSpot(3, 25),
              FlSpot(4, 30),
              FlSpot(5, 35),
            ],
            isCurved: true,
            color: Colors.cyan,
            barWidth: 3,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black26, width: 1),
        ),
        gridData: FlGridData(show: true),
      ),
    );
  }
}
