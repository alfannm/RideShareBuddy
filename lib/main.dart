import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/ride_listings_screen.dart';
import 'screens/create_offer_screen.dart';
import 'screens/create_request_screen.dart';
// import 'screens/ride_details_screen.dart';
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
      matricNumber: 'S72505',
      gender: 'Male',
      faculty: 'Faculty of Computer Science and Mathematics',
      program: 'Mobile Computing',
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

    // Add sample data for testing - 5 Ride Offers
    // Updated locations to match the new UMT specific list
    offers.addAll([
      RideOffer(
        pickup: 'Kompleks Siswa',
        destination: 'PSNZ',
        time: '05:30 PM',
        seats: 2,
        driverName: 'Aiman',
        driverInfo:
            'Student • Faculty of Ocean Engineering Technology\nVehicle: Perodua Axia (VAA 1234)',
        costSharing: 'RM 2.00',
      ),
      RideOffer(
        pickup: 'Kolej Kediaman',
        destination: 'Kafe Limbong',
        time: '02:00 PM',
        seats: 3,
        driverName: 'Nurul',
        driverInfo:
            'Student • Faculty of Science and Marine Environment\nVehicle: Proton Saga (WBB 8888)',
        costSharing: 'RM 1.00',
      ),
      RideOffer(
        pickup: 'Pusat Sukan dan Rekreasi',
        destination: 'Kompleks Kuliah Berpusat',
        time: '04:15 PM',
        seats: 1,
        driverName: 'Ahmad',
        driverInfo:
            'Student • Faculty of Maritime Studies\nVehicle: Yamaha Y15 (TCA 4567)',
        costSharing: 'RM 3.00',
      ),
      RideOffer(
        pickup: 'PSNZ',
        destination: 'DSM',
        time: '08:00 AM',
        seats: 4,
        driverName: 'Siti',
        driverInfo: 'Staff • Library (PSNZ)\nVehicle: Honda City (VEE 9090)',
        costSharing: 'RM 2.00',
      ),
      RideOffer(
        pickup: 'KKSAM',
        destination: 'INOS',
        time: '01:30 PM',
        seats: 2,
        driverName: 'Zainal',
        driverInfo:
            'Lecturer • Faculty of Fisheries and Food Science\nVehicle: Toyota Vios (WVV 1111)',
        costSharing: 'Free',
      ),
    ]);

    // Add sample data for testing - 5 Ride Requests
    requests.addAll([
      RideRequest(
        pickup: 'Kafe Limbong',
        destination: 'Kolej Kediaman',
        time: '06:00 PM',
        riders: 2,
        requesterName: 'Hafiz',
        requesterInfo: 'Student • Faculty of Computer Science and Mathematics',
        notes: 'Carrying heavy bags',
      ),
      RideRequest(
        pickup: 'Kompleks Siswa',
        destination: 'Makmal Berpusat',
        time: '03:30 PM',
        riders: 1,
        requesterName: 'Aina',
        requesterInfo: 'Student • Faculty of Science and Marine Environment',
        notes: 'Willing to pay extra',
      ),
      RideRequest(
        pickup: 'PPAL',
        destination: 'UMTCC',
        time: '11:00 AM',
        riders: 3,
        requesterName: 'Yusof',
        requesterInfo: 'Student • Faculty of Maritime Studies',
        notes: 'Group discussion',
      ),
      RideRequest(
        pickup: 'AKUATROP',
        destination: 'PISM',
        time: '09:30 PM',
        riders: 1,
        requesterName: 'Azlina',
        requesterInfo: 'Student • Faculty of Fisheries and Food Science',
        notes: 'Late lab session',
      ),
      RideRequest(
        pickup: 'Kompleks Kuliah Berpusat',
        destination: 'Kolej Kediaman',
        time: '08:30 AM',
        riders: 2,
        requesterName: 'Daniel',
        requesterInfo: 'Student • Faculty of Ocean Engineering Technology',
        notes: 'Morning class, urgent',
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
