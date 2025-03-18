import 'package:childcompass/screeens/child/child_code.dart';
import 'package:childcompass/screeens/child/child_registeration.dart';
import 'package:childcompass/screeens/mutual/onBoardingScreen.dart';
import 'package:childcompass/screeens/parent/child_connection.dart';
import 'package:childcompass/screeens/parent/email_verification.dart';
import 'package:childcompass/screeens/parent/parent_login.dart';
import 'package:childcompass/screeens/parent/parent_registeration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/parent_email_provider.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope( // Wrap your app inside ProviderScope
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
      },
    );
  }
}
