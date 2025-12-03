import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ride.dart';
import '../widgets/ride_card.dart';
// import 'ride_details_screen.dart'; // No longer needed

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
  bool showFilterBar = false;
  String pickupFilter = '';
  String destinationFilter = '';
  String timeFilter = '';
  dynamic selectedRide;

  // UMT Locations List
  final List<String> locationOptions = [
    'Faculty of Computer Science and Mathematics',
    'Faculty of Fisheries and Food Science',
    'Faculty of Ocean Engineering Technology',
    'Faculty of Maritime Studies',
    'Faculty of Business, Economics and Social Development',
    'Faculty of Science and Marine Environment',
    'DSM', 'Kolej Kediaman', 'Kafe Limbong', 'KKSAM', 'Pusat Sukan dan Rekreasi',
    'Kompleks Siswa', 'PISM', 'PSNZ', 'INOS', 'AKUATROP', 'PPAL',
    'UMTCC', 'Makmal Berpusat', 'Kompleks Kuliah Berpusat',
  ];

  List<dynamic> getDisplayItems() {
    if (widget.type == 'offers') {
      final filtered = filterRideOffers(widget.offers, pickupFilter, destinationFilter, timeFilter);
      return sortRidesByTime(filtered, (offer) => offer.time);
    } else {
      final filtered = filterRideRequests(widget.requests, pickupFilter, destinationFilter, timeFilter);
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
      backgroundColor: const Color(0xFFEBF4FF),
      body: Stack(
        children: [
          // 1. Static Wave Background
          Positioned.fill(
            child: CustomPaint(
              painter: FluidBackgroundPainter(animationValue: 0.5),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // --- HEADER ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      // Back Button (White Circle)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]
                        ),
                        child: IconButton(
                          onPressed: widget.onBack,
                          icon: const Icon(Icons.arrow_back),
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.type == 'offers' ? 'Available Rides' : 'Ride Requests',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      // Filter Toggle Button
                      Container(
                        decoration: BoxDecoration(
                          color: showFilterBar ? const Color(0xFF2B67F6) : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]
                        ),
                        child: IconButton(
                          onPressed: () => setState(() => showFilterBar = !showFilterBar),
                          icon: Icon(showFilterBar ? Icons.close : Icons.tune),
                          color: showFilterBar ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- FILTER BAR (Animated) ---
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Container(
                    height: showFilterBar ? null : 0,
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias, 
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Filter Results",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
                                ),
                                if (pickupFilter.isNotEmpty || destinationFilter.isNotEmpty || timeFilter.isNotEmpty)
                                  GestureDetector(
                                    onTap: clearFilters,
                                    child: const Text(
                                      "Reset",
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFilterDropdown(
                                    label: 'Pickup',
                                    value: pickupFilter,
                                    items: locationOptions,
                                    onChanged: (v) => setState(() => pickupFilter = v ?? ''),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildFilterDropdown(
                                    label: 'Destination',
                                    value: destinationFilter,
                                    items: locationOptions,
                                    onChanged: (v) => setState(() => destinationFilter = v ?? ''),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTimePickerFilter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // --- LIST CONTENT ---
                Expanded(
                  child: displayItems.isEmpty
                      ? Center(
                          child: Container(
                            margin: const EdgeInsets.all(32),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                const Text(
                                  'No rides found.',
                                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                                if (pickupFilter.isNotEmpty || destinationFilter.isNotEmpty || timeFilter.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: TextButton(
                                      onPressed: clearFilters,
                                      child: const Text('Clear Filters'),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 80), // Bottom padding for floating button
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
                                  setState(() => selectedRide = offer);
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
                                  setState(() => selectedRide = request);
                                  _showRideDetailsModal(context, request, 'request');
                                },
                              );
                            }
                          },
                        ),
                ),
              ],
            ),
          ),

          // --- FLOATING ACTION BUTTON (Bottom) ---
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (widget.type == 'offers' ? const Color(0xFF2B67F6) : const Color(0xFF4CAF50)).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: widget.onCreateNew,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.type == 'offers' ? const Color(0xFF2B67F6) : const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  widget.type == 'offers' ? 'Create Ride Request' : 'Create Ride Offer',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- DETAILS MODAL ---
  void _showRideDetailsModal(BuildContext context, dynamic ride, String type) {
    final isOffer = type == 'offer';
    final RideOffer? offer = isOffer ? ride as RideOffer : null;
    final RideRequest? request = !isOffer ? ride as RideRequest : null;

    // Data Extraction
    final pickup = isOffer ? offer!.pickup : request!.pickup;
    final destination = isOffer ? offer!.destination : request!.destination;
    final time = isOffer ? offer!.time : request!.time;
    final personName = isOffer ? offer!.driverName : request!.requesterName;
    final infoRaw = isOffer ? offer!.driverInfo : request!.requesterInfo;

    final infoLines = infoRaw.split('\n');
    final primaryInfo = infoLines.isNotEmpty ? infoLines[0] : '';
    final secondaryInfo = infoLines.length > 1 ? infoLines[1] : '';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modal Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isOffer ? 'Ride Offer Details' : 'Request Details',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Modal Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route Visualizer
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Ensure left alignment
                          children: [
                            _buildRouteRow(pickup, const Color(0xFF2B67F6), isStart: true),
                            // Vertical Line Connector
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0), // (12px dot width - 2px line width) / 2 = 5px
                              child: Container(
                                height: 24, 
                                width: 2, 
                                color: const Color(0xFFE5E7EB)
                              ),
                            ),
                            _buildRouteRow(destination, const Color(0xFF4CAF50), isStart: false),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text('Trip Info', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 12),

                      _buildDetailRow(Icons.access_time_filled, 'Time', time, const Color(0xFF2B67F6)),
                      const SizedBox(height: 12),
                      if (isOffer) _buildDetailRow(Icons.airline_seat_recline_normal, 'Seats', '${offer!.seats} seat${offer.seats > 1 ? 's' : ''}', const Color(0xFF2B67F6))
                      else _buildDetailRow(Icons.group, 'Riders', '${request!.riders} rider${request.riders > 1 ? 's' : ''}', const Color(0xFF2B67F6)),
                      
                      if (isOffer && offer!.costSharing != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(Icons.payments, 'Cost', offer.costSharing!, const Color(0xFF4CAF50)),
                      ],
                      if (!isOffer && request!.notes != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(Icons.note, 'Notes', request.notes!, const Color(0xFF4CAF50)),
                      ],

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(isOffer ? 'Driver' : 'Requester', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 12),

                      // Driver/Requester Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFFE0E7FF),
                              child: Text(personName[0].toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2B67F6))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(personName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                                  if (primaryInfo.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(primaryInfo, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                    ),
                                  if (secondaryInfo.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(secondaryInfo, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontStyle: FontStyle.italic)),
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
              ),

              // Modal Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _launchWhatsApp(infoRaw);
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Contact via WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchWhatsApp(String contactInfo) async {
    final phoneMatch = RegExp(r'\d+').firstMatch(contactInfo);
    if (phoneMatch != null) {
      final phone = phoneMatch.group(0);
      final url = 'https://wa.me/$phone';
      if (await canLaunch(url)) await launch(url);
    }
  }

  // --- Sub-widgets for Modal ---
  Widget _buildRouteRow(String location, Color color, {required bool isStart}) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4)]),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(location, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)))),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
            ],
          ),
        ),
      ],
    );
  }

  // --- Filter Widgets ---
  Widget _buildFilterDropdown({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF9CA3AF)),
      items: items.map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTimePickerFilter() {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        hintText: timeFilter.isEmpty ? 'Select Time' : timeFilter,
        hintStyle: TextStyle(color: timeFilter.isEmpty ? Colors.grey[400] : Colors.black87, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixIcon: const Icon(Icons.access_time, size: 20, color: Color(0xFF9CA3AF)),
      ),
      onTap: () async {
        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
        if (time != null) {
          setState(() {
            final hour = time.hourOfPeriod;
            final minute = time.minute.toString().padLeft(2, '0');
            final period = time.period == DayPeriod.am ? 'AM' : 'PM';
            timeFilter = '$hour:$minute $period';
          });
        }
      },
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

    paint.color = const Color(0xFFBBDEFB).withOpacity(0.3);
    _drawWave(canvas, size, paint, baselineY: size.height * 0.25, amplitude: 20, speedMultiplier: 1.0 * twoPi, offset: 0);
    
    paint.color = const Color(0xFF90CAF9).withOpacity(0.3);
    _drawWave(canvas, size, paint, baselineY: size.height * 0.4, amplitude: 25, speedMultiplier: 1.3 * twoPi, offset: math.pi / 4);
    
    paint.color = const Color(0xFF64B5F6).withOpacity(0.35);
    _drawWave(canvas, size, paint, baselineY: size.height * 0.55, amplitude: 30, speedMultiplier: 1.6 * twoPi, offset: math.pi / 2);
    
    paint.color = const Color(0xFF42A5F5).withOpacity(0.35);
    _drawWave(canvas, size, paint, baselineY: size.height * 0.7, amplitude: 35, speedMultiplier: 2.0 * twoPi, offset: math.pi);
    
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