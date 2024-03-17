
// ignore_for_file: use_super_parameters, library_private_types_in_public_api, inference_failure_on_instance_creation, avoid_types_on_closure_parameters

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _selectedActivity;
  late User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
              ),
              child: ActivityList(onActivitySelected: _showActivityDetails),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
              ),
              child: _selectedActivity != null
                  ? ActivityDetails(
                      activityData: _selectedActivity!,
                      onAddToCart: _addToCart,
                    )
                  : const Placeholder(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_activity),
            label: 'Activités',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          if (index == 2) {
            _showUserProfile(context);
          } else if (index == 1) {
            _showCartActivities(context);
          }
        },
      ),
    );
  }

  void _showActivityDetails(Map<String, dynamic> activityData) {
    setState(() {
      _selectedActivity = activityData;
    });
  }

  void _addToCart(Map<String, dynamic> activityData) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance.collection('panier').add({
        ...activityData,
        'userId': currentUser.uid,
        'userName': currentUser.displayName ?? '',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activité ajoutée au panier'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez vous connecter pour ajouter une activité au panier.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showUserProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserProfileScreen(user: _currentUser)),
    );
  }

  void _showCartActivities(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartActivitiesScreen(currentUser: _currentUser)),
    );
  }
}

class ActivityList extends StatelessWidget {
  final void Function(Map<String, dynamic>) onActivitySelected;

  const ActivityList({Key? key, required this.onActivitySelected}) : super(key: key);

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
          final activities = snapshot.data!.docs;
          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activityData = activities[index].data() as Map<String, dynamic>;
              final title = activityData['titre'] ?? '';
              return Card(
                child: ListTile(
                  title: Text(title.toString()),
                  onTap: () {
                    onActivitySelected(activityData);
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}

class ActivityDetails extends StatelessWidget {
  final Map<String, dynamic> activityData;
  final void Function(Map<String, dynamic>) onAddToCart;

  const ActivityDetails({
    Key? key,
    required this.activityData,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(activityData['titre'] as String),
          const SizedBox(height: 8),
          Image.network(
            activityData['image'] as String,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Text('Lieu: ${activityData['lieu']}'),
          Text('Prix: ${activityData['prix']}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              onAddToCart(activityData);
            },
            child: const Text('Ajouter au panier'),
          ),
        ],
      ),
    );
  }
}

class UserProfileScreen extends StatefulWidget {
  final User? user;

  const UserProfileScreen({Key? key, this.user}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _birthdayController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Profil'),
    ),
    body: Center(
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profil',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _saveUserProfile(widget.user!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Valider',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.user != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReadOnlyField(Icons.email, 'Email', widget.user!.email ?? ''),
                    _buildReadOnlyField(Icons.lock, 'Password', '******'),
                    _buildTextField(Icons.calendar_today, 'Birthday', _birthdayController),
                    _buildTextField(Icons.home, 'Address', _addressController),
                    _buildPostalCodeTextField(Icons.location_on, 'Postal Code', _postalCodeController),
                    _buildTextField(Icons.location_city, 'City', _cityController),
                    const SizedBox(height: 16),
                  ],
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

  
  Widget _buildReadOnlyField(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.black),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField(IconData icon, String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.black,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostalCodeTextField(IconData icon, String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.black,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[0-9]{5}$')),
            ],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '12345',
            ),
          ),
        ],
      ),
    );
  }

  void _saveUserProfile(User user) {
    final Map<String, dynamic> userProfile = {
      'birthday': _birthdayController.text,
      'address': _addressController.text,
      'postalCode': _postalCodeController.text,
      'city': _cityController.text,
    };

    FirebaseFirestore.instance.collection('users').doc(user.uid).set(userProfile)
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informations de profil enregistrées avec succès.'),
          duration: Duration(seconds: 2),
        ),
      );
    })
        .catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'enregistrement des informations de profil.'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}



class CartActivitiesScreen extends StatelessWidget {
  final User? currentUser;

  const CartActivitiesScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activités du Panier'),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[900],
            borderRadius: BorderRadius.circular(10),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('panier')
                .where('userId', isEqualTo: currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final activities = snapshot.data!.docs;
                if (activities.isEmpty) {
                  return const Center(
                    child: Text('Le panier est vide.'),
                  );
                } else {
                  return ListView.separated(
                    itemCount: activities.length,
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                    itemBuilder: (context, index) {
                      final activityData = activities[index].data() as Map<String, dynamic>;
                      return ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(activityData['titre'].toString()),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _removeFromCart(activities[index].id);
                              },
                              child: const Text('Retirer'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _removeFromCart(String documentId) async {
    await FirebaseFirestore.instance.collection('panier').doc(documentId).delete();
  }
}
