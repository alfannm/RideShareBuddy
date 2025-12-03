// User Profile Model

class UserProfile {
  final String name;
  final String program;
  final String contactMethod;
  final String contactValue;
  final bool hasVehicle;
  final String? vehicleModel;
  final String? vehiclePlate;

  UserProfile({
    required this.name,
    required this.program,
    required this.contactMethod,
    required this.contactValue,
    required this.hasVehicle,
    this.vehicleModel,
    this.vehiclePlate,
  });

  String getContactInfo() {
    if (contactMethod == 'WhatsApp') {
      return 'WhatsApp: $contactValue';
    } else if (contactMethod == 'Phone') {
      return 'Phone: $contactValue';
    }
    return contactValue;
  }
}
