import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth.dart';
import '../helpers/sliderightroute.dart';
import 'register.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  
  static const Color royalGreen = Color(0xFF00561b);

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    String? token = await storage.read(key: 'access_token');
    if (token != null) {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      EasyLoading.show(status: 'Authenticating...', indicator: const CircularProgressIndicator(color: royalGreen));
      bool success = await AuthService().login(_emailController.text, _passwordController.text);
      EasyLoading.dismiss();
      
      if (mounted) {
        if (success) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid credentials or server error'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_rounded, size: 80, color: royalGreen),
              const SizedBox(height: 16),
              const Text('BMI Sync', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: royalGreen)),
              const SizedBox(height: 8),
              const Text('Sign in to continue', style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                color: Colors.white,
                shadowColor: royalGreen.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          cursorColor: royalGreen,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(color: royalGreen),
                            prefixIcon: const Icon(Icons.email_outlined, color: royalGreen),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: royalGreen, width: 2)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) => 
                              (value != null && EmailValidator.validate(value)) ? null : 'Please enter a valid email',
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          cursorColor: royalGreen,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: royalGreen),
                            prefixIcon: const Icon(Icons.lock_outline, color: royalGreen),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: royalGreen, width: 2)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          obscureText: true,
                          validator: (value) => 
                              (value != null && value.isNotEmpty) ? null : 'Please enter your password',
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            backgroundColor: royalGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: _login,
                          child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.push(context, SlideRightRoute(page: RegisterScreen()));
                },
                child: const Text('Don\'t have an account? Register', style: TextStyle(color: royalGreen, fontWeight: FontWeight.w600, fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
