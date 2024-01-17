import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter FCM Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthService().handleAuth(),
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  handleAuth() {
    return StreamBuilder(
      stream: _auth.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return ChatScreen();
        } else {
          return SignInScreen();
        }
      },
    );
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print("Error signing in: $e");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String email = _emailController.text.trim();
                String password = _passwordController.text.trim();
                _authService.signInWithEmailAndPassword(email, password);
              },
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  User? _user;
  late String _currentUserId;
  TextEditingController _messageController = TextEditingController();
  List<String> _messages = [];

  List<String> _availableUsers = [];
  String _selectedUser = ''; // Initialize with an empty string

  @override
  void initState() {
    super.initState();

    _fetchUserData(); // Added to fetch user data from Firestore

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      _handleIncomingMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: $message");
      // Handle message when the app is in the foreground
      _handleIncomingMessage(message);
    });

    _firebaseMessaging.getToken().then((token) {
      print("FCM Token: $token");
      // Save the token or send it to your server
    });

    _user = _auth.currentUser;
    _currentUserId = _user!.uid;
  }

  void _fetchUserEmails() async {
    try {
      List<String> emails = [];

      // Fetch user data directly from Firebase Authentication
      await FirebaseAuth.instance.currentUser!.reload(); // Refresh user data
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        emails.add(user.email!); // Add the current user's email to the list
      }

      setState(() {
        _availableUsers = emails;
        if (_availableUsers.isNotEmpty) {
          _selectedUser = _availableUsers[0];
        }
      });
    } catch (e) {
      print("Error fetching user emails: $e");
    }
  }

  // New method to fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      final User? user = _auth.currentUser;

      // Fetch user data from Firestore
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isNotEqualTo: user?.uid)
          .get();

      List<String> emails =
          userSnapshot.docs.map((doc) => doc['email'] as String).toList();

      setState(() {
        _availableUsers = emails;
        if (_availableUsers.isNotEmpty) {
          _selectedUser = _availableUsers[0];
        }
      });
    } catch (e) {
      print("Error fetching user emails: $e");
    }
  }

  void _handleIncomingMessage(RemoteMessage message) {
    print('Received message: ${message.data}');
    _updateUI(message.data);
    _saveMessageToFirestore(message.data);
  }

  void _updateUI(Map<String, dynamic> messageData) {
    String messageText = messageData['text'];
    setState(() {
      _messages.add(messageText);
    });
  }

  void _saveMessageToFirestore(Map<String, dynamic> messageData) {
    _firestore.collection('messages').add({
      'text': messageData['text'],
      'senderId': messageData['senderId'],
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _sendMessage(String message) {
    _firestore.collection('messages').add({
      'text': message,
      'senderId': _currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter FCM Chat'),
        actions: [
          IconButton(
            onPressed: () async {
              await _auth.signOut();
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Column(
        children: [
          // User selection dropdown
          DropdownButton(
            value: _selectedUser,
            items: _availableUsers.map((user) {
              return DropdownMenuItem(
                value: user,
                child: Text(user),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedUser = value.toString();
                // Update UI or load chat messages for the selected user
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(_messageController.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
