import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_fin/moblie/screens/Annoce.dart';
import 'package:projet_fin/moblie/screens/DeatilsVoiture.dart';
import 'package:projet_fin/moblie/screens/notification.dart';

class Accueil extends StatefulWidget {
  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? selectedCategory;
  List<QueryDocumentSnapshot> _filteredListings = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => NotificationScreen())
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Icon(Icons.notifications),
            ),
            Text("Accueil"),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AnnonceDashboard())
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Icon(Icons.send),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Recherche",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage('assets/ecran.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _filterByCategory('Automatique'),
                      child: CategoryItem('Automatique', 'assets/automatique.png'),
                    ),
                    GestureDetector(
                      onTap: () => _filterByCategory('Manuelle'),
                      child: CategoryItem('Manuelle', 'assets/manuelle.png'),
                    ),
                    GestureDetector(
                      onTap: () => _filterByCategory('Vente'),
                      child: CategoryItem('Vente', 'assets/ferrari.png'),
                    ),
                    GestureDetector(
                      onTap: () => _filterByCategory('Location'),
                      child: CategoryItem('Location', 'assets/camry.png'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              if (_searchQuery.isEmpty && selectedCategory == null) ...[
                SectionTitle('Récemment ajouté'),
                SizedBox(height: 10),
                RecentItems(),

                SectionTitle('Vente'),
                SizedBox(height: 10),
                ProductList(listingType: 'Vente'),

                SectionTitle('Location'),
                SizedBox(height: 10),
                ProductList(listingType: 'Location'),
              ],
              SizedBox(height: 50),

              // StreamBuilder pour afficher uniquement les voitures disponibles
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('car_listings')
                    .where('available', isEqualTo: false) // Filtre pour les voitures disponibles
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  List<QueryDocumentSnapshot> allListings = snapshot.data!.docs;
                  List<QueryDocumentSnapshot> filteredListings = allListings.where((listing) {
                    final data = listing.data() as Map<String, dynamic>;
                    final matchesSearch = _searchQuery.isEmpty ||
                        data['Nom'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        data['Marque'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        data['price'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

                    final matchesCategory = selectedCategory == null ||
                        (selectedCategory == 'Automatique' && data['transmission'] == 'Automatique') ||
                        (selectedCategory == 'Manuelle' && data['transmission'] == 'Manuelle') ||
                        (selectedCategory == 'Vente' && data['listing_type'] == 'Vente') ||
                        (selectedCategory == 'Location' && data['listing_type'] == 'Location');

                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filteredListings.isEmpty) {
                    return Text("Aucun résultat trouvé");
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          _searchQuery.isNotEmpty
                              ? "Résultats de recherche pour '$_searchQuery':"
                              : selectedCategory != null
                              ? "Résultats filtrés pour $selectedCategory:"
                              : "Toutes les annonces disponibles:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: filteredListings.map((listing) {
                            final data = listing.data() as Map<String, dynamic>;
                            return ProductItem(
                              data['Nom'] ?? 'Nom non disponible',
                              data['availability_date'] ?? 'Année non disponible',
                              data['price']?.toString() ?? 'Prix non disponible',
                              data['listing_type'] ?? 'Type non disponible',
                              data['description'] ?? 'Description non disponible',
                              data['image_urls'] ?? [],
                              listing.id,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Les autres classes (SectionTitle, RecentItems, ProductList, ProductItem, CategoryItem) restent inchangées
// Les autres classes restent inchangées
// Widget pour les titres des sections
class SectionTitle extends StatelessWidget {
  final String title;

  SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Tout voir',
          style: TextStyle(
            color: Colors.purple,
          ),
        ),
      ],
    );
  }
}

// Widget pour afficher les annonces récentes
class RecentItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('car_listings')
          .orderBy('created_at', descending: true) // Assure-toi d'avoir un champ 'created_at' dans ta collection
          .limit(2) // Limite à 2 éléments
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        // Récupère les documents
        List<QueryDocumentSnapshot> recentListings = snapshot.data!.docs;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: recentListings.map((listing) {
            // Crée un RecentItem pour chaque annonce
            return RecentItem(
              listing['Nom'] ?? 'Nom non disponible',
              listing['price'] ?? 'Modèle non disponible',
              listing['image_urls'] is List && listing['image_urls'].isNotEmpty
                  ? listing['image_urls'][0] // Récupère la première image si c'est une liste
                  : 'https://via.placeholder.com/80', // Image par défaut si aucune image n'est disponible
            );
          }).toList(),
        );
      },
    );
  }
}

class RecentItem extends StatelessWidget {
  final String Nom;
  final String price;
  final String imagePath;

  RecentItem(this.Nom, this.price, this.imagePath);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(imagePath, width: 80, height: 80), // Utilisation de l'image récupérée de Firestore
        Text(Nom, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(price),
      ],
    );
  }
}

// Widget pour les produits (données récupérées depuis Firestore)
class ProductList extends StatelessWidget {
  final String listingType;

  ProductList({required this.listingType});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('car_listings')
          .where('available', isEqualTo: false) // Filtre pour les voitures disponibles
          .where('listing_type', isEqualTo: listingType) // Filtre par type de listing
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        // Récupère les documents
        List<QueryDocumentSnapshot> listings = snapshot.data!.docs;

        if (listings.isEmpty) {
          return Text("Aucune annonce de $listingType trouvée.");
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: listings.map((listing) {
              final data = listing.data() as Map<String, dynamic>;
              return ProductItem(
                data['Nom'] ?? 'Nom non disponible',
                data['availability_date'] ?? 'Année non disponible',
                data['price']?.toString() ?? 'Prix non disponible',
                data['listing_type'] ?? 'Type non disponible',
                data['description'] ?? 'Description non disponible',
                data['image_urls'] ?? [],
                listing.id,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// Classe ProductItem modifiée
class ProductItem extends StatelessWidget {
  final String nom;
  final String availabilityDate;
  final String price;
  final String listingType;
  final String description;
  final dynamic imageUrls;
  final String listingId; // Ajouter l'ID de l'annonce

  const ProductItem(this.nom, this.availabilityDate, this.price, this.listingType, this.description, this.imageUrls, this.listingId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl;

    if (imageUrls is List && imageUrls.isNotEmpty) {
      imageUrl = imageUrls[0];
    } else if (imageUrls is String) {
      imageUrl = imageUrls;
    } else {
      imageUrl = 'https://via.placeholder.com/120';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsVoiture(
              nom: nom,
              availability_date: availabilityDate,
              price: price,
              description: description,
              imageUrls: imageUrls is List ? imageUrls : [imageUrls],
              email: nom,
              listingId: listingId, listing_type: listingType, // Passer l'ID à DetailsVoiture
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(8),
        width: 120,
        child: Column(
          children: [
            Image.network(imageUrl, width: 120, height: 80),
            Text(nom, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(availabilityDate),
            Text(price, style: TextStyle(color: Colors.purple)),
          ],
        ),
      ),
    );
  }
}


// Widget pour les catégories
class CategoryItem extends StatelessWidget {
  final String title;
  final String imagePath;

  const CategoryItem(this.title, this.imagePath, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Image.asset(imagePath, width: 50, height: 50),
          SizedBox(height: 5),
          Text(title),
        ],
      ),
    );
  }
}
// Méthode pour filtrer les annonces par catégorie
//void _filterByCategory(String category) {
  //setState(() {
  //  selectedCategory = category; // Met à jour la catégorie sélectionnée
 // });
//}