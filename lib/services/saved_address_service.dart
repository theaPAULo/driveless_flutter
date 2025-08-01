// lib/services/saved_address_service.dart
//
// Service for managing saved addresses with local storage
// Replicates iOS Core Data functionality using SharedPreferences

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_address_model.dart';
import '../utils/constants.dart';
import '../widgets/autocomplete_text_field.dart';

/// Service class for managing saved addresses (equivalent to iOS SavedAddressManager)
class SavedAddressService extends ChangeNotifier {
  static const String _storageKey = 'saved_addresses';
  
  /// List of all saved addresses
  List<SavedAddress> _savedAddresses = [];
  
  /// Getter for saved addresses (public access)
  List<SavedAddress> get savedAddresses => List.unmodifiable(_savedAddresses);
  
  /// Singleton instance
  static final SavedAddressService _instance = SavedAddressService._internal();
  factory SavedAddressService() => _instance;
  SavedAddressService._internal();

  /// Initialize the service and load saved addresses from storage
  Future<void> initialize() async {
    await _loadSavedAddresses();
  }

  // MARK: - Load/Save Operations

  /// Load saved addresses from local storage
  Future<void> _loadSavedAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? addressesJson = prefs.getString(_storageKey);
      
      if (addressesJson != null) {
        final List<dynamic> addressesList = json.decode(addressesJson);
        _savedAddresses = addressesList
            .map((json) => SavedAddress.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Sort addresses: Home first, Work second, then custom by creation date
        _sortAddresses();
        
        if (EnvironmentConfig.logApiCalls) {
          print('✅ Loaded ${_savedAddresses.length} saved addresses');
        }
      }
      
      notifyListeners();
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error loading saved addresses: $e');
      }
    }
  }

  /// Save all addresses to local storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String addressesJson = json.encode(
        _savedAddresses.map((address) => address.toJson()).toList(),
      );
      
      await prefs.setString(_storageKey, addressesJson);
      
      if (EnvironmentConfig.logApiCalls) {
        print('✅ Saved ${_savedAddresses.length} addresses to storage');
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error saving addresses: $e');
      }
    }
  }

  // MARK: - Address Management

  /// Add a new saved address
  /// Returns true if successful, false if duplicate or error
  Future<bool> addAddress({
    required String label,
    required String fullAddress,
    required String displayName,
    required SavedAddressType addressType,
    String? placeId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Generate unique ID
      final String id = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create new address
      final SavedAddress newAddress = SavedAddress(
        id: id,
        label: label.trim(),
        fullAddress: fullAddress.trim(),
        displayName: displayName.trim(),
        addressType: addressType,
        createdDate: DateTime.now(),
        isDefault: addressType == SavedAddressType.home, // Home is default
        placeId: placeId,
        latitude: latitude,
        longitude: longitude,
      );

      // Check for duplicates
      if (_isDuplicateAddress(newAddress)) {
        if (EnvironmentConfig.logApiCalls) {
          print('⚠️ Duplicate address not added: ${newAddress.label}');
        }
        return false;
      }

      // For Home/Work, remove existing address of same type
      if (addressType != SavedAddressType.custom) {
        _savedAddresses.removeWhere((addr) => addr.addressType == addressType);
      }

      // Add new address
      _savedAddresses.add(newAddress);
      _sortAddresses();
      
      // Save to storage
      await _saveToStorage();
      notifyListeners();

      if (EnvironmentConfig.logApiCalls) {
        print('✅ Added saved address: ${newAddress.label} (${addressType.displayName})');
      }

      return true;
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error adding address: $e');
      }
      return false;
    }
  }

  /// Update an existing saved address
  Future<bool> updateAddress(
    String addressId, {
    String? label,
    String? fullAddress,
    String? displayName,
    SavedAddressType? addressType,
    String? placeId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final int index = _savedAddresses.indexWhere((addr) => addr.id == addressId);
      if (index == -1) {
        if (EnvironmentConfig.logApiCalls) {
          print('❌ Address not found for update: $addressId');
        }
        return false;
      }

      // Create updated address
      final SavedAddress updatedAddress = _savedAddresses[index].copyWith(
        label: label,
        fullAddress: fullAddress,
        displayName: displayName,
        addressType: addressType,
        placeId: placeId,
        latitude: latitude,
        longitude: longitude,
      );

      // Check for duplicates (excluding current address)
      final List<SavedAddress> otherAddresses = _savedAddresses
          .where((addr) => addr.id != addressId)
          .toList();
      
      for (final address in otherAddresses) {
        if (updatedAddress.isSameLocation(address)) {
          if (EnvironmentConfig.logApiCalls) {
            print('⚠️ Update would create duplicate address');
          }
          return false;
        }
      }

      // Update the address
      _savedAddresses[index] = updatedAddress;
      _sortAddresses();
      
      // Save to storage
      await _saveToStorage();
      notifyListeners();

      if (EnvironmentConfig.logApiCalls) {
        print('✅ Updated saved address: ${updatedAddress.label}');
      }

      return true;
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error updating address: $e');
      }
      return false;
    }
  }

  /// Delete a saved address
  Future<bool> deleteAddress(String addressId) async {
    try {
      final int initialCount = _savedAddresses.length;
      _savedAddresses.removeWhere((addr) => addr.id == addressId);
      
      if (_savedAddresses.length < initialCount) {
        await _saveToStorage();
        notifyListeners();
        
        if (EnvironmentConfig.logApiCalls) {
          print('✅ Deleted saved address: $addressId');
        }
        return true;
      } else {
        if (EnvironmentConfig.logApiCalls) {
          print('❌ Address not found for deletion: $addressId');
        }
        return false;
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error deleting address: $e');
      }
      return false;
    }
  }

  /// Clear all saved addresses (for testing/reset)
  Future<void> clearAllAddresses() async {
    try {
      _savedAddresses.clear();
      await _saveToStorage();
      notifyListeners();
      
      if (EnvironmentConfig.logApiCalls) {
        print('✅ Cleared all saved addresses');
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error clearing addresses: $e');
      }
    }
  }

  // MARK: - Address Retrieval

  /// Get home address (null if not set)
  SavedAddress? get homeAddress {
    try {
      return _savedAddresses.firstWhere(
        (addr) => addr.addressType == SavedAddressType.home,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get work address (null if not set)
  SavedAddress? get workAddress {
    try {
      return _savedAddresses.firstWhere(
        (addr) => addr.addressType == SavedAddressType.work,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all custom addresses
  List<SavedAddress> get customAddresses {
    return _savedAddresses
        .where((addr) => addr.addressType == SavedAddressType.custom)
        .toList();
  }

  /// Get addresses by type
  List<SavedAddress> getAddressesByType(SavedAddressType type) {
    return _savedAddresses
        .where((addr) => addr.addressType == type)
        .toList();
  }

  /// Find address by ID
  SavedAddress? getAddressById(String id) {
    try {
      return _savedAddresses.firstWhere((addr) => addr.id == id);
    } catch (e) {
      return null;
    }
  }

  // MARK: - Helper Methods

  /// Check if an address would be a duplicate
  bool _isDuplicateAddress(SavedAddress newAddress) {
    for (final existingAddress in _savedAddresses) {
      if (newAddress.isSameLocation(existingAddress)) {
        return true;
      }
    }
    return false;
  }

  /// Sort addresses: Home first, Work second, custom by creation date
  void _sortAddresses() {
    _savedAddresses.sort((a, b) {
      // Home addresses first
      if (a.addressType == SavedAddressType.home && b.addressType != SavedAddressType.home) {
        return -1;
      }
      if (b.addressType == SavedAddressType.home && a.addressType != SavedAddressType.home) {
        return 1;
      }
      
      // Work addresses second
      if (a.addressType == SavedAddressType.work && b.addressType == SavedAddressType.custom) {
        return -1;
      }
      if (b.addressType == SavedAddressType.work && a.addressType == SavedAddressType.custom) {
        return 1;
      }
      
      // Within same type, sort by creation date (newest first)
      return b.createdDate.compareTo(a.createdDate);
    });
  }

  /// Convert SavedAddress to PlaceDetails for route planning integration
  PlaceDetails savedAddressToPlaceDetails(SavedAddress address) {
    return PlaceDetails(
      placeId: address.placeId ?? '',
      name: address.displayName.isNotEmpty ? address.displayName : address.label,
      formattedAddress: address.fullAddress,
      latitude: address.latitude ?? 0.0,
      longitude: address.longitude ?? 0.0,
    );
  }

  /// Create SavedAddress from PlaceDetails (for easy saving from route input)
  SavedAddress placeDetailsToSavedAddress({
    required PlaceDetails place,
    required String label,
    required SavedAddressType addressType,
  }) {
    return SavedAddress(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      fullAddress: place.formattedAddress,
      displayName: place.name,
      addressType: addressType,
      createdDate: DateTime.now(),
      isDefault: addressType == SavedAddressType.home,
      placeId: place.placeId,
      latitude: place.latitude,
      longitude: place.longitude,
    );
  }

  // MARK: - Statistics

  /// Get count of addresses by type
  Map<SavedAddressType, int> get addressCounts {
    final Map<SavedAddressType, int> counts = {
      SavedAddressType.home: 0,
      SavedAddressType.work: 0,
      SavedAddressType.custom: 0,
    };
    
    for (final address in _savedAddresses) {
      counts[address.addressType] = (counts[address.addressType] ?? 0) + 1;
    }
    
    return counts;
  }

  /// Get total count of saved addresses
  int get totalAddressCount => _savedAddresses.length;

  /// Get count of Home + Work addresses (for UI display)
  int get homeAndWorkCount {
    return _savedAddresses
        .where((addr) => addr.addressType != SavedAddressType.custom)
        .length;
  }
}