import 'package:childcompass/screeens/child/child_code.dart';
import 'package:childcompass/screeens/child/child_registeration.dart';
import 'package:childcompass/screeens/mutual/onBoardingScreen.dart';
import 'package:childcompass/screeens/parent/child_connection.dart';
import 'package:childcompass/screeens/parent/email_verification.dart';
import 'package:childcompass/screeens/parent/parent_login.dart';
import 'package:childcompass/screeens/parent/parent_registeration.dart';
import 'package:childcompass/screeens/parent/parent_dashboard.dart';
import 'package:childcompass/screeens/parent/child_location_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Mapbox with the token
  final token = dotenv.env['MAPBOX_ACCESS_TOKEN'];
  if (token == null) {
    throw Exception('MAPBOX_ACCESS_TOKEN not found in .env file');
  }
  MapboxOptions.setAccessToken(token);

  print("Mapbox token initialized: ${token.substring(0, 5)}...");

  runApp(
    ProviderScope(
      child: MyApp(initialRoute: '/onBoardingScreen'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Child Compass',
      initialRoute: initialRoute,
      routes: {
        '/onBoardingScreen': (context) => onBoardingScreen(),
        '/childRegisteration': (context) => childRegistration(),
        '/parentRegisteration': (context) => ParentRegistration(),
        '/parentLogin': (context) => parentLogin(),
        '/emailVerification': (context) => EmailVerification(),
        '/childConnection': (context) => ChildConnection(),
        '/childCode': (context) => childCode(),
        '/parentDashboard': (context) => parentDashboard(),
        '/childLocationMap': (context) => ParentMapScreen(),
      },
    );
  }
}