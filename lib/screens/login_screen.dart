import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for fade-in effect
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Start animation on load
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showAlert(String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isSuccess ? 'Success' : 'Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isSuccess) {
                  Navigator.pushNamed(context, '/home');
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  bool _validateFields() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showAlert("Please enter your email.", false);
      return false;
    }

    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(email)) {
      _showAlert("Please enter a valid email address.", false);
      return false;
    }

    if (password.isEmpty) {
      _showAlert("Please enter your password.", false);
      return false;
    }

    if (password.length < 6) {
      _showAlert("Password must be at least 6 characters long.", false);
      return false;
    }

    return true;
  }

  void _login() async {
    if (!_validateFields()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String userId = userCredential.user!.uid;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);

      DocumentSnapshot userDoc = await _firestore.collection('user').doc(userId).get();

      if (userDoc.exists) {
        Navigator.pushNamed(context, '/home');
      } else {
        _showAlert('User document does not exist.', false);
      }
    } catch (e) {
      _showAlert('Login failed: ${e.toString()}', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _header(),
                    const SizedBox(height: 50),
                    _inputFields(),
                    const SizedBox(height: 20),
                    _loginButton(),
                    const SizedBox(height: 10),
                    _signup(),
                    const SizedBox(height: 20),
                    _forgotPassword(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F6FB), // Light purple background color
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        const Text(
          "Welcome Back!",
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5B5E6F),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Log in to your account",
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 18,
            color: Color(0xFF8A8C9F),
          ),
        ),
        const SizedBox(height: 20),
        Image.asset(
          'lib/assets/illust.png', // Replace with the actual path to your illustration
          height: 150,
        ),
      ],
    );
  }

  Widget _inputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "Email",
            hintStyle: const TextStyle(
              fontFamily: 'Satoshi',
              color: Color(0xFFB1B3C1),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            fillColor: const Color(0xFFE9E8F7),
            filled: true,
            prefixIcon: const Icon(Icons.person, color: Color(0xFF8A8C9F)),
          ),
          style: const TextStyle(fontFamily: 'Satoshi', color: Color(0xFF5B5E6F)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: "Password",
            hintStyle: const TextStyle(
              fontFamily: 'Satoshi',
              color: Color(0xFFB1B3C1),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            fillColor: const Color(0xFFE9E8F7),
            filled: true,
            prefixIcon: const Icon(Icons.lock, color: Color(0xFF8A8C9F)),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF8A8C9F),
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          obscureText: !_isPasswordVisible,
          style: const TextStyle(fontFamily: 'Satoshi', color: Color(0xFF5B5E6F)),
        ),
      ],
    );
  }

  Widget _forgotPassword() {
    return TextButton(
      onPressed: () {
        // Forgot password action
      },
      child: const Text(
        "Forgot password?",
        style: TextStyle(
          fontFamily: 'Satoshi',
          color: Color(0xFF8A8C9F),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: const Color(0xFF8B69E6),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF7F6FB)))
            : const Text(
          "Login",
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _signup() {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/signup');
      },
      child: const Text(
        "Don't have an account? Sign Up",
        style: TextStyle(
          fontFamily: 'Satoshi',
          color: Color(0xFF8B69E6),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
