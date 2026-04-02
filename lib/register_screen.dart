import 'package:flutter/material.dart';
import 'package:bmicalculatorapp2/services/auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:email_validator/email_validator.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService authService = AuthService();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  void register() async {
    if (!EmailValidator.validate(emailController.text)) {
        EasyLoading.showError("INVALID EMAIL FORMAT");
        return;
    }
    
    EasyLoading.show(status: 'Registering Entity...', maskType: EasyLoadingMaskType.black);
    
    try {
      var res = await authService.register(
        emailController.text, 
        passwordController.text,
        nameController.text
      );
      if (res != null) {
        if (res.statusCode == 200 || res.statusCode == 201) {
          EasyLoading.dismiss();
          EasyLoading.showSuccess("REGISTRATION COMPLETE");
          Navigator.pop(context); // Retour au login
        } else {
          EasyLoading.dismiss();
          EasyLoading.showError("Registration Failed: \${res.statusCode}");
        }
      } else {
        EasyLoading.dismiss();
        EasyLoading.showError("Server not reachable");
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError("Network Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.pinkAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "NEW\nENTITY",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "CONFIGURE YOUR PARAMETERS",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.pinkAccent.withOpacity(0.8),
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 50),

              _buildModernInput(
                controller: nameController,
                hintText: "DESIGNATION (NAME)",
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 20),
              _buildModernInput(
                controller: emailController,
                hintText: "COM LINK (EMAIL)",
                icon: Icons.alternate_email,
              ),
              const SizedBox(height: 20),
              _buildModernInput(
                controller: passwordController,
                hintText: "SECURITY KEY",
                icon: Icons.security,
                isPassword: true,
              ),
              
              const SizedBox(height: 50),

              Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF003C), Color(0xFF8A00FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF003C).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    "INITIALIZE CORE",
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 16, 
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2
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
        border: Border.all(color: Colors.pinkAccent.withOpacity(0.3), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.pinkAccent),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), letterSpacing: 1.5, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}
