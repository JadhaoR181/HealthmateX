import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/backend_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onRegister;

  const RegisterPage({Key? key, required this.onRegister}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final BackendService _backendService =
      BackendService(baseUrl: "https://healthmatex-backend.onrender.com");
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  String name = '', email = '', phone = '', password = '', confirmPassword = '';

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
                    width: 120,
                    height: 120,
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
                        const TextSpan(text: "HealthMate"),
                        TextSpan(
                          text: "X",
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "Register and get started",
                    style:
                        TextStyle(fontSize: 20, color: blue.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 36),

                  // Full Name Field
                  TextFormField(
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Enter your name'
                        : null,
                    onChanged: (val) => name = val,
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  TextFormField(
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val == null || !val.contains('@')
                        ? 'Enter valid email'
                        : null,
                    onChanged: (val) => email = val,
                  ),
                  const SizedBox(height: 20),

                  // Phone Number Field (optional)
                  TextFormField(
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number (optional)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    onChanged: (val) => phone = val,
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    obscureText: _obscurePass,
                    validator: (val) => val == null || val.length < 6
                        ? 'Password min 6 chars'
                        : null,
                    onChanged: (val) => password = val,
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  TextFormField(
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    obscureText: _obscureConfirm,
                    validator: (val) =>
                        val != password ? 'Passwords do not match' : null,
                    onChanged: (val) => confirmPassword = val,
                  ),
                  const SizedBox(height: 36),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  if (_isLoading) const CircularProgressIndicator(),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
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
                                  print('Starting Firebase signup...');
                                  final user = await _authService
                                      .signUpWithEmail(email, password);
                                  print(
                                      'Firebase signup completed. User: $user');

                                  if (user != null) {
                                    final token = await user.getIdToken(true);
                                    print('Token received: $token');

                                    final success =
                                        await _backendService.saveUserProfile(
                                      uid: user.uid,
                                      name: name,
                                      email: email,
                                      phone: phone,
                                      firebaseIdToken: token!,
                                    );

                                    print(
                                        'Backend saveUserProfile response: $success');

                                    if (!success) {
                                      setState(() {
                                        _errorMessage =
                                            'Failed to save user data. Please try again.';
                                      });
                                      return;
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Registration successful! Please log in.'),
                                        backgroundColor: Colors.blueAccent,
                                      ),
                                    );

                                    Navigator.pushReplacementNamed(
                                        context, '/login');
                                  }
                                } catch (e) {
                                  print('Error during registration: $e');
                                  setState(() {
                                    _errorMessage =
                                        'Registration failed: ${e.toString()}';
                                  });
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                      child: const Text(
                        "Register",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Navigate to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?",
                          style: TextStyle(fontSize: 16)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
