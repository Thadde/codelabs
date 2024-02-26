// ignore_for_file: sort_child_properties_last, inference_failure_on_function_return_type, unused_local_variable, deprecated_member_use, must_be_immutable, prefer_single_quotes

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ProfileScreen>(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/dash.png',
              height: 150,
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome!',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                } catch (e) {
                  print('Error signing out: $e');
                }
              },
              child: const Text('Sign Out'),
            ),
            const SizedBox(height: 20),
            const ActivityDropdown(),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/flutterfire_300x.png'),
          ),
          const SizedBox(height: 20),
          Text(
            'Username',
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 10),
          Text(
            'user@example.com',
            // ignore: deprecated_member_use
            style: Theme.of(context).textTheme.subtitle1,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
              } catch (e) {
                print('Error signing out: $e');
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class ActivityDropdown extends StatelessWidget {
  const ActivityDropdown({super.key});

 
  
  String? get headline6 => null;
  
  get label => null;
  
  Null get titleLarge => null;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('activites').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<DropdownMenuItem<String>> dropdownItems = [];
          final activities = snapshot.data!.docs;
          for (var activity in activities) {
            final activityData = activity.data() as Map<String, dynamic>;
            final imageURL = activityData['image'] ?? '';
            final title = activityData['titre'] ?? '';
            final lieu = activityData['lieu'] ?? '';
            final prix = activityData['prix'] != null ? activityData['prix'].toString() : '';
            var dropdownMenuItem = DropdownMenuItem(
                child: ListTile(
                  
                  title: const Text("ok"),
                  subtitle: Text('$lieu - $prix'),
                ),
                value: label,
              );
            
          }
          return DropdownButton<String>(
            items: dropdownItems,
            onChanged: (value) {},
            hint: const Text('Sélectionner une activité'),
          );
        }
      },
    );
  }
}

