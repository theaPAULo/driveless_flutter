// lib/models/saved_address_model.dart
//
// Data models for saved addresses system
// Replicates iOS Core Data SavedAddress functionality using local storage

import 'dart:convert';

/// Enum for different types of saved addresses (matching iOS app)
enum SavedAddressType {
  home,
  work,
  custom;
  
  /// Display name for UI (matching iOS app)
  String get displayName {
    switch (this) {
      case SavedAddressType.home:
        return 'Home';
      case SavedAddressType.work:
        return 'Work'; 
      case SavedAddressType.custom:
        return 'Custom';
    }
  }
  
  /// Icon name for UI (matching iOS app design)
  String get iconName {
    switch (this) {
      case SavedAddressType.home:
        return 'home'; // Material Icons home icon
      case SavedAddressType.work:
        return 'business'; // Material Icons business icon
      case SavedAddressType.custom:
        return 'place'; // Material Icons place icon
    }
  }
  
  /// Icon color (matching iOS app green theme)
  String get colorHex {
    switch (this) {
      case SavedAddressType.home:
        return '#2E7D32'; // Green for home
      case SavedAddressType.work:
        return '#1976D2'; // Blue for work
      case SavedAddressType.custom:
        return '#7B1FA2'; // Purple for custom
    }
  }
}

/// Model class for saved addresses (matching iOS Core Data SavedAddress)
class SavedAddress {
  /// Unique identifier for the address
  final String id;
  
  /// User-friendly label (e.g., "Home", "Mom's House", "Favorite Restaurant")
  final String label;
  
  /// Complete formatted address from Google Places
  final String fullAddress;
  
  /// Business name or display name (e.g., "Starbucks" instead of full address)
  final String displayName;
  
  /// Type of address (home, work, custom)
  final SavedAddressType addressType;
  
  /// Date when address was created
  final DateTime createdDate;
  
  /// Whether this is the default address for its type
  final bool isDefault;
  
  /// Google Place ID for API calls (optional)
  final String? placeId;
  
  /// Latitude coordinate (optional, for map display)
  final double? latitude;
  
  /// Longitude coordinate (optional, for map display)
  final double? longitude;

  /// Constructor for creating a new saved address
  SavedAddress({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.displayName,
    required this.addressType,
    required this.createdDate,
    this.isDefault = false,
    this.placeId,
    this.latitude,
    this.longitude,
  });

  /// Create SavedAddress from JSON (for local storage)
  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id'] as String,
      label: json['label'] as String,
      fullAddress: json['fullAddress'] as String,
      displayName: json['displayName'] as String,
      addressType: SavedAddressType.values.firstWhere(
        (e) => e.name == json['addressType'],
        orElse: () => SavedAddressType.custom,
      ),
      createdDate: DateTime.parse(json['createdDate'] as String),
      isDefault: json['isDefault'] as bool? ?? false,
      placeId: json['placeId'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  /// Convert SavedAddress to JSON (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'fullAddress': fullAddress,
      'displayName': displayName,
      'addressType': addressType.name,
      'createdDate': createdDate.toIso8601String(),
      'isDefault': isDefault,
      'placeId': placeId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Create a copy of this address with updated fields
  SavedAddress copyWith({
    String? id,
    String? label,
    String? fullAddress,
    String? displayName,
    SavedAddressType? addressType,
    DateTime? createdDate,
    bool? isDefault,
    String? placeId,
    double? latitude,
    double? longitude,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      displayName: displayName ?? this.displayName,
      addressType: addressType ?? this.addressType,
      createdDate: createdDate ?? this.createdDate,
      isDefault: isDefault ?? this.isDefault,
      placeId: placeId ?? this.placeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  /// Format address for display in UI (matching iOS app behavior)
  /// Shows business name if available, otherwise shows abbreviated address
  String get formattedForDisplay {
    if (displayName.isNotEmpty && displayName != fullAddress) {
      return displayName;
    }
    
    // If full address is too long, show abbreviated version
    if (fullAddress.length > 50) {
      final parts = fullAddress.split(',');
      if (parts.length >= 2) {
        return '${parts[0].trim()}, ${parts[1].trim()}';
      }
    }
    
    return fullAddress;
  }

  /// Check if this address is the same as another (for deduplication)
  bool isSameLocation(SavedAddress other) {
    // First check if they have the same Place ID
    if (placeId != null && other.placeId != null) {
      return placeId == other.placeId;
    }
    
    // Fallback to coordinate comparison (within ~100m tolerance)
    if (latitude != null && longitude != null && 
        other.latitude != null && other.longitude != null) {
      final latDiff = (latitude! - other.latitude!).abs();
      final lngDiff = (longitude! - other.longitude!).abs();
      return latDiff < 0.001 && lngDiff < 0.001; // Roughly 100m tolerance
    }
    
    // Fallback to address string comparison
    return fullAddress.toLowerCase().trim() == other.fullAddress.toLowerCase().trim();
  }

  @override
  String toString() {
    return 'SavedAddress(id: $id, label: $label, type: ${addressType.displayName}, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedAddress && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}