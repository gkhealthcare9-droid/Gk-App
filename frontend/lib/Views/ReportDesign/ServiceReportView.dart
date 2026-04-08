import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ServiceReport {
  static Future<Uint8List> generateServicereport({
    required String hospitalName,
    required String hospitalAddress,
    required String hospitalPhone,
    required String hospitalCity,
    required String hospitalState,
    required String serialNumber,
    required String actionTaken,
    required String machineStatus,
    required String remarks,
    required String engineerName,
    required String clientName,
    required Uint8List? signatureBytes,
    required String productCategory,
    required String manufacturer,
    required String natureOfComplaint,
    required String sparesReplaced,
    required String serviceType,
    required DateTime warrantyStartDate,
    required DateTime? warrantyEndDate,
    required String warrantyDuration,
    required String meterReading,
    required String complaintFrom, // 👈 Add this

  }) async {
    final pdf = pw.Document();

    pw.MemoryImage? gkImage;
    try {
      final gkBytes = await rootBundle.load('assets/images/logo.jpg');
      gkImage = pw.MemoryImage(gkBytes.buffer.asUint8List());
    } catch (e) {
      print('Failed to load logo.jpg: $e');
    }

    pw.MemoryImage? sealImage;
    try {
      final sealBytes = await rootBundle.load('assets/images/gk.jpg');
      sealImage = pw.MemoryImage(sealBytes.buffer.asUint8List());
    } catch (e) {
      print('Failed to load gk.jpg: $e');
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (gkImage != null) pw.Image(gkImage, width: 80, height: 50),
                    pw.Spacer(),
                    pw.Text(
                      'Service Report',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey900,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Spacer(),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Report No: RPT-001', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Date: 29/4/2025', style: pw.TextStyle(fontSize: 8)),
                        pw.Text('Time: 12:09 PM', style: pw.TextStyle(fontSize: 8)),
                        pw.Text('Place: $hospitalCity', style: pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 3),
                pw.Divider(),

                // Client Details
                pw.Center(
                  child: pw.Text(
                    'Client Details',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  columnWidths: {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(2)},
                  children: [
                    _tableRow('Hospital Name', hospitalName),
                    _tableRow('Address', hospitalAddress),
                    _tableRow('City, State', '$hospitalCity, $hospitalState'),
                    _tableRow('Phone', hospitalPhone),
                  ],
                ),

                pw.SizedBox(height: 5),

                // Machine Details
                pw.Center(
                  child: pw.Text(
                    'Machine Details',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  columnWidths: {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(2)},
                  children: [
                    _tableRow('Type of System', productCategory),
                    _tableRow('Manufacturer', manufacturer),
                    _tableRow('Serial Number', serialNumber),
                    pw.TableRow(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          child: pw.Text(
                            'Running Hours',
                            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          child: _buildMeterReading(meterReading),
                        ),
                      ],
                    ),
                  ],
                ),

                // Warranty & Service Details
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text(
                    'Warranty & Service Details',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  columnWidths: {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(2)},
                  children: [
                    _tableRow("Complaint From", complaintFrom),

                    _tableRow('Warranty Start Date', _formatDate(warrantyStartDate)),
                    _tableRow('Warranty End Date', _formatDate(warrantyEndDate)),
                    _tableRow('Warranty Duration', warrantyDuration.isNotEmpty ? warrantyDuration : 'N/A'),
                    pw.TableRow(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          child: pw.Text('Service Type', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          child: pw.Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _buildServiceOption('AMC', serviceType),
                              _buildServiceOption('CMC', serviceType),
                              _buildServiceOption('On Call Service', serviceType),
                              _buildServiceOption('Rental', serviceType),
                              _buildServiceOption('Extended Warranty', serviceType),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Alarm Details
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text(
                    'Alarm Details',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  columnWidths: {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(2)},
                  children: [
                    _tableRow('Nature of Complaint / Machine Alarm', natureOfComplaint.isNotEmpty ? natureOfComplaint : 'N/A'),
                    _tableRow('Spares Replaced', sparesReplaced.isNotEmpty ? sparesReplaced : 'N/A'),
                    _tableRow('Action Taken', actionTaken.isNotEmpty ? actionTaken : 'N/A'),
                    _tableRow('Note By Engineer', remarks.isNotEmpty ? remarks : 'N/A'),
                  ],
                ),

                pw.SizedBox(height: 5),

                // Machine Status
                _buildMachineStatusWithTitle(machineStatus, 50),

                pw.SizedBox(height: 5),

                // Engineer and Client Section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Engineer Name:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 3),
                        pw.Text(engineerName, style: pw.TextStyle(fontSize: 9)),
                        pw.SizedBox(height: 3),
                        if (sealImage != null)
                          pw.Container(
                            width: 30,
                            height: 30,
                            child: pw.Image(sealImage, fit: pw.BoxFit.contain),
                          ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Client Signature:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 3),
                        pw.Text(clientName, style: pw.TextStyle(fontSize: 9)),
                        pw.SizedBox(height: 3),
                        pw.Container(
                          width: 80,
                          height: 25,
                          decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey, width: 1)),
                          ),
                          child: signatureBytes != null
                              ? pw.Image(pw.MemoryImage(signatureBytes), fit: pw.BoxFit.contain)
                              : pw.Center(child: pw.Text('Signature: N/A', style: pw.TextStyle(fontSize: 9))),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.Divider(),

                // For Office Use Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FFFACD'), // Light yellow
                    border: pw.Border.all(color: PdfColors.grey, width: 0.5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Center(
                        child: pw.Text(
                          'For Office Use:',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildMeterReading(String meterReading) {
    if (meterReading == 'N/A' || meterReading.length != 8 || !RegExp(r'^\d+$').hasMatch(meterReading)) {
      return pw.Text('N/A', style: pw.TextStyle(fontSize: 9));
    }

    final digits = meterReading.split('');
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: List.generate(8, (index) {
        return [
          pw.Container(
            width: 20,
            height: 27.5,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: PdfColors.black),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Center(
              child: pw.Text(
                digits[index],
                style: pw.TextStyle(fontSize: 12),
              ),
            ),
          ),
          if (index < 7) pw.SizedBox(width: 4),
        ];
      }).expand((element) => element).toList(),
    );
  }

  static pw.Widget _buildMachineStatusWithTitle(String status, double minHeight) {
    PdfColor bgColor;

    if (status.toLowerCase() == 'working') {
      bgColor = PdfColors.green;
    } else if (status.toLowerCase().contains('partial')) {
      bgColor = PdfColors.orange;
    } else {
      bgColor = PdfColors.red;
    }

    return pw.Container(
      constraints: pw.BoxConstraints(minHeight: minHeight),
      padding: const pw.EdgeInsets.all(4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Machine Status',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            color: bgColor,
            child: pw.Text(
              status,
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.TableRow _tableRow(String title, String value) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: pw.Text(title, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: pw.Text(value, style: pw.TextStyle(fontSize: 9, color: PdfColors.black)),
        ),
      ],
    );
  }

  static pw.Widget _buildServiceOption(String option, String selectedServiceType) {
    final isSelected = option == selectedServiceType;
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Row(
        children: [
          pw.Container(
            width: 8,
            height: 8,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 1, color: PdfColors.black),
              color: isSelected ? PdfColors.green : PdfColors.white,
            ),
          ),
          pw.SizedBox(width: 4),
          pw.Text(option, style: pw.TextStyle(fontSize: 8)),
        ],
      ),
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  static String _formatTime(DateTime? date) {
    if (date == null) return 'N/A';
    int hour = date.hour;
    int minute = date.minute;
    String ampm = 'AM';
    if (hour >= 12) {
      ampm = 'PM';
      if (hour > 12) hour -= 12;
    }
    if (hour == 0) hour = 12;
    return '$hour:${minute.toString().padLeft(2, '0')} $ampm';
  }
}