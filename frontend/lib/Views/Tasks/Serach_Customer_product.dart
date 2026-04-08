import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:sales_grow/Controllers/Product/Product.dart';
import 'package:sales_grow/Views/Widgets/CustomAppBar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../Models/product/getproduct_model.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' as io;

class SearchProducts extends StatefulWidget {
  const SearchProducts({super.key});

  @override
  State<SearchProducts> createState() => _SearchProductsState();
}

class _SearchProductsState extends State<SearchProducts> {
  final ProductController _productController = Get.put(ProductController());
  final TextEditingController _searchCtrl = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final RxnString _selectedCategoryId = RxnString();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _productController.fetchProducts());
  }

  bool _matchesSearch(GetProductModel product) {
    final query = _searchQuery.value.toLowerCase();

    // Category filter
    if (_selectedCategoryId.value != null &&
        product.productCategory?.id != _selectedCategoryId.value) {
      return false;
    }

    // Text search
    if (query.isEmpty) return true;
    return (product.productName?.toLowerCase().contains(query) ?? false) ||
        (product.productCategory?.productCategory
            ?.toLowerCase()
            .contains(query) ??
            false) ||
        (product.hsn?.toLowerCase().contains(query) ?? false) ||
        (product.tax?.toString().contains(query) ?? false) ||
        (product.rate?.toString().contains(query) ?? false);
  }

  List<TextSpan> _highlightText(String text) {
    final query = _searchQuery.value.toLowerCase();
    if (query.isEmpty || !text.toLowerCase().contains(query)) {
      return [TextSpan(text: text)];
    }

    final matches = <TextSpan>[];
    final lower = text.toLowerCase();
    int start = 0;
    int idx = lower.indexOf(query);
    while (idx != -1) {
      if (idx > start) {
        matches.add(TextSpan(text: text.substring(start, idx)));
      }
      matches.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: const TextStyle(
            backgroundColor: Colors.yellow, fontWeight: FontWeight.bold),
      ));
      start = idx + query.length;
      idx = lower.indexOf(query, start);
    }
    if (start < text.length) {
      matches.add(TextSpan(text: text.substring(start)));
    }
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Products'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => _searchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: 'Search Products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 12),

                // Category dropdown
                Obx(() {
                  final catsRaw = _productController.products
                      .map((p) => p.productCategory)
                      .where((c) => c != null)
                      .map((c) => c!)
                      .toList();
                  final uniqueCats = {
                    for (var c in catsRaw) c.id!: c
                  }.values.toList();

                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedCategoryId.value,
                    decoration: InputDecoration(
                      hintText: 'Filter by Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: [
                      DropdownMenuItem(value: '', child: Text('All Categories')),
                      ...uniqueCats.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.productCategory!),
                      )),
                    ],
                    onChanged: (val) => setState(() {
                      _selectedCategoryId.value = val!.isEmpty ? null : val;
                    }),
                  );
                }),
              ],
            ),
          ),

          // Product list
          Expanded(
            child: Obx(() {
              if (_productController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final filtered = _productController.products
                  .where(_matchesSearch)
                  .toList();
              if (filtered.isEmpty) {
                return const Center(child: Text('No Products Found'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final product = filtered[i];
                  return GestureDetector(
                    onTap: () =>
                        Get.to(() => ProductDetailScreen(product: product)),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shopping_bag,
                                  size: 22, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    children: _highlightText(
                                        product.productName ?? 'Unnamed'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children: _highlightText(
                                  'Category: ${product.productCategory?.productCategory ?? 'N/A'}'),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children:
                              _highlightText('HSN: ${product.hsn ?? 'N/A'}'),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children: _highlightText(
                                  'Rate: ₹${product.rate?.toStringAsFixed(2) ?? '0.00'}'),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children:
                              _highlightText('Tax: ${product.tax ?? 0}%'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final GetProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: product.productName ?? "Product Details",
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareProduct(context),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(context),
            const SizedBox(height: 24),
            _buildInfoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(BuildContext context) {
    if (product.images != null && product.images!.isNotEmpty) {
      return SizedBox(
        height: 250,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: product.images!.length,
          itemBuilder: (ctx, idx) {
            final imageUrl = product.images![idx];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenGallery(
                    images: product.images!,
                    initialIndex: idx,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Hero(
                  tag: imageUrl,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.image_not_supported, size: 80),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Product Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              Tooltip(
                message: 'Copy Product Details',
                child: IconButton(
                  icon: const Icon(Icons.content_copy, size: 20, color: Colors.grey),
                  onPressed: () {
                    final copyText = '''product name: ${product.productName ?? 'N/A'}
product id: ${product.productId?.toString() ?? 'N/A'}''';
                    Clipboard.setData(ClipboardData(text: copyText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Product details copied to clipboard'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('🛒 Product Name', product.productName),
          const Divider(),
          _buildDetailRow('🆔 Product ID', product.productId?.toString()),
          const Divider(),
          _buildDetailRow('🏷️ Category', product.productCategory?.productCategory),
          const Divider(),
          _buildDetailRow('🧾 HSN Code', product.hsn),
          const Divider(),
          _buildDetailRow('💵 Rate',
              product.rate != null ? '₹${product.rate!.toStringAsFixed(2)}' : null),
          const Divider(),
          _buildDetailRow('📈 Tax', product.tax != null ? '${product.tax}%' : null),
        ],
      ),
    );
  }
  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareProduct(BuildContext context) async {
    try {
      final pdf = pw.Document();
      final List<pw.Widget> imageWidgets = [];
      if (product.images != null && product.images!.isNotEmpty) {
        for (var url in product.images!) {
          try {
            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) {
              final image = pw.MemoryImage(response.bodyBytes);
              imageWidgets.add(
                pw.Container(
                  margin: const pw.EdgeInsets.symmetric(vertical: 5),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300, width: 1),
                  ),
                  child: pw.Image(image, width: 150, height: 150, fit: pw.BoxFit.cover),
                ),
              );
            }
          } catch (e) {
            print('Error loading image $url: $e');
          }
        }
      }

      final font = pw.Font.helvetica();
      final boldFont = pw.Font.helveticaBold();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          header: (context) => pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Product Details',
                  style: pw.TextStyle(
                      font: boldFont, fontSize: 20, color: PdfColors.blue900),
                ),
                pw.Text(
                  'Generated on: ${DateTime.now().toString().split('.')[0]}',
                  style: pw.TextStyle(
                      font: font, fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
          ),
          build: (pw.Context context) => [
            pw.SizedBox(height: 10),
            if (imageWidgets.isNotEmpty) ...[
              pw.Text('Images',
                  style: pw.TextStyle(font: boldFont, fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: imageWidgets,
              ),
              pw.SizedBox(height: 20),
            ],
            pw.Text('Product Information',
                style: pw.TextStyle(font: boldFont, fontSize: 16)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                _buildPdfTableRow(
                  'Product Name',
                  product.productName ?? 'N/A',
                  font: font,
                  boldFont: boldFont,
                  isHeader: true,
                ),
                _buildPdfTableRow(
                  'Product ID',
                  product.productId?.toString() ?? 'N/A',
                  font: font,
                  boldFont: boldFont,
                ),
                _buildPdfTableRow(
                  'Category',
                  product.productCategory?.productCategory ?? 'N/A',
                  font: font,
                  boldFont: boldFont,
                ),
                _buildPdfTableRow(
                  'HSN Code',
                  product.hsn ?? 'N/A',
                  font: font,
                  boldFont: boldFont,
                ),
                _buildPdfTableRow(
                  'Rate',
                  product.rate != null
                      ? 'INR ${product.rate!.toStringAsFixed(2)}'
                      : 'N/A',
                  font: font,
                  boldFont: boldFont,
                ),
                _buildPdfTableRow(
                  'Tax',
                  product.tax != null ? '${product.tax}%' : 'N/A',
                  font: font,
                  boldFont: boldFont,
                ),
              ],
            ),
          ],
        ),
      );

      final bytes = await pdf.save();

      if (kIsWeb) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => bytes,
          name: 'product_${product.productId ?? 'details'}.pdf',
        );
      } else {
        final tempDir = await getTemporaryDirectory();
        final file = io.File(
            '${tempDir.path}/product_${product.productId ?? 'details'}.pdf');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles([XFile(file.path)],
            text: 'Product Details: ${product.productName ?? 'Product'}');
      }
    } catch (e) {
      print('Error generating or sharing PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share product details: $e')),
      );
    }
  }

  pw.TableRow _buildPdfTableRow(
      String title,
      String value, {
        required pw.Font font,
        required pw.Font boldFont,
        bool isHeader = false,
      }) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: isHeader ? PdfColors.grey200 : PdfColors.white,
      ),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              font: isHeader ? boldFont : boldFont,
              fontSize: 12,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            value,
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenGallery({super.key, required this.images, required this.initialIndex});

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('${_currentIndex + 1}/${widget.images.length}'),
        centerTitle: true,
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.images.length,
        pageController: _pageController,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        builder: (context, index) {
          final imageUrl = widget.images[index];
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrl),
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            minScale: PhotoViewComputedScale.contained * 1,
            maxScale: PhotoViewComputedScale.covered * 2.5,
          );
        },
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}