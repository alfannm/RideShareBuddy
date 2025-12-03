// Screen 3: CREATE RIDE OFFER
// Widget Construction Requirement: TextFields for ride info, Dropdowns/Time pickers for selections

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
    'KTS',
    'Library',
    'Residential College',
    'Campus Gate',
    'Lecture Hall A',
    'Mydin',
    'Kuala Terengganu',
  ];

  // Business Logic: Form validation
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Business Logic: Seat count validation (must be >= 1)
  String? validateSeats(String? value) {
    if (value == null || value.isEmpty) {
      return 'Seats is required';
    }
    final seats = int.tryParse(value);
    if (seats == null || seats < 1) {
      return 'Seats must be at least 1';
    }
    return null;
  }

  void handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (time.isEmpty) {
        // Widget Construction Requirement: Snackbar for confirmations
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a time'),
            backgroundColor: Colors.red,
          ),
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

      // Widget Construction Requirement: Snackbar for confirmations
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride offer created successfully!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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

              // Form
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Widget Construction Requirement: Dropdown for selections
                          // Pickup Location
                          DropdownButtonFormField<String>(
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
                            validator: (value) => validateRequired(value, 'Pickup location'),
                            onSaved: (value) => pickup = value ?? '',
                            onChanged: (value) => pickup = value ?? '',
                          ),

                          const SizedBox(height: 16),

                          // Destination
                          DropdownButtonFormField<String>(
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
                            validator: (value) => validateRequired(value, 'Destination'),
                            onSaved: (value) => destination = value ?? '',
                            onChanged: (value) => destination = value ?? '',
                          ),

                          const SizedBox(height: 16),

                          // Widget Construction Requirement: Time picker for selections
                          // Time Picker
                          TextFormField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Departure Time',
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.access_time),
                              hintText: time.isEmpty ? 'Select time' : time,
                            ),
                            onTap: () async {
                              final selectedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (selectedTime != null) {
                                setState(() {
                                  final hour = selectedTime.hourOfPeriod;
                                  final minute = selectedTime.minute.toString().padLeft(2, '0');
                                  final period = selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
                                  time = '$hour:$minute $period';
                                });
                              }
                            },
                          ),

                          const SizedBox(height: 16),

                          // Widget Construction Requirement: TextField for ride info
                          // Available Seats
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Available Seats',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            initialValue: '1',
                            validator: validateSeats,
                            onSaved: (value) => seats = int.parse(value ?? '1'),
                          ),

                          const SizedBox(height: 16),

                          // Cost Sharing Toggle
                          const Text(
                            'Cost Sharing',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isFree = true;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isFree ? const Color(0xFF2B67F6) : Colors.white,
                                      border: Border.all(
                                        color: isFree ? const Color(0xFF2B67F6) : const Color(0xFFE5E7EB),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Free',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isFree ? Colors.white : const Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isFree = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !isFree ? const Color(0xFF2B67F6) : Colors.white,
                                      border: Border.all(
                                        color: !isFree ? const Color(0xFF2B67F6) : const Color(0xFFE5E7EB),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Cost-Sharing',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: !isFree ? Colors.white : const Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (!isFree) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Cost Amount (RM)',
                                border: OutlineInputBorder(),
                                prefixText: 'RM ',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (value) {
                                if (!isFree && (value == null || value.isEmpty)) {
                                  return 'Cost amount is required';
                                }
                                return null;
                              },
                              onSaved: (value) => costAmount = value ?? '',
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Widget Construction Requirement: Button for creating offers
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Create Offer',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
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
      ),
    );
  }
}
