// lib/screens/saved_addresses_screen.dart
//
// Saved addresses management screen matching iOS design
// Allows users to manage Home, Work, and Custom addresses

import 'package:flutter/material.dart';

import '../models/saved_address_model.dart';
import '../services/saved_address_service.dart';
import '../utils/constants.dart';
import 'add_address_screen.dart';

class SavedAddressesScreen extends StatefulWidget {
  final SavedAddressService addressService;

  const SavedAddressesScreen({
    Key? key,
    required this.addressService,
  }) : super(key: key);

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  @override
  void initState() {
    super.initState();
    // Listen to address service changes
    widget.addressService.addListener(_onAddressesChanged);
  }

  @override
  void dispose() {
    widget.addressService.removeListener(_onAddressesChanged);
    super.dispose();
  }

  void _onAddressesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final addresses = widget.addressService.savedAddresses;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Saved Locations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Done',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: addresses.isEmpty ? _buildEmptyState() : _buildAddressList(),
    );
  }

  // MARK: - Empty State (when no addresses saved)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty State Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.home_outlined,
                color: Color(0xFF2E7D32),
                size: 50,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Empty State Title
            const Text(
              'No Saved Addresses',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Empty State Description
            Text(
              'Save your frequently visited places like home, work, or favorite restaurants for quick route planning.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Add First Address Button
            _buildAddLocationButton(isFirstAddress: true),
          ],
        ),
      ),
    );
  }

  // MARK: - Address List (when addresses exist)
  Widget _buildAddressList() {
    final addresses = widget.addressService.savedAddresses;
    
    return Column(
      children: [
        // Header Info (showing counts)
        if (addresses.isNotEmpty) _buildHeaderInfo(),
        
        // Address List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              return _buildAddressRow(addresses[index]);
            },
          ),
        ),
        
        // Add Location Button (bottom)
        Padding(
          padding: const EdgeInsets.all(20),
          child: _buildAddLocationButton(),
        ),
      ],
    );
  }

  // MARK: - Header Info (matching iOS design)
  Widget _buildHeaderInfo() {
    final addresses = widget.addressService.savedAddresses;
    final counts = widget.addressService.addressCounts;
    final homeAndWorkCount = counts[SavedAddressType.home]! + counts[SavedAddressType.work]!;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Total Saved Count
          Column(
            children: [
              Text(
                '${addresses.length}',
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Saved',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          // Divider
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[600],
          ),
          
          // Home & Work Count
          Column(
            children: [
              Text(
                '$homeAndWorkCount',
                style: TextStyle(
                  color: homeAndWorkCount > 0 ? const Color(0xFF2E7D32) : Colors.grey[500],
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Home & Work',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - Address Row (matching iOS layout)
  Widget _buildAddressRow(SavedAddress address) {
    Color iconColor;
    IconData iconData;
    
    // Set icon and color based on address type
    switch (address.addressType) {
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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Address Type Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Address Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Address Label
                Text(
                  address.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Formatted Address
                Text(
                  address.formattedForDisplay,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Address Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    address.addressType.displayName,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Actions Menu
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.grey[500],
              size: 20,
            ),
            color: const Color(0xFF3C3C3E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _editAddress(address);
              } else if (value == 'delete') {
                _deleteAddress(address);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: Colors.grey[300],
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Edit',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - Add Location Button
  Widget _buildAddLocationButton({bool isFirstAddress = false}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _addNewAddress,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              isFirstAddress ? 'Add Your First Location' : 'Add Location',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Actions

  /// Navigate to add new address screen
  void _addNewAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(
          addressService: widget.addressService,
        ),
      ),
    );
  }

  /// Edit existing address
  void _editAddress(SavedAddress address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(
          addressService: widget.addressService,
          editingAddress: address,
        ),
      ),
    );
  }

  /// Delete address with confirmation
  void _deleteAddress(SavedAddress address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Delete Address',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${address.label}"? This action cannot be undone.',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                final success = await widget.addressService.deleteAddress(address.id);
                
                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Deleted "${address.label}"'),
                        backgroundColor: const Color(0xFF2E7D32),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to delete address'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}