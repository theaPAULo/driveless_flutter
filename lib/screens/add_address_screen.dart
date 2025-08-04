// lib/screens/add_address_screen.dart
//
// Add or edit saved address screen with Google Places integration
// Allows users to add Home, Work, or Custom addresses

import 'package:flutter/material.dart';

import '../models/saved_address_model.dart';
import '../services/saved_address_service.dart';
import '../widgets/autocomplete_text_field.dart';
import '../utils/constants.dart';

class AddAddressScreen extends StatefulWidget {
  final SavedAddressService addressService;
  final SavedAddress? editingAddress; // null for new address, populated for editing

  const AddAddressScreen({
    Key? key,
    required this.addressService,
    this.editingAddress,
  }) : super(key: key);

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  // Form controllers
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  
  // Form state
  SavedAddressType _selectedType = SavedAddressType.home;
  PlaceDetails? _selectedPlace;
  bool _isSaving = false;
  
  // Focus nodes
  final FocusNode _labelFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    
    // If editing, populate fields with existing data
    if (widget.editingAddress != null) {
      final address = widget.editingAddress!;
      _selectedType = address.addressType;
      _labelController.text = address.label;
      _addressController.text = address.displayName.isNotEmpty 
          ? address.displayName 
          : address.fullAddress;
      
      // Create PlaceDetails from saved address
      _selectedPlace = PlaceDetails(
        placeId: address.placeId ?? '',
        name: address.displayName,
        formattedAddress: address.fullAddress,
        latitude: address.latitude ?? 0.0,
        longitude: address.longitude ?? 0.0,
      );
    } else {
      // For new addresses, set default label based on type
      _updateDefaultLabel();
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _labelController.dispose();
    _labelFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingAddress != null;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'Edit Address' : 'Add Address',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _canSave() && !_isSaving ? _saveAddress : null,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: _canSave() ? const Color(0xFF2E7D32) : Colors.grey[600],
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address Type Selection
            _buildAddressTypeSection(),
            
            const SizedBox(height: 24),
            
            // Address Search Field
            _buildAddressSearchSection(),
            
            const SizedBox(height: 24),
            
            // Label Input Field
            _buildLabelSection(),
            
            const SizedBox(height: 32),
            
            // Info Card
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  // MARK: - Address Type Selection
  Widget _buildAddressTypeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Address Type',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Address Type Options
          ...SavedAddressType.values.map((type) => _buildAddressTypeOption(type)),
        ],
      ),
    );
  }

  Widget _buildAddressTypeOption(SavedAddressType type) {
    final isSelected = _selectedType == type;
    Color iconColor;
    IconData iconData;
    
    switch (type) {
      case SavedAddressType.home:
        iconColor = const Color(0xFF2E7D32);
        iconData = Icons.home;
        break;
      case SavedAddressType.work:
        iconColor = const Color(0xFF1976D2);
        iconData = Icons.business;
        break;
      case SavedAddressType.custom:
        iconColor = const Color(0xFF7B1FA2);
        iconData = Icons.place;
        break;
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _updateDefaultLabel();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? iconColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? iconColor : Colors.grey[700]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Type Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Type Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[300],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _getTypeDescription(type),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection Indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: iconColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  String _getTypeDescription(SavedAddressType type) {
    switch (type) {
      case SavedAddressType.home:
        return 'Your primary residence';
      case SavedAddressType.work:
        return 'Your workplace or office';
      case SavedAddressType.custom:
        return 'Any other location';
    }
  }

  // MARK: - Address Search Section
  Widget _buildAddressSearchSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Address',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Google Places Autocomplete Field
          AutocompleteTextField(
            controller: _addressController,
            hint: 'Search for an address...',
            icon: Icons.search,
            iconColor: const Color(0xFF2E7D32),
            onPlaceSelected: (PlaceDetails place) {
              setState(() {
                _selectedPlace = place;
                // If label is still default, update it with place name
                if (_isDefaultLabel()) {
                  _labelController.text = place.name.isNotEmpty 
                      ? place.name 
                      : _selectedType.displayName;
                }
              });
            },
          ),
          
          // Selected Place Info
          if (_selectedPlace != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF2E7D32).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.place,
                    color: const Color(0xFF2E7D32),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedPlace!.name.isNotEmpty)
                          Text(
                            _selectedPlace!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        Text(
                          _selectedPlace!.formattedAddress,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // MARK: - Label Section
  Widget _buildLabelSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Label',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Give this address a friendly name',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Label Input Field
          TextField(
            controller: _labelController,
            focusNode: _labelFocusNode,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. "Mom\'s House", "Favorite Restaurant"',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
              filled: true,
              fillColor: const Color(0xFF3C3C3E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2E7D32),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  // MARK: - Info Card
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFF2E7D32),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Saved addresses can be quickly selected when planning routes, making it easier to navigate to your frequent destinations.',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Helper Methods

  /// Update default label based on selected type
  void _updateDefaultLabel() {
    if (_isDefaultLabel() || _labelController.text.isEmpty) {
      _labelController.text = _selectedType.displayName;
    }
  }

  /// Check if current label is a default label
  bool _isDefaultLabel() {
    final currentText = _labelController.text.trim();
    return currentText.isEmpty || 
           SavedAddressType.values.any((type) => type.displayName == currentText);
  }

  /// Check if form can be saved
  bool _canSave() {
    return _selectedPlace != null && 
           _labelController.text.trim().isNotEmpty &&
           !_isSaving;
  }

  /// Save the address
  Future<void> _saveAddress() async {
    if (!_canSave()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final label = _labelController.text.trim();
      final place = _selectedPlace!;

      bool success;
      
      if (widget.editingAddress != null) {
        // Update existing address
        success = await widget.addressService.updateAddress(
          widget.editingAddress!.id,
          label: label,
          fullAddress: place.formattedAddress,
          displayName: place.name,
          addressType: _selectedType,
          placeId: place.placeId,
          latitude: place.latitude,
          longitude: place.longitude,
        );
      } else {
        // Add new address
        success = await widget.addressService.addAddress(
          label: label,
          fullAddress: place.formattedAddress,
          displayName: place.name,
          addressType: _selectedType,
          placeId: place.placeId,
          latitude: place.latitude,
          longitude: place.longitude,
        );
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.editingAddress != null
                    ? 'Address updated successfully'
                    : 'Address saved successfully',
              ),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to ${widget.editingAddress != null ? 'update' : 'save'} address. It may already exist.',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('Error saving address: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}