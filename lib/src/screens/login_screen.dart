import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pos/global.dart';
import 'package:pos/routes.dart';
import 'package:pos/src/constants/color_constants.dart';
import 'package:pos/src/providers/bottom_provider.dart';
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
  TextEditingController userid = TextEditingController(text: '');
  FocusNode _userIDFocusNode = FocusNode();
  Color _userIDBorderColor = ColorConstants.borderColor;

  TextEditingController password = TextEditingController(text: '');
  FocusNode _passwordFocusNode = FocusNode();
  Color _passwordBorderColor = ColorConstants.borderColor;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _userIDFocusNode.addListener(() {
      setState(() {
        _userIDBorderColor = _userIDFocusNode.hasFocus
            ? Theme.of(context).primaryColor
            : ColorConstants.borderColor;
      });
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _passwordBorderColor = _passwordFocusNode.hasFocus
            ? Theme.of(context).primaryColor
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

  void _handleSubmitted(String value) {
    if (value.isNotEmpty) {
      showLoadingDialog(context);
      login();
    }
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
      if (response!["code"] == 200) {
        prefs.setString("name", response["name"]);
        await storage.write(key: "token", value: response["token"]);

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
      if (e is DioException &&
          e.error is SocketException &&
          !isConnectionTimeout) {
        isConnectionTimeout = true;
        Navigator.pushNamed(
          context,
          Routes.connection_timeout,
        );
        return;
      }
      if (e is DioException && e.response != null && e.response!.data != null) {
        if (e.response!.data["message"].toLowerCase() == "invalid token" ||
            e.response!.data["message"].toLowerCase() ==
                "invalid authorization header format") {
          Navigator.pushNamed(
            context,
            Routes.unauthorized,
          );
        } else {
          ToastUtil.showToast(
              e.response!.data['code'], e.response!.data['message']);
        }
      }
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
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 130,
                height: 130,
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
                  top: 32,
                  bottom: 24,
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  controller: userid,
                  focusNode: _userIDFocusNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  style: Theme.of(context).textTheme.bodyLarge,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: language["User Name"] ?? "User Name",
                    labelStyle: Theme.of(context).textTheme.labelSmall,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: InputBorder.none,
                  ),
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  controller: password,
                  focusNode: _passwordFocusNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  obscureText: obscurePassword,
                  style: Theme.of(context).textTheme.bodyLarge,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: language["Password"] ?? "Password",
                    labelStyle: Theme.of(context).textTheme.labelSmall,
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
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  onFieldSubmitted: _handleSubmitted,
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
                      borderRadius: BorderRadius.circular(25),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    if (userid.text.isEmpty) {
                      ToastUtil.showToast(
                          0, language["Enter User Name"] ?? "Enter User Name");
                      return;
                    }
                    if (password.text.isEmpty) {
                      ToastUtil.showToast(
                          0, language["Enter Password"] ?? "Enter Password");
                      return;
                    }
                    showLoadingDialog(context);
                    login();
                  },
                  child: Text(
                    language["Log In"] ?? "Log In",
                    style: Theme.of(context).textTheme.bodyMedium,
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
