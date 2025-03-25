import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../../provider/parent_email_provider.dart';
import '../../services/parent_api_service.dart';
import 'email_verification.dart';

class ParentRegistration extends ConsumerStatefulWidget {
  @override
  _ParentRegistrationState createState() => _ParentRegistrationState();
}

class _ParentRegistrationState extends ConsumerState<ParentRegistration> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    "assets/images/map.jpg",
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  top: 20,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back, size: 30, color: Colors.black),
                  ),
                ),

                // Main Content with Scrollable View
                SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      mainAxisAlignment:
                      isKeyboardVisible ? MainAxisAlignment.start : MainAxisAlignment.center,
                      children: [
                        if (!isKeyboardVisible) SizedBox(height: 50), // Prevent UI cutting

                        // Lottie Animation & Image Box
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Lottie.asset(
                                "assets/animations/parent.json",
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 170,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage("assets/images/messageBox/goodparent.png"),
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        // Registration Box
                        _buildRegistrationBox(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds the registration form UI with a blurred effect.
  Widget _buildRegistrationBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 320,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "REGISTER",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Quantico",
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),

              // Name Input
              TextField(
                controller: _nameController,
                decoration: _inputDecoration("Name"),
              ),
              SizedBox(height: 10),

              // Email Input
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration("Email"),
              ),
              SizedBox(height: 10),

              // Password Input
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: _inputDecoration("Password"),
              ),
              SizedBox(height: 10),

              // Error Message
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              SizedBox(height: 10),

              // Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : () => handleRegister(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Login Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Quantico",
                      fontSize: 12,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/parentLogin'),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Quantico",
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Common Input Field Decoration
  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  /// Handles registration API call
  void handleRegister(BuildContext context) async {
    String email = _emailController.text.trim();

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = "All fields are required!";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final apiService = parentApiService();
    final result = await apiService.registerParent(
      _nameController.text.trim(),
      email,
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (result != null && result.containsKey("message")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"])),
      );

      print("Raw API Response: '${result["message"]}'");

      if (result["message"].contains("Registration successful! Please check your email for a")) {
        ref.read(parentEmailProvider.notifier).state = email;
        print("Email stored in provider: $email");
        print("Navigating to Email Verification...");

        Future.delayed(Duration(milliseconds: 300), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EmailVerification()),
          );
        });
      }
    } else {
      setState(() {
        _errorMessage = "Error: Something went wrong. Please try again.";
      });
    }
  }
}
