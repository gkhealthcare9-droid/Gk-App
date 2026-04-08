import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InspectionReport {
  static Future<Uint8List> generateInspectionReport({
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
    required DateTime? warrantyStartDate,
    required DateTime? warrantyEndDate,
    required String warrantyDuration,
    required Uint8List? signatureBytes,
    required String productCategory,
    required String manufacturer,
    required List<String> trainedEmployees,
    required String natureOfComplaint,
    required String sparesReplaced,
    required String serviceType,
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
        margin: const pw.EdgeInsets.all(14),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(15),
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
                    if (gkImage != null) pw.Image(gkImage, width: 100, height: 70),
                    pw.Spacer(),
                    pw.Text(
                      'Inspection Report',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey900,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Spacer(),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Report No: RPT-001', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Date: ${_formatDate(warrantyStartDate)}', style: pw.TextStyle(fontSize: 10)),
                        pw.Text('Time: ${_formatTime(warrantyStartDate)}', style: pw.TextStyle(fontSize: 10)),
                        pw.Text('Place: $hospitalCity', style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 5),
                pw.Divider(),

                // Hospital Details
                pw.Center(
                  child: pw.Text(
                    'Client DETAILS',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  columnWidths: {
                    0: pw.FlexColumnWidth(1.5),
                    1: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    _tableRow('Hospital Name', hospitalName),
                    _tableRow('Address', hospitalAddress),
                    _tableRow('City, State', '$hospitalCity, $hospitalState'),
                    _tableRow('Phone', hospitalPhone),
                  ],
                ),

                pw.SizedBox(height: 10),

                // Machine Details
                pw.Center(
                  child: pw.Text(
                    'MACHINE DETAILS',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  columnWidths: {
                    0: pw.FlexColumnWidth(1.5),
                    1: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    _tableRow('Type of System', productCategory),
                    _tableRow('Manufacturer', manufacturer),
                    _tableRow('Serial Number', serialNumber),
                    _tableRow('Nature of Complaint', natureOfComplaint.isNotEmpty ? natureOfComplaint : 'N/A'),
                    _tableRow('Spares Replaced', sparesReplaced.isNotEmpty ? sparesReplaced : 'N/A'),
                  ],
                ),

                pw.SizedBox(height: 5),

                // Service Type Options
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Select Service Type', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                        columnWidths: {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(1)},
                        children: [
                          pw.TableRow(
                            children: [
                              _buildServiceOption('AMC', serviceType),
                              _buildServiceOption('CMC', serviceType),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              _buildServiceOption('On Call Service', serviceType),
                              _buildServiceOption('Rental', serviceType),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              _buildServiceOption('Extended Warranty', serviceType),
                              pw.Container(),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 5),

                // Action, Warranty, Note, Machine Status
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  columnWidths: {
                    0: pw.FlexColumnWidth(1.5),
                    1: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        _fixedHeightPaddedText('Action Taken', actionTaken, 80),
                        _fixedHeightWarranty(warrantyDuration, warrantyStartDate, warrantyEndDate, 80),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _fixedHeightPaddedText('Note By Engineer', remarks, 80),
                        _buildMachineStatusWithTitle(machineStatus, 80),  // ✅ Correct title + color box
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),

                // Engineer and Client Section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Engineer Name:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text(engineerName, style: pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 4),
                        if (sealImage != null)
                          pw.Container(
                            width: 40,
                            height: 40,
                            child: pw.Image(sealImage, fit: pw.BoxFit.contain),
                          ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Client Signature:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text(clientName, style: pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          width: 100,
                          height: 30,
                          decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey, width: 1)),
                          ),
                          child: signatureBytes != null
                              ? pw.Image(pw.MemoryImage(signatureBytes), fit: pw.BoxFit.contain)
                              : pw.Center(child: pw.Text('Signature: N/A', style: pw.TextStyle(fontSize: 10))),
                        ),
                      ],
                    ),
                  ],
                ),

              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
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
      padding: const pw.EdgeInsets.all(6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Machine Status',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            color: bgColor,
            child: pw.Text(
              status,
              style: pw.TextStyle(
                fontSize: 10,
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
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: pw.Text(title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: pw.Text(value, style: pw.TextStyle(fontSize: 10, color: PdfColors.black)),
        ),
      ],
    );
  }

  static pw.Widget _buildServiceOption(String option, String selectedServiceType) {
    final isSelected = option == selectedServiceType;
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Row(
        children: [
          pw.Container(
            width: 12,
            height: 12,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 1, color: PdfColors.black),
              color: isSelected ? PdfColors.green : PdfColors.white, // 🟩 Filled green if selected
            ),
          ),
          pw.SizedBox(width: 5),
          pw.Text(option, style: pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _fixedHeightPaddedText(String title, String value, double minHeight) {
    return pw.Container(
      constraints: pw.BoxConstraints(minHeight: minHeight),
      padding: const pw.EdgeInsets.all(6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  static pw.Widget _fixedHeightWarranty(String warrantyDuration, DateTime? startDate, DateTime? endDate, double height) {
    return pw.Container(
      height: height,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Warranty:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
          pw.Text('Years: $warrantyDuration', style: pw.TextStyle(fontSize: 10)),
          pw.Text('Start: ${_formatDate(startDate)}', style: pw.TextStyle(fontSize: 10)),
          pw.Text('End: ${_formatDate(endDate)}', style: pw.TextStyle(fontSize: 10)),
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
