import 'package:flutter/material.dart';
import 'package:projet_fin/Dashbord/Login.dart';


class Identite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil du Propriétaire'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 50, color: Colors.grey[700]),
              ),
            ),
            SizedBox(height: 20),
            Text('Nom: Ali BAH', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Email: ali@gmail.com', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Téléphone: +223 79 13 60 17', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Location: MALI', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Permis: image.png', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context)=> LoginPage())
                  );
                },
                child: Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}