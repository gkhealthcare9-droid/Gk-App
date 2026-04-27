import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sales_grow/Services/AuthServices/SecureStorageService.dart';
import 'package:sales_grow/Views/Widgets/CustomBottomNav.dart';
import '../../Utils/Appconstants.dart';
import '../../Utils/Colors.dart';
import '../Widgets/CustomAppBar.dart';
import 'GlobalAddEmployee.dart';
import 'EditStaff.dart';
import '../Widgets/CustomAlert.dart';

class EmployeesListScreen extends StatefulWidget {
  const EmployeesListScreen({super.key});

  @override
  _EmployeesListScreenState createState() => _EmployeesListScreenState();
}

class _EmployeesListScreenState extends State<EmployeesListScreen> {
  List employees = [];
  bool isLoading = true;
  String _userType = '';

  @override
  void initState() {
    super.initState();
    _loadUserType();
    fetchEmployees();
  }

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userType = prefs.getString('userType') ?? '';
    });
  }

  Future<void> fetchEmployees() async {
    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(AppConstants.BASE_URL + AppConstants.Employee),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          employees = json.decode(response.body);
        });
      }
    } catch (e) {
      CustomAlert.error('Failed to fetch employees: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Staff Management',
        actions: [
          if (_userType == 'admin')
            IconButton(
              onPressed: () {
                Get.to(() => const GlobalAddEmployee())?.then((_) => fetchEmployees());
              },
              icon: const Icon(Icons.add, color: AppColors.primaryBlue),
              tooltip: 'Add Staff',
            ),
          IconButton(
            onPressed: fetchEmployees,
            icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : employees.isEmpty
              ? const Center(child: Text('No staff members found'))
              : ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    final positionName = employee['position']?['name'] ?? 'General';
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        onTap: () => _showEmployeeDetails(employee, positionName),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                          child: const Icon(Icons.person, color: AppColors.primaryBlue),
                        ),
                        title: Row(
                          children: [
                            Text(employee['name'] ?? 'Unnamed'),
                            if (employee['userType'] == 'admin') ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryBlue.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'ADMIN',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text('Position: $positionName'),
                        trailing: _userType == 'admin'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                    onPressed: () {
                                      Get.to(() => EditStaffScreen(staff: employee))?.then((shouldRefresh) {
                                        if (shouldRefresh == true) fetchEmployees();
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () => _confirmDelete(employee['id']?.toString() ?? employee['_id']?.toString() ?? '', employee['name'] ?? 'this user'),
                                  ),
                                ],
                              )
                            : const Icon(Icons.chevron_right, color: Colors.grey),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _confirmDelete(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteUser(id);
    }
  }

  Future<void> _deleteUser(String id) async {
    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.delete(
        Uri.parse('${AppConstants.BASE_URL}/api/v1/user/$id'),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );

      if (response.statusCode == 200) {
        CustomAlert.success('Staff member deleted successfully');
        fetchEmployees(); // Refresh list
      } else {
        CustomAlert.error('Failed to delete user');
      }
    } catch (e) {
      CustomAlert.error('Something went wrong: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showEmployeeDetails(dynamic employee, String positionName) {
    Get.defaultDialog(
      title: 'Staff Details',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDetailRow(Icons.person, 'Name', employee['name']?.toString() ?? 'N/A'),
          _buildDetailRow(Icons.email, 'Email', employee['email']?.toString() ?? 'N/A'),
          _buildDetailRow(Icons.phone, 'Phone', employee['phone']?.toString() ?? 'N/A'),
          _buildDetailRow(Icons.work, 'Position', positionName),
          _buildDetailRow(Icons.security, 'Role', (employee['userType']?.toString() ?? 'user').toUpperCase()),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
        onPressed: () => Get.back(),
        child: const Text('Close', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
