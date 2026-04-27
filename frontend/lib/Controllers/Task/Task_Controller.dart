import 'package:get/get.dart';
import 'package:sales_grow/Models/TaskModel/GetTasks.dart';
import 'package:sales_grow/Views/Widgets/CustomBottomNav.dart';
import '../../Models/TaskModel/Task_Mode.dart';
import '../../Services/Task/Task_Services.dart';
import '../../Controllers/Dashboard/Dashboard_controller.dart';
import '../../Views/Tasks/Task_Screen.dart';
import '../../Views/Widgets/CustomAlert.dart';

class TaskController extends GetxController {
  // Observables
  var tasks = <TaskModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var allTasks = <Task>[].obs;
  final TaskService _taskService = TaskService();

  /// Fetch the current user's tasks
  Future<void> fetchTasks() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      List<TaskModel>? fetchedTasks = await _taskService.fetchMyTasks();
      if (fetchedTasks != null) {
        tasks.assignAll(fetchedTasks);
        errorMessage.value = '';
      }
    } catch (e) {
      print(e);
      errorMessage.value = e.toString();
      CustomAlert.error('Failed to fetch tasks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch all tasks and sort by createdAt in descending order
  Future<void> allfetchTasks() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      List<Task>? fetchedTasks = await _taskService.fetchAllTasks();
      if (fetchedTasks != null) {
        fetchedTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        allTasks.assignAll(fetchedTasks);
        errorMessage.value = '';
      }
    } catch (e) {
      print(e);
      errorMessage.value = e.toString();
      CustomAlert.error('Failed to fetch all tasks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a new task and refresh the list
  Future<void> createTask(
    String taskCategory,
    String taskName,
    String taskDescription,
    String assignedTo,
    String dueDate,
    String priority,
    String? customerId,
  ) async {
    try {
      isLoading.value = true;
      final created = await _taskService.createTask(
        taskCategory,
        taskName,
        taskDescription,
        assignedTo,
        dueDate,
        priority,
        customerId,
      );
      if (created == true) {
        CustomAlert.success('Task Assigned successfully!');
        await allfetchTasks(); // Refresh the list
        isLoading.value = false; // Reset loading BEFORE navigation
        
        // Wait for 2 seconds so user can see the alert
        await Future.delayed(const Duration(seconds: 2));
        
        Get.offAll(() => const CustomBottomNavBar());
      } else {
        CustomAlert.error('Something Went Wrong');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      CustomAlert.error('Failed to create task: $e');
    } finally {
      isLoading.value = false;
    }
  }


  /// Update an entire task object (used in Edit Task screen)
  Future<bool> updateTask(TaskModel updatedTask) async {
    try {
      isLoading.value = true;
      final success = await _taskService.updateFullTask(updatedTask);
      if (success) {
        await fetchTasks(); // or allfetchTasks() if you prefer refreshing all
        return true;
      } else {
        errorMessage.value = 'Update failed';
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      CustomAlert.error('Failed to update task: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }




  /// Update only the status of a given task
  Future<void> updateStatus(String status, String id) async {
    try {
      isLoading.value = true;
      final success = await _taskService.updateTask(status, id);
      print(success);
      if (success == true) {
        await allfetchTasks();
        CustomAlert.success('Status Updated');
      } else {
        CustomAlert.error('Something went Wrong');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      CustomAlert.error('Failed to update status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a task and refresh both the task list and dashboard stats
  Future<void> deleteTask(String id) async {
    try {
      isLoading.value = true;
      final success = await _taskService.deleteTask(id);
      if (success) {
        CustomAlert.success('Task deleted successfully!');
        await allfetchTasks(); // Refresh list
        
        // Also refresh dashboard stats so counts stay accurate
        try {
          if (Get.isRegistered<DashboardController>()) {
             final DashboardController dashboardController = Get.find<DashboardController>();
             await dashboardController.fetchStats();
          }
        } catch (e) {
          print('DashboardController stats refresh failed: $e');
        }
      } else {
        CustomAlert.error('Failed to delete task');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      CustomAlert.error('Deletion error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search tasks locally based on query and filters
  List<Task> searchTasks(String query, FilterState filterState) {
    final lowerQuery = query.toLowerCase();
    return allTasks.where((task) {
      bool matchesStatus =
          filterState.selectedStatuses.isEmpty ||
          filterState.selectedStatuses.contains(task.taskStatus);
      bool matchesCategory =
          filterState.selectedCategories.isEmpty ||
          filterState.selectedCategories.contains(task.taskCategory);
      bool matchesAssignedTo =
          filterState.selectedAssignedTo.isEmpty ||
          (task.assignedTo != null && filterState.selectedAssignedTo.contains(task.assignedTo!.name));
      bool matchesPriority =
          filterState.selectedPriorities.isEmpty ||
          filterState.selectedPriorities.contains(task.priority);
      bool matchesSearch =
          lowerQuery.isEmpty ||
          task.taskName.toLowerCase().contains(lowerQuery) ||
          task.taskDescription.toLowerCase().contains(lowerQuery);
      return matchesStatus &&
          matchesCategory &&
          matchesAssignedTo &&
          matchesPriority &&
          matchesSearch;
    }).toList();
  }
}
