import 'package:flutter/material.dart';
import 'package:pos/global.dart';

class ConnectionTimeoutScreen extends StatefulWidget {
  const ConnectionTimeoutScreen({super.key});

  @override
  State<ConnectionTimeoutScreen> createState() =>
      _ConnectionTimeoutScreenState();
}

class _ConnectionTimeoutScreenState extends State<ConnectionTimeoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/no_connection.png'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 10,
                ),
                child: Text(
                  "Connection Timed Out",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                ),
                child: Text(
                  "Please check your internet connection and try again.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 24,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          onPressed: () async {
            isConnectionTimeout = false;
            Navigator.of(context).pop();
          },
          child: Text(
            language["Try Again"] ?? "Try Again",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
