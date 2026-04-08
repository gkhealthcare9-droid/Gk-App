import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sales_grow/Models/TaskModel/Task_Mode.dart';
import '../../Controllers/Task/Task_Controller.dart';
import '../../Models/TaskModel/GetTasks.dart';
import 'dart:async';

import 'EditTaskScreen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  final TaskController taskController = Get.put(TaskController());
  final FilterState _filterState = FilterState();
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    Future.delayed(Duration.zero, () async {
      await taskController.allfetchTasks();
      _animationController.forward();
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _animationController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  int get activeFilterCount {
    return _filterState.selectedStatuses.length +
        _filterState.selectedCategories.length +
        _filterState.selectedAssignedTo.length +
        _filterState.selectedPriorities.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Obx(() {
          if (taskController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF14B8A6),
                strokeWidth: 5,
              ),
            );
          }
          if (taskController.errorMessage.isNotEmpty) {
            return _buildErrorState();
          }
          final filteredTasks = taskController.searchTasks(
            _searchController.text,
            _filterState,
          );
          if (filteredTasks.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: taskController.allfetchTasks,
            color: const Color(0xFF14B8A6),
            backgroundColor: const Color(0xFFF1F5F9),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        index * 0.05,
                        1.0,
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),
                  child: _buildTaskCard(task),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:
                  _isSearching
                      ? _buildSearchField()
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Tasks',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                              fontSize: 24,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isSearching = true;
                                  });
                                },
                                icon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF475569),
                                ),
                                tooltip: 'Search Tasks',
                              ),
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  IconButton(
                                    onPressed: _showFilterDialog,
                                    icon: const Icon(
                                      Icons.filter_list,
                                      color: Color(0xFF475569),
                                    ),
                                    tooltip: 'Filter Tasks',
                                  ),
                                  if (activeFilterCount > 0)
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF43F5E),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        activeFilterCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF94A3B8),
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFE2E8F0),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xFF1E293B),
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
          },
          icon: const Icon(Icons.close, color: Color(0xFF475569)),
          tooltip: 'Cancel Search',
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFF43F5E),
            size: 80,
          ),
          const SizedBox(height: 20),
          Text(
            'Error: ${taskController.errorMessage.value}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xFFF43F5E),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: taskController.allfetchTasks,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
            label: const Text(
              'Try Again',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearchActive = _searchController.text.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.task_alt_rounded,
            color: Color(0xFF94A3B8),
            size: 80,
          ),
          const SizedBox(height: 20),
          Text(
            isSearchActive ? 'No Matching Tasks' : 'No Tasks Yet!',
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xFF94A3B8),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearchActive
                ? 'Try a different search term.'
                : 'Add or refresh to get started.',
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xFF94A3B8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: taskController.allfetchTasks,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
            label: const Text(
              'Refresh',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final priorityColor =
        task.priority == 'High'
            ? const Color(0xFFF43F5E)
            : task.priority == 'Medium'
            ? const Color(0xFFFB923C)
            : const Color(0xFF14B8A6);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Tapped: ${task.taskName}')));
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: priorityColor, width: 4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.taskName,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                              size: 22,
                            ),
                            onPressed: () {
                              final taskModel = TaskModel(
                                id: task.id,
                                taskNumber: task.taskNumber,
                                taskCategory: task.taskCategory,
                                taskName: task.taskName,
                                taskDescription: task.taskDescription,
                                taskStatus: task.taskStatus,
                                assignedTo: task.assignedTo.id,
                                // 👈 Use `.name` if it's an object
                                dueDate: task.dueDate,
                                priority: task.priority,
                                createdAt: task.createdAt,
                                updatedAt: task.updatedAt,
                              );

                              Get.to(() => EditTaskScreen(task: taskModel));
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              task.priority,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: priorityColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: task.taskCategory,
                    color: const Color(0xFF64748B),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.info_outline,
                    label: 'Status',
                    value: task.taskStatus,
                    color:
                        task.taskStatus == 'Pending'
                            ? const Color(0xFFF43F5E)
                            : task.taskStatus == 'In Progress'
                            ? const Color(0xFFFB923C)
                            : const Color(0xFF14B8A6),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    label: 'Assigned To',
                    value: task.assignedTo.name,
                    color: const Color(0xFF64748B),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Due Date',
                    value: DateFormat.yMMMd().format(task.dueDate),
                    color: const Color(0xFF64748B),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.description_outlined,
                    label: 'Description',
                    value: task.taskDescription,
                    color: const Color(0xFF64748B),
                    isMultiLine: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment:
          isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            maxLines: isMultiLine ? 3 : 1,
            overflow: isMultiLine ? TextOverflow.ellipsis : TextOverflow.clip,
          ),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF14B8A6),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter Tasks',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.65,
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFilterSection(
                              title: 'Status',
                              items: ['Pending', 'In Progress', 'Completed'],
                              selectedItems: _filterState.selectedStatuses,
                              setDialogState: setDialogState,
                              accentColor: const Color(0xFF14B8A6),
                            ),
                            const Divider(color: Color(0xFFE2E8F0)),
                            _buildFilterSection(
                              title: 'Category',
                              items:
                                  taskController.allTasks
                                      .map((task) => task.taskCategory)
                                      .toSet()
                                      .toList(),
                              selectedItems: _filterState.selectedCategories,
                              setDialogState: setDialogState,
                              accentColor: const Color(0xFFFB923C),
                            ),
                            const Divider(color: Color(0xFFE2E8F0)),
                            _buildFilterSection(
                              title: 'Assigned To',
                              items:
                                  taskController.allTasks
                                      .map((task) => task.assignedTo.name)
                                      .toSet()
                                      .toList(),
                              selectedItems: _filterState.selectedAssignedTo,
                              setDialogState: setDialogState,
                              accentColor: const Color(0xFF7C3AED),
                            ),
                            const Divider(color: Color(0xFFE2E8F0)),
                            _buildFilterSection(
                              title: 'Priority',
                              items: ['High', 'Medium', 'Low'],
                              selectedItems: _filterState.selectedPriorities,
                              setDialogState: setDialogState,
                              accentColor: const Color(0xFFF43F5E),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _filterState.clear();
                                _searchController.clear();
                                _isSearching = false;
                              });
                              setDialogState(() {});
                            },
                            child: const Text(
                              'Clear All',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Color(0xFFF43F5E),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF14B8A6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              'Apply Filters',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeInOut),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeInOut)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> items,
    required Set<String> selectedItems,
    required StateSetter setDialogState,
    required Color accentColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: accentColor,
              fontSize: 16,
            ),
          ),
        ),
        ...items.map((item) {
          return CheckboxListTile(
            title: Text(
              item,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF1E293B),
                fontSize: 14,
              ),
            ),
            value: selectedItems.contains(item),
            activeColor: accentColor,
            checkColor: Colors.white,
            onChanged: (value) {
              setDialogState(() {
                setState(() {
                  if (value == true) {
                    selectedItems.add(item);
                  } else {
                    selectedItems.remove(item);
                  }
                });
              });
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            dense: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }),
      ],
    );
  }
}

class FilterState {
  final Set<String> selectedStatuses = {};
  final Set<String> selectedCategories = {};
  final Set<String> selectedAssignedTo = {};
  final Set<String> selectedPriorities = {};

  void clear() {
    selectedStatuses.clear();
    selectedCategories.clear();
    selectedAssignedTo.clear();
    selectedPriorities.clear();
  }
}
