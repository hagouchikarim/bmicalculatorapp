import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = const FlutterSecureStorage();
  
  final TextEditingController _heightController = TextEditingController(text: '170');
  final TextEditingController _weightController = TextEditingController(text: '65');
  
  double _bmi = 0;
  String _bmiStatus = '';
  Color _bmiColor = const Color(0xFF00561b); // Default Royal Green
  
  String _userName = '';
  String _userGender = 'M';

  static const Color royalGreen = Color(0xFF00561b);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? name = await storage.read(key: 'user_name');
    String? gender = await storage.read(key: 'user_gender');
    if (mounted) {
      setState(() {
        _userName = name ?? 'Invité';
        _userGender = gender ?? 'M';
      });
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    FocusScope.of(context).unfocus(); // Close keyboard
    double? height = double.tryParse(_heightController.text);
    double? weight = double.tryParse(_weightController.text);
    
    if (height == null || weight == null || height <= 0 || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez entrer des valeurs valides"), backgroundColor: Colors.red));
      return;
    }

    setState(() {
      _bmi = weight / ((height / 100) * (height / 100));
      
      double normalUpper = (_userGender == 'F') ? 24.0 : 25.0;
      double overweightUpper = (_userGender == 'F') ? 29.0 : 30.0;

      if (_bmi < 18.5) {
        _bmiStatus = 'Insuffisance \npondérale';
        _bmiColor = Colors.blue;
      } else if (_bmi >= 18.5 && _bmi < normalUpper) {
        _bmiStatus = 'Poids Normal';
        _bmiColor = Colors.green;
      } else if (_bmi >= normalUpper && _bmi < overweightUpper) {
        _bmiStatus = 'Surpoids';
        _bmiColor = Colors.orange;
      } else {
        _bmiStatus = 'Obésité';
        _bmiColor = Colors.red;
      }
    });
  }

  Future<void> _logout() async {
    await storage.deleteAll();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Le périmètre de la page (border) prend la couleur de la gauge
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: _bmi > 0 ? _bmiColor : Colors.transparent,
            width: _bmi > 0 ? 12.0 : 0.0,
          )
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: const Text('CALCULATEUR BMI', style: TextStyle(fontWeight: FontWeight.w900, color: royalGreen, letterSpacing: 1)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: royalGreen),
                    onPressed: _logout,
                    tooltip: 'Déconnexion',
                  )
                ],
              ),
              if (_userName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(_userGender == 'M' ? Icons.face : Icons.face_3, color: royalGreen, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _userGender == 'M' ? 'Bonjour Mr $_userName' : 'Bonjour Madame $_userName',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: royalGreen),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    children: [
                      // Formulaire de saisie directe
                      Card(
                        elevation: 4,
                        shadowColor: royalGreen.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputField(
                                      controller: _heightController,
                                      label: "Taille (cm)",
                                      icon: Icons.height,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildInputField(
                                      controller: _weightController,
                                      label: "Poids (kg)",
                                      icon: Icons.monitor_weight_outlined,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: royalGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                onPressed: _calculateBMI,
                                child: const Text("CALCULER", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Gauge Modernisée
                      if (_bmi > 0)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: _bmiColor.withOpacity(0.15), spreadRadius: 5, blurRadius: 20)
                            ]
                          ),
                          child: Column(
                            children: [
                              Text(
                                _bmiStatus.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: _bmiColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 250,
                                child: SfRadialGauge(
                                  enableLoadingAnimation: true,
                                  animationDuration: 1500,
                                  axes: <RadialAxis>[
                                    RadialAxis(
                                      minimum: 10,
                                      maximum: 40,
                                      showLabels: true,
                                      showTicks: true,
                                      axisLineStyle: AxisLineStyle(
                                        thickness: 0.15,
                                        thicknessUnit: GaugeSizeUnit.factor,
                                        color: Colors.grey.withOpacity(0.2),
                                      ),
                                      ranges: <GaugeRange>[
                                        GaugeRange(startValue: 10, endValue: 18.5, color: Colors.blue, startWidth: 0.15, endWidth: 0.15, sizeUnit: GaugeSizeUnit.factor),
                                        GaugeRange(startValue: 18.5, endValue: 25, color: Colors.green, startWidth: 0.15, endWidth: 0.15, sizeUnit: GaugeSizeUnit.factor),
                                        GaugeRange(startValue: 25, endValue: 30, color: Colors.orange, startWidth: 0.15, endWidth: 0.15, sizeUnit: GaugeSizeUnit.factor),
                                        GaugeRange(startValue: 30, endValue: 40, color: Colors.red, startWidth: 0.15, endWidth: 0.15, sizeUnit: GaugeSizeUnit.factor),
                                      ],
                                      pointers: <GaugePointer>[
                                        NeedlePointer(
                                          value: _bmi,
                                          needleColor: royalGreen,
                                          tailStyle: const TailStyle(length: 0.15, width: 6, color: royalGreen),
                                          knobStyle: const KnobStyle(color: Colors.white, borderColor: royalGreen, borderWidth: 0.05, knobRadius: 0.08),
                                        )
                                      ],
                                      annotations: <GaugeAnnotation>[
                                        GaugeAnnotation(
                                          widget: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _bmi.toStringAsFixed(1),
                                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _bmiColor),
                                              ),
                                              const Text('BMI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                                            ],
                                          ),
                                          angle: 90,
                                          positionFactor: 0.75,
                                        )
                                      ]
                                    )
                                  ]
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      cursorColor: royalGreen,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: royalGreen),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon, color: royalGreen),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: royalGreen, width: 2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
