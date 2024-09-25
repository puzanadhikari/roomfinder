import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meroapp/provider/pageProvider.dart';
import 'package:meroapp/provider/wishlistProvider.dart';
import 'package:meroapp/splashScreen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PageProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        // Add other providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
