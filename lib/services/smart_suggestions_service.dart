// lib/services/smart_suggestions_service.dart
//
// 🧠 Smart Address Suggestions Service
// ✅ Learn from user's most-used locations
// ✅ Provide intelligent autocomplete suggestions
// ✅ Track usage frequency and recency

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Address usage data for smart suggestions
class AddressUsage {
  final String address;
  final String displayName;
  final int usageCount;
  final DateTime lastUsed;
  final DateTime firstUsed;
  
  const AddressUsage({
    required this.address,
    required this.displayName,
    required this.usageCount,
    required this.lastUsed,
    required this.firstUsed,
  });
  
  /// Calculate relevance score (0.0 to 1.0)
  double get relevanceScore {
    const double maxDaysForRecency = 30.0;
    const double recencyWeight = 0.4;
    const double frequencyWeight = 0.6;
    
    // Recency score (higher for more recent)
    final daysSinceLastUse = DateTime.now().difference(lastUsed).inDays.toDouble();
    final recencyScore = (maxDaysForRecency - daysSinceLastUse.clamp(0, maxDaysForRecency)) / maxDaysForRecency;
    
    // Frequency score (logarithmic scale to prevent dominance)
    final frequencyScore = (usageCount / (usageCount + 5)).clamp(0.0, 1.0);
    
    return (recencyScore * recencyWeight + frequencyScore * frequencyWeight).clamp(0.0, 1.0);
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'displayName': displayName,
      'usageCount': usageCount,
      'lastUsed': lastUsed.toIso8601String(),
      'firstUsed': firstUsed.toIso8601String(),
    };
  }
  
  /// Create from JSON
  factory AddressUsage.fromJson(Map<String, dynamic> json) {
    return AddressUsage(
      address: json['address'] ?? '',
      displayName: json['displayName'] ?? '',
      usageCount: json['usageCount'] ?? 0,
      lastUsed: DateTime.tryParse(json['lastUsed'] ?? '') ?? DateTime.now(),
      firstUsed: DateTime.tryParse(json['firstUsed'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Smart address suggestions service
class SmartSuggestionsService extends ChangeNotifier {
  static final SmartSuggestionsService _instance = SmartSuggestionsService._internal();
  factory SmartSuggestionsService() => _instance;
  SmartSuggestionsService._internal();
  
  static const String _storageKey = 'smart_address_suggestions';
  static const int _maxSuggestions = 50; // Limit to prevent excessive storage
  
  List<AddressUsage> _addressHistory = [];
  bool _initialized = false;
  
  /// Initialize the service
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      await _loadAddressHistory();
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Smart suggestions initialization error: $e');
      }
      _addressHistory = [];
      _initialized = true;
    }
  }
  
  /// Record usage of an address
  Future<void> recordAddressUsage(String address, String displayName) async {
    await initialize();
    
    if (address.trim().isEmpty || displayName.trim().isEmpty) return;
    
    final cleanAddress = address.trim();
    final cleanDisplayName = displayName.trim();
    
    // Find existing entry or create new one
    final existingIndex = _addressHistory.indexWhere(
      (usage) => usage.address.toLowerCase() == cleanAddress.toLowerCase(),
    );
    
    if (existingIndex != -1) {
      // Update existing entry
      final existing = _addressHistory[existingIndex];
      _addressHistory[existingIndex] = AddressUsage(
        address: cleanAddress,
        displayName: cleanDisplayName,
        usageCount: existing.usageCount + 1,
        lastUsed: DateTime.now(),
        firstUsed: existing.firstUsed,
      );
    } else {
      // Add new entry
      _addressHistory.add(AddressUsage(
        address: cleanAddress,
        displayName: cleanDisplayName,
        usageCount: 1,
        lastUsed: DateTime.now(),
        firstUsed: DateTime.now(),
      ));
    }
    
    // Limit storage and remove oldest/least used entries
    _trimAddressHistory();
    
    await _saveAddressHistory();
    notifyListeners();
  }
  
  /// Get smart suggestions for a query
  List<AddressUsage> getSuggestions(String query, {int limit = 5}) {
    if (!_initialized || query.trim().isEmpty) return [];
    
    final cleanQuery = query.trim().toLowerCase();
    
    // Filter and score suggestions
    final candidates = _addressHistory
        .where((usage) =>
            usage.displayName.toLowerCase().contains(cleanQuery) ||
            usage.address.toLowerCase().contains(cleanQuery))
        .toList();
    
    // Sort by relevance score (highest first)
    candidates.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    
    return candidates.take(limit).toList();
  }
  
  /// Get top frequent addresses
  List<AddressUsage> getTopAddresses({int limit = 10}) {
    if (!_initialized) return [];
    
    final sorted = List<AddressUsage>.from(_addressHistory);
    sorted.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    
    return sorted.take(limit).toList();
  }
  
  /// Clear all address history
  Future<void> clearHistory() async {
    _addressHistory.clear();
    await _saveAddressHistory();
    notifyListeners();
  }
  
  /// Remove specific address from history
  Future<void> removeAddress(String address) async {
    _addressHistory.removeWhere(
      (usage) => usage.address.toLowerCase() == address.toLowerCase(),
    );
    await _saveAddressHistory();
    notifyListeners();
  }
  
  /// Get statistics
  Map<String, int> getStatistics() {
    return {
      'totalAddresses': _addressHistory.length,
      'totalUsages': _addressHistory.fold(0, (sum, usage) => sum + usage.usageCount),
      'uniqueAddresses': _addressHistory.map((u) => u.address.toLowerCase()).toSet().length,
    };
  }
  
  /// Trim address history to prevent excessive storage
  void _trimAddressHistory() {
    if (_addressHistory.length <= _maxSuggestions) return;
    
    // Sort by relevance score and keep top entries
    _addressHistory.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    _addressHistory = _addressHistory.take(_maxSuggestions).toList();
  }
  
  /// Load address history from storage
  Future<void> _loadAddressHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        _addressHistory = jsonList
            .map((json) => AddressUsage.fromJson(json as Map<String, dynamic>))
            .toList();
            
        // Clean up old entries (older than 90 days with low usage)
        _cleanupOldEntries();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading address history: $e');
      }
      _addressHistory = [];
    }
  }
  
  /// Save address history to storage
  Future<void> _saveAddressHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _addressHistory.map((usage) => usage.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving address history: $e');
      }
    }
  }
  
  /// Clean up old entries with low usage
  void _cleanupOldEntries() {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
    
    _addressHistory.removeWhere((usage) {
      final isOld = usage.lastUsed.isBefore(cutoffDate);
      final hasLowUsage = usage.usageCount < 3;
      return isOld && hasLowUsage;
    });
  }
}

/// Global instance for easy access
final smartSuggestions = SmartSuggestionsService();