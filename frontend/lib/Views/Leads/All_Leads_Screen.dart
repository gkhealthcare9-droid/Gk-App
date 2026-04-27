import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../Utils/Colors.dart';
import '../Widgets/CustomAppBar.dart';
import '../Widgets/CustomAlert.dart';
import 'package:get/get.dart';
import 'package:sales_grow/Views/Leads/FollowUp_leads_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Controllers/Leads/Leads_Controller.dart';
import '../../Models/Leads/Leads_Model.dart';
import 'Add_Leads_Screen.dart';
import 'Leads_Details_screen.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen>
    with SingleTickerProviderStateMixin {
  final FilterState _filterState = FilterState();
  final LeadController leadController = Get.put(LeadController());
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    Future.delayed(Duration.zero, () async {
      await leadController.fetchLeads();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Utility method to capitalize text
  String _capitalize(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Helper method to build info rows with icons
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // Open WhatsApp with phone number
  Future<void> _openWhatsApp(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      CustomAlert.error('No phone number provided');
      return;
    }
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length == 10) {
      digitsOnly = '91$digitsOnly'; // Default to +91 for 10-digit numbers
    } else if (digitsOnly.length == 12 && digitsOnly.startsWith('91')) {
      // Already has +91
    } else if (digitsOnly.length < 10) {
      CustomAlert.error('Invalid phone number format.');
      return;
    }
    final whatsappUrl = Uri.parse(
      'https://api.whatsapp.com/send?phone=$digitsOnly',
    );
    try {
      bool launched = await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      try {
        await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);
      } catch (e) {
        CustomAlert.error('Could not open WhatsApp or browser.');
      }
    }
  }

  // Get lead type icon and color
  Widget _getLeadTypeIndicator(String? leadType) {
    switch (leadType?.toLowerCase()) {
      case 'hot':
        return Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.red, size: 20),
            const SizedBox(width: 4),
            Text(
              'Hot',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ],
        );
      case 'cold':
        return Row(
          children: [
            Icon(Icons.ac_unit, color: Colors.blue, size: 20),
            const SizedBox(width: 4),
            Text(
              'Cold',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
            ),
          ],
        );
      case 'warm':
        return Row(
          children: [
            Icon(Icons.wb_sunny, color: Colors.orange, size: 20),
            const SizedBox(width: 4),
            Text(
              'Warm',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      default:
        return Row(
          children: [
            Icon(Icons.help_outline, color: Colors.grey, size: 20),
            const SizedBox(width: 4),
            Text(
              'Unknown',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        );
    }
  }

  // Get card background color based on lead type
  Color _getCardBackgroundColor(String? leadType) {
    switch (leadType?.toLowerCase()) {
      case 'hot':
        return Colors.red[50]!;
      case 'cold':
        return Colors.blue[50]!;
      case 'warm':
        return Colors.orange[50]!;
      default:
        return Colors.white;
    }
  }

  // Get status container color
  Color _getStatusBackgroundColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'new':
        return Colors.green[100]!;
      case 'open':
        return Colors.blue[100]!;
      case 'closed':
        return Colors.grey[300]!;
      default:
        return Colors.grey[200]!;
    }
  }

  // Get status border color
  Color _getStatusBorderColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'new':
        return Colors.green[300]!;
      case 'open':
        return Colors.blue[300]!;
      case 'closed':
        return Colors.grey[500]!;
      default:
        return Colors.grey[400]!;
    }
  }

  // Filter leads based on selected filters
  List<LeadModel> get filteredLeads {
    return leadController.leads.where((lead) {
      bool matchesStatus =
          _filterState.selectedStatuses.isEmpty ||
          _filterState.selectedStatuses.contains(lead.status?.toLowerCase());
      bool matchesLeadType =
          _filterState.selectedLeadTypes.isEmpty ||
          _filterState.selectedLeadTypes.contains(lead.leadType?.toLowerCase());
      bool matchesAssignedTo =
          _filterState.selectedAssignedTo.isEmpty ||
          _filterState.selectedAssignedTo.contains(lead.assigned?.name);
      bool matchesCompany =
          _filterState.selectedCompanies.isEmpty ||
          _filterState.selectedCompanies.contains(lead.company);
      bool matchesCity =
          _filterState.selectedCities.isEmpty ||
          _filterState.selectedCities.contains(lead.city);
      return matchesStatus &&
          matchesLeadType &&
          matchesAssignedTo &&
          matchesCompany &&
          matchesCity;
    }).toList();
  }

  // Calculate active filter count
  int get activeFilterCount {
    return _filterState.selectedStatuses.length +
        _filterState.selectedLeadTypes.length +
        _filterState.selectedAssignedTo.length +
        _filterState.selectedCompanies.length +
        _filterState.selectedCities.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: CustomAppBar(
        title: 'Leads',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
            onPressed: leadController.fetchLeads,
            tooltip: 'Refresh Leads',
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: AppColors.primaryBlue),
                onPressed: _showFilterDialog,
                tooltip: 'Filter Leads',
              ),
              if (activeFilterCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
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
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (leadController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF14B8A6),
                strokeWidth: 5,
              ),
            );
          }
          if (leadController.errorMessage.isNotEmpty) {
            return _buildErrorState();
          }
          if (filteredLeads.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: leadController.fetchLeads,
            color: const Color(0xFF14B8A6),
            backgroundColor: const Color(0xFFF1F5F9),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: filteredLeads.length,
              itemBuilder: (context, index) {
                final lead = filteredLeads[index];
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
                  child: _buildLeadCard(lead),
                );
              },
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddLeadScreen()),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        tooltip: 'Add New Lead',
        child: const Icon(Icons.add),
      ),
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
            'Error: ${leadController.errorMessage.value}',
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
            onPressed: leadController.fetchLeads,
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
              backgroundColor: Colors.lightBlue,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF94A3B8),
            size: 80,
          ),
          const SizedBox(height: 20),
          const Text(
            'No Leads Yet!',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xFF94A3B8),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add or refresh to get started.',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xFF94A3B8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const AddLeadScreen()),
            icon: const Icon(Icons.add, color: Colors.white, size: 20),
            label: const Text(
              'Add Lead',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
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

  Widget _buildLeadCard(LeadModel lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        color: _getCardBackgroundColor(lead.leadType),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Get.to(() => LeadDetailScreen(lead: lead)),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: Color(0xFF1976D2),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lead.name ?? 'Unnamed Lead',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.email_outlined,
                    'Email',
                    lead.email ?? 'N/A',
                  ),
                  _buildInfoRow(
                    Icons.phone_outlined,
                    'Phone',
                    lead.phone ?? 'N/A',
                  ),
                  _buildInfoRow(
                    Icons.business_outlined,
                    'Company',
                    lead.company ?? 'N/A',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [_getLeadTypeIndicator(lead.leadType)],
                    ),
                  ),
                  _buildInfoRow(
                    Icons.location_city,
                    'City',
                    lead.city ?? 'N/A',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const FaIcon(
                              FontAwesomeIcons.whatsapp,
                              color: Color(0xFF25D366),
                            ),
                            onPressed: () => _openWhatsApp(lead.phone),
                            tooltip: 'Message Lead',
                            splashRadius: 24,
                          ),
                          SizedBox(width: 8,),
                          IconButton(
                            icon: const Icon(Icons.phone, color: Colors.green),
                            onPressed: () async {
                              if (lead.phone != null &&
                                  lead.phone!.isNotEmpty) {
                                final uri = Uri.parse('tel:${lead.phone}');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                } else {
                                  CustomAlert.error('Cannot launch phone call');
                                }
                              } else {
                                CustomAlert.error('Phone number is not available');
                              }
                            },
                            tooltip: 'Call Lead',
                            splashRadius: 24,
                          ),
                        ],
                      ),
                      lead.status?.toLowerCase() == 'closed'
                          ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusBackgroundColor(lead.status),
                              border: Border.all(
                                color: _getStatusBorderColor(lead.status),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Closed',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                          : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: _getStatusBackgroundColor(lead.status),
                              border: Border.all(
                                color: _getStatusBorderColor(lead.status),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value:
                                  ['new', 'open', 'closed'].contains(
                                        lead.status?.trim().toLowerCase(),
                                      )
                                      ? lead.status!.trim().toLowerCase()
                                      : null,
                              hint: const Text('Select Status'),
                              underline: const SizedBox(),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF1976D2),
                              ),
                              items:
                                  ['new', 'open', 'closed'].map((status) {
                                    return DropdownMenuItem<String>(
                                      value: status,
                                      child: Text(_capitalize(status)),
                                    );
                                  }).toList(),
                              onChanged: (value) async {
                                if (value != null && lead.id != null) {
                                  await leadController.updateLeadStatus(
                                    lead.id!,
                                    value,
                                  );
                                }
                              },
                            ),
                          ),
                      TextButton(
                        onPressed: () {
                          if (lead.id != null) {
                            Get.to(
                              () => FollowUpDetailScreen(leadId: lead.id!),
                            );
                          } else {
                            CustomAlert.error('Lead ID is missing');
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1976D2),
                        ),
                        child: const Text(
                          'Follow-Up',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
                            'Filter Leads',
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
                              items: ['new', 'open', 'closed'],
                              selectedItems: _filterState.selectedStatuses,
                              setDialogState: setDialogState,
                              accentColor: const Color(0xFF14B8A6),
                              capitalize: true,
                            ),
                            const Divider(color: Color(0xFFE2E8F0)),
                            _buildFilterSection(
                              title: 'Lead Type',
                              items: ['hot', 'cold', 'warm'],
                              selectedItems: _filterState.selectedLeadTypes,
                              setDialogState: setDialogState,
                              accentColor: const Color(0xFFFB923C),
                              capitalize: true,
                            ),
                            const Divider(color: Color(0xFFE2E8F0)),
                            _buildFilterSection(
                              title: 'Assigned To',
                              items:
                                  leadController.leads
                                      .map((lead) => lead.assigned?.name)
                                      .where((name) => name != null)
                                      .toSet()
                                      .toList()
                                      .cast<String>(),
                              selectedItems: _filterState.selectedAssignedTo,
                              setDialogState: setDialogState,
                              accentColor: const Color(0xFF7C3AED),
                            ),
                            const Divider(color: Color(0xFFE2E8F0)),
                            // _buildFilterSection(
                            //   title: 'Company',
                            //   items:
                            //       leadController.leads
                            //           .map((lead) => lead.company)
                            //           .where((company) => company != null)
                            //           .toSet()
                            //           .toList()
                            //           .cast<String>(),
                            //   selectedItems: _filterState.selectedCompanies,
                            //   setDialogState: setDialogState,
                            //   accentColor: const Color(0xFF3B82F6),
                            // ),
                            const Divider(color: Color(0xFFE2E8F0)),
                            _buildFilterSection(
                              title: 'City',
                              items:
                                  leadController.leads
                                      .map((lead) => lead.city)
                                      .where((city) => city != null)
                                      .toSet()
                                      .toList()
                                      .cast<String>(),
                              selectedItems: _filterState.selectedCities,
                              setDialogState: setDialogState,
                              accentColor: const Color(0xFF10B981),
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
                              backgroundColor: Colors.lightBlue,
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
    bool capitalize = false,
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
              capitalize ? _capitalize(item) : item,
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
  final Set<String> selectedLeadTypes = {};
  final Set<String> selectedAssignedTo = {};
  final Set<String> selectedCompanies = {};
  final Set<String> selectedCities = {};

  void clear() {
    selectedStatuses.clear();
    selectedLeadTypes.clear();
    selectedAssignedTo.clear();
    selectedCompanies.clear();
    selectedCities.clear();
  }
}
