// lib/screens/saved_addresses_screen.dart
//
// ✨ ENHANCED Saved Addresses Screen with Professional Empty States
// ✅ UPDATED: Uses new EnhancedEmptyState system for better UX
// ✅ PRESERVES: All existing functionality, address management, types
// ✅ ADDS: Engaging empty state with tips for address management

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_address_model.dart';
import '../services/saved_address_service.dart';
import '../utils/constants.dart';
import '../providers/theme_provider.dart';
import '../widgets/empty_states.dart'; // CORRECTED: Import the right file
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
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: addresses.isNotEmpty ? [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            onPressed: () => _navigateToAddAddress(),
          ),
        ] : null,
      ),
      body: addresses.isEmpty 
        ? _buildEnhancedEmptyState(themeProvider) 
        : _buildAddressList(themeProvider, addresses),
    );
  }

  // ✨ NEW: Enhanced Empty State (replacing basic empty state)
  Widget _buildEnhancedEmptyState(ThemeProvider themeProvider) {
    return EnhancedEmptyState(
      type: EmptyStateType.savedAddresses,
      onActionPressed: () => _navigateToAddAddress(),
      // Optional: Add secondary action for help/tutorials
      showSecondaryAction: true,
      secondaryActionText: 'Learn More',
      onSecondaryActionPressed: () {
        _showAddressHelpDialog();
      },
    );
  }

  // PRESERVED: Address List (exactly the same functionality)
  Widget _buildAddressList(ThemeProvider themeProvider, List<SavedAddress> addresses) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildStatsHeader(themeProvider, addresses),
            
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

  // NEW: Stats Header (similar to route history)
  Widget _buildStatsHeader(ThemeProvider themeProvider, List<SavedAddress> addresses) {
    final homeCount = addresses.where((addr) => addr.addressType == SavedAddressType.home).length;
    final workCount = addresses.where((addr) => addr.addressType == SavedAddressType.work).length;
    final customCount = addresses.where((addr) => addr.addressType == SavedAddressType.custom).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.currentTheme == AppThemeMode.dark 
          ? Colors.grey[800]?.withOpacity(0.3) 
          : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '${addresses.length}',
                  style: const TextStyle(
                    color: Color(0xFF007AFF),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total\nAddresses',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: themeProvider.currentTheme == AppThemeMode.dark 
              ? Colors.grey[600] 
              : Colors.grey[300],
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$homeCount + $workCount',
                  style: const TextStyle(
                    color: Color(0xFF007AFF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Home &\nWork',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: themeProvider.currentTheme == AppThemeMode.dark 
              ? Colors.grey[600] 
              : Colors.grey[300],
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$customCount',
                  style: const TextStyle(
                    color: Color(0xFF007AFF),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Custom\nPlaces',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PRESERVED: Address Card (same styling and functionality)
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
      margin: const EdgeInsets.only(bottom: 12),
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
        padding: const EdgeInsets.all(20),
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
            
            const SizedBox(width: 20),
            
            // Address Info
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
                  const SizedBox(height: 6),
                  Text(
                    address.fullAddress,
                    style: TextStyle(
                      color: themeProvider.currentTheme == AppThemeMode.dark 
                        ? Colors.grey[400] 
                        : Colors.grey[600],
                      fontSize: 15,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Delete Action only (edit not supported)
            IconButton(
              onPressed: () => _confirmDeleteAddress(address),
              icon: Icon(
                Icons.delete,
                color: Colors.red.withOpacity(0.7),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PRESERVED: Navigation and action methods
  void _navigateToAddAddress() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(
          addressService: widget.addressService,
        ),
      ),
    );
  }

  void _confirmDeleteAddress(SavedAddress address) {
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
              Navigator.of(context).pop();
              _deleteAddress(address);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteAddress(SavedAddress address) {
    widget.addressService.deleteAddress(address.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${address.label} deleted'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            widget.addressService.addAddress(
              label: address.label,
              fullAddress: address.fullAddress,
              displayName: address.displayName,
              addressType: address.addressType,
              placeId: address.placeId,
              latitude: address.latitude,
              longitude: address.longitude,
            );
          },
        ),
      ),
    );
  }

  // NEW: Help dialog for address tips
  void _showAddressHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Address Tips'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Add your home and work addresses for quick route planning'),
            SizedBox(height: 8),
            Text('• Save frequently visited places like restaurants, shops, and gyms'),
            SizedBox(height: 8),
            Text('• Use custom labels to easily identify locations'),
            SizedBox(height: 8),
            Text('• Saved addresses will appear as quick-select buttons when planning routes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToAddAddress();
            },
            child: const Text('Add Address'),
          ),
        ],
      ),
    );
  }
}