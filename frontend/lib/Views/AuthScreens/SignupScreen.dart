import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/AuthController/Auth_controller.dart';
import '../../Utils/Colors.dart';
import '../AuthScreens/LoginScreen.dart';
import '../Widgets/CustomTextField.dart';
import '../Widgets/CustomButton.dart';
import '../Widgets/CustomAgreeWidget.dart';
import '../Widgets/CustomLazyLoader.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final SignupController _signupController = Get.put(SignupController());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool agreedToTerms = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: Obx(() {
        if (_signupController.isLoading.value) {
          return const CustomLazyLoader();
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Soft Light Blue
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 60,
                  bottom: 40,
                  left: 30,
                  right: 30,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentBlue,
                      AppColors.primaryBlue.withOpacity(0.8),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(60),
                    bottomLeft: Radius.circular(60),
                  ),
                ),
                child: AnimatedView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Registration Hub",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Join the medical network and simplify your daily operational healthcare tasks.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AnimatedView(
                        delay: 100,
                        child: CustomTextField(
                          controller: _nameController,
                          label: 'FULL NAME',
                          hintText: 'John Doe',
                          icon: Icons.person_outline,
                        ),
                      ),
                      AnimatedView(
                        delay: 200,
                        child: CustomTextField(
                          controller: _emailController,
                          label: 'EMAIL ADDRESS',
                          hintText: 'john@example.com',
                          icon: Icons.alternate_email_outlined,
                        ),
                      ),
                      AnimatedView(
                        delay: 300,
                        child: CustomTextField(
                          controller: _phoneController,
                          label: 'PHONE NUMBER',
                          hintText: '+91 9xxxxxxxxx',
                          icon: Icons.phone_android_outlined,
                        ),
                      ),
                      AnimatedView(
                        delay: 400,
                        child: CustomPasswordField(
                          controller: _passwordController,
                          label: 'PASSWORD',
                          hintText: 'Create password',
                        ),
                      ),
                      AnimatedView(
                        delay: 500,
                        child: CustomPasswordField(
                          controller: _confirmPasswordController,
                          label: 'CONFIRM PASSWORD',
                          hintText: 'Confirm password',
                        ),
                      ),

                      const SizedBox(height: 15),
                      AnimatedView(
                        delay: 600,
                        child: AgreeTermsCheckbox(
                          value: agreedToTerms,
                          onChanged: (val) {
                            setState(() => agreedToTerms = val);
                          },
                        ),
                      ),

                      const SizedBox(height: 35),
                      AnimatedView(
                        delay: 700,
                        child: SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            onTap: () {
                              if (!agreedToTerms) {
                                Get.snackbar(
                                  'Alert',
                                  'Please agree to terms and conditions',
                                );
                                return;
                              }
                              if (_passwordController.text !=
                                  _confirmPasswordController.text) {
                                Get.snackbar('Error', 'Passwords do not match');
                                return;
                              }
                              _signupController.signup(
                                _nameController.text.trim(),
                                _emailController.text.trim(),
                                _phoneController.text.trim(),
                                _passwordController.text.trim(),
                              );
                            },
                            buttonText: 'GET STARTED',
                            isYellow: true,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      AnimatedView(
                        delay: 800,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already using GK Healthcare? ",
                              style: TextStyle(
                                color: AppColors.grey.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap:
                                  () => Get.to(
                                    () => const LoginScreen(),
                                    transition: Transition.leftToRightWithFade,
                                  ),
                              child: const Text(
                                "Login Hub",
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
