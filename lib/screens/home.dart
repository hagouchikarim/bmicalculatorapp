import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../helpers/app_theme.dart';
import 'login.dart';

class _BmiRecord {
  final double bmi;
  final String status;
  final Color color;
  final DateTime date;
  final double height;
  final double weight;

  _BmiRecord({
    required this.bmi,
    required this.status,
    required this.color,
    required this.date,
    required this.height,
    required this.weight,
  });

  Map<String, dynamic> toJson() => {
        'bmi': bmi,
        'status': status,
        'color': color.toARGB32(),
        'date': date.toIso8601String(),
        'height': height,
        'weight': weight,
      };

  factory _BmiRecord.fromJson(Map<String, dynamic> json) => _BmiRecord(
        bmi: (json['bmi'] as num).toDouble(),
        status: json['status'] as String,
        color: Color(json['color'] as int),
        date: DateTime.parse(json['date'] as String),
        height: (json['height'] as num).toDouble(),
        weight: (json['weight'] as num).toDouble(),
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final storage = const FlutterSecureStorage();

  final TextEditingController _heightController =
      TextEditingController(text: '170');
  final TextEditingController _weightController =
      TextEditingController(text: '65');

  double _bmi = 0;
  String _bmiStatus = '';
  Color _bmiColor = AppTheme.primary;
  String _userName = '';
  String _userGender = 'M';
  List<_BmiRecord> _history = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200));
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _pulseController.repeat(reverse: true);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? name = await storage.read(key: 'user_name');
    String? gender = await storage.read(key: 'user_gender');
    String? historyJson = await storage.read(key: 'bmi_history');

    List<_BmiRecord> history = [];
    if (historyJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(historyJson);
        history = decoded
            .map((e) => _BmiRecord.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _userName = name ?? 'Invité';
        _userGender = gender ?? 'M';
        _history = history;
      });
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    FocusScope.of(context).unfocus();
    double? height = double.tryParse(_heightController.text);
    double? weight = double.tryParse(_weightController.text);

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.warning_amber_outlined, color: Colors.white),
          SizedBox(width: 8),
          Text('Veuillez entrer des valeurs valides')
        ]),
        backgroundColor: AppTheme.bmiObese,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    double bmi = weight / ((height / 100) * (height / 100));
    double normalUpper = (_userGender == 'F') ? 24.0 : 25.0;
    double overweightUpper = (_userGender == 'F') ? 29.0 : 30.0;

    String status;
    Color color;

    if (bmi < 18.5) {
      status = 'Insuffisance pondérale';
      color = AppTheme.bmiUnderweight;
    } else if (bmi < normalUpper) {
      status = 'Poids Normal';
      color = AppTheme.bmiNormal;
    } else if (bmi < overweightUpper) {
      status = 'Surpoids';
      color = AppTheme.bmiOverweight;
    } else {
      status = 'Obésité';
      color = AppTheme.bmiObese;
    }

    final record = _BmiRecord(
      bmi: bmi,
      status: status,
      color: color,
      date: DateTime.now(),
      height: height,
      weight: weight,
    );

    final updatedHistory = [record, ..._history].take(5).toList();

    storage.write(
        key: 'bmi_history',
        value: jsonEncode(updatedHistory.map((e) => e.toJson()).toList()));

    setState(() {
      _bmi = bmi;
      _bmiStatus = status;
      _bmiColor = color;
      _history = updatedHistory;
    });
  }

  double _getIdealWeight(double height) {
    // Formule de Devine ajustée au genre
    if (_userGender == 'M') {
      return 50.0 + 2.3 * ((height - 152.4) / 2.54);
    } else {
      return 45.5 + 2.3 * ((height - 152.4) / 2.54);
    }
  }

  Future<void> _logout() async {
    await storage.deleteAll();
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  Map<String, String> _getHealthTips() {
    if (_bmi < 18.5) {
      return {
        'icon': '🥗',
        'titre': 'Augmenter votre apport calorique',
        'conseil1': '• Mangez des repas riches en protéines et glucides sains',
        'conseil2': '• Ajoutez des collations nutritives entre les repas',
        'conseil3': '• Consultez un nutritionniste pour un plan adapté',
        'activite': '🏋️ Musculation recommandée pour prendre du muscle',
      };
    } else if (_bmiStatus == 'Poids Normal') {
      return {
        'icon': '✅',
        'titre': 'Excellent ! Maintenez votre forme',
        'conseil1': '• Continuez une alimentation variée et équilibrée',
        'conseil2': '• 30 min d\'activité modérée par jour',
        'conseil3': '• Hydratez-vous bien (1,5L d\'eau/jour)',
        'activite': '🏃 Cardio + musculation pour maintenir le résultat',
      };
    } else if (_bmiStatus == 'Surpoids') {
      return {
        'icon': '⚠️',
        'titre': 'Quelques ajustements à faire',
        'conseil1': '• Réduisez les aliments ultra-transformés',
        'conseil2': '• Préférez les légumes, fibres et protéines maigres',
        'conseil3': '• Évitez les boissons sucrées et l\'alcool',
        'activite': '🚶 Marche rapide 45 min/jour pour commencer',
      };
    } else {
      return {
        'icon': '🚨',
        'titre': 'Consultez un professionnel de santé',
        'conseil1': '• Réduisez les portions et mangez lentement',
        'conseil2': '• Supprimez sucres ajoutés et graisses saturées',
        'conseil3': '• Un suivi médical régulier est conseillé',
        'activite': '💧 Hydratation + activité douce progressive',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          color: AppTheme.background,
          border: Border.all(
            color: _bmi > 0 ? _bmiColor : Colors.transparent,
            width: _bmi > 0 ? 4.0 : 0.0,
          ),
        ),
        child: Column(
          children: [
            // === HERO HEADER ===
            _buildHeader(),

            // === SCROLLABLE CONTENT ===
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // INPUT CARD
                    _buildInputCard(),
                    const SizedBox(height: 20),

                    // GAUGE CARD (only after calc)
                    if (_bmi > 0) ...[
                      _buildGaugeCard(),
                      const SizedBox(height: 20),
                      _buildIdealWeightCard(),
                      const SizedBox(height: 20),
                      _buildHealthTipsCard(),
                      const SizedBox(height: 20),
                    ],

                    // HISTORY
                    if (_history.isNotEmpty) ...[
                      _buildHistoryCard(),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== WIDGETS ====================

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 16, 24),
          child: Row(
            children: [
              // Avatar
              ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4), width: 2),
                  ),
                  child: Icon(
                    _userGender == 'M'
                        ? Icons.face_rounded
                        : Icons.face_3_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userGender == 'M'
                          ? 'Bonjour, M. $_userName 👋'
                          : 'Bonjour, Mme $_userName 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Calculateur BMI — Suivi Santé',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.white, size: 22),
                onPressed: _logout,
                tooltip: 'Déconnexion',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calculate_rounded, color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text('Vos mesures',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMeasureField(
                  controller: _heightController,
                  label: 'Taille (cm)',
                  icon: Icons.height_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMeasureField(
                  controller: _weightController,
                  label: 'Poids (kg)',
                  icon: Icons.monitor_weight_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: AppTheme.primaryButtonStyle(radius: 12),
            onPressed: _calculateBMI,
            icon: const Icon(Icons.bar_chart_rounded, size: 20),
            label: const Text('CALCULER MON IMC',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasureField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      cursorColor: AppTheme.primary,
      style: const TextStyle(
          fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.primary),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppTheme.divider, width: 1.5)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildGaugeCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _bmiColor.withValues(alpha: 0.18),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Résultat IMC',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    _bmi.toStringAsFixed(1),
                    style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: _bmiColor,
                        height: 1),
                  ),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _bmiColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: _bmiColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Text(
                  _bmiStatus,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: _bmiColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 230,
            child: SfRadialGauge(
              enableLoadingAnimation: true,
              animationDuration: 1200,
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 10,
                  maximum: 40,
                  showLabels: true,
                  showTicks: true,
                  startAngle: 150,
                  endAngle: 30,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.12,
                    thicknessUnit: GaugeSizeUnit.factor,
                    color: Colors.grey.withValues(alpha: 0.1),
                  ),
                  ranges: <GaugeRange>[
                    GaugeRange(
                        startValue: 10,
                        endValue: 18.5,
                        color: AppTheme.bmiUnderweight,
                        startWidth: 0.12,
                        endWidth: 0.12,
                        sizeUnit: GaugeSizeUnit.factor,
                        label: 'Maigre',
                        labelStyle: const GaugeTextStyle(
                            fontSize: 9, fontWeight: FontWeight.w600)),
                    GaugeRange(
                        startValue: 18.5,
                        endValue: 25,
                        color: AppTheme.bmiNormal,
                        startWidth: 0.12,
                        endWidth: 0.12,
                        sizeUnit: GaugeSizeUnit.factor,
                        label: 'Normal',
                        labelStyle: const GaugeTextStyle(
                            fontSize: 9, fontWeight: FontWeight.w600)),
                    GaugeRange(
                        startValue: 25,
                        endValue: 30,
                        color: AppTheme.bmiOverweight,
                        startWidth: 0.12,
                        endWidth: 0.12,
                        sizeUnit: GaugeSizeUnit.factor,
                        label: 'Surpoids',
                        labelStyle: const GaugeTextStyle(
                            fontSize: 9, fontWeight: FontWeight.w600)),
                    GaugeRange(
                        startValue: 30,
                        endValue: 40,
                        color: AppTheme.bmiObese,
                        startWidth: 0.12,
                        endWidth: 0.12,
                        sizeUnit: GaugeSizeUnit.factor,
                        label: 'Obésité',
                        labelStyle: const GaugeTextStyle(
                            fontSize: 9, fontWeight: FontWeight.w600)),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: _bmi,
                      needleColor: _bmiColor,
                      needleLength: 0.7,
                      needleStartWidth: 1,
                      needleEndWidth: 5,
                      tailStyle: TailStyle(
                          length: 0.15,
                          width: 5,
                          color: _bmiColor.withValues(alpha: 0.5)),
                      knobStyle: KnobStyle(
                        color: Colors.white,
                        borderColor: _bmiColor,
                        borderWidth: 0.05,
                        knobRadius: 0.07,
                      ),
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    const GaugeAnnotation(
                      widget: SizedBox.shrink(),
                      angle: 90,
                      positionFactor: 0.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdealWeightCard() {
    double? height = double.tryParse(_heightController.text);
    if (height == null || height <= 0) return const SizedBox.shrink();

    double ideal = _getIdealWeight(height);
    double current = double.tryParse(_weightController.text) ?? 0;
    double diff = current - ideal;

    return Container(
      decoration: AppTheme.cardDecoration(shadowColor: AppTheme.primary),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.scale_rounded,
                color: AppTheme.primary, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Poids Idéal (formule Devine)',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  '${ideal.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                diff > 0
                    ? '−${diff.toStringAsFixed(1)} kg'
                    : '+${(-diff).toStringAsFixed(1)} kg',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: diff.abs() < 3
                        ? AppTheme.bmiNormal
                        : diff > 0
                            ? AppTheme.bmiOverweight
                            : AppTheme.bmiUnderweight),
              ),
              Text(
                diff > 0 ? 'à perdre' : 'à gagner',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTipsCard() {
    final tips = _getHealthTips();
    return Container(
      decoration: BoxDecoration(
        color: _bmiColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _bmiColor.withValues(alpha: 0.2), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(tips['icon']!, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tips['titre']!,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _bmiColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _tipLine(tips['conseil1']!),
          const SizedBox(height: 6),
          _tipLine(tips['conseil2']!),
          const SizedBox(height: 6),
          _tipLine(tips['conseil3']!),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _bmiColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tips['activite']!,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _bmiColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipLine(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 13,
          color: AppTheme.textPrimary,
          height: 1.4,
          fontWeight: FontWeight.w500),
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_rounded, color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text('Historique récent',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          ..._history.asMap().entries.map((entry) {
            final i = entry.key;
            final record = entry.value;
            final bool isFirst = i == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isFirst
                      ? record.color.withValues(alpha: 0.08)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isFirst
                        ? record.color.withValues(alpha: 0.3)
                        : Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: record.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          record.bmi.toStringAsFixed(1),
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: record.color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.status,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: record.color),
                          ),
                          Text(
                            '${record.height.toStringAsFixed(0)} cm · ${record.weight.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatDate(record.date),
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500),
                    ),
                    if (isFirst)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: record.color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Récent',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    return '${date.day}/${date.month}';
  }
}
