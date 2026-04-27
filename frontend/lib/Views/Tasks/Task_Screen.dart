import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sales_grow/Models/TaskModel/Task_Mode.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';
import '../../Controllers/Task/Task_Controller.dart';
import '../../Models/TaskModel/GetTasks.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
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
  String _userType = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    Future.delayed(Duration.zero, () async {
      await _loadUserType();
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

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userType = prefs.getString('userType') ?? '';
    });
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
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showTaskDetailsModal(task),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: priorityColor, width: 4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.taskName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            task.assignedTo?.name ?? 'Unassigned',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d, y').format(task.dueDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(task.taskStatus),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = status == 'Pending'
        ? const Color(0xFFF43F5E)
        : status == 'In Progress'
            ? const Color(0xFFFB923C)
            : const Color(0xFF14B8A6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showTaskDetailsModal(Task task) {
    final priorityColor =
        task.priority == 'High'
            ? const Color(0xFFF43F5E)
            : task.priority == 'Medium'
            ? const Color(0xFFFB923C)
            : const Color(0xFF14B8A6);

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${task.priority} Priority',
                    style: TextStyle(
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Get.back();
                        final taskModel = TaskModel(
                          id: task.id,
                          taskNumber: task.taskNumber,
                          taskCategory: task.taskCategory,
                          taskName: task.taskName,
                          taskDescription: task.taskDescription,
                          taskStatus: task.taskStatus,
                          assignedTo: task.assignedTo?.id ?? '',
                          dueDate: task.dueDate,
                          priority: task.priority,
                          createdAt: task.createdAt,
                          updatedAt: task.updatedAt,
                        );
                        Get.to(() => EditTaskScreen(task: taskModel));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFF43F5E)),
                      onPressed: () {
                        Get.back();
                        _confirmDelete(task.id);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              task.taskName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Task #${task.taskNumber}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const Divider(height: 32),
            _buildModalDetailRow(Icons.category_outlined, 'Category', task.taskCategory),
            _buildModalDetailRow(Icons.info_outline, 'Status', task.taskStatus, 
                valueColor: task.taskStatus == 'Pending' ? Colors.red : (task.taskStatus == 'In Progress' ? Colors.orange : Colors.green)),
            _buildModalDetailRow(Icons.person_outline, 'Assigned To', task.assignedTo?.name ?? 'Not Assigned'),
            _buildModalDetailRow(Icons.calendar_today_outlined, 'Due Date', DateFormat('MMMM dd, yyyy').format(task.dueDate)),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                task.taskDescription,
                style: const TextStyle(height: 1.5, fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildModalDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blueGrey),
          ),
          Text(
            value,
            style: TextStyle(color: valueColor ?? Colors.black87, fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal),
          ),
        ],
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
                                       .map((task) => task.assignedTo?.name ?? 'Not Assigned')
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

  void _confirmDelete(String taskId) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Task',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
          style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              taskController.deleteTask(taskId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF43F5E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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
