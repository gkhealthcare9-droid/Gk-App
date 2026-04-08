import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sales_grow/Controllers/AuthController/ProfileController.dart';
import 'package:sales_grow/Controllers/Task/Task_Controller.dart';
import 'package:sales_grow/Models/Customer/Customer.dart';
import 'package:sales_grow/Views/Tasks/Serach_Customer_product.dart';
import 'SearchCustomer_Screen.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen>
    with SingleTickerProviderStateMixin {
  final ProfileController _profileController = Get.put(ProfileController());
  final TaskController _taskController = Get.put(TaskController());
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _title = TextEditingController();
  final _productCtrl = TextEditingController();
  DateTime? _dueDate;
  String? _taskType;
  String? _priority;
  String? _assignedId;
  CustomerModel? _selectedCustomer;
  late AnimationController _animationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    Future.delayed(Duration.zero, () async {
      _profileController.fetchUsers();
    });
  }

  final _taskTypes = [
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
  ];
  final _priorities = ['Low', 'Medium', 'High'];

  @override
  void dispose() {
    _descCtrl.dispose();
    _title.dispose();
    _productCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  String formatDateToYMD(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void _submit() {
    if (!_formKey.currentState!.validate() ||
        _taskType == null ||
        _assignedId == null ||
        _title.text.isEmpty ||
        _priority == null ||
        _dueDate == null) {
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        colorText: Colors.white,
        backgroundColor: Colors.redAccent,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.error, color: Colors.white),
      );
      return;
    }
    _taskController.createTask(
      _taskType!,
      _title.text,
      _descCtrl.text,
      _assignedId!,
      formatDateToYMD(_dueDate),
      _priority!,
    );
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

  Future<void> _searchCustomer() async {
    final result = await Get.to(() => SearchCustomer());
    if (result is CustomerModel) {
      setState(() => _selectedCustomer = result);
    }
  }

  Future<void> _searchProduct() async {
    final result = await Get.to(() => SearchProducts());
    if (result is String) {
      setState(() => _productCtrl.text = result);
    }
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
  }) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: _buttonScaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white),
            label: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create New Task',
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
                              initialValue: _taskType,
                              items:
                                  _taskTypes
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
                              onChanged: (v) => setState(() => _taskType = v),
                              validator:
                                  (v) => v == null ? 'Select task type' : null,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.blueAccent,
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildGradientButton(
                              onPressed: _searchCustomer,
                              label: 'Search Customer',
                              icon: Icons.search,
                            ),
                            SizedBox(height: 16),
                            if (_selectedCustomer != null)
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Selected: ${_selectedCustomer!.customerName}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (_taskType == 'Supply' ||
                                _taskType == 'Courier') ...[
                              SizedBox(height: 16),
                              _buildGradientButton(
                                onPressed: _searchProduct,
                                label: 'Search Product',
                                icon: Icons.search,
                              ),
                            ],
                            if ((_taskType == 'Supply' ||
                                    _taskType == 'Courier') &&
                                _productCtrl.text.isNotEmpty) ...[
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _productCtrl,
                                readOnly: true,
                                decoration: _inputDecoration(
                                  'Selected Product',
                                ),
                                maxLines: null,
                              ),
                            ],
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _title,
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
                              controller: _descCtrl,
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
                            Obx(() {
                              if (_profileController.isLoading.value) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blueAccent,
                                  ),
                                );
                              }
                              if (_profileController.users.isEmpty) {
                                return Text(
                                  'No Users Available',
                                  style: GoogleFonts.poppins(
                                    color: Colors.redAccent,
                                  ),
                                );
                              }
                              return DropdownButtonFormField<String>(
                                initialValue: _assignedId,
                                decoration: _inputDecoration('Assign To'),
                                items:
                                    _profileController.users.map((user) {
                                      return DropdownMenuItem(
                                        value: user.id,
                                        child: Text(
                                          user.name,
                                          style: GoogleFonts.poppins(),
                                        ),
                                      );
                                    }).toList(),
                                onChanged:
                                    (val) => setState(() => _assignedId = val),
                                validator:
                                    (v) => v == null ? 'Select a user' : null,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.blueAccent,
                                ),
                              );
                            }),
                            SizedBox(height: 16),
                            GestureDetector(
                              onTap: _pickDate,
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
                                    text:
                                        _dueDate == null
                                            ? ''
                                            : DateFormat.yMMMd().format(
                                              _dueDate!,
                                            ),
                                  ),
                                  validator:
                                      (_) =>
                                          _dueDate == null ? 'Required' : null,
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: _inputDecoration('Priority'),
                              initialValue: _priority,
                              items:
                                  _priorities
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
                              onChanged: (v) => setState(() => _priority = v),
                              validator: (v) => v == null ? 'Required' : null,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.blueAccent,
                              ),
                            ),
                            SizedBox(height: 24),
                            _buildGradientButton(
                              onPressed: _submit,
                              label: 'Create Task',
                              icon: Icons.add_task,
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
    );
  }
}
