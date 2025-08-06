import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class HistoryUtils {
  static const String _historyKey = 'scan_history';
  static const int _maxHistoryItems = 100; // Limit history to prevent storage bloat

  /// Save a new scan entry to history
  static Future<bool> saveScan({
    required String status,
    required String description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];

      // Create the entry with timestamp, status, and description
      final entry = '${DateTime.now().toIso8601String()}|$status|${description.trim()}';

      // Add to beginning of list (most recent first)
      history.insert(0, entry);

      // Keep only the most recent items to prevent storage bloat
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      // Save back to SharedPreferences
      final success = await prefs.setStringList(_historyKey, history);
      
      if (success) {
        debugPrint('✅ Scan saved to history: $status - ${description.substring(0, description.length > 50 ? 50 : description.length)}...');
      } else {
        debugPrint('❌ Failed to save scan to history');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ Error saving scan to history: $e');
      return false;
    }
  }

  /// Load all scan history
  static Future<List<String>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      debugPrint('📚 Loaded ${history.length} history items');
      return history;
    } catch (e) {
      debugPrint('❌ Error loading history: $e');
      return [];
    }
  }

  /// Clear all scan history
  static Future<bool> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_historyKey);
      
      if (success) {
        debugPrint('🗑️ History cleared successfully');
      } else {
        debugPrint('❌ Failed to clear history');
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ Error clearing history: $e');
      return false;
    }
  }

  /// Get history count
  static Future<int> getHistoryCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      return history.length;
    } catch (e) {
      debugPrint('❌ Error getting history count: $e');
      return 0;
    }
  }

  /// Delete a specific history entry by index
  static Future<bool> deleteHistoryEntry(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      
      if (index >= 0 && index < history.length) {
        history.removeAt(index);
        final success = await prefs.setStringList(_historyKey, history);
        
        if (success) {
          debugPrint('🗑️ History entry at index $index deleted');
        }
        
        return success;
      } else {
        debugPrint('❌ Invalid history index: $index');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error deleting history entry: $e');
      return false;
    }
  }

  /// Get history statistics
  static Future<Map<String, int>> getHistoryStats() async {
    try {
      final history = await loadHistory();
      int realCount = 0;
      int scamCount = 0;
      
      for (final entry in history) {
        final parts = entry.split('|');
        if (parts.length >= 2) {
          final status = parts[1];
          if (status == 'Real') {
            realCount++;
          } else if (status == 'Scam') {
            scamCount++;
          }
        }
      }
      
      return {
        'total': history.length,
        'real': realCount,
        'scam': scamCount,
      };
    } catch (e) {
      debugPrint('❌ Error getting history stats: $e');
      return {'total': 0, 'real': 0, 'scam': 0};
    }
  }

  /// Parse a history entry into components
  static Map<String, dynamic>? parseHistoryEntry(String entry) {
    try {
      final parts = entry.split('|');
      if (parts.length >= 3) {
        return {
          'timestamp': DateTime.parse(parts[0]),
          'status': parts[1],
          'description': parts[2],
        };
      }
    } catch (e) {
      debugPrint('❌ Error parsing history entry: $e');
    }
    return null;
  }

  /// Export history as a formatted string (for future backup/export features)
  static Future<String> exportHistory() async {
    try {
      final history = await loadHistory();
      final buffer = StringBuffer();
      buffer.writeln('CareerCheckr Scan History Export');
      buffer.writeln('Generated: ${DateTime.now()}');
      buffer.writeln('Total Scans: ${history.length}');
      buffer.writeln('=' * 50);
      
      for (int i = 0; i < history.length; i++) {
        final parsed = parseHistoryEntry(history[i]);
        if (parsed != null) {
          buffer.writeln('\nScan #${i + 1}:');
          buffer.writeln('Date: ${parsed['timestamp']}');
          buffer.writeln('Result: ${parsed['status']}');
          buffer.writeln('Description: ${parsed['description']}');
          buffer.writeln('-' * 30);
        }
      }
      
      return buffer.toString();
    } catch (e) {
      debugPrint('❌ Error exporting history: $e');
      return 'Error exporting history';
    }
  }
}