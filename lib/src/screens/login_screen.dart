import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pos/global.dart';
import 'package:pos/src/constants/font_constants.dart';
import 'package:pos/routes.dart';
import 'package:pos/src/providers/bottom_provider.dart';
import 'package:pos/src/providers/cart_provider.dart';
import 'package:pos/src/services/auth_service.dart';
import 'package:pos/src/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final authService = AuthService();
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController(text: 'waiter001');
  TextEditingController password = TextEditingController(text: 'User@123');
  bool obscurePassword = true;

  login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final body = {
        "username": username.text,
        "password": password.text,
      };

      final response = await authService.loginData(body);
      if (response["code"] == 200) {
        prefs.setString("name", response["name"]);
        await storage.write(key: "token", value: response["token"]);

        CartProvider cartProvider =
            Provider.of<CartProvider>(context, listen: false);
        cartProvider.addCount(0);

        BottomProvider bottomProvider =
            Provider.of<BottomProvider>(context, listen: false);
        bottomProvider.selectIndex(0);

        Navigator.pushNamed(context, Routes.home);
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => exit(0),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo.png'),
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    language["User Name"] ?? "User Name",
                    style: FontConstants.caption1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: TextFormField(
                  controller: username,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  style: FontConstants.body1,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return language["Enter User Name"] ?? "Enter User Name";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    language["Password"] ?? "Password",
                    style: FontConstants.caption1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 32,
                ),
                child: TextFormField(
                  controller: password,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  obscureText: obscurePassword,
                  style: FontConstants.body1,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    suffixIcon: IconButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: SvgPicture.asset(
                        obscurePassword
                            ? "assets/icons/eye-close.svg"
                            : "assets/icons/eye.svg",
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).primaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return language["Enter Password"] ?? "Enter Password";
                    }
                    return null;
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      login();
                    }
                  },
                  child: Text(
                    language["Login"] ?? "Login",
                    style: FontConstants.button1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
