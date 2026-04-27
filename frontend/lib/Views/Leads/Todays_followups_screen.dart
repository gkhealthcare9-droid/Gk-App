import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Controllers/Leads/Leads_Controller.dart';
import 'package:sales_grow/Models/Leads/Leads_Model.dart';
import 'package:sales_grow/Views/Leads/FollowUp_leads_screen.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';

class TodaysFollowupScreen extends StatelessWidget {
  const TodaysFollowupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LeadController leadController = Get.put(LeadController());

    // Trigger fetch on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      leadController.todayFollowups();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Follow-Ups"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Obx(() {
        if (leadController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (leadController.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              leadController.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final List<FollowUpModel> followUps = leadController.followUps;

        if (followUps.isEmpty) {
          return const Center(child: Text("No follow-ups for today."));
        }

        return RefreshIndicator(
          onRefresh: () async => leadController.todayFollowups(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: followUps.length,
            itemBuilder: (context, index) {
              final item = followUps[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(item.lead?.name ?? 'Unknown Lead',
                      style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${item.datetime?.toLocal().toString().split(".")[0] ?? "N/A"}'),
                      Text('Notes: ${item.notes ?? "No notes"}'),
                      Text('Phone: ${item.lead?.phone ?? "N/A"}'),
                    ],
                  ),
                  onTap: () {
                    if (item.lead?.id != null) {
                      Get.to(() => FollowUpDetailScreen(leadId: item.lead!.id!));
                    } else {
                      CustomAlert.error("Lead ID is missing.");
                    }
                  },
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
