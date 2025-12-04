// Business Logic Requirement: Creation of Ride objects

class RideOffer {
  final String id;
  final String pickup;
  final String destination;
  final String time;
  final int seats;
  final String driverName;
  final String driverInfo;
  final String? costSharing;

  RideOffer({
    required this.pickup,
    required this.destination,
    required this.time,
    required this.seats,
    required this.driverName,
    required this.driverInfo,
    this.costSharing,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString() + 
           (DateTime.now().microsecondsSinceEpoch % 1000000).toString();

  // Business Logic: Count available seats and reject if seats < 1
  bool hasAvailableSeats() {
    return seats >= 1;
  }
}

class RideRequest {
  final String id;
  final String pickup;
  final String destination;
  final String time;
  final int riders;
  final String requesterName;
  final String requesterInfo;
  final String? notes;

  RideRequest({
    required this.pickup,
    required this.destination,
    required this.time,
    required this.riders,
    required this.requesterName,
    required this.requesterInfo,
    this.notes,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString() + 
           (DateTime.now().microsecondsSinceEpoch % 1000000).toString();
}

// --- Business Logic Functions ---

List<RideOffer> filterRideOffers(
  List<RideOffer> offers,
  String pickupFilter,
  String destinationFilter,
  String timeFilter,
) {
  return offers.where((offer) {
    final matchesPickup = pickupFilter.isEmpty ||
        offer.pickup.toLowerCase().contains(pickupFilter.toLowerCase());
    final matchesDestination = destinationFilter.isEmpty ||
        offer.destination.toLowerCase().contains(destinationFilter.toLowerCase());
    final matchesTime = timeFilter.isEmpty || offer.time.contains(timeFilter);
    
    return matchesPickup && matchesDestination && matchesTime && 
           offer.hasAvailableSeats();
  }).toList();
}

List<RideRequest> filterRideRequests(
  List<RideRequest> requests,
  String pickupFilter,
  String destinationFilter,
  String timeFilter,
) {
  return requests.where((request) {
    final matchesPickup = pickupFilter.isEmpty ||
        request.pickup.toLowerCase().contains(pickupFilter.toLowerCase());
    final matchesDestination = destinationFilter.isEmpty ||
        request.destination.toLowerCase().contains(destinationFilter.toLowerCase());
    final matchesTime = timeFilter.isEmpty || request.time.contains(timeFilter);
    
    return matchesPickup && matchesDestination && matchesTime;
  }).toList();
}

// Business Logic: Sort rides by time
List<T> sortRidesByTime<T>(List<T> rides, String Function(T) getTime) {
  final sortedList = List<T>.from(rides);
  sortedList.sort((a, b) {
    final timeA = parseTime(getTime(a));
    final timeB = parseTime(getTime(b));
    return timeA.compareTo(timeB);
  });
  return sortedList;
}

// FIX: Robust time parsing that handles both "HH:mm" (24h) and "HH:mm PM" (12h)
int parseTime(String timeStr) {
  try {
    timeStr = timeStr.trim();
    
    // Check if 12-hour format (contains AM or PM)
    bool is12Hour = timeStr.toUpperCase().contains('AM') || timeStr.toUpperCase().contains('PM');

    if (is12Hour) {
      final parts = timeStr.split(' ');
      if (parts.length < 2) return 0; // Fallback
      
      final timeParts = parts[0].split(':');
      final period = parts[1];

      int hours = int.parse(timeParts[0]);
      int minutes = int.parse(timeParts[1]);

      if (period.toUpperCase() == 'PM' && hours != 12) {
        hours += 12;
      } else if (period.toUpperCase() == 'AM' && hours == 12) {
        hours = 0;
      }
      return hours * 60 + minutes;
    } else {
      // Assume 24-hour format "HH:mm"
      final timeParts = timeStr.split(':');
      if (timeParts.length < 2) return 0;
      
      int hours = int.parse(timeParts[0]);
      int minutes = int.parse(timeParts[1]);
      return hours * 60 + minutes;
    }
  } catch (e) {
    // Return 0 (start of day) if parsing fails completely
    return 0;
  }
}