import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Controllers/Task/Task_Controller.dart';
import 'package:sales_grow/Views/SplashScreen/SplashScreen.dart';

import 'Controllers/AddCustomer/Customer_controller.dart';
import 'Controllers/Product/Product.dart';
import 'Utils/AppTheme.dart';


void main(){
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
        Get.put(ProductController());
        Get.put(CustomerController());
        Get.put(TaskController());
      }),
      home: const SplashScreen(),
    );
  }
}
