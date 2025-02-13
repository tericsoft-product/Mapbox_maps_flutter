import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:maps_flutter/screens/DrawingPointsScreen.dart';
import 'package:maps_flutter/screens/GpsScreen.dart';
import 'package:maps_flutter/screens/HomeScreen.dart';
import 'package:maps_flutter/screens/LocationEnableScreen.dart';
import 'package:maps_flutter/screens/OnboardScreen.dart';
import 'package:maps_flutter/screens/StartupScreen.dart';
import 'package:maps_flutter/screens/WeatherLayersScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) {
    await dotenv.load(fileName: ".env.production");
  } else {
    await dotenv.load(fileName: ".env.development");
  }
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  // dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  GoRouter router() {
    return GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/startup',
          builder: (context, state) => const StartupScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardScreen(),
        ),
        GoRoute(
          path: '/enable_location',
          builder: (context, state) => const LocationPermissionScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/gps',
          builder: (context, state) => const GpsScreen(),
        ),
        GoRoute(
          path: '/weather',
          builder: (context, state) => const WeatherLayersScreen(),
        ),
        GoRoute(
          path: '/drawing',
          builder: (context, state) => const DrawingPointsScreen(),
        ),
      ],
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Provider Demo',
      // theme: appTheme,
      routerConfig: router(),
    );
  }
}
