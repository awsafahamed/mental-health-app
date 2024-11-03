import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _newsletter = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

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
                  Navigator.pushNamed(context, '/login');
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
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty) {
      _showAlert("Please enter your username.", false);
      return false;
    }

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

    if (password != confirmPassword) {
      _showAlert("Passwords do not match.", false);
      return false;
    }

    return true;
  }

  void _signUp() async {
    if (!_validateFields()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _firestore.collection('user').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'newsletter': _newsletter,
      });

      _showAlert('Sign up successful!', true);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'The email address is already in use by another account.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else {
        errorMessage = 'An unknown error occurred. Please try again.';
      }
      _showAlert(errorMessage, false);
    } catch (e) {
      _showAlert('Sign up failed: ${e.toString()}', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          "Sign Up",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple,
            fontFamily: 'Satoshi',
          ),
        ),
        const SizedBox(height: 20),
        Image.asset(
          'lib/assets/signup.png',
          height: 150,
        ),
      ],
    );
  }

  Widget _buildSignUpCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputFields(),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _newsletter,
              onChanged: (bool? value) {
                setState(() {
                  _newsletter = value ?? false;
                });
              },
              activeColor: Colors.deepPurple,
            ),
            const Expanded(
              child: Text(
                "I would like to receive your newsletter and other promotional information.",
                style: TextStyle(color: Colors.black87, fontFamily: 'Satoshi', fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _signUp,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.deepPurple,
          ),
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Satoshi'),
                ),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(_nameController, "Name"),
        const SizedBox(height: 12),
        _buildTextField(_emailController, "Email", TextInputType.emailAddress),
        const SizedBox(height: 12),
        _buildPasswordField(_passwordController, "Password"),
        const SizedBox(height: 12),
        _buildPasswordField(_confirmPasswordController, "Confirm Password"),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, [TextInputType keyboardType = TextInputType.text]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.grey[200],
        filled: true,
      ),
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black, fontFamily: 'Satoshi'),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.grey[200],
        filled: true,
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.black54,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.black, fontFamily: 'Satoshi'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSignUpCard(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already Have an Account? ",
                        style: TextStyle(fontFamily: 'Satoshi', color: Colors.black54)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text("Login",
                          style: TextStyle(color: Colors.deepPurple, fontFamily: 'Satoshi')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
