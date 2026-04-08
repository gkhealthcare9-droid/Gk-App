import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sales_grow/Models/TaskModel/Task_Mode.dart';
import '../../Controllers/Task/Task_Controller.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel? task;

  const EditTaskScreen({super.key, this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final TaskController taskController = Get.find<TaskController>();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _taskNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late String _selectedTaskType;
  late String _selectedStatus;
  late String _selectedPriority;
  late String
  _selectedAssignedTo; // Updated to String, assuming user.id is String
  late DateTime _selectedDueDate;

  bool _isInitialized = false;

  void _initialize() {
    if (_isInitialized) return;
    final task = widget.task;
    print('Initializing with task: $task'); // Debug log
    _taskNameController = TextEditingController(text: task?.taskName ?? '');
    _descriptionController = TextEditingController(
      text: task?.taskDescription ?? '',
    );
    _categoryController = TextEditingController(text: task?.taskCategory ?? '');
    _selectedTaskType = task?.taskCategory ?? 'Service';
    _selectedStatus = task?.taskStatus ?? 'Pending';
    _selectedPriority = task?.priority ?? 'Medium';
    // Assuming task.assignedTo is a User object, use its id
    _selectedAssignedTo = task?.assignedTo ?? ''; // Adjust if id type differs
    _selectedDueDate = task?.dueDate ?? DateTime.now();
    _isInitialized = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialize();
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF14B8A6),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final updatedTask = (widget.task ??
              TaskModel(
                id: '',
                // Default int value for id
                dueDate: _selectedDueDate,
                createdAt: DateTime.now(),
                assignedTo: _selectedAssignedTo ?? "",
                // Adjust based on TaskModel
                taskCategory: _selectedTaskType,
                priority: _selectedPriority,
                updatedAt: DateTime.now(),
                taskStatus: _selectedStatus,
                taskNumber: 0,
                // Default int value for taskNumber
                taskName: _taskNameController.text,
                taskDescription: _descriptionController.text,
              ))
          .copyWith(
            taskName: _taskNameController.text,
            taskDescription: _descriptionController.text,
            taskCategory: _selectedTaskType,
            taskStatus: _selectedStatus,
            priority: _selectedPriority,
            assignedTo:
                _selectedAssignedTo.isNotEmpty ? _selectedAssignedTo : null,
            // Adjust based on TaskModel
            dueDate: _selectedDueDate,
            updatedAt: DateTime.now(),
          );

      bool success = await taskController.updateTask(updatedTask);
      if (success) {
        await taskController.allfetchTasks();
        Get.back();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully'),
            backgroundColor: Color(0xFF14B8A6),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${taskController.errorMessage.value}'),
            backgroundColor: const Color(0xFFF43F5E),
          ),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.blueAccent.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blueAccent, width: 2),
      ),
      prefixIcon: Icon(Icons.edit, color: Colors.blueAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      _initialize();
      return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.purple.shade100],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              // ⬇ Extra padding at bottom to push content + background down
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height +
                      100, // ⬅ extend background height
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () => Get.back(),
                        ),
                      ),
                      const SizedBox(height: 0),
                      Text(
                        'Edit Task',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.blue.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Card(
                          color: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  decoration: _inputDecoration('Task Type'),
                                  initialValue: _selectedTaskType,
                                  items:
                                      [
                                            'Service',
                                            'Sales',
                                            'Supply',
                                            'Visit',
                                            'Meeting',
                                            'Payment follow up',
                                            'Installation',
                                            'Whats App',
                                            'Message',
                                            'Leads',
                                            'Courier',
                                          ]
                                          .map(
                                            (t) => DropdownMenuItem(
                                              value: t,
                                              child: Text(
                                                t,
                                                style: GoogleFonts.poppins(),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (v) => setState(
                                        () => _selectedTaskType = v!,
                                      ),
                                  validator:
                                      (v) =>
                                          v == null ? 'Select task type' : null,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: _taskNameController,
                                  decoration: _inputDecoration('Task Title'),
                                  validator:
                                      (v) =>
                                          v == null || v.isEmpty
                                              ? 'Required'
                                              : null,
                                  style: GoogleFonts.poppins(),
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: _descriptionController,
                                  decoration: _inputDecoration('Description'),
                                  maxLines: 4,
                                  validator:
                                      (v) =>
                                          v == null || v.isEmpty
                                              ? 'Required'
                                              : null,
                                  style: GoogleFonts.poppins(),
                                ),
                                SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  decoration: _inputDecoration('Status'),
                                  initialValue: _selectedStatus,
                                  items:
                                      ['Pending', 'In Progress', 'Completed']
                                          .map(
                                            (s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(
                                                s,
                                                style: GoogleFonts.poppins(),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (v) =>
                                          setState(() => _selectedStatus = v!),
                                  validator:
                                      (v) => v == null ? 'Select status' : null,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  decoration: _inputDecoration('Priority'),
                                  initialValue: _selectedPriority,
                                  items:
                                      ['Low', 'Medium', 'High']
                                          .map(
                                            (p) => DropdownMenuItem(
                                              value: p,
                                              child: Text(
                                                p,
                                                style: GoogleFonts.poppins(),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (v) => setState(
                                        () => _selectedPriority = v!,
                                      ),
                                  validator:
                                      (v) =>
                                          v == null ? 'Select priority' : null,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Obx(() {
                                  // Extract unique assigned users by ID
                                  final seenIds = <String>{};
                                  final uniqueAssignees =
                                      taskController.allTasks
                                          .map((task) => task.assignedTo)
                                          .where(
                                            (user) => seenIds.add(user.id),
                                          ) // filters duplicates
                                          .toList();

                                  return DropdownButtonFormField<String>(
                                    decoration: _inputDecoration('Assigned To'),
                                    // Updated to match other dropdowns
                                    initialValue:
                                        uniqueAssignees.any(
                                              (user) =>
                                                  user.id ==
                                                  _selectedAssignedTo,
                                            )
                                            ? _selectedAssignedTo
                                            : null,
                                    items:
                                        uniqueAssignees
                                            .map(
                                              (user) =>
                                                  DropdownMenuItem<String>(
                                                    value: user.id,
                                                    child: Text(
                                                      user.name,
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                  ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedAssignedTo = value!;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select an assignee';
                                      }
                                      return null;
                                    },
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.blueAccent,
                                    ),
                                  );
                                }),
                                SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () => _selectDueDate(context),
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      decoration: _inputDecoration(
                                        'Due Date',
                                      ).copyWith(
                                        suffixIcon: Icon(
                                          Icons.calendar_today,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      controller: TextEditingController(
                                        text: DateFormat.yMMMd().format(
                                          _selectedDueDate,
                                        ),
                                      ),
                                      validator:
                                          (_) =>
                                              null,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _saveTask,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 20,
                                    ),
                                  ),
                                  child: Text(
                                    'Save Changes',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e, stack) {
      print('Build error: $e\nStack: $stack');
      return Scaffold(body: Center(child: Text('Error loading screen: $e')));
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration(label),
      validator: validator,
      style: GoogleFonts.poppins(),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required Color accentColor,
  }) {
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration(label),
      initialValue: value,
      items:
          items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: GoogleFonts.poppins()),
                ),
              )
              .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Select $label' : null,
      icon: Icon(Icons.arrow_drop_down, color: accentColor),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDueDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          decoration: _inputDecoration('Due Date').copyWith(
            suffixIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
          ),
          controller: TextEditingController(
            text: DateFormat.yMMMd().format(_selectedDueDate),
          ),
          validator: (_) => null,
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }
}
