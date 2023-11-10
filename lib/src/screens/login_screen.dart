import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pos/global.dart';
import 'package:pos/routes.dart';
import 'package:pos/src/constants/color_constants.dart';
import 'package:pos/src/providers/bottom_provider.dart';
import 'package:pos/src/providers/cart_provider.dart';
import 'package:pos/src/services/auth_service.dart';
import 'package:pos/src/utils/loading.dart';
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
  TextEditingController userid = TextEditingController(text: 'waiter001');
  FocusNode _userIDFocusNode = FocusNode();
  Color _userIDBorderColor = ColorConstants.borderColor;

  TextEditingController password = TextEditingController(text: 'User@123');
  FocusNode _passwordFocusNode = FocusNode();
  Color _passwordBorderColor = ColorConstants.borderColor;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _userIDFocusNode.addListener(() {
      setState(() {
        _userIDBorderColor = _userIDFocusNode.hasFocus
            ? ColorConstants.primaryColor
            : ColorConstants.borderColor;
      });
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _passwordBorderColor = _passwordFocusNode.hasFocus
            ? ColorConstants.primaryColor
            : ColorConstants.borderColor;
      });
    });
  }

  @override
  void dispose() {
    _userIDFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  login() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final body = {
        "username": userid.text,
        "password": password.text,
      };

      final response = await authService.loginData(body);
      Navigator.pop(context);

      if (response["code"] == 200) {
        prefs.setString("name", response["name"]);
        await storage.write(key: "token", value: response["token"]);

        CartProvider cartProvider =
            Provider.of<CartProvider>(context, listen: false);
        cartProvider.addCount(0);

        BottomProvider bottomProvider =
            Provider.of<BottomProvider>(context, listen: false);
        bottomProvider.selectIndex(0);

        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.home,
          (route) => false,
        );
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      Navigator.pop(context);
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _userIDFocusNode.unfocus();
        _passwordFocusNode.unfocus();
      },
      child: WillPopScope(
        onWillPop: () => exit(0),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 400,
                  height: 400,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/login.png'),
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Text(
                    "Welcome to POS",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _userIDBorderColor,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: userid,
                    focusNode: _userIDFocusNode,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    style: Theme.of(context).textTheme.bodyMedium,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelText: language["User Name"],
                      labelStyle: Theme.of(context).textTheme.labelMedium,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return language["Enter User Name"] ?? "Enter User Name";
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 32,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _passwordBorderColor,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: password,
                    focusNode: _passwordFocusNode,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    obscureText: obscurePassword,
                    style: Theme.of(context).textTheme.bodyMedium,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelText: language["Password"],
                      labelStyle: Theme.of(context).textTheme.labelMedium,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
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
                    bottom: 24,
                  ),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        showLoadingDialog(context);
                        login();
                      }
                    },
                    child: Text(
                      language["Login"] ?? "Login",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
