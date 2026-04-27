import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Controllers/AuthController/ProfileController.dart';
import 'package:sales_grow/Controllers/Task/Task_Controller.dart';
import 'package:sales_grow/Views/AuthScreens/LoginScreen.dart';
import 'package:sales_grow/Views/Widgets/CustomBottomNav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Controllers/AddCustomer/Customer_controller.dart';
import 'Controllers/Dashboard/Dashboard_controller.dart';
import 'Controllers/Product/Product.dart';
import 'Utils/AppTheme.dart';
import 'package:sales_grow/Views/Customer/CustomerList.dart';
import 'package:sales_grow/Utils/Appconstants.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('authToken');
  
  runApp(MyApp(isLoggedIn: token != null && token.isNotEmpty));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
      theme: AppTheme.lightTheme,
      initialBinding: BindingsBuilder(() {
        Get.lazyPut(() => ProductController(), fenix: true);
        Get.lazyPut(() => CustomerController(), fenix: true);
        Get.lazyPut(() => TaskController(), fenix: true);
        Get.lazyPut(() => DashboardController(), fenix: true);
        Get.lazyPut(() => ProfileController(), fenix: true);
      }),
      // Automatically navigate to Home if token exists, otherwise Login
      home: widget.isLoggedIn ? const CustomBottomNavBar() : const LoginScreen(),
      getPages: [
        GetPage(name: AppConstants.routeCustomers, page: () => const CustomersList()),
      ],
    );
  }
}
