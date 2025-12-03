// Screen 4: CREATE RIDE REQUEST
// Widget Construction Requirement: TextFields for ride info, Dropdowns/Time pickers for selections

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

  // Business Logic: Form validation
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Business Logic: Riders count validation (must be >= 1)
  String? validateRiders(String? value) {
    if (value == null || value.isEmpty) {
      return 'Number of riders is required';
    }
    final ridersCount = int.tryParse(value);
    if (ridersCount == null || ridersCount < 1) {
      return 'Riders must be at least 1';
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

      final request = RideRequest(
        pickup: pickup,
        destination: destination,
        time: time,
        riders: riders,
        requesterName: widget.userProfile?.name ?? 'Anonymous',
        requesterInfo: widget.userProfile?.getContactInfo() ?? 'No contact info',
        notes: notes.isEmpty ? null : notes,
      );

      widget.onSubmit(request);

      // Widget Construction Requirement: Snackbar for confirmations
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride request created successfully!'),
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
                        'Create Ride Request',
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
                              labelText: 'Needed By',
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
                          // Number of Riders
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Number of Riders',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            initialValue: '1',
                            validator: validateRiders,
                            onSaved: (value) => riders = int.parse(value ?? '1'),
                          ),

                          const SizedBox(height: 16),

                          // Additional Notes
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Additional Notes (Optional)',
                              border: OutlineInputBorder(),
                              hintText: 'E.g., Heavy luggage, preferred meeting point',
                            ),
                            maxLines: 3,
                            onSaved: (value) => notes = value ?? '',
                          ),

                          const SizedBox(height: 24),

                          // Widget Construction Requirement: Button for creating requests
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2B67F6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Create Request',
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
