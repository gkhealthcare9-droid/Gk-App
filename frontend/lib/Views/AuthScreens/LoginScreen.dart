import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utils/Responsive.dart';
import '../../Controllers/AuthController/Auth_controller.dart';
import '../../Utils/Colors.dart';
import '../Widgets/CustomTextField.dart';
import '../Widgets/CustomButton.dart';
import '../Widgets/CustomLazyLoader.dart';
import '../Widgets/CustomAlert.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _loginController = Get.put(LoginController());
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: Obx(() {
        if (_loginController.isLoading.value) {
          return const CustomLazyLoader();
        }
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.isDesktop(context) ? 450 : double.infinity,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section - Soft Light Blue
                  Container(
                    height: Responsive.isDesktop(context) ? 200 : MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryBlue.withOpacity(0.8), AppColors.accentBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(60),
                        bottomRight: Radius.circular(60),
                      ),
                    ),
                    child: AnimatedView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.security_rounded, size: Responsive.isDesktop(context) ? 40 : 60, color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "GK Healthcare",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.isDesktop(context) ? 22 : 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            "Enterprise Support System",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedView(
                            delay: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Welcome Back",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Secure sign-in for authorized personnel only.",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.grey.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          AnimatedView(
                            delay: 200,
                            child: CustomTextField(
                              controller: _emailController,
                              label: 'Email',
                              hintText: 'Enter your email',
                              icon: Icons.alternate_email_rounded,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Required';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          AnimatedView(
                            delay: 300,
                            child: CustomPasswordField(
                              controller: _passwordController,
                              label: 'Password',
                              hintText: 'Enter your password',
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Required';
                                return null;
                              },
                              footer: GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                          AnimatedView(
                            delay: 400,
                            child: SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                onTap: () {
                                  // Trigger form validation
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  final email = _emailController.text.trim();
                                  final password = _passwordController.text;

                                  // Secondary logic checks (Email Regex & Password Length)
                                  final emailRegex = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$");
                                  
                                  
                                  if (!emailRegex.hasMatch(email)) {
                                    CustomAlert.error("Please enter a valid email format (e.g. user@example.com).");
                                    return;
                                  }


                                  if (password.length < 6) {
                                    CustomAlert.error("Security requirement: Password must be at least 6 characters.");
                                    return;
                                  }

                                  _loginController.login(email, password);
                                },
                                buttonText: 'Login',
                                isYellow: true,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
