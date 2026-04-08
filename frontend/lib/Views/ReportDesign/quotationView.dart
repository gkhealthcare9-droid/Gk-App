import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class QuotationService {
  static Future<void> generateQuotationFromProducts({
    required List<Map<String, dynamic>> products,
    required String buyerName,
    required String buyerAddress,
    required String buyerGST,
    required String buyerState,
    required String quotationNumber,
    required String quotationDate,
    double taxRate = 0.18,
    String outputFileName = 'quotation.pdf',
    String? buyerContact,
    required String termsAndConditions,
    required String bankDetails,
  }) async {
    final pdf = pw.Document();

    // Load the image data for top-left (logo.jpg)
    final headerLogoBytes = await rootBundle.load('assets/images/logo.jpg');
    final headerLogoImage = pw.MemoryImage(headerLogoBytes.buffer.asUint8List());

    // Load the image data for bottom-right (gk.jpg)
    final footerLogoBytes = await rootBundle.load('assets/images/gk.jpg');
    final footerLogoImage = pw.MemoryImage(footerLogoBytes.buffer.asUint8List());

    // Load the Roboto font with error handling
    pw.Font regularFont;
    pw.Font boldFont;
    try {
      final regularFontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      regularFont = pw.Font.ttf(regularFontData);
    } catch (e) {
      throw Exception('Failed to load Roboto-Regular.ttf: $e');
    }
    try {
      final boldFontData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
      boldFont = pw.Font.ttf(boldFontData);
    } catch (e) {
      throw Exception('Failed to load Roboto-Bold.ttf: $e');
    }

    // Define a theme with the custom font
    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
    );

    // Calculate totals
    final subtotal = products.fold<double>(
      0.0,
          (sum, item) => sum + (item['amount'] as double),
    );
    final taxAmount = subtotal * taxRate;
    final total = subtotal + taxAmount;
    final taxLabel = taxRate == 0.05 ? 'GST @5%' : 'IGST PAYABLE';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        theme: theme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header: Logo on the left, Quotation Info on the right
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo (top-left)
                  pw.Image(headerLogoImage, width: 120),
                  pw.Spacer(),
                  // Quotation Info (top-right)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'QUOTATION',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Vendor Details and Quotation Number/Date in a row
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Vendor Details (left)
                  pw.Expanded(
                    flex: 3,
                    child: pw.Table(
                      border: pw.TableBorder.all(width: 0.5),
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'G K Health Care',
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Text(
                                    '#27/D, Ground Floor, Thirumala Nagar,\nAttur Village Yelahanka, Bangalore-560 064\nDrug License No. KAB52-170709/710\nGSTIN/UIN: 29ALZPC8787G1Z3\nState Name: Karnataka, Code: 29',
                                    style: pw.TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  // Quotation Number and Date (right)
                  pw.Expanded(
                    flex: 2,
                    child: pw.Table(
                      border: pw.TableBorder.all(width: 0.5),
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                'Quotation: $quotationNumber',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                'Dated: $quotationDate',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Buyer Details
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Buyer (Bill to)',
                              style: pw.TextStyle(fontSize: 10),
                            ),
                            pw.Text(
                              buyerName,
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              '$buyerAddress${buyerContact != null ? '\n$buyerContact' : ''}\nGSTIN/UIN: $buyerGST\nState Name: $buyerState',
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Item Table
              pw.Table(
                border: pw.TableBorder(
                  top: pw.BorderSide(width: 0.5),
                  bottom: pw.BorderSide(width: 0.5),
                  left: pw.BorderSide(width: 0.5),
                  right: pw.BorderSide(width: 0.5),
                  horizontalInside: pw.BorderSide.none,
                  verticalInside: pw.BorderSide(width: 0.5),
                ),
                columnWidths: {
                  0: pw.FlexColumnWidth(0.5), // Sl No.
                  1: pw.FlexColumnWidth(4.0), // Description of Goods
                  2: pw.FlexColumnWidth(1.0), // HSN/SAC
                  3: pw.FlexColumnWidth(0.8), // Quantity
                  4: pw.FlexColumnWidth(1.0), // Rate
                  5: pw.FlexColumnWidth(1.2), // Amount
                },
                children: [
                  // Header Row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                    ),
                    children: [
                      _tableCell('Sl\nNo.', align: pw.Alignment.center),
                      _tableCell('Description of Goods', align: pw.Alignment.center),
                      _tableCell('HSN/SAC', align: pw.Alignment.center),
                      _tableCell('Quantity', align: pw.Alignment.center),
                      _tableCell('Rate', align: pw.Alignment.center),
                      _tableCell('Amount', align: pw.Alignment.center),
                    ],
                  ),
                  // Item Rows
                  ...products.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final product = entry.value;
                    return _buildItemRow(
                      index,
                      '${product['name']}${product['ref'] != null ? '\n${product['ref']}' : ''}\n${product['description']}',
                      product['hsn'],
                      product['quantity'],
                      product['rate'] as double,
                      product['amount'] as double,
                    );
                  }),
                  // Subtotal Row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                    ),
                    children: [
                      _tableCell(''),
                      _tableCell(''),
                      _tableCell(''),
                      _tableCell(''),
                      _tableCell('Total', align: pw.Alignment.center, isBold: true),
                      _tableCell(subtotal.toStringAsFixed(2), align: pw.Alignment.center, isBold: true),
                    ],
                  ),
                  // IGST Row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                    ),
                    children: [
                      _tableCell(''),
                      _tableCell(''),
                      _tableCell(''),
                      _tableCell(''),
                      _tableCell(taxLabel, align: pw.Alignment.center, isBold: true),
                      _tableCell(taxAmount.toStringAsFixed(2), align: pw.Alignment.center, isBold: true),
                    ],
                  ),
                  // Grand Total Row
                  pw.TableRow(
                    children: [
                      _tableCell(''),
                      _tableCell(''),
                      _tableCell(''),
                      _tableCell(''),
                      _tableCell('Total', align: pw.Alignment.center, isBold: true),
                      _tableCell('₹ ${total.toStringAsFixed(2)}', align: pw.Alignment.center, isBold: true),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Terms and Bank Details
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    children: [
                      // Terms & Conditions
                      pw.Container(
                        color: PdfColors.grey100, // Subtle background shading
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                children: [
                                  pw.Text(
                                    'Terms & Conditions',
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 6),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: termsAndConditions
                                    .replaceAll('\$taxLabel', taxLabel)
                                    .split('\n')
                                    .map((line) => pw.Padding(
                                  padding: const pw.EdgeInsets.only(bottom: 3),
                                  child: pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        '• ',
                                        style: pw.TextStyle(
                                          fontSize: 8,
                                          color: PdfColors.blue800,
                                        ),
                                      ),
                                      pw.SizedBox(width: 2),
                                      pw.Expanded(
                                        child: pw.Text(
                                          line.trim(),
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            color: PdfColors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Bank Details
                      pw.Container(
                        color: PdfColors.grey100, // Subtle background shading
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                children: [
                                  pw.Text(
                                    'Bank Details',
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 6),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: bankDetails.split('\n').map((line) {
                                  final parts = line.split(':');
                                  if (parts.length == 2) {
                                    return pw.Padding(
                                      padding: const pw.EdgeInsets.only(bottom: 3),
                                      child: pw.Row(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                            '${parts[0].trim()}:',
                                            style: pw.TextStyle(
                                              fontSize: 8,
                                              fontWeight: pw.FontWeight.bold,
                                              color: PdfColors.blue800,
                                            ),
                                          ),
                                          pw.SizedBox(width: 4),
                                          pw.Expanded(
                                            child: pw.Text(
                                              parts[1].trim(),
                                              style: pw.TextStyle(
                                                fontSize: 8,
                                                color: PdfColors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return pw.SizedBox();
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Footer
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'E. & O. E.',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                    pw.Text(
                      'for G K Health Care',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Authorised Signatory',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Image(
                      footerLogoImage,
                      width: 80,
                      fit: pw.BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save to temporary directory and share
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$outputFileName');
      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Quotation PDF - $quotationNumber',
      );
    } catch (e) {
      throw Exception('Failed to generate or share PDF: $e');
    }
  }

  static pw.Widget _tableCell(
      String text, {
        pw.Alignment align = pw.Alignment.centerLeft,
        bool isBold = false,
      }) =>
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        alignment: align,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );

  static pw.TableRow _buildItemRow(
      int index,
      String description,
      String hsn,
      String quantity,
      double rate,
      double amount,
      ) =>
      pw.TableRow(
        children: [
          _tableCell('$index', align: pw.Alignment.center),
          _tableCell(description, align: pw.Alignment.topLeft),
          _tableCell(hsn, align: pw.Alignment.center),
          _tableCell(quantity, align: pw.Alignment.center, isBold: true),
          _tableCell(rate.toStringAsFixed(2), align: pw.Alignment.center),
          _tableCell(amount.toStringAsFixed(2), align: pw.Alignment.center, isBold: true),
        ],
      );
}