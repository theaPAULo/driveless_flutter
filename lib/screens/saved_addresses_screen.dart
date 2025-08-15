// lib/screens/saved_addresses_screen.dart
//
// Saved Addresses screen - CONSERVATIVE Theme Update
// ✅ PRESERVES: All existing functionality - address management, types, navigation
// ✅ CHANGES: Only hardcoded colors to use theme provider
// ✅ KEEPS: All logic, methods, UI structure, and behavior identical

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_address_model.dart';
import '../services/saved_address_service.dart';
import '../utils/constants.dart';
import '../providers/theme_provider.dart'; // NEW: Only for theme colors
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
    // PRESERVED: Listen to address service changes - EXACT SAME LOGIC
    widget.addressService.addListener(_onAddressesChanged);
  }

  @override
  void dispose() {
    // PRESERVED: Remove listener - EXACT SAME LOGIC
    widget.addressService.removeListener(_onAddressesChanged);
    super.dispose();
  }

  /// PRESERVED: Address change handler - EXACT SAME LOGIC
  void _onAddressesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme provider for colors only
    final themeProvider = Provider.of<ThemeProvider>(context);
    final addresses = widget.addressService.savedAddresses;
    
    return Scaffold(
      // CHANGED: Theme-aware background instead of Colors.black
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // CHANGED: Theme-aware app bar instead of Colors.black
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, 
            // CHANGED: Theme-aware icon color instead of Colors.white
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Saved Locations',
          style: TextStyle(
            // CHANGED: Theme-aware text color instead of Colors.white
            color: Theme.of(context).textTheme.bodyLarge?.color,
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
                color: Color(0xFF34C759), // PRESERVED: Brand green for action button
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: addresses.isEmpty ? _buildEmptyState(themeProvider) : _buildContent(addresses, themeProvider),
    );
  }

  // MARK: - Empty State - PRESERVED LOGIC, UPDATED COLORS
  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF34C759).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.home,
                color: Color(0xFF34C759),
                size: 50,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'No Saved Addresses',
              style: TextStyle(
                // CHANGED: Theme-aware text color
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Add your home, work, and frequently visited places for quick access when planning routes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                // CHANGED: Theme-aware secondary text color
                color: themeProvider.currentTheme == AppThemeMode.dark 
                  ? Colors.grey[400] 
                  : Colors.grey[600],
                fontSize: 16,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: () => _navigateToAddAddress(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34C759),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Main Content - PRESERVED STRUCTURE
  Widget _buildContent(List<SavedAddress> addresses, ThemeProvider themeProvider) {
    return Column(
      children: [
        _buildStatsHeader(addresses, themeProvider),
        Expanded(
          child: _buildAddressList(addresses, themeProvider),
        ),
      ],
    );
  }

  // MARK: - Stats Header - PRESERVED LOGIC, UPDATED COLORS
  Widget _buildStatsHeader(List<SavedAddress> addresses, ThemeProvider themeProvider) {
    final homeWorkCount = addresses.where((addr) => 
      addr.addressType == SavedAddressType.home || 
      addr.addressType == SavedAddressType.work
    ).length;
    
    final customCount = addresses.where((addr) => 
      addr.addressType == SavedAddressType.custom
    ).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // CHANGED: Theme-aware card color
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Total Addresses
          Expanded(
            child: Column(
              children: [
                Text(
                  addresses.length.toString(),
                  style: const TextStyle(
                    color: Color(0xFF34C759),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total\nAddresses',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // CHANGED: Theme-aware secondary text color
                    color: themeProvider.currentTheme == AppThemeMode.dark 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          
          // Home & Work
          Expanded(
            child: Column(
              children: [
                Text(
                  homeWorkCount.toString(),
                  style: TextStyle(
                    color: homeWorkCount > 0 ? const Color(0xFF34C759) : 
                      (themeProvider.currentTheme == AppThemeMode.dark 
                        ? Colors.grey[500] 
                        : Colors.grey[400]),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Home & Work',
                  style: TextStyle(
                    // CHANGED: Theme-aware secondary text color
                    color: themeProvider.currentTheme == AppThemeMode.dark 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Custom Locations
          Expanded(
            child: Column(
              children: [
                Text(
                  customCount.toString(),
                  style: TextStyle(
                    color: customCount > 0 ? const Color(0xFF34C759) : 
                      (themeProvider.currentTheme == AppThemeMode.dark 
                        ? Colors.grey[500] 
                        : Colors.grey[400]),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Custom\nLocations',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    // CHANGED: Theme-aware secondary text color
                    color: themeProvider.currentTheme == AppThemeMode.dark 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
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

  // MARK: - Address List - PRESERVED LOGIC, UPDATED COLORS
  Widget _buildAddressList(List<SavedAddress> addresses, ThemeProvider themeProvider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: addresses.length + 1, // +1 for add button
      itemBuilder: (context, index) {
        if (index == addresses.length) {
          return _buildAddButton(themeProvider);
        }
        return _buildAddressRow(addresses[index], themeProvider);
      },
    );
  }

  // MARK: - Address Row - PRESERVED LOGIC, UPDATED COLORS
  Widget _buildAddressRow(SavedAddress address, ThemeProvider themeProvider) {
    Color iconColor;
    IconData iconData;
    
    // PRESERVED: Set icon and color based on address type - EXACT SAME LOGIC
    switch (address.addressType) {
      case SavedAddressType.home:
        iconColor = const Color(0xFF34C759);
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
        // CHANGED: Theme-aware card color instead of hardcoded dark
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // CHANGED: Theme-aware shadow
            color: themeProvider.currentTheme == AppThemeMode.dark 
              ? Colors.black.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Address Type Icon - PRESERVED: Same logic for icon/color
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
          
          const SizedBox(width: 16),
          
          // Address Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.label,
                  style: TextStyle(
                    // CHANGED: Theme-aware text color
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address.fullAddress, // FIXED: Use fullAddress instead of formattedAddress
                  style: TextStyle(
                    // CHANGED: Theme-aware secondary text color
                    color: themeProvider.currentTheme == AppThemeMode.dark 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Edit/Delete Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _editAddress(address),
                icon: Icon(
                  Icons.edit,
                  // CHANGED: Theme-aware icon color
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
    );
  }

  // MARK: - Add Button - PRESERVED LOGIC, UPDATED COLORS
  Widget _buildAddButton(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, top: 8),
      child: Material(
        // CHANGED: Theme-aware card color
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _navigateToAddAddress(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
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
                
                const SizedBox(width: 16),
                
                Text(
                  'Add New Address',
                  style: TextStyle(
                    // CHANGED: Theme-aware text color
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

  // MARK: - Navigation Methods - PRESERVED EXACT LOGIC

  /// PRESERVED: Navigate to add address screen - EXACT SAME LOGIC
  void _navigateToAddAddress(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(
          addressService: widget.addressService,
        ),
      ),
    );
  }

  /// PRESERVED: Edit address - EXACT SAME LOGIC
  void _editAddress(SavedAddress address) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(
          addressService: widget.addressService,
          existingAddress: address,
        ),
      ),
    );
  }

  /// PRESERVED: Delete address with confirmation - EXACT SAME LOGIC
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
              widget.addressService.removeAddress(address);
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