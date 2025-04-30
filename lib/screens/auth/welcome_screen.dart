import 'package:flutter/material.dart';
import 'sign_up_screen.dart'; // Import the sign up screen
import 'log_in_screen.dart'; // Import the log in screen
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/home_screen.dart';

// 1) Google
Future<void> _handleGoogleSignIn(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(credential);

    final User? user = userCredential.user;
    print('Google sign in successful: ${user?.email}');

    // Navigation vers la page d'accueil
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PlantifyHomePage()),
    );
  } catch (e) {
    print('Error during Google sign in: $e');
  }
}

void main() {
  runApp(const WelcomeApp());
}

class WelcomeApp extends StatelessWidget {
  const WelcomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome Screen',
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF00A862),
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Widget _buildSocialButton({
    required String assetPath,
    required String label,
    required VoidCallback onPressed,
    required double width, // Ajouter un paramètre width
  }) {
    return SizedBox(
      width: width, // Définir la largeur du bouton
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          side: const BorderSide(color: Color(0xFFd1d5db)), // gray-300
          padding: const EdgeInsets.symmetric(
            vertical: 18,
          ), // Augmenter la hauteur
          foregroundColor: Colors.black87,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ), // Augmenter la taille du texte
        ),
        onPressed: onPressed,
        icon: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Alignement à gauche
          children: [
            Image.asset(
              assetPath,
              height: 24,
              width: 24,
              fit: BoxFit.contain,
            ), // Image à gauche
            const SizedBox(width: 12), // Espacement entre l'image et le texte
          ],
        ),
        label: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const greenColor = Color(0xFF00A862);
    const lightGreenColor = Color(0xFFE6F5EF);
    const buttonWidth = 300.0; // Largeur commune pour tous les boutons

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logoApp1.png',
                  height: 70,
                  width: 70,
                  fit: BoxFit.contain,
                  semanticLabel: 'Green leaf logo with two leaves',
                ),
                const SizedBox(height: 32),
                const Text(
                  "Let's Get Started!",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Let's dive in into your account",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildSocialButton(
                  assetPath:
                      'assets/images/google.png', // Remplace l'URL par l'image locale
                  label: 'Continue with Google',
                  onPressed: () => _handleGoogleSignIn(context),
                  width: buttonWidth, // Utiliser la largeur définie
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: buttonWidth, // Utiliser la largeur définie
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ), // Augmenter la hauteur
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16, // Augmenter la taille du texte
                      ),
                    ),
                    onPressed: () {
                      // Navigate to the sign-up screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text('Sign up'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: buttonWidth, // Utiliser la largeur définie
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: lightGreenColor,
                      foregroundColor: greenColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ), // Augmenter la hauteur
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16, // Augmenter la taille du texte
                      ),
                    ),
                    onPressed: () {
                      // Navigate to the log-in screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LogInScreen(),
                        ),
                      );
                    },
                    child: const Text('Log in'),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Privacy Policy · Terms of Service',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
