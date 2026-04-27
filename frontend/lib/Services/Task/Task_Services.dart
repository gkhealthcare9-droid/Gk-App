// lib/Services/task_service.dart

import 'package:dio/dio.dart';
import 'package:sales_grow/Models/TaskModel/GetTasks.dart';
import '../ApiService.dart';
import '../../Models/TaskModel/Task_Mode.dart';
import '../../Utils/AppConstants.dart';

class TaskService {
  final Dio _dio = ApiService().dio;

  Future<List<Task>?> fetchAllTasks() async {
    try {
      final response = await _dio.get('/api/v1/task/all');

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => Task.fromJson(item))
            .toList();
      } else {
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
      final response = await _dio.get('/api/v1/task/my-tasks');

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => TaskModel.fromJson(item))
            .toList();
      } else {
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

  Future<bool?> createTask(
    String taskCategory,
    String taskName,
    String taskDescription,
    String assignedTo,
    String dueDate,
    String priority,
    String? customerId,
  ) async {
    try {
      final payload = {
        'taskCategory': taskCategory,
        'taskName': taskName,
        'taskDescription': taskDescription,
        'assignedTo': assignedTo,
        'dueDate': dueDate,
        'priority': priority,
        'customerId': customerId,
      };
      final res = await _dio.post(
        '/api/v1/task/create',
        data: payload,
      );
      return res.statusCode == 201 || res.statusCode == 200;
    } on DioException catch (e) {
      print('Create task error: ${e.response?.data}');
      return false;
    }
  }

  Future<bool?> updateTask(String status, String id) async {
    try {
      final payload = {'taskStatus': status};
      final res = await _dio.put(
        '/api/v1/task/update/$id',
        data: payload,
      );
      return res.statusCode == 200 || res.statusCode == 202;
    } on DioException catch (e) {
      print('Update status error: ${e.response?.data}');
      return false;
    }
  }

  Future<bool> updateFullTask(TaskModel task) async {
    try {
      final Map<String, dynamic> payload = {
        'taskName': task.taskName,
        'taskDescription': task.taskDescription,
        'taskCategory': task.taskCategory,
        'taskStatus': task.taskStatus,
        'priority': task.priority,
        'assignedTo': task.assignedTo,
        'dueDate': task.dueDate.toIso8601String(),
      };

      final response = await _dio.put(
        '/api/v1/task/update/${task.id}',
        data: payload,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      print('Dio error during full update: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Unexpected error during full update: $e');
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      final response = await _dio.delete('/api/v1/task/$id');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Dio error during deletion: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Unexpected error during deletion: $e');
      return false;
    }
  }
}
