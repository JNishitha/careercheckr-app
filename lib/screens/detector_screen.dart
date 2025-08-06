// screens/detector_screen.dart
import 'package:flutter/material.dart';
import 'package:careercheckr/constants/colors.dart';
import 'package:careercheckr/widgets/career_bottom_nav.dart';
import 'package:careercheckr/services/scam_detector.dart';
import 'package:careercheckr/utils/history_utils.dart';

class DetectorScreen extends StatefulWidget {
  const DetectorScreen({Key? key}) : super(key: key);

  @override
  State<DetectorScreen> createState() => _DetectorScreenState();
}

class _DetectorScreenState extends State<DetectorScreen>
    with TickerProviderStateMixin {
  final TextEditingController _jobDescController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  late AnimationController _resultController;
  late AnimationController _pulseController;
  late Animation<double> _resultAnimation;
  late Animation<double> _pulseAnimation;

  String _result = '';
  bool _isLoading = false;
  int _scamScore = 0;
  String _scamLabel = '';
  bool? _isCorporateEmail;

  @override
  void initState() {
    super.initState();
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _resultAnimation = CurvedAnimation(
      parent: _resultController,
      curve: Curves.elasticOut,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _resultController.dispose();
    _pulseController.dispose();
    _jobDescController.dispose();
    _companyController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _analyzeText() async {
    final jobTitle = _titleController.text.trim();
    final company = _companyController.text.trim();
    final description = _jobDescController.text.trim();

    if (description.isEmpty) {
      _showSnackBar('Please enter a job description.', AppColors.warning);
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
      _scamScore = 0;
      _scamLabel = '';
    });

    // Add a realistic delay for analysis
    await Future.delayed(const Duration(seconds: 2));

    final analysis = ScamDetector.analyze(jobTitle, company, description);
    final score = analysis['score'] as int;
    final label = analysis['risk'] as String;
    final corporate = _isCorporateDomain(company);

    setState(() {
      _scamScore = score;
      _scamLabel = label;
      _isCorporateEmail = corporate;
      _result = _generateOfflineVerdict(score, label);
      _isLoading = false;
    });

    // Save the scan result to history
    if (score != -1 && label != 'Please enter a valid description') {
      try {
        // Determine status for history
        final status = (score >= 30) ? "Scam" : "Real";
        
        // Create a meaningful description for history
        final historyDescription = jobTitle.isNotEmpty 
            ? "$jobTitle${company.isNotEmpty ? ' at $company' : ''}"
            : description.length > 100 
                ? description.substring(0, 100) + "..."
                : description;

        await HistoryUtils.saveScan(
          status: status,
          description: historyDescription,
        );
        
        debugPrint('Scan saved to history: $status - $historyDescription');
        
        // Show a subtle confirmation
        _showSnackBar('Scan saved to history', AppColors.safe);
      } catch (e) {
        debugPrint('Error saving scan to history: $e');
      }
    }

    _resultController.forward();
  }

  String _generateOfflineVerdict(int score, String label) {
    if (score == -1 || label == 'Please enter a valid description') {
      return "⚠️ Please enter a valid and meaningful job description to analyze.";
    }

    if (score == 0) {
      return "✅ This job description appears clean and does not contain typical scam indicators.";
    } else {
      return "⚠️ $label of scam detected.\n\nThe job description contains $score% match with known scam phrases. Proceed with caution and verify the employer.";
    }
  }

  bool _isCorporateDomain(String emailOrDomain) {
    if (!emailOrDomain.contains('@')) return false;
    final domain = emailOrDomain.split('@').last.toLowerCase();
    final personalDomains = ['gmail.com', 'yahoo.com', 'outlook.com', 'protonmail.com'];
    return !personalDomains.contains(domain);
  }

  Color getRiskColor() {
    switch (_scamLabel) {
      case 'High Risk':
        return AppColors.danger;
      case 'Medium Risk':
        return AppColors.warning;
      case 'Low Risk':
        return AppColors.accent;
      case 'No Risk':
        return AppColors.safe;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  IconData getRiskIcon() {
    switch (_scamLabel) {
      case 'High Risk':
        return Icons.dangerous_rounded;
      case 'Medium Risk':
        return Icons.warning_rounded;
      case 'Low Risk':
        return Icons.info_rounded;
      case 'No Risk':
        return Icons.verified_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.surfaceGradient,
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(24.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildInputForm(),
                  const SizedBox(height: 24),
                  _buildAnalyzeButton(),
                  const SizedBox(height: 32),
                  if (_result.isNotEmpty) _buildResultSection(),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CareerBottomNav(currentIndex: 2),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: const FlexibleSpaceBar(
          centerTitle: false,
          titlePadding: EdgeInsets.only(left: 24, bottom: 16),
          title: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Scam Detector',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Analysis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the job details below for comprehensive analysis',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _titleController,
            label: 'Job Title',
            hint: 'e.g. Marketing Intern',
            icon: Icons.work_outline_rounded,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _companyController,
            label: 'Company Email / Domain',
            hint: 'e.g. hr@company.com',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _jobDescController,
            label: 'Job Description',
            hint: 'Paste the complete job/internship details here...',
            icon: Icons.description_outlined,
            maxLines: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isLoading ? _pulseAnimation.value : 1.0,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: _isLoading ? null : AppColors.primaryGradient,
              color: _isLoading ? AppColors.onSurfaceVariant : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isLoading ? [] : AppColors.buttonShadow,
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _analyzeText,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Analyzing...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Analyze Job',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultSection() {
    return ScaleTransition(
      scale: _resultAnimation,
      child: Column(
        children: [
          if (_scamLabel.isNotEmpty) _buildRiskIndicator(),
          const SizedBox(height: 16),
          if (_isCorporateEmail != null) _buildEmailValidation(),
          const SizedBox(height: 16),
          _buildResultCard(),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator() {
    final color = getRiskColor();
    final icon = getRiskIcon();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Risk Level: $_scamLabel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  'Confidence Score: $_scamScore%',
                  style: TextStyle(
                    fontSize: 14,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_scamScore%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailValidation() {
    final isValid = _isCorporateEmail!;
    final color = isValid ? AppColors.safe : AppColors.warning;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.verified_rounded : Icons.warning_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isValid
                  ? 'Corporate Email Domain Detected'
                  : 'Personal Email Domain - Proceed with Caution',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Analysis Result',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _result,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}