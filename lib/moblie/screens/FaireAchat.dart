import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AchatScreen extends StatefulWidget {
  final String carName;
  final String listingId;
  final List<dynamic> imageUrls;// Ajouter ici
  final String price;
  final String availability_date;



  const AchatScreen({Key? key, required this.carName, required this.listingId, required this.imageUrls, required this.price, required this.availability_date}) : super(key: key);

  @override
  _AchatScreenState createState() => _AchatScreenState();
}

class _AchatScreenState extends State<AchatScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _quartierController = TextEditingController();
  File? _selectedImage;
  DateTime? _startDate;
  DateTime? _endDate;

  final ImagePicker _picker = ImagePicker();

  String? _phoneError;
  String? _quartierError;
  String? _imageError;
  String? _dateError;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File imageFile = File(image.path);
      int imageSize = await imageFile.length();
      if (imageSize <= 5000000) {
        setState(() {
          _selectedImage = imageFile;
          _imageError = null; // Reset error message
        });
      } else {
        setState(() {
          _imageError = 'Veuillez sélectionner une image inférieure à 5 Mo.';
        });
      }
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      String fileName = 'reservations/${Uuid().v4()}.jpg';
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = firebaseStorageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      setState(() {
        _imageError = 'Erreur lors du téléchargement de l\'image: ${e.toString()}';
      });
      return null;
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _dateError = null; // Reset error message
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _dateError = null; // Reset error message
      });
    }
  }

  bool _validateDates() {
    if (_startDate != null && _endDate != null) {
      return _endDate!.isAfter(_startDate!);
    }
    return false;
  }

  bool _validateFields() {
    bool valid = true;

    if (_phoneController.text.isEmpty) {
      setState(() {
        _phoneError = 'Veuillez entrer un numéro de téléphone.';
      });
      valid = false;
    } else {
      setState(() {
        _phoneError = null; // Reset error message
      });
    }

    if (_quartierController.text.isEmpty) {
      setState(() {
        _quartierError = 'Veuillez entrer le nom du quartier.';
      });
      valid = false;
    } else {
      setState(() {
        _quartierError = null; // Reset error message
      });
    }

    if (_selectedImage == null) {
      setState(() {
        _imageError = 'Veuillez sélectionner une photo de pièce d’identité.';
      });
      valid = false;
    } else {
      setState(() {
        _imageError = null; // Reset error message
      });
    }

    if (!_validateDates()) {
      setState(() {
        _dateError = 'La date de fin doit être après la date de début.';
      });
      valid = false;
    } else {
      setState(() {
        _dateError = null; // Reset error message
      });
    }

    return valid;
  }

  Future<void> _submitReservation() async {
    String listingId = widget.listingId;
    List imageUrls = widget.imageUrls;
    if (_validateFields()) {
      try {
        String reservationId = Uuid().v4();
        String uid = FirebaseAuth.instance.currentUser!.uid;
        String? imageUrl;
        if (_selectedImage != null) {
          imageUrl = await _uploadImageToFirebase(_selectedImage!);
        }

        if (imageUrl == null) {
          setState(() {
            _imageError = 'Erreur lors du téléchargement de l\'image.';
          });
          return;
        }

        await FirebaseFirestore.instance.collection('ReservationCollection').add({
          'reservationId': reservationId,
          'carName': widget.carName,
          'listingId': listingId, // Ajouter ici
          'phone': _phoneController.text,
          'quartier': _quartierController.text,
          'startDate': _startDate,
          'endDate': _endDate,
          'UserId': uid,
          'imageUrls': imageUrls,
          'imageUrl': imageUrl,
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Succès'),
            content: Text('Votre Achat a été enregistrée avec succès.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        setState(() {
          _imageError = 'Erreur lors de l\'enregistrement : ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Faire une réservation'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nom de la voiture
              TextFormField(
                initialValue: widget.carName,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Nom de la voiture',
                  prefixIcon: Icon(Icons.directions_car),
                ),
              ),
              SizedBox(height: 10),

              // Numéro de téléphone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              if (_phoneError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _phoneError!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 10),

              // Photo de la pièce d’identité
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.photo),
                      SizedBox(width: 10),
                      Text(_selectedImage == null
                          ? 'Photo de la pièce d’identité'
                          : 'Image sélectionnée'),
                    ],
                  ),
                ),
              ),
              if (_imageError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _imageError!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 10),

              // Nom du quartier
              TextFormField(
                controller: _quartierController,
                decoration: InputDecoration(
                  labelText: 'Nom du quartier',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              if (_quartierError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _quartierError!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 10),

              // Date de début
              GestureDetector(
                onTap: () => _selectStartDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: _startDate == null
                          ? 'Date de début'
                          : DateFormat('dd-MM-yyyy').format(_startDate!),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              if (_dateError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _dateError!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 10),

              // Date de fin
              GestureDetector(
                onTap: () => _selectEndDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: _endDate == null
                          ? 'Date de fin'
                          : DateFormat('dd-MM-yyyy').format(_endDate!),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Bouton Soumettre
              ElevatedButton(
                onPressed: _submitReservation,
                child: Text('Acheter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
