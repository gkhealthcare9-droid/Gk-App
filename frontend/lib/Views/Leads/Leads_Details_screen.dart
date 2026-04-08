import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../Models/Leads/Leads_Model.dart';
import 'All_Leads_Screen.dart';

import 'EditLeadScreen.dart';

class LeadDetailScreen extends StatelessWidget {
  final LeadModel lead;

  const LeadDetailScreen({super.key, required this.lead});

  // Helper method to build info rows with icons
  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? 'N/A',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lead.name ?? 'Lead Details',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black87),
            onPressed: () async {
              final result = await Get.to(() => EditLeadScreen(lead: lead));
              if (result == true) {
                // ⬅️ Refresh the screen manually
                Get.off(() => LeadsScreen()); // Rebuilds screen with same lead
                // OR if you have leadController.fetchLeads() available, call that and update UI
              }
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lead Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.person_outline, 'Name', lead.name),
                      _buildInfoRow(Icons.email_outlined, 'Email', lead.email),
                      _buildInfoRow(Icons.phone_outlined, 'Phone', lead.phone),
                      _buildInfoRow(
                        Icons.work_outline,
                        'Position',
                        lead.position,
                      ),
                      _buildInfoRow(
                        Icons.business_outlined,
                        'Company',
                        lead.company,
                      ),
                      _buildInfoRow(
                        Icons.description_outlined,
                        'Description',
                        lead.description,
                      ),
                      _buildInfoRow(Icons.source, 'Source', lead.source),
                      _buildInfoRow(Icons.category, 'Lead Type', lead.leadType),
                      _buildInfoRow(
                        Icons.attach_money,
                        'Lead Value',
                        lead.leadValue?.toString(),
                      ),
                      _buildInfoRow(
                        Icons.person_add,
                        'Assigned To',
                        lead.assigned?.name,
                      ),
                      _buildInfoRow(Icons.info_outline, 'Status', lead.status),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Address Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.location_on, 'Address', lead.address),
                      _buildInfoRow(Icons.location_city, 'City', lead.city),
                      _buildInfoRow(Icons.map, 'State', lead.state),
                      _buildInfoRow(Icons.flag, 'Country', lead.country),
                      _buildInfoRow(Icons.pin, 'Pincode', lead.pincode),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Timestamps',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.create,
                        'Created At',
                        lead.createdAt != null
                            ? DateFormat.yMMMd().add_jm().format(
                              lead.createdAt!.toLocal(),
                            )
                            : 'N/A',
                      ),
                      // _buildInfoRow(
                      //   Icons.update,
                      //   'Updated At',
                      //   lead.updatedAt != null
                      //       ? DateFormat.yMMMd().add_jm().format(lead.updatedAt!.toLocal())
                      //       : 'N/A',
                      // ),
                    ],
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
