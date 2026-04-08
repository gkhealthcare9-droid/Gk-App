import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class DeliveryChallanService {
  static Future<void> generateDeliveryChallan({
    required String vendorName,
    required String vendorAddress,
    required String vendorGST,
    required String vendorState,
    required String? vendorContact,
    required String? vendorAccounts,
    required String? vendorEmail,
    required String poNumber,
    required List<Map<String, dynamic>> products,
    required double transportCharge,
    required String selectedTax,
    required String createdBy,
  }) async {
    final pdf = pw.Document();

    // Load the logo and seal images from assets
    final logoBytes = await rootBundle.load('assets/images/logo.jpg');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    final sealBytes = await rootBundle.load('assets/images/gk.jpg');
    final sealImage = pw.MemoryImage(sealBytes.buffer.asUint8List());

    // Load the font for rupee symbol support
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.5),
            ),
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header: Logo + Company Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(width: 150, child: pw.Image(logoImage)),
                    pw.Expanded(
                      child: pw.Align(
                        alignment: pw.Alignment.center,
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'GK HEALTH CARE',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),

                            pw.Text(
                              'DELIVERY NOTE',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                    pw.Container(width: 150),
                  ],
                ),
                pw.SizedBox(height: 10),

                // Buyer & PO Details
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  columnWidths: {
                    0: pw.FlexColumnWidth(1),
                    1: pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        // Buyer Info (H M Enterprises)
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'H M ENTERPRISES',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                '#27/D, Ground Floor, Thirumala Nagar,',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                              pw.Text(
                                'Attur Village Yelahanka, Bangalore - 566 064',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                'Drug Licence No. KAB52-170709/710',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                              pw.Text(
                                'GSTIN/UN: 29ALZPC8787G1Z3',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                              pw.Text(
                                'State Name: Karnataka, Code: 29',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        // PO Details
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Column(
                            children: [
                              pw.Table(
                                border: pw.TableBorder.all(width: 0.5),
                                columnWidths: {
                                  0: pw.FlexColumnWidth(1),
                                  1: pw.FlexColumnWidth(1),
                                },
                                children: [
                                  pw.TableRow(
                                    children: [
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.all(4),
                                        child: pw.Text(
                                          'Delivery No.',
                                          style: pw.TextStyle(fontSize: 10),
                                        ),
                                      ),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.all(4),
                                        child: pw.Text(
                                          'Dated',
                                          style: pw.TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  pw.TableRow(
                                    children: [
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.all(4),
                                        child: pw.Text(
                                          poNumber,
                                          style: pw.TextStyle(fontSize: 10),
                                        ),
                                      ),
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.all(4),
                                        child: pw.Text(
                                          DateFormat('dd/MM/yyyy').format(DateTime.now()),
                                          style: pw.TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 20),
                              pw.Text(
                                'Created By: $createdBy',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Supplier Details
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  columnWidths: {
                    0: pw.FlexColumnWidth(1),
                    1: pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Supplier (Bill from)',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                vendorName,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              ...vendorAddress.split('\n').map((line) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    line,
                                    style: pw.TextStyle(fontSize: 10),
                                  ),
                                  pw.SizedBox(height: 2),
                                ],
                              )),
                              if (vendorContact != null && vendorContact.isNotEmpty) ...[
                                pw.Text(
                                  'Phone No: $vendorContact',
                                  style: pw.TextStyle(fontSize: 10),
                                ),
                                pw.SizedBox(height: 2),
                              ],
                              if (vendorAccounts != null && vendorAccounts.isNotEmpty) ...[
                                pw.Text(
                                  'Accounts: $vendorAccounts',
                                  style: pw.TextStyle(fontSize: 10),
                                ),
                                pw.SizedBox(height: 2),
                              ],
                              if (vendorEmail != null && vendorEmail.isNotEmpty) ...[
                                pw.Text(
                                  'Email: $vendorEmail',
                                  style: pw.TextStyle(fontSize: 10),
                                ),
                                pw.SizedBox(height: 2),
                              ],
                              pw.Text(
                                'GSTIN: $vendorGST',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                'State Name: $vendorState, ',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Dispatch Doc No: $poNumber',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                              pw.Text(
                                'Destination: $vendorState',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                              pw.SizedBox(height: 10),
                              pw.Text(
                                'Dispatched through: Road',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                              pw.SizedBox(height: 10),
                              pw.Text(
                                'EN',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                              pw.SizedBox(height: 10),
                              pw.Text(
                                'EN',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Product Table
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
                    0: pw.FlexColumnWidth(0.4),
                    1: pw.FlexColumnWidth(5.5),
                    2: pw.FlexColumnWidth(1),
                    3: pw.FlexColumnWidth(1),
                    4: pw.FlexColumnWidth(1),
                    5: pw.FlexColumnWidth(1),
                    6: pw.FlexColumnWidth(1.2),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        for (final text in [
                          'SlNo',
                          'Description of Goods',
                          'HSN',
                          'Rate',
                          'Quantity',
                          'Taxable Value',
                          'Amount',
                        ])
                          pw.Container(
                            height: 25,
                            alignment: pw.Alignment.center,
                            padding: const pw.EdgeInsets.all(4),
                            decoration: pw.BoxDecoration(
                              border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
                            ),
                            child: pw.Text(
                              text,
                              style: pw.TextStyle(fontSize: 8),
                            ),
                          ),
                      ],
                    ),
                    ...products.asMap().entries.map((entry) {
                      final index = entry.key;
                      final product = entry.value;
                      final amount = double.parse(product['rate'].toString()) * double.parse(product['quantity']);
                      return pw.TableRow(
                        verticalAlignment: pw.TableCellVerticalAlignment.top,
                        children: [
                          pw.Container(
                            height: 30,
                            alignment: pw.Alignment.center,
                            padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                            child: pw.Text(
                              '${index + 1}',
                              style: pw.TextStyle(fontSize: 8),
                            ),
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  product['name'],
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text(
                                  product['description'],
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontStyle: pw.FontStyle.italic,
                                  ),
                                ),
                                pw.Text(
                                  'Ref PO No: $poNumber',
                                  style: pw.TextStyle(
                                    fontSize: 7,
                                    fontStyle: pw.FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Container(
                            height: 30,
                            alignment: pw.Alignment.center,
                            padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                            child: pw.Text(
                              product['hsn'],
                              style: pw.TextStyle(fontSize: 8),
                            ),
                          ),
                          pw.Container(
                            height: 30,
                            alignment: pw.Alignment.center,
                            padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                            child: pw.Text(
                              product['rate'].toString(),
                              style: pw.TextStyle(fontSize: 8),
                            ),
                          ),
                          pw.Container(
                            height: 30,
                            alignment: pw.Alignment.center,
                            padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                            child: pw.Text(
                              product['quantity'],
                              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                          pw.Container(
                            height: 30,
                            alignment: pw.Alignment.center,
                            padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                            child: pw.Text(
                              product['tax'],
                              style: pw.TextStyle(fontSize: 8),
                            ),
                          ),
                          pw.Container(
                            height: 30,
                            alignment: pw.Alignment.center,
                            padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                            child: pw.Text(
                              amount.toStringAsFixed(2),
                              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    }),
                    pw.TableRow(
                      children: [
                        pw.Container(
                          height: 30,
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.all(4),
                          decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(width: 1)),
                          ),
                          child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Container(
                          height: 30,
                          alignment: pw.Alignment.centerRight,
                          padding: const pw.EdgeInsets.all(4),
                          decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(width: 1)),
                          ),
                          child: pw.Text(
                            'IGST $selectedTax',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontStyle: pw.FontStyle.italic,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Container(
                          height: 30,
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.all(4),
                          decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(width: 1)),
                          ),
                          child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Container(
                          height: 30,
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.all(4),
                          decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(width: 1)),
                          ),
                          child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Container(
                          height: 30,
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.all(4),
                          decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(width: 1)),
                          ),
                          child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Container(
                          height: 30,
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.all(4),
                          decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(width: 1)),
                          ),
                          child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Container(
                          height: 30,
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.all(2),
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(width: 1),
                              top: pw.BorderSide(width: 0.5),
                            ),
                          ),
                          child: pw.Text(
                            '${products.fold(0.0, (sum, item) => sum + (double.parse(item['rate'].toString()) * double.parse(item['quantity']))).toStringAsFixed(2)}\n'
                                '${(products.fold(0.0, (sum, item) => sum + (double.parse(item['rate'].toString()) * double.parse(item['quantity']))) * (selectedTax.contains('18%') ? 0.18 : 0.12)).toStringAsFixed(2)}\n'
                                '${transportCharge.toStringAsFixed(2)}',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Container(
                          height: 15,
                          padding: const pw.EdgeInsets.all(4),
                          alignment: pw.Alignment.centerRight,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(width: 0.5),
                          ),
                          child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Container(
                          height: 15,
                          padding: const pw.EdgeInsets.all(4),
                          alignment: pw.Alignment.centerRight,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(width: 0.5),
                          ),
                          child: pw.Text(
                            'Total',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Container(
                          height: 15,
                          padding: const pw.EdgeInsets.all(4),
                          alignment: pw.Alignment.centerRight,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(width: 0.5),
                          ),
                          child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Container(
                          height: 15,
                          padding: const pw.EdgeInsets.all(4),
                          alignment: pw.Alignment.centerRight,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(width: 0.5),
                          ),
                          child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Container(
                          height: 15,
                          padding: const pw.EdgeInsets.all(4),
                          alignment: pw.Alignment.centerRight,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(width: 0.5),
                          ),
                          child: pw.Text(
                            '${products.fold(0.0, (sum, item) => sum + double.parse(item['quantity'])).toStringAsFixed(0)} NOs',
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Container(
                          height: 15,
                          padding: const pw.EdgeInsets.all(4),
                          alignment: pw.Alignment.centerRight,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(width: 0.5),
                          ),
                          child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Container(
                          height: 15,
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.all(4),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(width: 0.5),
                          ),
                          child: pw.Text(
                            '₹ ${(products.fold(0.0, (sum, item) => sum + (double.parse(item['rate'].toString()) * double.parse(item['quantity']))) + (products.fold(0.0, (sum, item) => sum + (double.parse(item['rate'].toString()) * double.parse(item['quantity']))) * (selectedTax.contains('18%') ? 0.18 : 0.12)) + transportCharge).toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              font: ttf,
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Amount in Words and Transport Charge
                pw.Table(
                  border: pw.TableBorder.all(width: 0.5),
                  columnWidths: {
                    0: pw.FlexColumnWidth(1.8),
                    1: pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Amount Chargeable (in words)',
                                style: pw.TextStyle(fontSize: 8),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text(
                                _numberToWords(
                                  (products.fold(0.0, (sum, item) => sum + (double.parse(item['rate'].toString()) * double.parse(item['quantity']))) +
                                      (products.fold(0.0, (sum, item) => sum + (double.parse(item['rate'].toString()) * double.parse(item['quantity']))) *
                                          (selectedTax.contains('18%') ? 0.18 : 0.12)) +
                                      transportCharge)
                                      .toInt(),
                                ),
                                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Transport Charge: ₹${transportCharge.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              font: ttf,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Footer
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Recd. in GOOD CONDITION',
                      style: pw.TextStyle(fontSize: 8),
                    ),
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 0.5),
                      ),
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Image(sealImage, width: 80, height: 40),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'Authorised Signatory',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
                pw.Text(
                  'For Office Use:',
                  style: pw.TextStyle(fontSize: 8),
                ),
                pw.SizedBox(height: 5),
                dashedLine(),

                pw.SizedBox(height: 3),
                dashedLine(),

                pw.SizedBox(height: 3),
                dashedLine(),

                pw.SizedBox(height: 15),
                pw.Text(
                  'G K Health Care Authorised Signatory',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save PDF to temporary file and share
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/Delivery_Challan_$poNumber.pdf');
    await tempFile.writeAsBytes(await pdf.save());
    print('✅ PDF created at: ${tempFile.path}');

    // Share the PDF using share_plus
    await Share.shareXFiles(
      [XFile(tempFile.path)],
      text: 'Purchase Order $poNumber',
      subject: 'Purchase Order $poNumber',
    );
  }

  static String _numberToWords(int number) {
    if (number == 0) return 'Zero';

    const List<String> units = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];
    const List<String> tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];
    const List<String> thousands = ['', 'Thousand', 'Lakh', 'Crore'];

    String words = '';
    int thousandIndex = 0;

    while (number > 0) {
      if (number % 1000 != 0) {
        String temp = '';
        int n = number % 1000;

        if (n >= 100) {
          temp += '${units[n ~/ 100]} Hundred ';
          n %= 100;
        }

        if (n > 0) {
          if (n < 20) {
            temp += '${units[n]} ';
          } else {
            temp += '${tens[n ~/ 10]} ';
            if (n % 10 > 0) temp += '${units[n % 10]} ';
          }
        }

        temp += '${thousands[thousandIndex]} ';
        words = temp + words;
      }
      number ~/= 1000;
      thousandIndex++;
    }

    return '${words.trim()} Only';
  }
  static pw.Widget dashedLine() {
    return pw.Container(
      height: 1,
      width: double.infinity,
      child: pw.CustomPaint(
        size: const PdfPoint(500, 1),
        painter: (canvas, size) {
          const dashWidth = 3.0;
          const dashSpace = 2.0;
          double startX = 0;

          canvas.setLineWidth(1);
          canvas.setStrokeColor(PdfColors.black);

          while (startX < size.x) {
            canvas.moveTo(startX, 0);
            canvas.lineTo(startX + dashWidth, 0);
            canvas.strokePath();
            startX += dashWidth + dashSpace;
          }
        },
      ),
    );
  }

}