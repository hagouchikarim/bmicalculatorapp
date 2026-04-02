import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bmicalculatorapp2/services/auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:bmicalculatorapp2/register_screen.dart';
import 'package:bmicalculatorapp2/main.dart'; // Pour _HomeState (BMI)
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();
  final storage = const FlutterSecureStorage();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    EasyLoading.show(status: 'Authenticating...', maskType: EasyLoadingMaskType.black);
    
    try {
      var res = await authService.login(emailController.text, passwordController.text);
      if (res != null) {
        if (res.statusCode == 200) {
          var dataResp = jsonDecode(res.body);
          await storage.write(key: 'token', value: dataResp['access_token']);
          await storage.write(key: 'refresh_token', value: dataResp['refresh_token']);
          EasyLoading.dismiss();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Home()),
          );
        } else {
          EasyLoading.dismiss();
          EasyLoading.showError("Auth Failed: \${res.statusCode}");
        }
      } else {
        EasyLoading.dismiss();
        EasyLoading.showError("Server not reachable");
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError("Network Error. Check Server IP.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A), // Deep dark space background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Placeholder / Title
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.cyanAccent, Colors.pinkAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Text(
                  "BMI\nSYNC",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "SYSTEM AUTHORIZATION REQUIRED",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 60),

              // Inputs
              _buildModernInput(
                controller: emailController,
                hintText: "USERNAME/EMAIL",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildModernInput(
                controller: passwordController,
                hintText: "ACCESS CODE",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              
              const SizedBox(height: 50),

              // Action Button
              Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00F0FF), Color(0xFF1E50FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F0FF).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    "INITIALIZE CONNECTION",
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 16, 
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen()));
                },
                child: Text(
                  "NO ACCESS? REGISTER ENTITY.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.pinkAccent.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E), // Dark card color
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.cyanAccent),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), letterSpacing: 1.5, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}