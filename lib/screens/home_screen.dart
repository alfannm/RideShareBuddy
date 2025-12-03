// Screen 1: HOME/DASHBOARD with Collapsible Profile

import 'package:flutter/material.dart';
import '../models/user.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onFindRide;
  final VoidCallback onOfferRide;
  final UserProfile profile;
  final Function(UserProfile) onSaveProfile;

  const HomeScreen({
    Key? key,
    required this.onFindRide,
    required this.onOfferRide,
    required this.profile,
    required this.onSaveProfile,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool isProfileExpanded = false;
  bool showSuccess = false;
  
  // Profile form controllers
  late TextEditingController nameController;
  late TextEditingController programController;
  late TextEditingController contactValueController;
  late TextEditingController vehicleModelController;
  late TextEditingController vehiclePlateController;
  
  String selectedContactMethod = 'WhatsApp';
  bool hasVehicle = false;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with profile data
    nameController = TextEditingController(text: widget.profile.name);
    programController = TextEditingController(text: widget.profile.program);
    contactValueController = TextEditingController(text: widget.profile.contactValue);
    vehicleModelController = TextEditingController(text: widget.profile.vehicleModel ?? '');
    vehiclePlateController = TextEditingController(text: widget.profile.vehiclePlate ?? '');
    
    selectedContactMethod = widget.profile.contactMethod;
    hasVehicle = widget.profile.hasVehicle;
    
    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.75).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    programController.dispose();
    contactValueController.dispose();
    vehicleModelController.dispose();
    vehiclePlateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void toggleProfile() {
    setState(() {
      isProfileExpanded = !isProfileExpanded;
      if (isProfileExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  bool isFormValid() {
    if (nameController.text.trim().isEmpty ||
        programController.text.trim().isEmpty ||
        contactValueController.text.trim().isEmpty) {
      return false;
    }
    
    if (hasVehicle) {
      if (vehicleModelController.text.trim().isEmpty ||
          vehiclePlateController.text.trim().isEmpty) {
        return false;
      }
    }
    
    return true;
  }

  void handleSave() {
    if (!isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final updatedProfile = UserProfile(
      name: nameController.text,
      program: programController.text,
      contactMethod: selectedContactMethod,
      contactValue: contactValueController.text,
      hasVehicle: hasVehicle,
      vehicleModel: hasVehicle ? vehicleModelController.text : null,
      vehiclePlate: hasVehicle ? vehiclePlateController.text.toUpperCase() : null,
    );
    
    widget.onSaveProfile(updatedProfile);
    
    setState(() {
      showSuccess = true;
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showSuccess = false;
          isProfileExpanded = false;
          _animationController.reverse();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Logo with animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 320,
                        height: 320,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 320,
                            height: 320,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2B67F6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              size: 120,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons (hidden when profile is expanded)
                  if (!isProfileExpanded) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: widget.onFindRide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B67F6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Find a Ride',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: widget.onOfferRide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Offer a Ride',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                  
                  // Profile Section - Collapsible
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Profile Header Button
                        InkWell(
                          onTap: toggleProfile,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2B67F6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'My Profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  isProfileExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: const Color(0xFF6B7280),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Collapsible Profile Content
                        if (isProfileExpanded) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Success Message
                                if (showSuccess)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4CAF50),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Profile updated successfully!',
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                
                                // Personal Information Section
                                _buildSectionHeader('Personal Information', Icons.person),
                                const SizedBox(height: 16),
                                
                                _buildTextField(
                                  controller: nameController,
                                  label: 'Full Name',
                                  placeholder: 'e.g., Ahmad Bin Ali',
                                ),
                                const SizedBox(height: 16),
                                
                                _buildTextField(
                                  controller: programController,
                                  label: 'Program',
                                  placeholder: 'e.g., Computer Science',
                                ),
                                const SizedBox(height: 16),
                                
                                _buildTextField(
                                  controller: contactValueController,
                                  label: 'Phone Number',
                                  placeholder: '+60123456789',
                                ),
                                const SizedBox(height: 16),
                                
                                _buildDropdown(
                                  label: 'Preferred Contact Method',
                                  value: selectedContactMethod,
                                  items: ['WhatsApp', 'Telegram', 'Phone Call', 'SMS/Message'],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedContactMethod = value!;
                                    });
                                  },
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Vehicle Information Section
                                _buildSectionHeader('Vehicle Information', Icons.directions_car),
                                const SizedBox(height: 16),
                                
                                CheckboxListTile(
                                  value: hasVehicle,
                                  onChanged: (value) {
                                    setState(() {
                                      hasVehicle = value!;
                                    });
                                  },
                                  title: const Text('I own a vehicle and can offer rides'),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: const Color(0xFF2B67F6),
                                ),
                                
                                if (hasVehicle) ...[
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: vehicleModelController,
                                    label: 'Vehicle Model',
                                    placeholder: 'e.g., Perodua Myvi',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: vehiclePlateController,
                                    label: 'License Plate Number',
                                    placeholder: 'e.g., TER 1234',
                                    uppercase: true,
                                  ),
                                ],
                                
                                const SizedBox(height: 24),
                                
                                // Save Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: isFormValid() ? handleSave : null,
                                    icon: const Icon(Icons.save),
                                    label: const Text(
                                      'Save Profile',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2B67F6),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.grey[300],
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: icon == Icons.person ? const Color(0xFF2B67F6) : const Color(0xFF4CAF50),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    bool uppercase = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textCapitalization: uppercase ? TextCapitalization.characters : TextCapitalization.none,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2B67F6), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              borderRadius: BorderRadius.circular(12),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
