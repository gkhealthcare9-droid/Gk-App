import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/Appconstants.dart';
import '../../Utils/Colors.dart';
import '../../Controllers/Dashboard/Dashboard_controller.dart';

class StateListScreen extends StatefulWidget {
  const StateListScreen({super.key});

  @override
  _StateListScreenState createState() => _StateListScreenState();
}

class _StateListScreenState extends State<StateListScreen> {
  List states = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStates();
  }

  Future<void> fetchStates() async {
    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(AppConstants.BASE_URL + AppConstants.LOCATION + '/states'),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          states = json.decode(response.body);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch states: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addState(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.post(
        Uri.parse(AppConstants.BASE_URL + AppConstants.LOCATION + '/states/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: json.encode({'name': name}),
      );

      if (response.statusCode == 201) {
        fetchStates();
        Get.find<DashboardController>().fetchStats();
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add state: $e');
    }
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
        actions: [
          IconButton(onPressed: fetchStates, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : states.isEmpty
              ? const Center(child: Text('No states found'))
              : ListView.builder(
                  itemCount: states.length,
                  itemBuilder: (context, index) {
                    final state = states[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                          child: const Icon(Icons.map, color: AppColors.primaryBlue),
                        ),
                        title: Text(state['name']),
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
