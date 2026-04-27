import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/Appconstants.dart';
import '../../Utils/Colors.dart';
import '../../Controllers/Dashboard/Dashboard_controller.dart';
import '../Widgets/CustomAlert.dart';

class StateListScreen extends StatefulWidget {
  const StateListScreen({super.key});

  @override
  _StateListScreenState createState() => _StateListScreenState();
}

class _StateListScreenState extends State<StateListScreen> {
  List states = [];
  bool isLoading = true;
  String? userType;

  @override
  void initState() {
    super.initState();
    _loadUserType();
    fetchStates();
  }

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('userType');
    });
  }

  bool get isAdmin => userType == 'admin';

  Future<void> fetchStates() async {
    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse('${AppConstants.BASE_URL}${AppConstants.LOCATION}/states'),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          states = json.decode(response.body);
        });
      }
    } catch (e) {
      CustomAlert.error('Failed to fetch states: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addState(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.post(
        Uri.parse(
          '${AppConstants.BASE_URL}${AppConstants.LOCATION}/states/add',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: json.encode({'name': name}),
      );

      if (response.statusCode == 201) {
        CustomAlert.success('State added successfully');
        fetchStates();
        Get.find<DashboardController>().fetchStats();
        Get.back();
      }
    } catch (e) {
      CustomAlert.error('Failed to add state: $e');
    }
  }

  Future<void> _updateState(int id, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.put(
        Uri.parse('${AppConstants.BASE_URL}${AppConstants.LOCATION}/states/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: json.encode({'name': name}),
      );

      if (response.statusCode == 200) {
        CustomAlert.success('State updated successfully');
        fetchStates();
        Get.back();
      } else {
        CustomAlert.error('Failed to update state');
      }
    } catch (e) {
      CustomAlert.error('Failed to update state: $e');
    }
  }

  Future<void> _deleteState(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.delete(
        Uri.parse('${AppConstants.BASE_URL}${AppConstants.LOCATION}/states/$id'),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );

      if (response.statusCode == 200) {
        CustomAlert.success('State deleted successfully');
        fetchStates();
        Get.find<DashboardController>().fetchStats();
      } else {
        final error = json.decode(response.body)['error'] ?? 'Failed to delete state';
        CustomAlert.error(error);
      }
    } catch (e) {
      CustomAlert.error('Failed to delete state: $e');
    }
  }

  void _showEditDialog(dynamic state) {
    String name = state['name'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit State'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'State Name'),
          controller: TextEditingController(text: name),
          onChanged: (v) => name = v,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => _updateState(state['id'], name),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(dynamic state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete State'),
        content: Text('Are you sure you want to delete ${state['name']}? This will fail if there are cities in this state.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _deleteState(state['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    String name = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add State'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'State Name'),
          onChanged: (v) => name = v,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => _addState(name),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geography: States'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: fetchStates, icon: const Icon(Icons.refresh)),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : states.isEmpty
              ? const Center(child: Text('No states found'))
              : ListView.builder(
                itemCount: states.length,
                itemBuilder: (context, index) {
                  final state = states[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                        child: const Icon(
                          Icons.map,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      title: Text(state['name']),
                      trailing: isAdmin ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.primaryBlue),
                            onPressed: () => _showEditDialog(state),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteDialog(state),
                          ),
                        ],
                      ) : null,
                    ),
                  );
                },
              ),
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }
}
