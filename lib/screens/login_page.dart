import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/backend_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLogin;

  const LoginPage({Key? key, required this.onLogin}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final BackendService _backendService =
      BackendService(baseUrl: "https://healthmatex-backend.onrender.com");

  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  bool _obscurePassword = true;

  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF2684FF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App icon with shadow circle
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/icon.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: blue,
                      ),
                      children: [
                        const TextSpan(text: "Healthmate"),
                        TextSpan(
                            text: "X", style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: blue.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Email Field
                  TextFormField(
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val == null || !val.contains('@')
                        ? 'Enter valid email'
                        : null,
                    onChanged: (val) => email = val,
                  ),
                  const SizedBox(height: 24),

                  // Password Field
                  TextFormField(
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (val) => val == null || val.length < 6
                        ? 'Password min 6 chars'
                        : null,
                    onChanged: (val) => password = val,
                  ),
                  const SizedBox(height: 36),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_isLoading) const CircularProgressIndicator(),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                      ),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                  _errorMessage = null;
                                });
                                try {
                                  final user = await _authService
                                      .signInWithEmail(email, password);
                                  if (user != null) {
                                    final token = await user.getIdToken(true);
                                    final profile =
                                        await _backendService.getUserProfile(
                                      uid: user.uid,
                                      firebaseIdToken: token!,
                                    );

                                    // Optional: You can process or store `profile` if needed

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Login successful!'),
                                        backgroundColor: Colors.blueAccent,
                                      ),
                                    );

                                    widget
                                        .onLogin(); // Notify parent for navigation
                                  }
                                } catch (e) {
                                  setState(() {
                                    _errorMessage =
                                        'Login failed: ${e.toString()}';
                                  });
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/register'),
                        child: Text(
                          "Register",
                          style: TextStyle(
                            color: blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
