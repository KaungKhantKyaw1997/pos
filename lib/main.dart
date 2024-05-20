import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos/routes.dart';
import 'package:pos/src/providers/bottom_provider.dart';
import 'package:pos/src/providers/cart_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BottomProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var smallestDimension = MediaQuery.of(context).size.shortestSide;
    final useMobileLayout = smallestDimension < 600;

    if (useMobileLayout) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POS',
      theme: ThemeData(
        primaryColor: Color(0xff7468D4),
        primaryColorLight: Color(0xffF2F4FF),
        primaryColorDark: Color(0xff7468D4),
        scaffoldBackgroundColor: Color(0xFFF8F8FA),
        textTheme:
            GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).copyWith(
          displayLarge: GoogleFonts.poppins(
            fontSize: !useMobileLayout ? 30 : 26,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          displayMedium: GoogleFonts.poppins(
            fontSize: !useMobileLayout ? 30 : 26,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          displaySmall: GoogleFonts.poppins(
            fontSize: !useMobileLayout ? 30 : 26,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
          headlineLarge: GoogleFonts.poppins(
            fontSize: !useMobileLayout ? 26 : 22,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          headlineMedium: GoogleFonts.poppins(
            fontSize: !useMobileLayout ? 26 : 22,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          headlineSmall: GoogleFonts.poppins(
            fontSize: !useMobileLayout ? 26 : 22,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: !useMobileLayout ? 22 : 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          titleMedium: GoogleFonts.poppins(
            fontSize: !useMobileLayout ? 22 : 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          titleSmall: GoogleFonts.poppins(
            fontSize: !useMobileLayout ? 22 : 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
          bodyLarge: GoogleFonts.poppins(
            fontSize: !useMobileLayout ? 18 : 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: !useMobileLayout ? 18 : 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          bodySmall: GoogleFonts.poppins(
            fontSize: !useMobileLayout ? 18 : 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
          labelLarge: GoogleFonts.poppins(
            fontSize: !useMobileLayout ? 14 : 10,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          labelMedium: GoogleFonts.poppins(
            fontSize: !useMobileLayout ? 14 : 10,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          labelSmall: GoogleFonts.poppins(
            fontSize: !useMobileLayout ? 14 : 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      initialRoute: Routes.splash,
      routes: Routes.routes,
    );
  }
}
