// lib/Screens/Products/AddVendorProductScreen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddVendorProductScreen extends StatefulWidget {
  final String id;
  const AddVendorProductScreen({super.key, required this.id});

  @override
  State<AddVendorProductScreen> createState() =>
      _AddVendorProductScreenState();
}

class _AddVendorProductScreenState extends State<AddVendorProductScreen> {
  // ── 1) The four product categories ───────────────────────
  final List<String> _categories = [
    'Dialysis Machine',
    'Reprocessing Machine',
    'Pulmonary',
    'PTS',
  ];
  String? _selectedCategory;

  // ── 2) If "Dialysis Machine" is chosen, these fields appear:
  //  2a) Make and Model dropdown data:
  final List<String> _makes = ['Fresenius'];
  String? _selectedMake;

  final List<String> _models = ['4008S'];
  String? _selectedModel;

  //  2b) Qty field (numeric)
  final TextEditingController _qtyController = TextEditingController(text: '9');

  //  2c) Serial No dropdown (example list; replace with real data)
  final List<String> _serialNumbers = ['SN-001', 'SN-002', 'SN-003'];
  String? _selectedSerialNo;

  //  2d) AMC Start & End dates
  DateTime? _amcStartDate;
  DateTime? _amcEndDate;

  Future<void> _pickAmcStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _amcStartDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _amcStartDate = picked;
      });
    }
  }

  Future<void> _pickAmcEndDate() async {
    final now = DateTime.now();
    final initial = _amcEndDate ??
        (_amcStartDate != null ? _amcStartDate! : now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _amcStartDate ?? now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _amcEndDate = picked;
      });
    }
  }

  // ── 3) The seven “Telle calling response” options ─────────
  final List<String> _telleOptions = [
    'Did not Receive',
    'Quotation Submitted',
    'Call me later',
    'Not interested',
    'Interested in product',
    'No more in business',
    'Order Lost',
    'Other',
  ];
  String? _selectedTelle;

  // ── 4) The four “communication” options ───────────────────
  final List<String> _communication = [
    'SMS',
    'Email',
    'Phone',
    'WhatsApp',
    'Sales Visit',
    'Service Visit',
  ];
  String? _selectedCommunication;

  // ── 5) Follow-up date (nullable until user picks one) ────
  DateTime? _followUpDate;

  Future<void> _pickFollowUpDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? now,
      firstDate: now, // no past
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _followUpDate = picked;
      });
    }
  }

  // ── 6) Save & return all gathered fields ──────────────────
  void _saveAndReturn() {
    // Validate category
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product category.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // If Dialysis Machine, validate its subfields:
    if (_selectedCategory == 'Dialysis Machine') {
      if (_selectedMake == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a Make.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (_selectedModel == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a Model.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      final qty = int.tryParse(_qtyController.text.trim());
      if (qty == null || qty < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid quantity.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (_selectedSerialNo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a Serial No.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (_amcStartDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please pick an AMC Start Date.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (_amcEndDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please pick an AMC End Date.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    // Validate Telle response
    if (_selectedTelle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Telle calling response.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Validate communication
    if (_selectedCommunication == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a communication method.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Validate follow-up date
    if (_followUpDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick a follow-up date.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Build return map:
    final data = {
      'category': _selectedCategory!,
      'telleResponse': _selectedTelle!,
      'communication': _selectedCommunication!,
      'followUpDate': _followUpDate!.toIso8601String(),
    };

    // If Dialysis Machine, include its subfields
    if (_selectedCategory == 'Dialysis Machine') {
      data.addAll({
        'make': _selectedMake!,
        'model': _selectedModel!,
        'qty': _qtyController.text.trim(),
        'serialNo': _selectedSerialNo!,
        'amcStart': _amcStartDate!.toIso8601String(),
        'amcEnd': _amcEndDate!.toIso8601String(),
      });
    }

    Navigator.pop(context, data);
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format dates for display
    String formatDate(DateTime? d) =>
        d == null ? 'Select date' : DateFormat('dd/MM/yyyy').format(d);

    final followUpText = formatDate(_followUpDate);
    final amcStartText = formatDate(_amcStartDate);
    final amcEndText = formatDate(_amcEndDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vendor Product'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) Product Category Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Product Category *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;

                  // Reset all Dialysis‐specific fields if category changes
                  if (val != 'Dialysis Machine') {
                    _selectedMake = null;
                    _selectedModel = null;
                    _qtyController.text = '9';
                    _selectedSerialNo = null;
                    _amcStartDate = null;
                    _amcEndDate = null;
                  }
                });
              },
              hint: const Text('Select category'),
            ),

            const SizedBox(height: 24),

            // ── 2) ONLY when category == "Dialysis Machine" ──────
            if (_selectedCategory == 'Dialysis Machine') ...[
              // 2a) Make dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedMake,
                decoration: InputDecoration(
                  labelText: 'Make *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                items: _makes.map((make) {
                  return DropdownMenuItem(
                    value: make,
                    child: Text(make),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedMake = val;
                  });
                },
                hint: const Text('Select Make'),
              ),
              const SizedBox(height: 16),

              // 2b) Model dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedModel,
                decoration: InputDecoration(
                  labelText: 'Model *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                items: _models.map((model) {
                  return DropdownMenuItem(
                    value: model,
                    child: Text(model),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedModel = val;
                  });
                },
                hint: const Text('Select Model'),
              ),
              const SizedBox(height: 16),

              // 2c) Qty numeric field
              TextFormField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Qty *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 16),

              // 2d) Serial No dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedSerialNo,
                decoration: InputDecoration(
                  labelText: 'Serial No *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                items: _serialNumbers.map((sn) {
                  return DropdownMenuItem(
                    value: sn,
                    child: Text(sn),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSerialNo = val;
                  });
                },
                hint: const Text('Select Serial No'),
              ),
              const SizedBox(height: 16),

              // 2e) AMC Start Date picker
              GestureDetector(
                onTap: _pickAmcStartDate,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        'AMC Start Date: $amcStartText',
                        style: TextStyle(
                          fontSize: 16,
                          color: _amcStartDate == null
                              ? Colors.grey[600]
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2f) AMC End Date picker
              GestureDetector(
                onTap: _pickAmcEndDate,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        'AMC End Date: $amcEndText',
                        style: TextStyle(
                          fontSize: 16,
                          color: _amcEndDate == null
                              ? Colors.grey[600]
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── 3) Telle Calling Response Dropdown ─────────────────
            DropdownButtonFormField<String>(
              initialValue: _selectedTelle,
              decoration: InputDecoration(
                labelText: 'Telle calling response *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              items: _telleOptions.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedTelle = val;
                });
              },
              hint: const Text('Select response'),
            ),

            const SizedBox(height: 24),

            // ── 4) Communication Dropdown ──────────────────────────
            DropdownButtonFormField<String>(
              initialValue: _selectedCommunication,
              decoration: InputDecoration(
                labelText: 'Communication *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              items: _communication.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(opt),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCommunication = val;
                });
              },
              hint: const Text('Select communication'),
            ),

            const SizedBox(height: 24),

            // ── 5) Follow-Up Date Picker ───────────────────────────
            GestureDetector(
              onTap: _pickFollowUpDate,
              child: Container(
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      'Follow‐Up Date: $followUpText',
                      style: TextStyle(
                        fontSize: 16,
                        color: _followUpDate == null
                            ? Colors.grey[600]
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── 6) Save Button ─────────────────────────────────────
            ElevatedButton(
              onPressed: _saveAndReturn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
