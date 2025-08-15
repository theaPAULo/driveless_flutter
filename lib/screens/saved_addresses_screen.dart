// lib/screens/saved_addresses_screen.dart
//
// Saved Addresses screen - IMPROVED SPACING & WIDTH
// ✅ FIXED: Better card width and padding for improved readability
// ✅ FIXED: Proper spacing between elements
// ✅ PRESERVES: All existing functionality - address management, types, navigation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_address_model.dart';
import '../services/saved_address_service.dart';
import '../utils/constants.dart';
import '../providers/theme_provider.dart';
import 'add_address_screen.dart';

class SavedAddressesScreen extends StatefulWidget {
  final SavedAddressService addressService;

  const SavedAddressesScreen({
    super.key,
    required this.addressService,
  });

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  @override
  void initState() {
    super.initState();
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final addresses = widget.addressService.savedAddresses;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Saved Addresses',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: addresses.isEmpty ? _buildEmptyState(themeProvider) : _buildAddressList(themeProvider, addresses),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16), // IMPROVED: Reduced padding
        child: Column(
          children: [
            _buildAddButton(themeProvider),
            
            const SizedBox(height: 40),
            
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: themeProvider.currentTheme == AppThemeMode.dark 
                        ? Colors.grey[800] 
                        : Colors.grey[100],
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 60,
                      color: themeProvider.currentTheme == AppThemeMode.dark 
                        ? Colors.grey[600] 
                        : Colors.grey[400],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'No Saved Addresses',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Add your home, work, and frequently\nvisited places for quick access.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: themeProvider.currentTheme == AppThemeMode.dark 
                        ? Colors.grey[400] 
                        : Colors.grey[600],
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList(ThemeProvider themeProvider, List<SavedAddress> addresses) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16), // IMPROVED: Reduced horizontal padding
        child: Column(
          children: [
            _buildAddButton(themeProvider),
            
            Expanded(
              child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) => _buildAddressCard(themeProvider, addresses[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // IMPROVED: Better card layout and spacing
  Widget _buildAddressCard(ThemeProvider themeProvider, SavedAddress address) {
    Color iconColor;
    IconData iconData;
    
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
      margin: const EdgeInsets.only(bottom: 12), // IMPROVED: Reduced margin
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeProvider.currentTheme == AppThemeMode.dark 
              ? Colors.black.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // IMPROVED: Increased internal padding
        child: Row(
          children: [
            // Address Type Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 20), // IMPROVED: Increased spacing
            
            // Address Info - IMPROVED: Better text layout
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6), // IMPROVED: Better spacing
                  Text(
                    address.fullAddress,
                    style: TextStyle(
                      color: themeProvider.currentTheme == AppThemeMode.dark 
                        ? Colors.grey[400] 
                        : Colors.grey[600],
                      fontSize: 15, // IMPROVED: Slightly larger text
                      height: 1.3, // IMPROVED: Better line height
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12), // IMPROVED: Space before buttons
            
            // Edit/Delete Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _editAddress(address),
                  icon: Icon(
                    Icons.edit,
                    color: themeProvider.currentTheme == AppThemeMode.dark 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: () => _deleteAddress(address),
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8), // IMPROVED: Reduced margin
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _navigateToAddAddress(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20), // IMPROVED: Consistent padding
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF34C759),
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 20), // IMPROVED: Consistent spacing
                
                Text(
                  'Add New Address',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Navigation Methods
  void _navigateToAddAddress(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(
          addressService: widget.addressService,
        ),
      ),
    );
  }

  void _editAddress(SavedAddress address) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(
          addressService: widget.addressService,
          editingAddress: address, // FIXED: Correct parameter name
        ),
      ),
    );
  }

  void _deleteAddress(SavedAddress address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete "${address.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.addressService.deleteAddress(address.id); // FIXED: Correct method name
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}