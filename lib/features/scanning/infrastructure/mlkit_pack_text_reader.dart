import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:medivault/core/error/failure.dart';
import 'package:medivault/features/scanning/domain/pack_label.dart';

/// On-device Latin text recognition. The image never leaves the phone.
final class MlKitPackTextReader implements PackTextReader {
  TextRecognizer? _recognizer;

  @override
  Future<List<RecognizedLine>> readFile(String path) async {
    final file = File(path);
    if (path.trim().isEmpty || !await file.exists()) {
      throw const Failure('scan_failed');
    }
    final stat = await file.stat();
    if (stat.type != FileSystemEntityType.file) {
      throw const Failure('scan_failed');
    }
    try {
      final recognizer = _recognizer ??= TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final recognized = await recognizer.processImage(
        InputImage.fromFilePath(path),
      );
      return [
        for (final block in recognized.blocks)
          for (final line in block.lines)
            if (line.text.trim().isNotEmpty)
              RecognizedLine(
                line.text,
                confidenceMilli: confidenceMilliFromUnitInterval(
                  line.confidence,
                ),
              ),
      ];
    } catch (error) {
      if (error is Failure) {
        rethrow;
      }
      await _closeQuietly();
      throw const Failure('scan_failed');
    }
  }

  Future<void> close() => _closeQuietly();

  Future<void> _closeQuietly() async {
    final recognizer = _recognizer;
    _recognizer = null;
    if (recognizer == null) {
      return;
    }
    try {
      await recognizer.close();
    } catch (_) {
      // The next scan creates a new recognizer.
    }
  }
}
