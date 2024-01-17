// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fcm_atoz/home_screen.dart'; // Import HomeScreen

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   handleAuth() {
//     return StreamBuilder(
//       stream: _auth.authStateChanges(),
//       builder: (BuildContext context, snapshot) {
//         if (snapshot.hasData) {
//           return HomeScreen(); // Navigate to HomeScreen directly
//         } else {
//           return SignInScreen();
//         }
//       },
//     );
//   }

//   Future signInWithEmailAndPassword(String email, String password) async {
//     try {
//       await _auth.signInWithEmailAndPassword(email: email, password: password);
//       await _storeUserDataInFirestore();
//     } catch (e) {
//       print("Error signing in: $e");
//     }
//   }

//   Future<void> _storeUserDataInFirestore() async {
//     final User? user = _auth.currentUser;
//     await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
//       'email': user?.email,
//       'created': FieldValue.serverTimestamp(),
//       // Add more user data as needed
//     });
//   }

  
// }

// class SignInScreen extends StatefulWidget {
//   @override
//   _SignInScreenState createState() => _SignInScreenState();
// }

// class _SignInScreenState extends State<SignInScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   final AuthService _authService = AuthService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Sign In'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(labelText: 'Email'),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               controller: _passwordController,
//               decoration: InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 String email = _emailController.text.trim();
//                 String password = _passwordController.text.trim();
//                 _authService.signInWithEmailAndPassword(email, password);
//               },
//               child: Text('Sign In'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
