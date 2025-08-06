import 'package:flutter/material.dart';
import 'package:careercheckr/widgets/career_bottom_nav.dart';
import 'package:careercheckr/services/scam_detector.dart';
import 'package:careercheckr/utils/url_helper.dart';
import 'package:careercheckr/utils/history_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();

  String _result = "";
  bool _isLoading = false;
  bool _isScam = false;

  @override
  void dispose() {
    _jobController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _checkFakeOrReal() async {
    final description = _jobController.text.trim();
    final company = _companyController.text.trim();

    if (description.isEmpty) {
      _showMessage("Please paste a job/internship description.");
      return;
    }

    setState(() {
      _isLoading = true;
      _result = "";
      _isScam = false;
    });

    try {
      // Add a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));
      
      final combinedText = "Unknown Job $company $description";
      final scamScore = ScamDetector.scamScore(combinedText, _companyController.text.trim(), _jobController.text.trim());
      final riskLabel = ScamDetector.scamRiskLabel(scamScore);
      final scamDetected = scamScore >= 30;

      setState(() {
        _isScam = scamDetected;
        _result = scamDetected
            ? "⚠️ $riskLabel: This may be a fake internship/job. (Scam Score: $scamScore)"
            : "✅ This seems like a real opportunity. (Scam Score: $scamScore)";
      });

      // Save the scan result to history
      await _saveScanToHistory(scamDetected, description, company, scamScore);

    } catch (e) {
      _showMessage("Something went wrong. Please try again.");
      debugPrint("Analysis error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveScanToHistory(bool isScam, String description, String company, int scamScore) async {
    try {
      final status = isScam ? "Scam" : "Real";
      
      // Create a meaningful description for history
      String historyDescription;
      if (company.isNotEmpty) {
        historyDescription = "Job at $company";
        if (description.length > 50) {
          historyDescription += " - ${description.substring(0, 50)}...";
        }
      } else {
        historyDescription = description.length > 100 
            ? description.substring(0, 100) + "..."
            : description;
      }

      await HistoryUtils.saveScan(
        status: status,
        description: historyDescription,
      );
      
      debugPrint('Scan saved to history from home screen: $status - Score: $scamScore');
      
      // Show a subtle success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis saved to history'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      debugPrint('Error saving scan to history: $e');
    }
  }

  void _searchOnGoogle() {
    final company = _companyController.text.trim();
    if (company.isEmpty) {
      _showMessage("Please enter a company name.");
      return;
    }
    searchCompany(company);
  }

  void _clearFields() {
    setState(() {
      _jobController.clear();
      _companyController.clear();
      _result = "";
      _isScam = false;
    });
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/auth');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checklist = [
      "🔎 Check for a company website",
      "📧 Official email (avoid Gmail/Yahoo)",
      "💰 No upfront fees",
      "📝 Clear job/internship duties",
      "📞 Contact info available",
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('CareerCheckr'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_result.isNotEmpty)
            IconButton(
              onPressed: _clearFields,
              icon: const Icon(Icons.clear),
              tooltip: 'Clear Results',
            ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Paste any job or internship description below and let CareerCheckr analyze it.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            
            // Company Name Field
            const Text(
              'Company Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _companyController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'e.g. Google, Infosys, etc.',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                prefixIcon: const Icon(Icons.business_rounded),
              ),
            ),
            const SizedBox(height: 20),
            
            // Job Description Field
            const Text(
              'Paste Job/Internship Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _jobController,
              enabled: !_isLoading,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Paste the full job or internship details here...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                prefixIcon: const Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _checkFakeOrReal,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white, 
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(Icons.search, color: Colors.white),
                    label: Text(
                      _isLoading ? "Analyzing..." : "Analyze",
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _searchOnGoogle,
                    icon: const Icon(Icons.open_in_new, color: Colors.white),
                    label: const Text("Google", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Results Section
            if (_result.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: _isScam ? Colors.red : Colors.green, 
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (_isScam ? Colors.red : Colors.green).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      _isScam ? Icons.warning_rounded : Icons.verified_rounded,
                      color: _isScam ? Colors.red : Colors.green,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _result,
                      style: TextStyle(
                        fontSize: 16,
                        color: _isScam ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            
            // Safety Checklist
            const Text(
              "🔐 Scam Protection Checklist:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: checklist
                    .map((point) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_outline, 
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  point,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick Access to Other Features
            if (_result.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/history'),
                            icon: const Icon(Icons.history_rounded, size: 18),
                            label: const Text('View History'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.blue.shade200,
                        ),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/tips'),
                            icon: const Icon(Icons.tips_and_updates_rounded, size: 18),
                            label: const Text('Safety Tips'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const CareerBottomNav(currentIndex: 0),
    );
  }
}