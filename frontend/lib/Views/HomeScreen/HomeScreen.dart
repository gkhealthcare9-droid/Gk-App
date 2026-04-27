import 'package:flutter/material.dart';
import '../../Utils/Responsive.dart';
import 'package:get/get.dart';
import '../../Utils/Colors.dart';
import '../../Controllers/AddCustomer/Customer_controller.dart';
import '../../Controllers/Dashboard/Dashboard_controller.dart';
import '../Customer/AddCustomer.dart';
import '../Customer/CustomerList.dart';
import '../Leads/Add_Leads_Screen.dart';
import '../Leads/All_Leads_Screen.dart';
import '../OutstandingScreen/Outstanding_screen.dart';
import '../ProductScreen/CreateProduct_screen.dart';
import '../ProductScreen/ViewProducts.dart';
import '../Expenses/expenses.dart';
import '../Vendor/AddVendor.dart';
import '../Vendor/VendorList.dart';
import '../Widgets/CustomLazyLoader.dart';
import '../../Services/AuthServices/SecureStorageService.dart';
import 'ReportScreen.dart';
import 'ViewReportScreen.dart';
import '../EmployeeManagement/EmployeeList.dart';
import '../Classification/CategoryList.dart';
import '../Geography/StateList.dart';
import '../Geography/CityList.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userType;
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final name = await SecureStorageService.getUserName();
    final type = await SecureStorageService.getUserType() ?? 'User';

    if (mounted) {
      setState(() {
        userName = name ?? 'Admin';
        userType = type[0].toUpperCase() + type.substring(1).toLowerCase();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userType == null) {
      return const Scaffold(body: CustomLazyLoader());
    }

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.isDesktop(context) ? 1200 : double.infinity,
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 40, 25, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dashboard",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 10),
                  child: AnimatedView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "WELCOME BACK, ${userName?.toUpperCase() ?? 'ADMIN'}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryBlue,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive.isDesktop(context) ? 4 : (Responsive.isTablet(context) ? 3 : 2),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.15,
                  ),
                  delegate: SliverChildListDelegate([
                    Obx(() {
                      final stats = Get.find<DashboardController>().stats;
                      return _buildModernCard('Total Customers: ${stats['customers'] ?? 0}', 'Management', Icons.people_alt_rounded, AppColors.accentBlue, () => Get.to(() => const CustomersList())?.then((_) => Get.find<DashboardController>().fetchStats()), 200);
                    }),
                    Obx(() {
                      final stats = Get.find<DashboardController>().stats;
                      return _buildModernCard('Total Vendors: ${stats['vendors'] ?? 0}', 'Supply Chain', Icons.storefront_rounded, Colors.teal, () => Get.to(() => VendorsListScreen())?.then((_) => Get.find<DashboardController>().fetchStats()), 300);
                    }),
                    Obx(() {
                      final stats = Get.find<DashboardController>().stats;
                      return _buildModernCard('Total Staff: ${stats['employees'] ?? 0}', 'Staffing', Icons.badge_rounded, Colors.indigo, () => Get.to(() => const EmployeesListScreen())?.then((_) => Get.find<DashboardController>().fetchStats()), 400);
                    }),
                    _buildModernCard('Onboarding', 'Add Customer', Icons.person_add_rounded, Colors.orange, () => Get.to(() => AddCustomerScreen())?.then((_) => Get.find<DashboardController>().fetchStats()), 500),
                    _buildModernCard('Procurement', 'Add Vendor', Icons.add_home_work_rounded, Colors.deepPurple, () => Get.to(() => AddVendorScreen())?.then((_) => Get.find<DashboardController>().fetchStats()), 600),
                    _buildModernCard('Analytics', 'Gen. Reports', Icons.assignment_rounded, Colors.indigo, () => Get.to(() => const ReportScreen()), 700),
                    _buildModernCard('Archive', 'View Reports', Icons.analytics_rounded, Colors.pinkAccent, () => Get.to(() => const ViewReportScreen()), 800),
                    Obx(() {
                      final stats = Get.find<DashboardController>().stats;
                      return _buildModernCard('Total Products: ${stats['products'] ?? 0}', 'Inventory', Icons.inventory_2_rounded, Colors.blueGrey, () => Get.to(() => ProductForm())?.then((_) => Get.find<DashboardController>().fetchStats()), 900);
                    }),
                    _buildModernCard('Finance', 'Manage Expenses', Icons.account_balance_wallet_rounded, Colors.green, () => Get.to(() => const ExpenseScreen()), 1000),
                    _buildModernCard('Database', 'All Products', Icons.view_list_rounded, Colors.redAccent, () => Get.to(() => const ViewProducts()), 1100),
                    Obx(() {
                      final stats = Get.find<DashboardController>().stats;
                      final totalOutstanding = stats['totalOutstanding'] ?? 0;
                      return _buildModernCard('Outstanding: ₹$totalOutstanding', 'Payments', Icons.insights_rounded, AppColors.secondaryBlue, () => Get.to(() => const OutstandingAllScreen()), 1200);
                    }),
                    Obx(() {
                      final stats = Get.find<DashboardController>().stats;
                      return _buildModernCard('Total Leads: ${stats['leads'] ?? 0}', 'Sales', Icons.add_location_alt_rounded, Colors.brown, () => Get.to(() => const AddLeadScreen())?.then((_) => Get.find<DashboardController>().fetchStats()), 1300);
                    }),
                    _buildModernCard('Marketing', 'All Leads', Icons.map_rounded, Colors.cyan, () => Get.to(() => const LeadsScreen()), 1400),
                    Obx(() {
                      final stats = Get.find<DashboardController>().stats;
                      return _buildModernCard('Total Categories: ${stats['categories'] ?? 0}', 'Classification', Icons.category_rounded, Colors.amber, () => Get.to(() => const CategoryListScreen())?.then((_) => Get.find<DashboardController>().fetchStats()), 1500);
                    }),
                    _buildModernCard('Geography', 'States', Icons.map_rounded, Colors.indigoAccent, () => Get.to(() => const StateListScreen()), 1600),
                    _buildModernCard('Geography', 'Cities', Icons.location_city_rounded, Colors.blueGrey, () => Get.to(() => const CityListScreen()), 1700),
                  ]),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard(String dynamicBrief, String staticCategory, IconData icon, Color color, VoidCallback onTap, int delay) {
    return AnimatedView(
      delay: delay,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.02),
                blurRadius: 40,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                dynamicBrief.toUpperCase(),
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: color, letterSpacing: 1.5),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  staticCategory,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black.withOpacity(0.8),
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