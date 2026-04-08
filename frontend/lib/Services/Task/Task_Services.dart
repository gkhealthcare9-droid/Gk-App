// lib/Services/task_service.dart

import 'package:dio/dio.dart';
import 'package:sales_grow/Models/TaskModel/GetTasks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/TaskModel/Task_Mode.dart';
import '../../Utils/AppConstants.dart';

class TaskService {
  final Dio _dio = Dio();

  /// Fetches the logged-in user’s tasks.
  /// GET api/v1/task/my-tasks
  // Future<List<TaskModel>> fetchMyTasks() async {
  //   try {
  //     final res = await _dio.get('/api/v1/task/my-tasks');
  //     if (res.statusCode == 200 && res.data is List) {
  //       return (res.data as List)
  //           .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
  //           .toList();
  //     }
  //     throw Exception('Unexpected response format');
  //   } on DioError catch (e) {
  //     // You can inspect e.response?.data for error details
  //     throw Exception('Failed to load tasks: ${e.message}');
  //   }
  // }
  Future<List<Task>?> fetchAllTasks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get(
        '${AppConstants.BASE_URL}/api/v1/task/all',
      );

      if (response.statusCode == 200 && response.data is List) {
        print(response.data);

        return (response.data as List)
            .map((item) => Task.fromJson(item))
            .toList();
      } else {
        print('Failed to fetch customers: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('Dio error: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  Future<List<TaskModel>?> fetchMyTasks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get(
        '${AppConstants.BASE_URL}/api/v1/task/my-tasks',
      );

      if (response.statusCode == 200 && response.data is List) {
        print(response.data);

        return (response.data as List)
            .map((item) => TaskModel.fromJson(item))
            .toList();
      } else {
        print('Failed to fetch customers: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('Dio error: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  // Future<List<TaskModel>?> fetchMyTasks() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? token = prefs.getString('authToken');
  //
  //     if (token == null) throw Exception('Token not found');
  //
  //     _dio.options.headers['Authorization'] = 'Bearer $token';
  //     final response = await _dio.get(
  //       '${AppConstants.BASE_URL}/api/v1/task/my-tasks',
  //     );
  //
  //     if (response.statusCode == 200 && response.data is List) {
  //       print(response.data);
  //
  //       if (response.statusCode == 200 && response.data is List) {
  //         return (response.data as List)
  //             .map((item) => TaskModel.fromJson(item))
  //             .toList();
  //       }
  //       // on non-200, return empty list instead of null
  //       return [];
  //     } else {
  //       print('Failed to fetch customers: ${response.statusCode}');
  //       return null;
  //     }
  //   } on DioException catch (e) {
  //     print('Dio error: ${e.response?.data}');
  //     return null;
  //   } catch (e) {
  //     print('Unexpected error: $e');
  //     return null;
  //   }
  // }

  /// Creates a new task record.
  /// POST api/v1/task/create
  Future<bool?> createTask(
    String taskCategory,
    String taskName,
    String taskDescription,
    String assignedTo,
    String dueDate,
    String priority,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final payload = {
        'taskCategory': taskCategory,
        'taskName': taskName,
        'taskDescription': taskDescription,
        'assignedTo': assignedTo,
        'dueDate': dueDate,
        'priority': priority,
      };
      print(payload);
      final res = await _dio.post(
        '${AppConstants.BASE_URL}/api/v1/task/create',
        data: payload,
      );
      if (res.statusCode == 201 || res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
      throw Exception('Failed to create task');
    } on DioException catch (e) {
      throw Exception('Create task error: ${e.message}');
    }
  }

  Future<bool?> updateTask(String status, String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) return null;

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final payload = {'taskStatus': status};
      final res = await _dio.put(
        '${AppConstants.BASE_URL}/api/v1/task/update/$id',
        data: payload,
      );

      // Backend typically returns 200 for updates
      if (res.statusCode == 200 || res.statusCode == 202) {
        return true;
      }

      // If not 200 or unexpected, return null
      return null;
    } on DioException catch (e) {
      print(e);
      throw Exception('Update task error: ${e.message}');
    }
  }

  ///update task
  /// Updates an entire task (full update from Edit Task screen)
  Future<bool> updateFullTask(TaskModel task) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');

      if (token == null) return false;

      _dio.options.headers['Authorization'] = 'Bearer $token';

      final Map<String, dynamic> payload = {
        'taskName': task.taskName,
        'taskDescription': task.taskDescription,
        'taskCategory': task.taskCategory,
        'taskStatus': task.taskStatus,
        'priority': task.priority,
        'assignedTo': task.assignedTo,

        // Adjust if your model uses a nested object
        'dueDate': task.dueDate.toIso8601String(),
        'updatedAt':
            task.updatedAt.toIso8601String() ??
            DateTime.now().toIso8601String(),
      };

      final response = await _dio.put(
        '${AppConstants.BASE_URL}/api/v1/task/update/${task.id}',
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Update failed: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      print('Dio error during full update: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Unexpected error during full update: $e');
      return false;
    }
  }
}
