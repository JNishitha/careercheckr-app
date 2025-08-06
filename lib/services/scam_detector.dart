class ScamDetector {
  static const List<String> scamKeywords = [
    "quick money",
    "registration fee",
    "investment",
    "no interview",
    "pay first",
    "cash app",
    "bitcoin",
    "mlm",
    "urgent requirement",
    "sms job",
    "easy income",
    "work from home - no experience",
    "entry fee",
    "limited seats",
  ];

  static bool isGibberish(String text) {
    // If text is too short or contains no real words
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length < 5) return true;

    int longWords = words.where((w) => w.length > 3).length;
    return longWords < 3; // Most words are short/random
  }

  static int scamScore(String title, String company, String description) {
    final combinedText = "$title $company $description".toLowerCase();

    if (isGibberish(combinedText)) {
      return -1; // invalid input flag
    }

    int matches = 0;
    for (final keyword in scamKeywords) {
      if (combinedText.contains(keyword)) {
        matches++;
      }
    }

    if (scamKeywords.isEmpty) return 0;
    final score = (matches / scamKeywords.length) * 100;
    return score.round();
  }

  static String scamRiskLabel(int score) {
    if (score == -1) return 'Invalid';
    if (score >= 60) return 'High Risk';
    if (score >= 30) return 'Medium Risk';
    if (score > 0) return 'Low Risk';
    return 'No Risk';
  }

  static bool isScam(String title, String company, String description) {
    final score = scamScore(title, company, description);
    return score >= 30;
  }

  static List<String> matchedKeywords(String title, String company, String description) {
    final combinedText = "$title $company $description".toLowerCase();
    return scamKeywords.where((keyword) => combinedText.contains(keyword)).toList();
  }

  static Map<String, dynamic> analyze(String title, String company, String description) {
    final score = scamScore(title, company, description);

    if (score == -1) {
      return {
        'score': -1,
        'risk': 'Invalid',
        'message': 'Please enter a valid job description.',
        'keywords': [],
      };
    }

    return {
      'score': score,
      'risk': scamRiskLabel(score),
      'keywords': matchedKeywords(title, company, description),
    };
  }
}
