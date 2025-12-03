// User Profile Model - Updated with UMT Specifics

class VehicleDetails {
  final String model;
  final String plateNumber;
  final int maxSeats;
  final String type; // 'Car', 'Motorcycle', 'Bicycle', 'Other'
  final String? otherTypeDescription; // If type is 'Other'

  VehicleDetails({
    required this.model,
    required this.plateNumber,
    required this.maxSeats,
    required this.type,
    this.otherTypeDescription,
  });

  VehicleDetails copyWith({
    String? model,
    String? plateNumber,
    int? maxSeats,
    String? type,
    String? otherTypeDescription,
  }) {
    return VehicleDetails(
      model: model ?? this.model,
      plateNumber: plateNumber ?? this.plateNumber,
      maxSeats: maxSeats ?? this.maxSeats,
      type: type ?? this.type,
      otherTypeDescription: otherTypeDescription ?? this.otherTypeDescription,
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String role; // 'Student', 'Lecturer', 'Staff', 'Other'
  final String? matricNumber; // Only for Students
  final String? gender; // 'Male', 'Female'
  final String? faculty; // For Students & Lecturers
  final String? program; // Only for Students
  final String? department; // Only for Staff
  final String? otherRoleDescription; // If role is 'Other'
  final String contactMethod; 
  final String phoneNumber; 
  final bool isVehicleOwner;
  final VehicleDetails? vehicleDetails;

  UserProfile({
    required this.id,
    required this.name,
    required this.role,
    this.matricNumber,
    this.gender,
    this.faculty,
    this.program,
    this.department,
    this.otherRoleDescription,
    required this.contactMethod,
    required this.phoneNumber,
    required this.isVehicleOwner,
    this.vehicleDetails,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? role,
    String? matricNumber,
    String? gender,
    String? faculty,
    String? program,
    String? department,
    String? otherRoleDescription,
    String? contactMethod,
    String? phoneNumber,
    bool? isVehicleOwner,
    VehicleDetails? vehicleDetails,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      matricNumber: matricNumber ?? this.matricNumber,
      gender: gender ?? this.gender,
      faculty: faculty ?? this.faculty,
      program: program ?? this.program,
      department: department ?? this.department,
      otherRoleDescription: otherRoleDescription ?? this.otherRoleDescription,
      contactMethod: contactMethod ?? this.contactMethod,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isVehicleOwner: isVehicleOwner ?? this.isVehicleOwner,
      vehicleDetails: vehicleDetails ?? this.vehicleDetails,
    );
  }

  String getContactInfo() {
    final method = contactMethod.toLowerCase();
    if (method.contains('whatsapp')) {
      return 'WhatsApp: $phoneNumber';
    } else if (method.contains('phone')) {
      return 'Phone: $phoneNumber';
    } else if (method.contains('telegram')) {
      return 'Telegram: $phoneNumber';
    }
    return phoneNumber;
  }
}