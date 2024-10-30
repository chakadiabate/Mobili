import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:projet_fin/moblie/screens/Annoce.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _NomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _availabilityDateController = TextEditingController();

  bool _isAutomatic = false;
  bool _isManual = false;
  bool _isLoading = false;
  List<File> _selectedImages = [];
  String? _listingType; // Nouvelle variable pour le type de l'annonce

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _selectAvailabilityDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _availabilityDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<List<String>> _uploadImages(List<File> imageFiles) async {
    List<String> downloadUrls = [];
    try {
      for (File imageFile in imageFiles) {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        Reference storageRef = _storage.ref().child('car_images/$fileName');
        UploadTask uploadTask = storageRef.putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }
    } catch (e) {
      print('Erreur lors du téléchargement de l’image: $e');
      throw Exception('Erreur lors du téléchargement des images: $e');
    }
    return downloadUrls;
  }

  Future<void> _createListing() async {
    // Récupérer l'utilisateur actuellement connecté
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous devez être connecté pour créer une annonce.')),
      );
      return;
    }

    if (_NomController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _listingType == null || // Vérifiez le type de l'annonce
        _selectedImages.isEmpty ||
        _availabilityDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs et ajouter des images.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Générer un identifiant unique pour l'annonce
      String id_annonce = _firestore.collection('car_listings').doc().id;

      // Téléchargement des images
      List<String> imageUrls = await _uploadImages(_selectedImages);

      // Enregistrement de l'annonce dans Firestore
      await _firestore.collection('car_listings').doc(id_annonce).set({
        'id_annonce': id_annonce, // ID unique de l'annonce
        'user_id': user.uid, // Identifiant de l'utilisateur connecté
        'Nom': _NomController.text,
        'description': _descriptionController.text,
        'price': _priceController.text,
        'city': _cityController.text,
        'seats': _seatsController.text,
        'brand': _brandController.text,
        'year': _yearController.text,
        'availability_date': _availabilityDateController.text,
        'transmission': _isAutomatic ? 'Automatique' : _isManual ? 'Manuelle' : 'Non spécifié',
        'listing_type': _listingType, // Type de l'annonce
        'image_urls': imageUrls,
        'available': false, // Champ disponible, par défaut false
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Annonce créée avec succès !')),
      );
      // Attendre un court instant pour que le message soit visible
      await Future.delayed(Duration(seconds: 2));

      // Navigation vers la page de navigation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AnnonceDashboard()),  // Remplacez `Navigation` par votre page de navigation
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la création de l\'annonce : $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Créer une annonce'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Créer une annonce',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _NomController,
              decoration: InputDecoration(
                labelText: 'Nom de la voiture',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Description de la voiture',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Prix',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _availabilityDateController,
              decoration: InputDecoration(
                labelText: 'Date de disponibilité',
                prefixIcon: Icon(Icons.date_range),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: _selectAvailabilityDate,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6200EE),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                textStyle: TextStyle(fontSize: 16),
              ),
              onPressed: _pickImages,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Ajouter trois images de la voiture',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            _selectedImages.isNotEmpty
                ? Wrap(
              children: _selectedImages
                  .map((image) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(image, height: 100, width: 100),
              ))
                  .toList(),
            )
                : Text('Aucune image sélectionnée.'),
            SizedBox(height: 16),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Nom de ta ville',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _seatsController,
              decoration: InputDecoration(
                labelText: 'Nombre de places',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _brandController,
              decoration: InputDecoration(
                labelText: 'Marque',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _yearController,
              decoration: InputDecoration(
                labelText: 'Année',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isAutomatic,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAutomatic = value!;
                      _isManual = !value;
                    });
                  },
                ),
                Text('Automatique'),
                SizedBox(width: 24),
                Checkbox(
                  value: _isManual,
                  onChanged: (bool? value) {
                    setState(() {
                      _isManual = value!;
                      _isAutomatic = !value;
                    });
                  },
                ),
                Text('Manuelle'),
              ],
            ),
            SizedBox(height: 32),
            // Sélecteur de type d'annonce
            Text('Type d\'annonce'),
            Row(
              children: [
                Radio<String>(
                  value: 'Location',
                  groupValue: _listingType,
                  onChanged: (value) {
                    setState(() {
                      _listingType = value;
                    });
                  },
                ),
                Text('Location'),
                SizedBox(width: 16),
                Radio<String>(
                  value: 'Vente',
                  groupValue: _listingType,
                  onChanged: (value) {
                    setState(() {
                      _listingType = value;
                    });
                  },
                ),
                Text('Vente'),
              ],
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createListing,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Ajouter l\'annonce'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6A67CE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
