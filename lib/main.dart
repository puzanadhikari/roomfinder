import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meroapp/provider/pageProvider.dart';
import 'package:meroapp/provider/wishlistProvider.dart';
import 'package:meroapp/splashScreen.dart';
import 'package:provider/provider.dart';
import 'package:khalti_flutter/khalti_flutter.dart';

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
      child:  MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return KhaltiScope(
      publicKey: 'test_public_key_5c5fa086bb704a54b1efd924a2acb036',

      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Khalti integration app",
          navigatorKey: _,
          home: SplashScreen(),
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
          ),

          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ne', 'NP'),
          ],
          localizationsDelegates: const [
            KhaltiLocalizations.delegate,
          ],
        );
      },
    );
  }
}