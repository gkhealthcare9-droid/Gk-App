import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';
import '../../Controllers/AddCustomer/Customer_controller.dart';
import '../Widgets/CustomButton.dart';

class CustomSignaturePopup extends StatefulWidget {
  final SignatureController controller;
  final void Function(Uint8List?, String) onSigned;

  const CustomSignaturePopup({
    super.key,
    required this.controller,
    required this.onSigned,
  });

  @override
  State<CustomSignaturePopup> createState() => _CustomSignaturePopupState();
}

class _CustomSignaturePopupState extends State<CustomSignaturePopup> {
  String? selectedEmployeeName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      content: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
            border: Border.all(color: Colors.black, width: 2),
          ),
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Signature',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SizedBox(
                    width: 300,
                    height: 250,
                    child: Signature(
                      controller: widget.controller,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(2, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text('Select Client'),
                            value: selectedEmployeeName,
                            items: Get.find<CustomerController>().employees.map((e) {
                              return DropdownMenuItem<String>(
                                value: e.name,
                                child: Text(e.name ?? 'Unnamed'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedEmployeeName = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                      onTap: () {
                        widget.controller.clear();
                      },
                      buttonText: 'Clear',
                    ),
                    CustomButton(
                      onTap: () async {
                        if (selectedEmployeeName == null) {
                          CustomAlert.error('Please select an employee before signing');
                          return;
                        }
                        if (widget.controller.isNotEmpty) {
                          final signatureBytes = await widget.controller.toPngBytes();
                          widget.onSigned(signatureBytes, selectedEmployeeName!);
                        } else {
                          widget.onSigned(null, selectedEmployeeName!);
                        }
                        Navigator.of(context).pop();
                      },
                      buttonText: 'Save',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}