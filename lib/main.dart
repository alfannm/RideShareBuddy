import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/ride_listings_screen.dart';
import 'screens/create_offer_screen.dart';
import 'screens/create_request_screen.dart';
import 'screens/ride_details_screen.dart';
import 'models/ride.dart';
import 'models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RideShare Buddy',
      theme: ThemeData(
        primaryColor: const Color(0xFF2B67F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2B67F6),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const RideShareApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RideShareApp extends StatefulWidget {
  const RideShareApp({Key? key}) : super(key: key);

  @override
  State<RideShareApp> createState() => _RideShareAppState();
}

class _RideShareAppState extends State<RideShareApp> {
  // Business Logic: List storage for rides
  List<RideOffer> offers = [];
  List<RideRequest> requests = [];
  
  // User profile
  UserProfile? userProfile;
  
  // Current screen state
  String currentScreen = 'home';
  String? selectedRideId;
  String? selectedRideType;

  @override
  void initState() {
    super.initState();
    // Initialize with sample user profile
    userProfile = UserProfile(
      id: 'u1',
      name: 'Alfan Na Im bin Shabaruddin',
      role: 'Student',
      faculty: 'Faculty of Computer Science and Mathematics',
      program: 'BCS. Mobile Computing',
      contactMethod: 'WhatsApp',
      phoneNumber: '+601124181384',
      isVehicleOwner: true,
      vehicleDetails: VehicleDetails(
        model: 'Yamaha 135LC Fi',
        plateNumber: 'VJH 5198',
        maxSeats: 1,
      ),
    );

    // Add sample data for testing - 5 Ride Offers
    offers.addAll([
      RideOffer(
        pickup: 'KTS',
        destination: 'Library',
        time: '5:30 PM',
        seats: 2,
        driverName: 'Aiman',
        driverInfo: 'FiST Student',
        costSharing: 'RM2-RM4',
      ),
      RideOffer(
        pickup: 'Residential College',
        destination: 'Mydin',
        time: '2:00 PM',
        seats: 3,
        driverName: 'Nurul',
        driverInfo: 'FST Student',
        costSharing: 'RM3',
      ),
      RideOffer(
        pickup: 'Campus Gate',
        destination: 'Kuala Terengganu',
        time: '4:15 PM',
        seats: 1,
        driverName: 'Ahmad',
        driverInfo: 'FKM Student',
        costSharing: 'RM5-RM7',
      ),
      RideOffer(
        pickup: 'Library',
        destination: 'Lecture Hall A',
        time: '8:00 AM',
        seats: 4,
        driverName: 'Siti',
        driverInfo: 'FPP Student',
        costSharing: 'RM2',
      ),
      RideOffer(
        pickup: 'KTS',
        destination: 'Mydin',
        time: '1:30 PM',
        seats: 2,
        driverName: 'Zainal',
        driverInfo: 'FKM Student',
        costSharing: 'Free',
      ),
    ]);

    // Add sample data for testing - 5 Ride Requests
    requests.addAll([
      RideRequest(
        pickup: 'Mydin',
        destination: 'Campus Gate',
        time: '6:00 PM',
        riders: 2,
        requesterName: 'Hafiz',
        requesterInfo: 'FiST Student',
        notes: 'Can share costs',
      ),
      RideRequest(
        pickup: 'Residential College',
        destination: 'Kuala Terengganu',
        time: '3:30 PM',
        riders: 1,
        requesterName: 'Aina',
        requesterInfo: 'FST Student',
        notes: 'Willing to pay RM5',
      ),
      RideRequest(
        pickup: 'KTS',
        destination: 'Mydin',
        time: '11:00 AM',
        riders: 3,
        requesterName: 'Yusof',
        requesterInfo: 'FKM Student',
        notes: 'Need ride for groceries shopping',
      ),
      RideRequest(
        pickup: 'Library',
        destination: 'Residential College',
        time: '9:30 PM',
        riders: 1,
        requesterName: 'Azlina',
        requesterInfo: 'FPP Student',
        notes: 'Late study session',
      ),
      RideRequest(
        pickup: 'Campus Gate',
        destination: 'Lecture Hall A',
        time: '8:30 AM',
        riders: 2,
        requesterName: 'Daniel',
        requesterInfo: 'FiST Student',
        notes: 'Morning class, willing to pay RM2',
      ),
    ]);
  }

  void navigateTo(String screen) {
    setState(() {
      currentScreen = screen;
    });
  }

  void handleCreateOffer(RideOffer offer) {
    setState(() {
      offers.add(offer);
      currentScreen = 'listings-offers';
    });
  }

  void handleCreateRequest(RideRequest request) {
    setState(() {
      requests.add(request);
      currentScreen = 'listings-requests';
    });
  }

  void handleViewDetails(String id, String type) {
    setState(() {
      selectedRideId = id;
      selectedRideType = type;
      currentScreen = 'details';
    });
  }

  void handleSaveProfile(UserProfile profile) {
    setState(() {
      userProfile = profile;
    });
  }

  Widget getCurrentScreen() {
    switch (currentScreen) {
      case 'home':
        return HomeScreen(
          onFindRide: () => navigateTo('listings-offers'),
          onOfferRide: () => navigateTo('listings-requests'),
          profile: userProfile!, // Fixed: Added profile
          onSaveProfile: handleSaveProfile, // Fixed: Added save function
        );

      case 'listings-offers':
        return RideListingsScreen(
          type: 'offers',
          offers: offers,
          requests: requests,
          onBack: () => navigateTo('home'),
          onCreateNew: () => navigateTo('create-request'),
          onViewDetails: handleViewDetails,
        );

      case 'listings-requests':
        return RideListingsScreen(
          type: 'requests',
          offers: offers,
          requests: requests,
          onBack: () => navigateTo('home'),
          onCreateNew: () => navigateTo('create-offer'),
          onViewDetails: handleViewDetails,
        );

      case 'create-offer':
        return CreateOfferScreen(
          userProfile: userProfile,
          onBack: () => navigateTo('listings-requests'),
          onSubmit: handleCreateOffer,
        );

      case 'create-request':
        return CreateRequestScreen(
          userProfile: userProfile,
          onBack: () => navigateTo('listings-offers'),
          onSubmit: handleCreateRequest,
        );

      case 'details':
        final ride = selectedRideType == 'offer'
            ? offers.firstWhere((o) => o.id == selectedRideId)
            : requests.firstWhere((r) => r.id == selectedRideId);
        return RideDetailsScreen(
          type: selectedRideType!,
          ride: ride,
          onBack: () => navigateTo(
            selectedRideType == 'offer' ? 'listings-offers' : 'listings-requests',
          ),
        );

      default:
        // FIX: The error was here. We added the missing parameters.
        return HomeScreen(
          onFindRide: () => navigateTo('listings-offers'),
          onOfferRide: () => navigateTo('listings-requests'),
          profile: userProfile!,
          onSaveProfile: handleSaveProfile,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return getCurrentScreen();
  }
}