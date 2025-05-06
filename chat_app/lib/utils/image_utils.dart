import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<File> compressImageFile(File file) async {
  final dir = await getTemporaryDirectory();
  final targetPath = path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.webp');

  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 96,
    format: CompressFormat.webp,
    minWidth: 1080,
    minHeight: 1080
  );

  if (result == null) {
    throw Exception("Error al comprimir la imagen");
  }

  return File(result.path);
}