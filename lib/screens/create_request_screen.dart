import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ride.dart';
import '../models/user.dart';

class CreateRequestScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final VoidCallback onBack;
  final Function(RideRequest) onSubmit;

  const CreateRequestScreen({
    Key? key,
    required this.userProfile,
    required this.onBack,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  String pickup = '';
  String destination = '';
  String time = '';
  int riders = 1;
  String notes = '';

  final List<String> locationOptions = [
    'KTS',
    'Library',
    'Residential College',
    'Campus Gate',
    'Lecture Hall A',
    'Mydin',
    'Kuala Terengganu',
  ];

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    return null;
  }

  String? validateRiders(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (int.tryParse(value) == null) return 'Invalid';
    return null;
  }

  void handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (time.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select a time'),
              backgroundColor: Colors.red),
        );
        return;
      }
      _formKey.currentState!.save();

      final request = RideRequest(
        pickup: pickup,
        destination: destination,
        time: time,
        riders: riders,
        requesterName: widget.userProfile?.name ?? 'Anonymous',
        requesterInfo:
            widget.userProfile?.getContactInfo() ?? 'No contact info',
        notes: notes.isEmpty ? null : notes,
      );

      widget.onSubmit(request);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Request created successfully!'),
            backgroundColor: Color(0xFF4CAF50)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF4FF),
      body: Stack(
        children: [
          // 1. Static Wave Background
          Positioned.fill(
            child: CustomPaint(
              painter: FluidBackgroundPainter(animationValue: 0.5),
            ),
          ),

          // 2. Main Layout
          SafeArea(
            child: Column(
              children: [
                // --- STICKY HEADER ---
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ]),
                        child: IconButton(
                          onPressed: widget.onBack,
                          icon: const Icon(Icons.arrow_back),
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Create Request',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- SCROLLABLE FORM ---
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Trip Details'),
                            const SizedBox(height: 16),
                            _buildDropdownField(
                              label: 'Pickup Location',
                              value: pickup.isEmpty ? null : pickup,
                              items: locationOptions,
                              onChanged: (v) =>
                                  setState(() => pickup = v ?? ''),
                              validator: (v) => validateRequired(v, 'Pickup'),
                              icon: Icons.my_location,
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownField(
                              label: 'Destination',
                              value: destination.isEmpty ? null : destination,
                              items: locationOptions,
                              onChanged: (v) =>
                                  setState(() => destination = v ?? ''),
                              validator: (v) =>
                                  validateRequired(v, 'Destination'),
                              icon: Icons.location_on,
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Time & Riders'),
                            const SizedBox(height: 16),
                            _buildDateTimeField(
                              label: 'Needed By',
                              value: time,
                              placeholder: 'Select time',
                              icon: Icons.access_time_filled,
                              onTap: () async {
                                final t = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now());
                                if (t != null) {
                                  setState(() => time = t.format(context));
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              label: 'Number of Riders',
                              initialValue: '1',
                              inputType: TextInputType.number,
                              validator: validateRiders,
                              onSaved: (v) => riders = int.parse(v ?? '1'),
                              icon: Icons.people,
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Extra Info'),
                            const SizedBox(height: 16),
                            _buildInputField(
                              label: 'Additional Notes',
                              placeholder: 'e.g., Heavy luggage...',
                              icon: Icons.note,
                              maxLines: 3,
                              onSaved: (v) => notes = v ?? '',
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                      0xFF2B67F6), // Request uses Blue
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor:
                                      const Color(0xFF2B67F6).withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text(
                                  'Create Request',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Reuse Helper Widgets ---
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
    );
  }

  Widget _buildInputField({
    required String label,
    String? placeholder,
    String? initialValue,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
    Function(String?)? onSaved,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ${validator != null ? "*" : ""}',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          keyboardType: inputType,
          maxLines: maxLines,
          inputFormatters: inputType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : [],
          decoration: _inputDecoration(placeholder, icon),
          validator: validator,
          onSaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required String value,
    required String placeholder,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label *',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          decoration:
              _inputDecoration(value.isEmpty ? placeholder : value, icon)
                  .copyWith(
            hintStyle: TextStyle(
                color: value.isEmpty ? Colors.grey[400] : Colors.black87),
          ),
          onTap: onTap,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String? Function(String?)? validator,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label *',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700])),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down),
          decoration: _inputDecoration('Select', icon),
          items: items
              .map((l) => DropdownMenuItem(value: l, child: Text(l)))
              .toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String? hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2B67F6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}

// --- Shared Fluid Wave Background Painter ---
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
        offset: 0);
    // Wave 2
    paint.color = const Color(0xFF90CAF9).withOpacity(0.3);
    _drawWave(canvas, size, paint,
        baselineY: size.height * 0.4,
        amplitude: 25,
        speedMultiplier: 1.3 * twoPi,
        offset: math.pi / 4);
    // Wave 3
    paint.color = const Color(0xFF64B5F6).withOpacity(0.35);
    _drawWave(canvas, size, paint,
        baselineY: size.height * 0.55,
        amplitude: 30,
        speedMultiplier: 1.6 * twoPi,
        offset: math.pi / 2);
    // Wave 4
    paint.color = const Color(0xFF42A5F5).withOpacity(0.35);
    _drawWave(canvas, size, paint,
        baselineY: size.height * 0.7,
        amplitude: 35,
        speedMultiplier: 2.0 * twoPi,
        offset: math.pi);
    // Wave 5 (Front/Bottom)
    paint.color = const Color(0xFF1E88E5).withOpacity(0.4);
    _drawWave(canvas, size, paint,
        baselineY: size.height * 0.85,
        amplitude: 40,
        speedMultiplier: 2.5 * twoPi,
        offset: math.pi * 1.5);
  }

  void _drawWave(Canvas canvas, Size size, Paint paint,
      {required double baselineY,
      required double amplitude,
      required double speedMultiplier,
      required double offset}) {
    final path = Path();
    path.moveTo(0, baselineY);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
          i,
          baselineY +
              amplitude *
                  math.sin((i / size.width * 2 * math.pi) +
                      (animationValue * speedMultiplier) +
                      offset));
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant FluidBackgroundPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
