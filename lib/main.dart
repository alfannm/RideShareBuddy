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
    
    // 1. Initialize with a complete UMT Student Profile
    userProfile = UserProfile(
      id: 'u1',
      name: 'Alfan Na Im bin Shabaruddin',
      role: 'Student',
      matricNumber: 'S58492',
      gender: 'Male',
      faculty: 'Faculty of Computer Science and Mathematics',
      program: 'Mobile Computing',
      // department: null, // Not needed for student
      contactMethod: 'WhatsApp',
      phoneNumber: '+601124181384',
      isVehicleOwner: true,
      vehicleDetails: VehicleDetails(
        model: 'Yamaha 135LC Fi',
        plateNumber: 'VJH 5198',
        maxSeats: 1,
        type: 'Motorcycle',
      ),
    );

    // 2. Align Mock Data with UMT Context
    // We update driverInfo/requesterInfo to match the style of the new profile data
    
    offers.addAll([
      RideOffer(
        pickup: 'KTS',
        destination: 'Library',
        time: '5:30 PM',
        seats: 2,
        driverName: 'Aiman',
        driverInfo: 'Student • Faculty of Ocean Engineering Technology',
        costSharing: 'RM 2.00',
      ),
      RideOffer(
        pickup: 'Residential College',
        destination: 'Mydin',
        time: '2:00 PM',
        seats: 3,
        driverName: 'Nurul',
        driverInfo: 'Student • Faculty of Science and Marine Environment',
        costSharing: 'RM 3.00',
      ),
      RideOffer(
        pickup: 'Campus Gate',
        destination: 'Kuala Terengganu',
        time: '4:15 PM',
        seats: 1,
        driverName: 'Dr. Ahmad',
        driverInfo: 'Lecturer • Faculty of Maritime Studies',
        costSharing: 'RM 5.00',
      ),
      RideOffer(
        pickup: 'Library',
        destination: 'Lecture Hall A',
        time: '8:00 AM',
        seats: 4,
        driverName: 'Siti',
        driverInfo: 'Student • Faculty of Fisheries and Food Science',
        costSharing: 'RM 1.00',
      ),
      RideOffer(
        pickup: 'KTS',
        destination: 'Mydin',
        time: '1:30 PM',
        seats: 2,
        driverName: 'Zainal',
        driverInfo: 'Staff • Development & Maintenance Department',
        costSharing: 'Free',
      ),
    ]);

    requests.addAll([
      RideRequest(
        pickup: 'Mydin',
        destination: 'Campus Gate',
        time: '6:00 PM',
        riders: 2,
        requesterName: 'Hafiz',
        requesterInfo: 'Student • Faculty of Business, Economics and Social Development',
        notes: 'Can share costs, carrying groceries',
      ),
      RideRequest(
        pickup: 'Residential College',
        destination: 'Kuala Terengganu',
        time: '3:30 PM',
        riders: 1,
        requesterName: 'Aina',
        requesterInfo: 'Student • Faculty of Computer Science and Mathematics',
        notes: 'Willing to pay RM 5',
      ),
      RideRequest(
        pickup: 'KTS',
        destination: 'Mydin',
        time: '11:00 AM',
        riders: 3,
        requesterName: 'Yusof',
        requesterInfo: 'Student • Faculty of Ocean Engineering Technology',
        notes: 'Need ride for group shopping',
      ),
      RideRequest(
        pickup: 'Library',
        destination: 'Residential College',
        time: '9:30 PM',
        riders: 1,
        requesterName: 'Azlina',
        requesterInfo: 'Student • Faculty of Maritime Studies',
        notes: 'Late study session, female driver preferred',
      ),
      RideRequest(
        pickup: 'Campus Gate',
        destination: 'Lecture Hall A',
        time: '8:30 AM',
        riders: 2,
        requesterName: 'Daniel',
        requesterInfo: 'Student • Faculty of Fisheries and Food Science',
        notes: 'Morning class, willing to pay RM 2',
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
          profile: userProfile!,
          onSaveProfile: handleSaveProfile,
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