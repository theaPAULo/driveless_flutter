// lib/services/saved_address_service.dart
//
// Service for managing saved addresses with Firestore cloud storage
// Replaces SharedPreferences with Firebase Firestore for cross-device sync
// Maintains backward compatibility and offline support

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/saved_address_model.dart';
import '../utils/constants.dart';
import '../widgets/autocomplete_text_field.dart';

/// Service class for managing saved addresses with Firestore backend
class SavedAddressService extends ChangeNotifier {
  static const String _localStorageKey = 'saved_addresses';
  
  /// List of all saved addresses
  List<SavedAddress> _savedAddresses = [];
  
  /// Getter for saved addresses (public access)
  List<SavedAddress> get savedAddresses => List.unmodifiable(_savedAddresses);
  
  /// Singleton instance
  static final SavedAddressService _instance = SavedAddressService._internal();
  factory SavedAddressService() => _instance;
  SavedAddressService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize the service and load saved addresses
  Future<void> initialize() async {
    await _loadSavedAddresses();
  }

  // MARK: - Load/Save Operations

  /// Load saved addresses from Firestore (with local fallback)
  Future<void> _loadSavedAddresses() async {
    try {
      final User? currentUser = _auth.currentUser;
      
      if (currentUser != null) {
        // User is signed in - try to load from Firestore
        await _loadFromFirestore(currentUser.uid);
      } else {
        // User not signed in - load from local storage
        await _loadFromLocalStorage();
      }
      
      // Sort addresses: Home first, Work second, then custom by creation date
      _sortAddresses();
      
      if (EnvironmentConfig.logApiCalls) {
        print('✅ Loaded ${_savedAddresses.length} saved addresses');
      }
      
      notifyListeners();
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error loading saved addresses: $e');
      }
      // Fallback to local storage on any error
      await _loadFromLocalStorage();
      notifyListeners();
    }
  }

  /// Load addresses from Firestore
  Future<void> _loadFromFirestore(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_addresses')
          .orderBy('createdDate', descending: false)
          .get();
      
      _savedAddresses = snapshot.docs
          .map((doc) => SavedAddress.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
      
      if (EnvironmentConfig.logApiCalls) {
        print('✅ Loaded ${_savedAddresses.length} addresses from Firestore');
      }
      
      // Also save to local storage as backup
      await _saveToLocalStorage();
      
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error loading from Firestore: $e');
      }
      throw e; // Re-throw to trigger local storage fallback
    }
  }

  /// Load addresses from local storage (fallback)
  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? addressesJson = prefs.getString(_localStorageKey);
      
      if (addressesJson != null) {
        final List<dynamic> addressesList = json.decode(addressesJson);
        _savedAddresses = addressesList
            .map((json) => SavedAddress.fromJson(json as Map<String, dynamic>))
            .toList();
        
        if (EnvironmentConfig.logApiCalls) {
          print('✅ Loaded ${_savedAddresses.length} addresses from local storage');
        }
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error loading from local storage: $e');
      }
    }
  }

  /// Save all addresses to both Firestore and local storage
  Future<void> _saveAddresses() async {
    final User? currentUser = _auth.currentUser;
    
    // Always save to local storage as backup
    await _saveToLocalStorage();
    
    // If user is signed in, also save to Firestore
    if (currentUser != null) {
      await _saveToFirestore(currentUser.uid);
    }
  }

  /// Save addresses to Firestore
  Future<void> _saveToFirestore(String userId) async {
    try {
      final WriteBatch batch = _firestore.batch();
      final CollectionReference addressCollection = _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_addresses');
      
      // First, get existing documents to delete them
      final QuerySnapshot existingDocs = await addressCollection.get();
      for (QueryDocumentSnapshot doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }
      
      // Add all current addresses
      for (SavedAddress address in _savedAddresses) {
        final DocumentReference docRef = addressCollection.doc(address.id);
        final Map<String, dynamic> data = address.toJson();
        data.remove('id'); // Don't store ID in document data
        batch.set(docRef, data);
      }
      
      // Commit the batch
      await batch.commit();
      
      if (EnvironmentConfig.logApiCalls) {
        print('✅ Saved ${_savedAddresses.length} addresses to Firestore');
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error saving to Firestore: $e');
      }
      // Don't throw - local storage still works
    }
  }

  /// Save addresses to local storage (backup)
  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String addressesJson = json.encode(
        _savedAddresses.map((address) => address.toJson()).toList(),
      );
      
      await prefs.setString(_localStorageKey, addressesJson);
      
      if (EnvironmentConfig.logApiCalls) {
        print('✅ Saved ${_savedAddresses.length} addresses to local storage');
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error saving to local storage: $e');
      }
    }
  }

  /// Migrate existing local addresses to Firestore (one-time operation)
  Future<void> migrateLocalAddressesToFirestore() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      if (EnvironmentConfig.logApiCalls) {
        print('⚠️ Cannot migrate: user not signed in');
      }
      return;
    }
    
    try {
      // Check if user already has addresses in Firestore
      final QuerySnapshot existing = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('saved_addresses')
          .limit(1)
          .get();
      
      if (existing.docs.isNotEmpty) {
        if (EnvironmentConfig.logApiCalls) {
          print('ℹ️ User already has Firestore addresses, skipping migration');
        }
        return;
      }
      
      // Load local addresses
      await _loadFromLocalStorage();
      
      if (_savedAddresses.isNotEmpty) {
        // Save to Firestore
        await _saveToFirestore(currentUser.uid);
        
        if (EnvironmentConfig.logApiCalls) {
          print('✅ Migrated ${_savedAddresses.length} addresses to Firestore');
        }
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error during migration: $e');
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
      
      // Save to storage (both local and Firestore)
      await _saveAddresses();
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
      
      // Save to storage (both local and Firestore)
      await _saveAddresses();
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
        await _saveAddresses();
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
      await _saveAddresses();
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
        (address) => address.addressType == SavedAddressType.home,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get work address (null if not set)
  SavedAddress? get workAddress {
    try {
      return _savedAddresses.firstWhere(
        (address) => address.addressType == SavedAddressType.work,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all custom addresses
  List<SavedAddress> get customAddresses {
    return _savedAddresses
        .where((address) => address.addressType == SavedAddressType.custom)
        .toList();
  }

  /// Get address by ID
  SavedAddress? getAddressById(String id) {
    try {
      return _savedAddresses.firstWhere((address) => address.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search addresses by label or address text
  List<SavedAddress> searchAddresses(String query) {
    if (query.isEmpty) return savedAddresses;
    
    final String lowercaseQuery = query.toLowerCase();
    return _savedAddresses.where((address) {
      return address.label.toLowerCase().contains(lowercaseQuery) ||
             address.fullAddress.toLowerCase().contains(lowercaseQuery) ||
             address.displayName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // MARK: - Helper Methods

  /// Check if address is a duplicate
  bool _isDuplicateAddress(SavedAddress newAddress) {
    for (final address in _savedAddresses) {
      if (newAddress.isSameLocation(address)) {
        return true;
      }
    }
    return false;
  }

  /// Sort addresses: Home first, Work second, then custom by creation date
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
      
      // Within same type, sort by creation date (newest first for custom)
      if (a.addressType == SavedAddressType.custom && b.addressType == SavedAddressType.custom) {
        return b.createdDate.compareTo(a.createdDate);
      }
      
      return 0;
    });
  }

  // MARK: - Authentication Integration

  /// Handle user sign in - migrate local addresses to Firestore
  Future<void> onUserSignIn() async {
    await migrateLocalAddressesToFirestore();
    await _loadSavedAddresses(); // Reload to get latest data
  }

  /// Handle user sign out - keep local copy
  Future<void> onUserSignOut() async {
    // Just save current addresses to local storage
    await _saveToLocalStorage();
    
    if (EnvironmentConfig.logApiCalls) {
      print('ℹ️ User signed out, addresses saved locally');
    }
  }

  // MARK: - Utility Methods (for UI compatibility)

  /// Convert SavedAddress to PlaceDetails format (for route input compatibility)
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

  /// Get count of addresses by type (required by SavedAddressesScreen)
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
  
  /// Get count by type
  int get homeAddressCount => _savedAddresses.where((a) => a.addressType == SavedAddressType.home).length;
  int get workAddressCount => _savedAddresses.where((a) => a.addressType == SavedAddressType.work).length;
  int get customAddressCount => _savedAddresses.where((a) => a.addressType == SavedAddressType.custom).length;
}