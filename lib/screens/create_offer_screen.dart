import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ride.dart';
import '../models/user.dart';
import 'home_screen.dart'; 

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

  final List<String> seatOptions = List.generate(9, (index) => (index + 1).toString());

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
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
      
      String driverDetails = widget.userProfile != null 
          ? '${widget.userProfile!.role} • ${widget.userProfile!.faculty ?? widget.userProfile!.department ?? "UMT"}'
          : 'Anonymous';

      if (widget.userProfile?.vehicleDetails != null) {
        driverDetails += '\nVehicle: ${widget.userProfile!.vehicleDetails!.model} (${widget.userProfile!.vehicleDetails!.plateNumber})';
      }

      final offer = RideOffer(
        pickup: pickup,
        destination: destination,
        time: time,
        seats: seats,
        driverName: widget.userProfile?.name ?? 'Anonymous',
        driverInfo: driverDetails,
        costSharing: isFree ? 'Free' : 'RM $costAmount',
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
      backgroundColor: const Color(0xFFEBF4FF),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: FluidBackgroundPainter(animationValue: 0.5),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
                          ]
                        ),
                        child: IconButton(
                          onPressed: widget.onBack,
                          icon: const Icon(Icons.arrow_back),
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Create Ride Offer',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                            _buildSectionTitle('Route Details'),
                            const SizedBox(height: 16),
                            _buildDropdownField(
                              label: 'Pickup Location',
                              value: pickup.isEmpty ? null : pickup,
                              items: locationOptions,
                              onChanged: (v) => setState(() => pickup = v ?? ''),
                              validator: (v) => validateRequired(v, 'Pickup'),
                              icon: Icons.my_location,
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownField(
                              label: 'Destination',
                              value: destination.isEmpty ? null : destination,
                              items: locationOptions,
                              onChanged: (v) => setState(() => destination = v ?? ''),
                              validator: (v) => validateRequired(v, 'Destination'),
                              icon: Icons.location_on,
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Trip Details'),
                            const SizedBox(height: 16),
                            _buildDateTimeField(
                              label: 'Departure Time',
                              value: time,
                              placeholder: 'Select time',
                              icon: Icons.access_time_filled,
                              onTap: () async {
                                final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                                if (t != null) {
                                  // FIX: Force 12-hour format manually
                                  final String period = t.hour >= 12 ? 'PM' : 'AM';
                                  int hour12 = t.hour > 12 ? t.hour - 12 : t.hour;
                                  if (hour12 == 0) hour12 = 12;
                                  final String minute = t.minute.toString().padLeft(2, '0');
                                  
                                  setState(() => time = '$hour12:$minute $period');
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownField(
                              label: 'Available Seats',
                              value: seats.toString(),
                              items: seatOptions,
                              onChanged: (v) => setState(() => seats = int.parse(v!)),
                              validator: null,
                              icon: Icons.event_seat,
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Pricing'),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  _buildToggleButton('Free', isFree, () => setState(() => isFree = true)),
                                  _buildToggleButton('Cost-Sharing', !isFree, () => setState(() => isFree = false)),
                                ],
                              ),
                            ),
                            if (!isFree) ...[
                              const SizedBox(height: 16),
                              _buildInputField(
                                label: 'Cost Amount (RM)',
                                placeholder: 'e.g. 5.00',
                                inputType: const TextInputType.numberWithOptions(decimal: true),
                                icon: Icons.attach_money,
                                validator: (v) => (!isFree && (v == null || v.isEmpty)) ? 'Required' : null,
                                onSaved: (v) => costAmount = v ?? '',
                              ),
                            ],
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor: const Color(0xFF4CAF50).withOpacity(0.4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text(
                                  'Create Offer',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  // --- Helper Widgets ---
  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)));
  }

  Widget _buildInputField({required String label, String? placeholder, String? initialValue, required IconData icon, TextInputType inputType = TextInputType.text, String? Function(String?)? validator, Function(String?)? onSaved}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ${validator != null ? "*" : ""}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          keyboardType: inputType,
          inputFormatters: inputType == TextInputType.number ? [FilteringTextInputFormatter.digitsOnly] : [],
          decoration: _inputDecoration(placeholder, icon),
          validator: validator,
          onSaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildDateTimeField({required String label, required String value, required String placeholder, required IconData icon, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          decoration: _inputDecoration(value.isEmpty ? placeholder : value, icon).copyWith(
            hintStyle: TextStyle(color: value.isEmpty ? Colors.grey[400] : Colors.black87),
          ),
          onTap: onTap,
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required String? value, required List<String> items, required ValueChanged<String?> onChanged, required String? Function(String?)? validator, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down),
          decoration: _inputDecoration('Select', icon),
          items: items.map((l) => DropdownMenuItem(value: l, child: Text(l, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2B67F6), width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? const Color(0xFF2B67F6) : const Color(0xFF6B7280), fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}