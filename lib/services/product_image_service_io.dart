import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ProductImageService {
  ProductImageService._();

  static Future<String?> pickAndStoreImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, 'product_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final extension = p.extension(file.name).isNotEmpty
        ? p.extension(file.name)
        : '.png';
    final storedPath = p.join(
      imagesDir.path,
      '${DateTime.now().microsecondsSinceEpoch}$extension',
    );

    if (file.path != null && file.path!.isNotEmpty) {
      await File(file.path!).copy(storedPath);
    } else if (file.bytes != null) {
      await File(storedPath).writeAsBytes(file.bytes!);
    } else {
      return null;
    }

    return storedPath;
  }
}
