import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/ride.dart';
import '../widgets/ride_card.dart';
import 'ride_details_screen.dart';

class RideListingsScreen extends StatefulWidget {
  final String type; // 'offers' or 'requests'
  final List<RideOffer> offers;
  final List<RideRequest> requests;
  final VoidCallback onBack;
  final VoidCallback onCreateNew;
  final Function(String id, String type) onViewDetails;

  const RideListingsScreen({
    Key? key,
    required this.type,
    required this.offers,
    required this.requests,
    required this.onBack,
    required this.onCreateNew,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  State<RideListingsScreen> createState() => _RideListingsScreenState();
}

class _RideListingsScreenState extends State<RideListingsScreen> {
  bool showFilter = false;
  String pickupFilter = '';
  String destinationFilter = '';
  String timeFilter = '';
  dynamic selectedRide;

  final List<String> locationOptions = [
    'KTS',
    'Library',
    'Residential College',
    'Campus Gate',
    'Lecture Hall A',
    'Mydin',
    'Kuala Terengganu',
  ];

  List<dynamic> getDisplayItems() {
    if (widget.type == 'offers') {
      final filtered = filterRideOffers(
        widget.offers,
        pickupFilter,
        destinationFilter,
        timeFilter,
      );
      return sortRidesByTime(filtered, (offer) => offer.time);
    } else {
      final filtered = filterRideRequests(
        widget.requests,
        pickupFilter,
        destinationFilter,
        timeFilter,
      );
      return sortRidesByTime(filtered, (request) => request.time);
    }
  }

  void clearFilters() {
    setState(() {
      pickupFilter = '';
      destinationFilter = '';
      timeFilter = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = getDisplayItems();

    return Scaffold(
      // Updated background color to match Home theme
      backgroundColor: const Color(0xFFEBF4FF),
      
      // Right-side Filter Drawer
      endDrawer: Drawer(
        width: 320,
        child: SafeArea(
          child: Column(
            children: [
              // Drawer Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
              
              // Drawer Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Pickup Location Dropdown
                      DropdownButtonFormField<String>(
                        value: pickupFilter.isEmpty ? null : pickupFilter,
                        decoration: const InputDecoration(
                          labelText: 'Pickup Location',
                          border: OutlineInputBorder(),
                        ),
                        items: locationOptions.map((location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            pickupFilter = value ?? '';
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Destination Dropdown
                      DropdownButtonFormField<String>(
                        value: destinationFilter.isEmpty ? null : destinationFilter,
                        decoration: const InputDecoration(
                          labelText: 'Destination',
                          border: OutlineInputBorder(),
                        ),
                        items: locationOptions.map((location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            destinationFilter = value ?? '';
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Time Picker
                      TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Time',
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.access_time),
                          hintText: timeFilter.isEmpty ? 'Select time' : timeFilter,
                        ),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              final hour = time.hourOfPeriod;
                              final minute = time.minute.toString().padLeft(2, '0');
                              final period = time.period == DayPeriod.am ? 'AM' : 'PM';
                              timeFilter = '$hour:$minute $period';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Drawer Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      clearFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B7280),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('Clear Filters'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Backdrop with 50% opacity when drawer is open
      drawerScrimColor: Colors.black.withOpacity(0.5),
      
      body: Stack(
        children: [
          // 1. Static Wave Background
          Positioned.fill(
            child: CustomPaint(
              painter: FluidBackgroundPainter(
                animationValue: 0.5, // Static value for non-moving waves
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            // FIX: Wrapped in Center to fix "weird not center UI" issue
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: widget.onBack,
                            icon: const Icon(Icons.arrow_back),
                            color: const Color(0xFF1F2937),
                          ),
                          Expanded(
                            child: Text(
                              widget.type == 'offers' ? 'Available Rides' : 'Ride Requests',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                            icon: const Icon(Icons.tune),
                            color: const Color(0xFF1F2937),
                          ),
                        ],
                      ),
                    ),

                    // List View
                    Expanded(
                      child: displayItems.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9), // Slightly transparent
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'No rides found. Try adjusting your filters.',
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: displayItems.length,
                              itemBuilder: (context, index) {
                                final item = displayItems[index];
                                if (widget.type == 'offers') {
                                  final offer = item as RideOffer;
                                  return RideCard(
                                    pickup: offer.pickup,
                                    destination: offer.destination,
                                    time: offer.time,
                                    seats: offer.seats,
                                    type: 'offer',
                                    onTap: () {
                                      setState(() {
                                        selectedRide = offer;
                                      });
                                      _showRideDetailsModal(context, offer, 'offer');
                                    },
                                  );
                                } else {
                                  final request = item as RideRequest;
                                  return RideCard(
                                    pickup: request.pickup,
                                    destination: request.destination,
                                    time: request.time,
                                    riders: request.riders,
                                    type: 'request',
                                    onTap: () {
                                      setState(() {
                                        selectedRide = request;
                                      });
                                      _showRideDetailsModal(context, request, 'request');
                                    },
                                  );
                                }
                              },
                            ),
                    ),

                    // Create New Button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: widget.onCreateNew,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.type == 'offers'
                                ? const Color(0xFF2B67F6)
                                : const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            widget.type == 'offers'
                                ? 'Create Ride Request'
                                : 'Create Ride Offer',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show Ride Details as Modal Dialog
  void _showRideDetailsModal(BuildContext context, dynamic ride, String type) {
    final isOffer = type == 'offer';
    final RideOffer? offer = isOffer ? ride as RideOffer : null;
    final RideRequest? request = !isOffer ? ride as RideRequest : null;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modal Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isOffer ? 'Ride Offer Details' : 'Ride Request Details',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),

              // Modal Content
              Container(
                constraints: const BoxConstraints(maxHeight: 500),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pickup
                      _buildDetailRow(
                        Icons.location_on,
                        'Pickup',
                        isOffer ? offer!.pickup : request!.pickup,
                        const Color(0xFF2B67F6),
                      ),
                      const SizedBox(height: 16),

                      // Destination
                      _buildDetailRow(
                        Icons.location_on,
                        'Destination',
                        isOffer ? offer!.destination : request!.destination,
                        const Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 16),

                      // Time
                      _buildDetailRow(
                        Icons.access_time,
                        'Time',
                        isOffer ? offer!.time : request!.time,
                        const Color(0xFF2B67F6),
                      ),
                      const SizedBox(height: 16),

                      // Seats/Riders
                      _buildDetailRow(
                        Icons.people,
                        isOffer ? 'Seats Available' : 'Riders',
                        isOffer ? '${offer!.seats}' : '${request!.riders}',
                        const Color(0xFF2B67F6),
                      ),
                      const SizedBox(height: 16),

                      // Driver/Requester
                      _buildDetailRow(
                        Icons.person,
                        isOffer ? 'Driver' : 'Requester',
                        isOffer
                            ? '${offer!.driverName} · ${offer.driverInfo}'
                            : '${request!.requesterName} · ${request.requesterInfo}',
                        const Color(0xFF2B67F6),
                      ),

                      // Cost Sharing or Notes
                      if (isOffer && offer!.costSharing != null) ...[
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.payments,
                          'Cost Sharing',
                          offer.costSharing!,
                          const Color(0xFF4CAF50),
                        ),
                      ],
                      if (!isOffer && request!.notes != null) ...[
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          Icons.note,
                          'Notes',
                          request.notes!,
                          const Color(0xFF4CAF50),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Modal Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Contact via WhatsApp
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Contact via WhatsApp'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Shared Fluid Wave Background Painter (Identical to Home) ---
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