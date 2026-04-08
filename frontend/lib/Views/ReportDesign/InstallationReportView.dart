import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InstallationRepotView {
  static Future<Uint8List> generateInstallationRepotView({
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
    required int reportNumber,
    required String manufacturer, required List<String> trainedEmployees, required String complaintFrom,
  }) async {
    final pdf = pw.Document();

    pw.MemoryImage? gkImage;
    try {
      final gkBytes = await rootBundle.load('assets/images/logo.jpg');
      gkImage = pw.MemoryImage(gkBytes.buffer.asUint8List());
    } catch (e) {
      print('Failed to load logo.jpg: $e');
    }


    pw.MemoryImage? sealimage;
    try {
      final sealBytes = await rootBundle.load('assets/images/gk.jpg');
      sealimage = pw.MemoryImage(sealBytes.buffer.asUint8List());
    } catch (e) {
      print('Failed to load logo.jpg: $e');
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColors.black, // Outer black border
                width: 1,
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (gkImage != null)
                      pw.Image(gkImage, width: 120, height: 80),
                    pw.Spacer(),
                    pw.Text(
                      'Installation Report',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey900,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Spacer(),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Report No:$reportNumber', // <<< Your report number here
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'Date: ${_formatDate(warrantyStartDate)}',
                          style: pw.TextStyle(fontSize: 11),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Time: ${_formatTime(warrantyStartDate)}',
                          style: pw.TextStyle(fontSize: 11),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Place: $hospitalCity',
                          style: pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 2),
                pw.Divider(),

                // Hospital Details
                pw.Center(
                  child: pw.Text(
                    'Client DETAILS',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
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
                pw.SizedBox(height: 20),

                // Machine Details
                pw.Center(
                  child: pw.Text(
                    'MACHINE DETAILS',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
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
                  ],
                ),

                // Action Taken / Warranty and Note / Machine Status
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  defaultVerticalAlignment: pw.TableCellVerticalAlignment.top,
                  columnWidths: {
                    0: pw.FlexColumnWidth(1.5),
                    1: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        _fixedHeightPaddedText('Action Taken', actionTaken, 100),
                        _fixedHeightWarranty(warrantyDuration, warrantyStartDate, warrantyEndDate, 100),
                      ],
                    ),
                    pw.TableRow(
                      children: [

                        _fixedHeightPaddedText('Note By Engineer', remarks, 100),
                        _fixedHeightPaddedText('Machine Status', machineStatus, 100),
                      ],
                    ),
                  ],
                ),
pw.SizedBox(height: 10),
                // Engineer and Client Section
                // Engineer and Client Section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Engineer Name:',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Row(
                          children: [

                            pw.Text(engineerName, style: pw.TextStyle(fontSize: 11)),
                            pw.SizedBox(width: 12),
                            if (sealimage != null)
                              pw.Container(
                                width: 50,
                                height: 50,
                                child: pw.Image(sealimage),
                              ),
                          ],
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Client Signature:',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(clientName, style: pw.TextStyle(fontSize: 11)),
                        pw.SizedBox(height: 5),
                        pw.Container(
                          width: 120,
                          height: 30,
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(color: PdfColors.grey, width: 1),
                            ),
                          ),
                          child: signatureBytes != null
                              ? pw.Image(
                            pw.MemoryImage(signatureBytes),
                            fit: pw.BoxFit.contain,
                          )
                              : pw.Center(
                            child: pw.Text(
                              'Signature: N/A',
                              style: pw.TextStyle(fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Divider(),// Small gap before Office Use

// 🔵 FOR OFFICE USE SECTION
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
                      pw.Text(
                        'Training Given To:',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),

                      if (trainedEmployees.isNotEmpty)
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: List.generate(
                                  (trainedEmployees.length / 2).ceil(), // first half
                                      (index) => pw.Text(
                                    '${index + 1}) ${trainedEmployees[index]}',
                                    style: pw.TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                            pw.SizedBox(width: 20), // gap between two columns
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: List.generate(
                                  (trainedEmployees.length / 2).floor(), // second half
                                      (index) => pw.Text(
                                    '${index + 1 + (trainedEmployees.length / 2).ceil()}) ${trainedEmployees[index + (trainedEmployees.length / 2).ceil()]}',
                                    style: pw.TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        pw.Text(
                          'No employees trained.',
                          style: pw.TextStyle(fontSize: 10),
                        ),


                      pw.Align(
                        alignment: pw.Alignment.bottomRight,
                        child: pw.Text(
                          'Signature: _______________',
                          style: pw.TextStyle(fontSize: 10),
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

  // Helper to create table rows
  static pw.TableRow _tableRow(String title, String value) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 11, color: PdfColors.black),
          ),
        ),
      ],
    );
  }

  // Fixed height padded text widget
  static pw.Widget _fixedHeightPaddedText(String title, String value, double height) {
    return pw.Container(
      height: height,
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 11, color: PdfColors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  // Special warranty formatting
  static pw.Widget _fixedHeightWarranty(String warrantyDuration, DateTime? startDate, DateTime? endDate, double height) {
    return pw.Container(
      height: height,
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Warranty:',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Expanded(
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(text: 'Years: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.TextSpan(text: '$warrantyDuration\n', style: pw.TextStyle(fontSize: 11)),
                  pw.TextSpan(text: 'Start: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.TextSpan(text: '${_formatDate(startDate)}\n', style: pw.TextStyle(fontSize: 11)),
                  pw.TextSpan(text: 'End: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.TextSpan(text: _formatDate(endDate), style: pw.TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Date format helper
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
    String minuteStr = minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $ampm';
  }

}
