// ignore_for_file: use_super_parameters

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'home.dart';


class AuthGate extends StatelessWidget {
 const AuthGate({Key? key}) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return StreamBuilder<User?>(
     stream: FirebaseAuth.instance.authStateChanges(),
     builder: (context, snapshot) {
       if (!snapshot.hasData) {
         return SignInScreen(
           providers: [
             EmailAuthProvider(),
           ],
           headerBuilder: (context, constraints, shrinkOffset) {
             return Padding(
               padding: const EdgeInsets.all(20),
               child: AspectRatio(
                 aspectRatio: 1,
                 child: Image.asset('flutterfire_300x.png'),
               ),
             );
           },
           
           footerBuilder: (context, action) {
             return const Padding(
               padding: EdgeInsets.only(top: 16),
               child: Text(
                 'En vous coonectant,vous acceptez les conditions utilisateurs.',
                 style: TextStyle(color: Color.fromARGB(255, 77, 64, 64)),
               ),
             );
           },
           
         );
       }
       return const HomeScreen();
     },
   );
 }
}
