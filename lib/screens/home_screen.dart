import 'dart:math' as math;
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isProfileExpanded = false;
  bool showSuccess = false;

  // --- Animation Controllers ---
  late AnimationController _animationController; 
  late AnimationController _bgController; 
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _buttonsFadeAnimation;
  late Animation<double> _profileExpandAnimation;
  
  // --- Form Controllers ---
  late TextEditingController nameController;
  late TextEditingController facultyController;
  late TextEditingController programController;
  late TextEditingController phoneNumberController;
  late TextEditingController vehicleModelController;
  late TextEditingController plateNumberController;

  String selectedRole = 'Student';
  String selectedContactMethod = 'WhatsApp';
  bool isVehicleOwner = false;
  int maxSeats = 4;

  @override
  void initState() {
    super.initState();

    // 1. Initialize Profile Animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _logoScaleAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _buttonsFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.8, curve: Curves.easeInOut)), 
    );

    _profileExpandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 2. Initialize Background Animation
    _bgController = AnimationController(
      duration: const Duration(seconds: 12), 
      vsync: this,
    )..repeat(); 

    // 3. Initialize Form Data
    nameController = TextEditingController(text: widget.profile.name);
    facultyController = TextEditingController(text: widget.profile.faculty);
    programController = TextEditingController(text: widget.profile.program ?? '');
    phoneNumberController = TextEditingController(text: widget.profile.phoneNumber);
    vehicleModelController = TextEditingController(text: widget.profile.vehicleDetails?.model ?? '');
    plateNumberController = TextEditingController(text: widget.profile.vehicleDetails?.plateNumber ?? '');

    selectedRole = widget.profile.role;
    selectedContactMethod = widget.profile.contactMethod;
    isVehicleOwner = widget.profile.isVehicleOwner;
    maxSeats = widget.profile.vehicleDetails?.maxSeats ?? 4;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bgController.dispose(); 
    nameController.dispose();
    facultyController.dispose();
    programController.dispose();
    phoneNumberController.dispose();
    vehicleModelController.dispose();
    plateNumberController.dispose();
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
        facultyController.text.trim().isEmpty ||
        phoneNumberController.text.trim().isEmpty) {
      return false;
    }
    if (selectedRole == 'Student' && programController.text.trim().isEmpty) {
      return false;
    }
    if (isVehicleOwner) {
      if (vehicleModelController.text.trim().isEmpty ||
          plateNumberController.text.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  void handleSave() {
    if (!isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final vehicleDetails = isVehicleOwner
        ? VehicleDetails(
            model: vehicleModelController.text,
            plateNumber: plateNumberController.text.toUpperCase(),
            maxSeats: maxSeats,
          )
        : null;

    final updatedProfile = UserProfile(
      id: widget.profile.id,
      name: nameController.text,
      role: selectedRole,
      faculty: facultyController.text,
      program: programController.text.isEmpty ? null : programController.text,
      contactMethod: selectedContactMethod,
      phoneNumber: phoneNumberController.text,
      isVehicleOwner: isVehicleOwner,
      vehicleDetails: vehicleDetails,
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
      backgroundColor: const Color(0xFFEBF4FF),
      body: Stack(
        children: [
          // 1. Fluid Wave Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return CustomPaint(
                  painter: FluidBackgroundPainter(
                    animationValue: _bgController.value,
                  ),
                );
              },
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    // We remove IntrinsicHeight to fix the overflow error.
                    // Instead, we use mainAxisAlignment to control positioning.
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          // When expanded: Start from top to allow scrolling.
                          // When collapsed: Center vertically for dashboard look.
                          mainAxisAlignment: isProfileExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 24),

                            // Animated Logo
                            ScaleTransition(
                              scale: _logoScaleAnimation,
                              child: Container(
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
                            
                            // Animated Buttons
                            SizeTransition(
                              sizeFactor: _buttonsFadeAnimation,
                              axisAlignment: -1.0, 
                              child: FadeTransition(
                                opacity: _buttonsFadeAnimation,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 32),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: widget.onFindRide,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF2B67F6),
                                          foregroundColor: Colors.white,
                                          elevation: 2,
                                          shadowColor: const Color(0xFF2B67F6).withOpacity(0.4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Find a Ride',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                                          elevation: 2,
                                          shadowColor: const Color(0xFF4CAF50).withOpacity(0.4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Offer a Ride',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Profile Section
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.92), 
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Header
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
                                            child: const Icon(Icons.person, color: Colors.white, size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'My Profile',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF111827),
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(
                                            isProfileExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Form
                                  SizeTransition(
                                    sizeFactor: _profileExpandAnimation,
                                    axisAlignment: -1.0,
                                    child: Column(
                                      children: [
                                        const Divider(height: 1),
                                        Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _buildSectionHeader('Personal Information', Icons.person),
                                              const SizedBox(height: 16),
                                              _buildTextField(
                                                controller: nameController,
                                                label: 'Full Name',
                                                placeholder: 'e.g., Ahmad Bin Ali',
                                              ),
                                              const SizedBox(height: 16),
                                              _buildDropdown(
                                                label: 'Role',
                                                value: selectedRole,
                                                items: const ['Student', 'Lecturer', 'Staff', 'Other'],
                                                onChanged: (val) => setState(() => selectedRole = val!),
                                              ),
                                              const SizedBox(height: 16),
                                              _buildTextField(
                                                controller: facultyController,
                                                label: 'Faculty',
                                                placeholder: 'e.g., Faculty of Computing',
                                              ),
                                              const SizedBox(height: 16),
                                              if (selectedRole == 'Student') ...[
                                                _buildTextField(
                                                  controller: programController,
                                                  label: 'Program',
                                                  placeholder: 'e.g., Computer Science',
                                                ),
                                                const SizedBox(height: 16),
                                              ],
                                              _buildTextField(
                                                controller: phoneNumberController,
                                                label: 'Phone Number',
                                                placeholder: '+60123456789',
                                                inputType: TextInputType.phone,
                                              ),
                                              const SizedBox(height: 16),
                                              _buildDropdown(
                                                label: 'Preferred Contact Method',
                                                value: selectedContactMethod,
                                                items: const ['WhatsApp', 'Telegram', 'Phone', 'SMS/Message'],
                                                onChanged: (val) => setState(() => selectedContactMethod = val!),
                                              ),
                                              const SizedBox(height: 24),

                                              _buildSectionHeader('Vehicle Information', Icons.directions_car),
                                              const SizedBox(height: 8),
                                              CheckboxListTile(
                                                value: isVehicleOwner,
                                                onChanged: (val) => setState(() => isVehicleOwner = val ?? false),
                                                title: const Text('I own a vehicle and can offer rides'),
                                                contentPadding: EdgeInsets.zero,
                                                activeColor: const Color(0xFF2B67F6),
                                                controlAffinity: ListTileControlAffinity.leading,
                                              ),
                                              if (isVehicleOwner) ...[
                                                const SizedBox(height: 16),
                                                _buildTextField(
                                                  controller: vehicleModelController,
                                                  label: 'Vehicle Model',
                                                  placeholder: 'e.g., Perodua Myvi',
                                                ),
                                                const SizedBox(height: 16),
                                                _buildTextField(
                                                  controller: plateNumberController,
                                                  label: 'License Plate',
                                                  placeholder: 'e.g., ABC 1234',
                                                  uppercase: true,
                                                ),
                                                const SizedBox(height: 16),
                                                _buildDropdown(
                                                  label: 'Max Seats',
                                                  value: maxSeats.toString(),
                                                  items: const ['1', '2', '3', '4', '5', '6', '7'],
                                                  onChanged: (val) => setState(() => maxSeats = int.parse(val!)),
                                                ),
                                              ],
                                              
                                              const SizedBox(height: 24),

                                              // Success Message
                                              AnimatedSize(
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.easeInOut,
                                                child: AnimatedOpacity(
                                                  duration: const Duration(milliseconds: 300),
                                                  opacity: showSuccess ? 1.0 : 0.0,
                                                  child: showSuccess
                                                      ? Container(
                                                          margin: const EdgeInsets.only(bottom: 16),
                                                          padding: const EdgeInsets.all(12),
                                                          width: double.infinity,
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFF4CAF50),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: const Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(Icons.check_circle, color: Colors.white, size: 20),
                                                              SizedBox(width: 8),
                                                              Text(
                                                                'Profile Saved Successfully!',
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : const SizedBox.shrink(),
                                                ),
                                              ),
                                              
                                              // Save Button
                                              SizedBox(
                                                width: double.infinity,
                                                height: 48,
                                                child: ElevatedButton.icon(
                                                  onPressed: handleSave,
                                                  icon: const Icon(Icons.save),
                                                  label: const Text('Save Profile'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF2B67F6),
                                                    foregroundColor: Colors.white,
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
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Helpers ---
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2B67F6), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    bool uppercase = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label *',
          style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: inputType,
          textCapitalization: uppercase ? TextCapitalization.characters : TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2B67F6), width: 1.5)),
          ),
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
        Text(
          '$label *',
          style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD1D5DB)), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// --- Fluid Wave Background Painter ---
class FluidBackgroundPainter extends CustomPainter {
  final double animationValue;

  FluidBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const double twoPi = 2 * math.pi;

    // Wave 1 (Back/Top)
    paint.color = const Color(0xFFBBDEFB).withOpacity(0.3);
    _drawWave(canvas, size, paint, 
      baselineY: size.height * 0.25, 
      amplitude: 20, 
      speedMultiplier: 1.0 * twoPi, 
      offset: 0
    );

    // Wave 2
    paint.color = const Color(0xFF90CAF9).withOpacity(0.3); 
    _drawWave(canvas, size, paint, 
      baselineY: size.height * 0.4, 
      amplitude: 25, 
      speedMultiplier: 1.3 * twoPi, 
      offset: math.pi / 4
    );

    // Wave 3
    paint.color = const Color(0xFF64B5F6).withOpacity(0.35); 
    _drawWave(canvas, size, paint, 
      baselineY: size.height * 0.55, 
      amplitude: 30, 
      speedMultiplier: 1.6 * twoPi, 
      offset: math.pi / 2
    );

     // Wave 4
    paint.color = const Color(0xFF42A5F5).withOpacity(0.35); 
    _drawWave(canvas, size, paint, 
      baselineY: size.height * 0.7, 
      amplitude: 35, 
      speedMultiplier: 2.0 * twoPi, 
      offset: math.pi
    );

    // Wave 5 (Front/Bottom)
    paint.color = const Color(0xFF1E88E5).withOpacity(0.4); 
    _drawWave(canvas, size, paint, 
      baselineY: size.height * 0.85, 
      amplitude: 40, 
      speedMultiplier: 2.5 * twoPi, 
      offset: math.pi * 1.5
    );
  }

  void _drawWave(Canvas canvas, Size size, Paint paint, {
    required double baselineY,
    required double amplitude,
    required double speedMultiplier,
    required double offset,
  }) {
    final path = Path();
    path.moveTo(0, baselineY);

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        baselineY +
            amplitude *
                math.sin((i / size.width * 2 * math.pi) + 
                    (animationValue * speedMultiplier) + 
                    offset),
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant FluidBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}