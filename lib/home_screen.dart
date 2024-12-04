import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("Home Screen");
    });
    User? updatedUser = _auth.currentUser;
    debugPrint('User name: ${updatedUser?.displayName}');
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(
      const AssetImage('lib/assets/homepagebackground.jpg'),
      context,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color.fromRGBO(
          233,
          186,
          138,
          0.7,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            onPressed: () async {
              debugPrint('logout tapped');
              try {
                await _auth.signOut();
                debugPrint('Successfully logged in lets goto home screen');
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (route) => false);
              } catch (e) {
                debugPrint('Logout Error Block $e');
              } finally {
                debugPrint('Logout Finally Block');
              }
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/homepagebackground.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome ${_auth.currentUser?.displayName}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      debugPrint('Lets goto Sensing Info Screen');
                      Navigator.of(context).pushNamed('/sensing');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: const Text('Sensing'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      debugPrint('Lets goto Planting Info Screen');
                      Navigator.of(context).pushNamed('/planting');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: const Text('Planting'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
