import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/Appconstants.dart';
import '../../Utils/Colors.dart';
import '../../Controllers/Dashboard/Dashboard_controller.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  _CityListScreenState createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  List cities = [];
  List states = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await Future.wait([fetchCities(), fetchStates()]);
  }

  Future<void> fetchStates() async {
    try {
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
      print('Error fetching states: $e');
    }
  }

  Future<void> fetchCities() async {
    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse(AppConstants.BASE_URL + AppConstants.LOCATION + '/cities'),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          cities = json.decode(response.body);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch cities: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addCity(String name, int stateId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.post(
        Uri.parse(AppConstants.BASE_URL + AppConstants.LOCATION + '/cities/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: json.encode({'name': name, 'stateId': stateId}),
      );

      if (response.statusCode == 201) {
        fetchCities();
        Get.find<DashboardController>().fetchStats();
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add city: $e');
    }
  }

  void _showAddDialog() {
    String name = '';
    int? selectedStateId;
    if (states.isNotEmpty) selectedStateId = states[0]['id'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add City'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'City Name'),
              onChanged: (v) => name = v,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedStateId,
              items: states
                  .map<DropdownMenuItem<int>>((e) => DropdownMenuItem<int>(
                        value: e['id'],
                        child: Text(e['name']),
                      ))
                  .toList(),
              onChanged: (v) => selectedStateId = v,
              decoration: const InputDecoration(labelText: 'State'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (selectedStateId != null) {
                _addCity(name, selectedStateId!);
              }
            },
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
        title: const Text('Geography: Cities'),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(onPressed: fetchCities, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cities.isEmpty
              ? const Center(child: Text('No cities found'))
              : ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                          child: const Icon(Icons.location_city, color: AppColors.primaryBlue),
                        ),
                        title: Text(city['name']),
                        subtitle: Text('State: ${city['State']?['name'] ?? 'Unknown'}'),
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
