import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/Appconstants.dart';
import '../../Utils/Colors.dart';
import '../../Controllers/Dashboard/Dashboard_controller.dart';
import '../Widgets/CustomBackButton.dart';

class ExcelUploadScreen extends StatefulWidget {
  const ExcelUploadScreen({super.key});

  @override
  _ExcelUploadScreenState createState() => _ExcelUploadScreenState();
}

class _ExcelUploadScreenState extends State<ExcelUploadScreen> {
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  String _userType = '';

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userType = prefs.getString('userType') ?? '';
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('authToken');
      final url = AppConstants.BASE_URL + AppConstants.EXCEL_IMPORT;
      
      print('--- Starting Excel Upload ---');
      print('Target URL: $url');
      print('File Name: ${_selectedFile!.name}');
      print('File Size: ${_selectedFile!.size} bytes');

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer ${token ?? ''}';
      
      if (_selectedFile!.bytes != null) {
        print('Adding file from bytes...');
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          _selectedFile!.bytes!,
          filename: _selectedFile!.name,
        ));
      } else {
        print('Error: File bytes are null!');
        if (mounted) {
          CustomAlert.error('Could not read file data. Try a different file.');
        }
        return;
      }

      print('Sending request...');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          CustomAlert.success('File imported successfully');
        }
        Get.find<DashboardController>().fetchStats();
        setState(() {
          _selectedFile = null;
        });
      } else {
        final errorMsg = json.decode(response.body)['message'] ?? 'Failed to import file';
        if (mounted) {
          CustomAlert.error('Import failed: $errorMsg');
        }
      }
    } catch (e) {
      print('Upload catch error: $e');
      if (mounted) {
        CustomAlert.error('An error occurred: $e');
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(onTap: () => Get.back()),
        title: const Text('Excel Import'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upload_file_rounded,
                size: 80,
                color: AppColors.primaryBlue.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              const Text(
                'Bulk Import Data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Upload an Excel file (.xlsx) with the standard format.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              if (_selectedFile != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedFile!.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => setState(() => _selectedFile = null),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              SizedBox(
                width: double.infinity,
                height: 55,
                child: _userType == 'admin'
                    ? ElevatedButton(
                        onPressed: _isUploading ? null : (_selectedFile == null ? _pickFile : _uploadFile),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isUploading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _selectedFile == null ? 'Select Excel File' : 'Start Import',
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: const Center(
                          child: Text(
                            'Only Administrators can import data.',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
