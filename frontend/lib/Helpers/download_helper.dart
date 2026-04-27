import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sales_grow/Views/Widgets/CustomAlert.dart';
import 'package:get/get.dart';

Future<void> downloadFile(List<int> bytes, String fileName, String mimeType) async {
  try {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], subject: 'Exported Data: $fileName');
  } catch (e) {
    CustomAlert.error('Could not save or share file: $e');
  }
}
