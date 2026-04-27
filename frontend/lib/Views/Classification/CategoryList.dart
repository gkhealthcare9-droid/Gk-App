import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/Appconstants.dart';
import '../../Utils/Colors.dart';
import '../Widgets/CustomAppBar.dart';
import '../Widgets/CustomAlert.dart';
import '../../Controllers/Dashboard/Dashboard_controller.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  List categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(AppConstants.BASE_URL + AppConstants.CATEGORY),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body);
        });
      }
    } catch (e) {
      CustomAlert.error('Failed to fetch categories: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addCategory(String name, String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.post(
        Uri.parse('${AppConstants.BASE_URL}${AppConstants.CATEGORY}/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: json.encode({'name': name, 'type': type}),
      );

      if (response.statusCode == 201) {
        CustomAlert.success('Category added successfully');
        fetchCategories();
        Get.find<DashboardController>().fetchStats();
        await Future.delayed(const Duration(seconds: 2));
        Get.back();
      }
    } catch (e) {
      CustomAlert.error('Failed to add category: $e');
    }
  }

  void _showAddDialog() {
    String name = '';
    String type = 'General';
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Category Name'),
                  onChanged: (v) => name = v,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items:
                      ['General', 'Product', 'Employee']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (v) => type = v!,
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => _addCategory(name, type),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Categories',
        actions: [
          IconButton(
            onPressed: fetchCategories,
            icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : categories.isEmpty
              ? const Center(child: Text('No categories found'))
              : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(cat['name']),
                      subtitle: Text('Type: ${cat['type']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text('Are you sure you want to delete this category?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final prefs = await SharedPreferences.getInstance();
                            String? token = prefs.getString('authToken');
                            final response = await http.delete(
                              Uri.parse(
                                '${AppConstants.BASE_URL}${AppConstants.CATEGORY}/${cat['id']}',
                              ),
                              headers: {'Authorization': 'Bearer ${token ?? ''}'},
                            );
                            if (response.statusCode == 200) {
                              CustomAlert.success('Category deleted successfully');
                              fetchCategories();
                              Get.find<DashboardController>().fetchStats();
                            } else {
                              CustomAlert.error('Failed to delete category');
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
