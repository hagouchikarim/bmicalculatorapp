import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../services/auth.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedGender = 'M';

  static const Color royalGreen = Color(0xFF00561b);

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      EasyLoading.show(status: 'Registering...', indicator: const CircularProgressIndicator(color: royalGreen));
      int status = await AuthService().register(
        _emailController.text, 
        _passwordController.text, 
        _nameController.text,
        _selectedGender
      );
      EasyLoading.dismiss();
      
      if (mounted) {
        if (status == 200 || status == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registered Successfully'),
              backgroundColor: royalGreen,
            ),
          );
          Navigator.pop(context); // Go back to login
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed (Error $status)'),
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
      appBar: AppBar(
        title: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold, color: royalGreen)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: royalGreen),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_add_alt_1_rounded, size: 64, color: royalGreen),
              const SizedBox(height: 16),
              const Text('Join BMI Sync', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: royalGreen)),
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
                          controller: _nameController,
                          cursorColor: royalGreen,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: const TextStyle(color: royalGreen),
                            prefixIcon: const Icon(Icons.person_outline, color: royalGreen),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: royalGreen, width: 2)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) => 
                              (value != null && value.isNotEmpty) ? null : 'Please enter your name',
                        ),
                        const SizedBox(height: 20),
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
                              (value != null && value.length >= 6) ? null : 'Password must be at least 6 characters',
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: InputDecoration(
                            labelText: 'Sexe',
                            labelStyle: const TextStyle(color: royalGreen),
                            prefixIcon: Icon(_selectedGender == 'M' ? Icons.male : Icons.female, color: royalGreen),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: royalGreen, width: 2)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'M', child: Text('Homme')),
                            DropdownMenuItem(value: 'F', child: Text('Femme')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedGender = val);
                          },
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
                          onPressed: _register,
                          child: const Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
