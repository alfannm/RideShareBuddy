import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ride.dart';
import '../models/user.dart';

class CreateOfferScreen extends StatefulWidget {
  final UserProfile? userProfile;
  final VoidCallback onBack;
  final Function(RideOffer) onSubmit;

  const CreateOfferScreen({
    Key? key,
    required this.userProfile,
    required this.onBack,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String pickup = '';
  String destination = '';
  String time = '';
  int seats = 1;
  bool isFree = true;
  String costAmount = '';

  final List<String> locationOptions = [
    'KTS', 'Library', 'Residential College', 'Campus Gate', 
    'Lecture Hall A', 'Mydin', 'Kuala Terengganu',
  ];

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    return null;
  }

  String? validateSeats(String? value) {
    if (value == null || value.isEmpty) return 'Seats is required';
    if (int.tryParse(value) == null) return 'Invalid number';
    return null;
  }

  void handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (time.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a time'), backgroundColor: Colors.red),
        );
        return;
      }
      _formKey.currentState!.save();

      final offer = RideOffer(
        pickup: pickup,
        destination: destination,
        time: time,
        seats: seats,
        driverName: widget.userProfile?.name ?? 'Anonymous',
        driverInfo: widget.userProfile?.getContactInfo() ?? 'No contact info',
        costSharing: isFree ? 'Free' : 'RM$costAmount',
      );

      widget.onSubmit(offer);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ride offer created!'), backgroundColor: Color(0xFF4CAF50)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF4FF), // Match Theme
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
                // --- STICKY HEADER (Outside ScrollView) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back),
                        color: const Color(0xFF1F2937),
                      ),
                      const Expanded(
                        child: Text(
                          'Create Ride Offer',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- SCROLLABLE FORM ---
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Pickup Location', border: OutlineInputBorder()),
                              items: locationOptions.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                              validator: (v) => validateRequired(v, 'Pickup location'),
                              onSaved: (v) => pickup = v ?? '',
                              onChanged: (v) => pickup = v ?? '',
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Destination', border: OutlineInputBorder()),
                              items: locationOptions.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                              validator: (v) => validateRequired(v, 'Destination'),
                              onSaved: (v) => destination = v ?? '',
                              onChanged: (v) => destination = v ?? '',
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Departure Time',
                                border: const OutlineInputBorder(),
                                suffixIcon: const Icon(Icons.access_time),
                                hintText: time.isEmpty ? 'Select time' : time,
                              ),
                              onTap: () async {
                                final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                if (t != null) {
                                  setState(() {
                                    time = t.format(context); // Simple format
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Available Seats', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              initialValue: '1',
                              validator: validateSeats,
                              onSaved: (v) => seats = int.parse(v ?? '1'),
                            ),
                            const SizedBox(height: 16),
                            const Text('Cost Sharing', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => isFree = true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isFree ? const Color(0xFF2B67F6) : Colors.white,
                                        border: Border.all(color: isFree ? const Color(0xFF2B67F6) : const Color(0xFFE5E7EB)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('Free', textAlign: TextAlign.center, style: TextStyle(color: isFree ? Colors.white : const Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => isFree = false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: !isFree ? const Color(0xFF2B67F6) : Colors.white,
                                        border: Border.all(color: !isFree ? const Color(0xFF2B67F6) : const Color(0xFFE5E7EB)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('Cost-Sharing', textAlign: TextAlign.center, style: TextStyle(color: !isFree ? Colors.white : const Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (!isFree) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                decoration: const InputDecoration(labelText: 'Cost Amount (RM)', border: OutlineInputBorder(), prefixText: 'RM '),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (v) => (!isFree && (v == null || v.isEmpty)) ? 'Cost required' : null,
                                onSaved: (v) => costAmount = v ?? '',
                              ),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Create Offer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
    _drawWave(canvas, size, paint, baselineY: size.height * 0.25, amplitude: 20, speedMultiplier: 1.0 * twoPi, offset: 0);
    // Wave 2
    paint.color = const Color(0xFF90CAF9).withOpacity(0.3);
    _drawWave(canvas, size, paint, baselineY: size.height * 0.4, amplitude: 25, speedMultiplier: 1.3 * twoPi, offset: math.pi / 4);
    // Wave 3
    paint.color = const Color(0xFF64B5F6).withOpacity(0.35);
    _drawWave(canvas, size, paint, baselineY: size.height * 0.55, amplitude: 30, speedMultiplier: 1.6 * twoPi, offset: math.pi / 2);
    // Wave 4
    paint.color = const Color(0xFF42A5F5).withOpacity(0.35);
    _drawWave(canvas, size, paint, baselineY: size.height * 0.7, amplitude: 35, speedMultiplier: 2.0 * twoPi, offset: math.pi);
    // Wave 5 (Front/Bottom)
    paint.color = const Color(0xFF1E88E5).withOpacity(0.4);
    _drawWave(canvas, size, paint, baselineY: size.height * 0.85, amplitude: 40, speedMultiplier: 2.5 * twoPi, offset: math.pi * 1.5);
  }

  void _drawWave(Canvas canvas, Size size, Paint paint, {required double baselineY, required double amplitude, required double speedMultiplier, required double offset}) {
    final path = Path();
    path.moveTo(0, baselineY);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(i, baselineY + amplitude * math.sin((i / size.width * 2 * math.pi) + (animationValue * speedMultiplier) + offset));
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant FluidBackgroundPainter oldDelegate) => oldDelegate.animationValue != animationValue;
}