import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Controllers/AuthController/ProfileController.dart';
import '../../Utils/Colors.dart';
import '../AuthScreens/LoginScreen.dart';
import '../Widgets/CustomButton.dart';
import '../Widgets/CustomTextField.dart';
import '../Widgets/CustomAlert.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  StreamSubscription? _profileSubscription;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<ProfileController>();
    // Fetch profile
    controller.fetchProfile();
    
    // Initial population
    final user = controller.userProfile.value;
    _nameController.text = user.name ?? '';
    _emailController.text = user.email ?? '';
    _phoneController.text = user.phone ?? '';

    // Listen to changes and update controllers only if screen is active
    _profileSubscription = controller.userProfile.listen((user) {
      if (!mounted) return;
      if (user.name != null) _nameController.text = user.name!;
      if (user.email != null) _emailController.text = user.email!;
      if (user.phone != null) _phoneController.text = user.phone!;
    });
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      CustomAlert.error('Failed to log out: $e');
    }
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('ACCOUNT PROFILE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
          ),
        ],
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar Section
                const Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primaryBlue,
                        child: Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Fields Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Full Name',
                        controller: _nameController,
                        hintText: 'Enter name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        label: 'Email Address',
                        controller: _emailController,
                        hintText: 'Enter email',
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        hintText: 'Enter phone',
                        icon: Icons.phone_android_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onTap: () async {
                      if (_nameController.text.trim().isEmpty) {
                        CustomAlert.error('Name cannot be empty');
                        return;
                      }
                      await profileController.updateProfile(
                        name: _nameController.text,
                        email: _emailController.text,
                        phone: _phoneController.text,
                      );
                    },
                    buttonText: 'UPDATE PROFILE',
                    isYellow: true,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Last Login: ${profileController.userProfile.value.lastLogin ?? 'N/A'}",
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}