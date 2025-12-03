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

// Business Logic: Filtering lists based on user input
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

int parseTime(String timeStr) {
  final parts = timeStr.split(' ');
  final timeParts = parts[0].split(':');
  final period = parts[1];
  
  int hours = int.parse(timeParts[0]);
  int minutes = int.parse(timeParts[1]);
  
  // Convert to 24-hour format
  if (period == 'PM' && hours != 12) {
    hours += 12;
  } else if (period == 'AM' && hours == 12) {
    hours = 0;
  }
  
  return hours * 60 + minutes;
}
