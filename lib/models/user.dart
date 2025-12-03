// User Profile Model - Advanced Version

class VehicleDetails {
  final String model;
  final String plateNumber;
  final int maxSeats;

  VehicleDetails({
    required this.model,
    required this.plateNumber,
    required this.maxSeats,
  });

  // Helper to create a copy with some updated values
  VehicleDetails copyWith({
    String? model,
    String? plateNumber,
    int? maxSeats,
  }) {
    return VehicleDetails(
      model: model ?? this.model,
      plateNumber: plateNumber ?? this.plateNumber,
      maxSeats: maxSeats ?? this.maxSeats,
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String role; // 'student', 'lecturer', 'staff', 'other'
  final String faculty;
  final String? program; // Only for students
  final String contactMethod; // 'WhatsApp', 'telegram', 'phone', 'message'
  final String phoneNumber; // Replaces 'contactValue'
  final bool isVehicleOwner; // Replaces 'hasVehicle'
  final VehicleDetails? vehicleDetails;

  UserProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.faculty,
    this.program,
    required this.contactMethod,
    required this.phoneNumber,
    required this.isVehicleOwner,
    this.vehicleDetails,
  });

  // Helper to create a modified copy of the profile
  UserProfile copyWith({
    String? id,
    String? name,
    String? role,
    String? faculty,
    String? program,
    String? contactMethod,
    String? phoneNumber,
    bool? isVehicleOwner,
    VehicleDetails? vehicleDetails,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      faculty: faculty ?? this.faculty,
      program: program ?? this.program,
      contactMethod: contactMethod ?? this.contactMethod,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isVehicleOwner: isVehicleOwner ?? this.isVehicleOwner,
      vehicleDetails: vehicleDetails, // Note: Pass null explicitly if needed in logic, or keep existing
    );
  }

  String getContactInfo() {
    final method = contactMethod.toLowerCase();
    if (method.contains('WhatsApp')) {
      return 'WhatsApp: $phoneNumber';
    } else if (method.contains('phone')) {
      return 'Phone: $phoneNumber';
    } else if (method.contains('telegram')) {
      return 'Telegram: $phoneNumber';
    }
    return phoneNumber;
  }
}