import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projet_fin/Dashbord/Annoce.dart';
import 'package:projet_fin/Dashbord/Login.dart';
import 'package:projet_fin/Dashbord/Profil.dart';
import 'package:projet_fin/Dashbord/accueil.dart';
import 'package:projet_fin/Dashbord/reservation.dart';
import 'package:projet_fin/Dashbord/utilisateur.dart';

class Sidebar extends StatefulWidget {
  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _selectedIndex = 0;

  // Liste des pages à afficher
  final List<Widget> _pages = [
    Dashboard(),
    Utilisateur(),
    DashbordReservation(),
    DashbordAnnonce(),
    DashbordProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Met à jour l'index de la page sélectionnée
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 300, // Largeur de la sidebar
            color: Colors.white, // Couleur de fond
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.30,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/lo.png'),
                    ),
                  ),
                ),
                _buildListTile(
                  icon: Icons.home,
                  title: 'Dashboard',
                  index: 0,
                ),
                _buildListTile(
                  icon: Icons.person,
                  title: 'Utilisateur',
                  index: 1,
                ),
                _buildListTile(
                  icon: Icons.calendar_today,
                  title: 'Réservations',
                  index: 2,
                ),
                _buildListTile(
                  icon: Icons.announcement,
                  title: 'Annonces',
                  index: 3,
                ),
                _buildListTile(
                  icon: Icons.person,
                  title: 'Mon Profil',
                  index: 4,
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.black),
                  title: Text('Déconnexion', style: TextStyle(color: Colors.black)),
                  onTap: () async {
                    await signOut(context); // Appel de la méthode de déconnexion
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _pages[_selectedIndex],
            // Affiche la page correspondant à l'index sélectionné
          ),
        ],

      ),
    );
  }

  // Fonction pour construire chaque item de la liste
  Widget _buildListTile({required IconData icon, required String title, required int index}) {
    bool isSelected = _selectedIndex == index; // Vérifie si cet élément est sélectionné

    return Container(
      color: isSelected ? Colors.blue[100] : Colors.transparent, // Changez la couleur de fond
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.blue : Colors.black), // Change la couleur de l'icône
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black, // Change la couleur du texte
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Change le poids de la police
          ),
        ),
        onTap: () {
          _onItemTapped(index); // Met à jour l'index lorsque l'item est tapé
        },
      ),
    );
  }
}
Future<void> signOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    // Redirigez vers l'écran de connexion après la déconnexion
    Navigator.pushReplacementNamed(context, '/LoginPage');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Vous vous êtes déconnecté")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur lors de la déconnexion : $e")),
    );
    print("Erreur lors de la déconnexion : $e");
  }
}