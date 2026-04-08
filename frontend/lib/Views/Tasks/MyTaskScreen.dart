import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Controllers/Task/Task_Controller.dart';

class MyTaskListScreen extends StatefulWidget {
  const MyTaskListScreen({super.key});

  @override
  State<MyTaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<MyTaskListScreen> {
  final TaskController taskController = Get.put(TaskController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () async {
      taskController.fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Your Tasks'),
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Obx(() {
          if (taskController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (taskController.tasks.isEmpty) {
            return const Center(child: Text('No tasks found'));
          }
          return RefreshIndicator(
            onRefresh: taskController.allfetchTasks,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: taskController.tasks.length,
              itemBuilder: (context, index) {
                final task = taskController.tasks[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.taskName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Category: ${task.taskCategory}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${task.taskStatus}',
                          style: TextStyle(
                            color:
                                task.taskStatus == 'Pending'
                                    ? Colors.red
                                    : task.taskStatus == 'In Progress'
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),

                        const SizedBox(height: 4),
                        Text(
                          'Due Date: ${DateFormat.yMMMd().format(task.dueDate)}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Priority: ${task.priority}',
                          style: TextStyle(
                            color:
                                task.priority == 'High'
                                    ? Colors.red
                                    : task.priority == 'Medium'
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          task.taskDescription,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 20),
                        Obx(() {
                          if (taskController.isLoading.value) {
                            return CircularProgressIndicator();
                          }
                          return Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  taskController.updateStatus(
                                    'Completed',
                                    task.id,
                                  );
                                },
                                icon: Icon(
                                  Icons.check_circle,
                                  size: 30,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
