import 'package:flutter/material.dart';
import 'package:projet_fin/moblie/screens/profil.dart';
import 'package:projet_fin/moblie/screens/reservation.dart';
import 'package:projet_fin/moblie/screens/notification.dart';
import 'accueil_screen.dart';

// Page de Navigation qui contient la BottomNavigationBar et gère la navigation
class Navigation extends StatefulWidget {
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  // Index de la page actuellement sélectionnée (par défaut 0 => Page d'accueil)
  int _selectedIndex = 0;

  // Liste des pages à afficher dans la navigation
  final List<Widget> _pages = [
    Accueil(),
    Reservation(),
    NotificationScreen(),
    Profil(),
  ];

  // Fonction appelée lorsqu'un item est tapé dans la BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Met à jour l'index pour afficher la page correcte
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Affiche la page correspondant à l'index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Index de l'item actuellement sélectionné
        onTap: _onItemTapped, // Appelle cette fonction lorsque l'utilisateur clique sur un item
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Réservation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Discussion',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'person',
          ),
        ],
        selectedItemColor: Colors.blue, // Couleur de l'item sélectionné
        unselectedItemColor: Colors.grey, // Couleur des items non sélectionnés
      ),
    );
  }
}

