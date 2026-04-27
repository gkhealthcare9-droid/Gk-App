import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/Appconstants.dart';
import '../../Utils/Colors.dart';
import '../../Controllers/Dashboard/Dashboard_controller.dart';
import '../Widgets/CustomAlert.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  _CityListScreenState createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  List cities = [];
  List states = [];
  bool isLoading = true;
  String? userType;

  @override
  void initState() {
    super.initState();
    _loadUserType();
    fetchInitialData();
  }

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('userType');
    });
  }

  bool get isAdmin => userType == 'admin';

  Future<void> fetchInitialData() async {
    await Future.wait([fetchCities(), fetchStates()]);
  }

  Future<void> fetchStates() async {
    try {
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
      print('Error fetching states: $e');
    }
  }

  Future<void> fetchCities() async {
    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse('${AppConstants.BASE_URL}${AppConstants.LOCATION}/cities'),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          cities = json.decode(response.body);
        });
      }
    } catch (e) {
      CustomAlert.error('Failed to fetch cities: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addCity(String name, int stateId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.post(
        Uri.parse(
          '${AppConstants.BASE_URL}${AppConstants.LOCATION}/cities/add',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: json.encode({'name': name, 'stateId': stateId}),
      );

      if (response.statusCode == 201) {
        CustomAlert.success('City added successfully');
        fetchCities();
        Get.find<DashboardController>().fetchStats();
        Get.back();
      }
    } catch (e) {
      CustomAlert.error('Failed to add city: $e');
    }
  }

  void _showAddDialog() {
    String name = '';
    int? selectedStateId;
    if (states.isNotEmpty) selectedStateId = states[0]['id'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                  initialValue: selectedStateId,
                  items:
                      states
                          .map<DropdownMenuItem<int>>(
                            (e) => DropdownMenuItem<int>(
                              value: e['id'],
                              child: Text(e['name']),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => selectedStateId = v,
                  decoration: const InputDecoration(labelText: 'State'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedStateId != null) {
                    _addCity(name, selectedStateId!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                child: const Text(
                  'Add City',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _updateCity(int id, String name, int stateId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.put(
        Uri.parse(
          '${AppConstants.BASE_URL}${AppConstants.LOCATION}/cities/$id',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: json.encode({'name': name, 'stateId': stateId}),
      );

      if (response.statusCode == 200) {
        CustomAlert.success('City updated successfully');
        fetchCities();
        Get.back();
      } else {
        CustomAlert.error('Failed to update city');
      }
    } catch (e) {
      CustomAlert.error('Failed to update city: $e');
    }
  }

  Future<void> _deleteCity(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      final response = await http.delete(
        Uri.parse(
          '${AppConstants.BASE_URL}${AppConstants.LOCATION}/cities/$id',
        ),
        headers: {'Authorization': 'Bearer ${token ?? ''}'},
      );

      if (response.statusCode == 200) {
        CustomAlert.success('City deleted successfully');
        fetchCities();
        Get.find<DashboardController>().fetchStats();
      } else {
        CustomAlert.error('Failed to delete city');
      }
    } catch (e) {
      CustomAlert.error('Failed to delete city: $e');
    }
  }

  void _showEditDialog(dynamic city) {
    String name = city['name'];
    int? selectedStateId = city['stateId'];
    if (selectedStateId == null && states.isNotEmpty) {
      selectedStateId = states[0]['id'];
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit City'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'City Name'),
                  controller: TextEditingController(text: name),
                  onChanged: (v) => name = v,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: selectedStateId,
                  items:
                      states
                          .map<DropdownMenuItem<int>>(
                            (e) => DropdownMenuItem<int>(
                              value: e['id'],
                              child: Text(e['name']),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => selectedStateId = v,
                  decoration: const InputDecoration(labelText: 'State'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedStateId != null) {
                    _updateCity(city['id'], name, selectedStateId!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(dynamic city) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete City'),
            content: Text('Are you sure you want to delete ${city['name']}?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  _deleteCity(city['id']);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
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
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: fetchCities, icon: const Icon(Icons.refresh)),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : cities.isEmpty
              ? const Center(child: Text('No cities found'))
              : ListView.builder(
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                        child: const Icon(
                          Icons.location_city,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      title: Text(city['name']),
                      subtitle: Text(
                        'State: ${city['State']?['name'] ?? 'Unknown'}',
                      ),
                      trailing: isAdmin ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.primaryBlue,
                            ),
                            onPressed: () => _showEditDialog(city),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteDialog(city),
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
