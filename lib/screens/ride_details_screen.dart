// Screen 5: RIDE DETAILS
// Widget Construction Requirement: Dialog for confirmations

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ride.dart';

class RideDetailsScreen extends StatelessWidget {
  final String type; // 'offer' or 'request'
  final dynamic ride; // RideOffer or RideRequest
  final VoidCallback onBack;

  const RideDetailsScreen({
    Key? key,
    required this.type,
    required this.ride,
    required this.onBack,
  }) : super(key: key);

  void _showContactDialog(BuildContext context, String contactInfo) {
    // Widget Construction Requirement: Dialog for confirmations
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(contactInfo),
              const SizedBox(height: 16),
              const Text(
                'Would you like to contact via WhatsApp?',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _launchWhatsApp(contactInfo);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
              ),
              child: const Text('WhatsApp'),
            ),
          ],
        );
      },
    );
  }

  void _launchWhatsApp(String contactInfo) async {
    // Extract phone number from contact info
    final phoneMatch = RegExp(r'\d+').firstMatch(contactInfo);
    if (phoneMatch != null) {
      final phone = phoneMatch.group(0);
      final url = 'https://wa.me/$phone';
      if (await canLaunch(url)) {
        await launch(url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOffer = type == 'offer';
    final RideOffer? offer = isOffer ? ride as RideOffer : null;
    final RideRequest? request = !isOffer ? ride as RideRequest : null;

    final pickup = isOffer ? offer!.pickup : request!.pickup;
    final destination = isOffer ? offer!.destination : request!.destination;
    final time = isOffer ? offer!.time : request!.time;
    final personName = isOffer ? offer!.driverName : request!.requesterName;
    final contactInfo = isOffer ? offer!.driverInfo : request!.requesterInfo;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
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
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back),
                      color: const Color(0xFF1F2937),
                    ),
                    Expanded(
                      child: Text(
                        isOffer ? 'Ride Offer Details' : 'Ride Request Details',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Details Card
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Route Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6FA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2B67F6),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      pickup,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 5),
                                height: 24,
                                width: 2,
                                color: const Color(0xFFE5E7EB),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4CAF50),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      destination,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Time
                        _buildInfoRow(Icons.access_time, 'Time', time),

                        const SizedBox(height: 12),

                        // Seats or Riders
                        if (isOffer)
                          _buildInfoRow(
                            Icons.airline_seat_recline_normal,
                            'Available Seats',
                            '${offer!.seats} seat${offer.seats > 1 ? 's' : ''}',
                          )
                        else
                          _buildInfoRow(
                            Icons.people,
                            'Number of Riders',
                            '${request!.riders} rider${request.riders > 1 ? 's' : ''}',
                          ),

                        const SizedBox(height: 12),

                        // Cost Sharing (for offers)
                        if (isOffer && offer!.costSharing != null)
                          _buildInfoRow(
                            Icons.payments,
                            'Cost Sharing',
                            offer.costSharing!,
                          ),

                        const SizedBox(height: 12),

                        // Person Info
                        _buildInfoRow(
                          Icons.person,
                          isOffer ? 'Driver' : 'Requester',
                          personName,
                        ),

                        // Notes (for requests)
                        if (!isOffer && request!.notes != null) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.note, 'Notes', request.notes!),
                        ],

                        const SizedBox(height: 24),

                        const Divider(),

                        const SizedBox(height: 24),

                        // Contact Section
                        const Text(
                          'Contact Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          contactInfo,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Contact Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _showContactDialog(context, contactInfo),
                            icon: const Icon(Icons.phone),
                            label: Text(
                              isOffer ? 'Contact Driver' : 'Contact Requester',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6B7280)),
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
              const SizedBox(height: 2),
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
