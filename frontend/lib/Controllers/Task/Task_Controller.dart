import 'package:get/get.dart';
import 'package:sales_grow/Models/TaskModel/GetTasks.dart';
import 'package:sales_grow/Views/Widgets/CustomBottomNav.dart';
import '../../Models/TaskModel/Task_Mode.dart';
import '../../Services/Task/Task_Services.dart';
import '../../Views/Tasks/Task_Screen.dart';

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
      Get.snackbar('Error', 'Failed to fetch tasks: $e');
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
      Get.snackbar('Error', 'Failed to fetch all tasks: $e');
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
      );
      if (created == true) {
        Get.snackbar('Success', 'Task Assigned');
        Get.offAll(() => CustomBottomNavBar());
      } else {
        Get.snackbar('Error', 'Something Went Wrong');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to create task: $e');
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
      Get.snackbar('Error', 'Failed to update task: $e');
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
        Get.snackbar('Success', 'Status Updated');
      } else {
        Get.snackbar('Error', 'Something went Wrong');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to update status: $e');
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
          filterState.selectedAssignedTo.contains(task.assignedTo.name);
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
