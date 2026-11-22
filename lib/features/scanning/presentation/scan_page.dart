import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medivault/core/logging/safe_logger.dart';
import 'package:medivault/features/inventory/domain/medicine.dart';
import 'package:medivault/features/scanning/domain/pack_label.dart';

final packTextReaderProvider = Provider<PackTextReader>(
  (ref) => const UnavailablePackTextReader(),
);

const _ink = Color(0xFF0F5C78);
const _check = Color(0xFF6B3E00);
const _sureEnough = 700;

enum _Phase { starting, denied, unavailable, ready, reading, failed, review }

/// Opens the camera, reads one pack, then deletes the photo.
class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  CameraController? _camera;
  _Phase _phase = _Phase.starting;
  LabelReading? _reading;
  String? _message;

  @override
  void initState() {
    super.initState();
    _openCamera();
  }

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    await _releaseCamera();
    if (!mounted) {
      return;
    }
    setState(() {
      _phase = _Phase.starting;
      _reading = null;
      _message = null;
    });
    try {
      final cameras = await availableCameras();
      if (!mounted) {
        return;
      }
      if (cameras.isEmpty) {
        setState(() => _phase = _Phase.unavailable);
        return;
      }
      final controller = CameraController(
        _backCamera(cameras),
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _camera = controller;
        _phase = _Phase.ready;
      });
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }
      final denied =
          error.code == 'CameraAccessDenied' ||
          error.code == 'CameraAccessDeniedWithoutPrompt';
      setState(() => _phase = denied ? _Phase.denied : _Phase.unavailable);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _phase = _Phase.unavailable);
    }
  }

  Future<void> _readPack() async {
    final camera = _camera;
    if (camera == null || _phase != _Phase.ready) {
      return;
    }
    setState(() => _phase = _Phase.reading);
    final reader = ref.read(packTextReaderProvider);
    final logger = ref.read(safeLoggerProvider);
    String? path;
    try {
      final shot = await camera.takePicture();
      path = shot.path;
      final reading = readLabel(await reader.readFile(path));
      final deleted = await _deletePhoto(path, logger);
      path = null;
      if (!mounted) {
        return;
      }
      await _releaseCamera();
      if (!mounted) {
        return;
      }
      setState(() {
        _reading = reading;
        _phase = _Phase.review;
        _message = _reviewMessage(reading, deleted);
      });
    } catch (_) {
      logger.event('scan_failed');
      final deleted = await _deletePhoto(path, logger);
      if (!mounted) {
        return;
      }
      setState(() {
        _phase = _Phase.failed;
        _message = deleted
            ? 'The pack could not be read. Hold it steady in bright light and try again.'
            : 'The pack could not be read, and the photo could not be deleted. Restart MediVault and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan a pack')),
      body: switch (_phase) {
        _Phase.starting => const _Status(
          message: 'Opening the camera.',
          busy: true,
        ),
        _Phase.denied => const _Status(
          message: 'MediVault needs the camera to read a pack. Allow the camera in Settings, then come back.',
        ),
        _Phase.unavailable => const _Status(
          message: 'This phone has no camera MediVault can use.',
        ),
        _Phase.failed => _Status(
          message: _message ?? 'The pack could not be read.',
          action: 'Try again',
          onAction: _openCamera,
        ),
        _Phase.ready || _Phase.reading => _Preview(
          camera: _camera!,
          busy: _phase == _Phase.reading,
          onRead: _readPack,
        ),
        _Phase.review => LabelReview(
          reading: _reading ?? const LabelReading(),
          message: _message,
          onScanAgain: _openCamera,
        ),
      },
    );
  }

  Future<void> _releaseCamera() async {
    final camera = _camera;
    _camera = null;
    await camera?.dispose();
  }
}

CameraDescription _backCamera(List<CameraDescription> cameras) {
  for (final camera in cameras) {
    if (camera.lensDirection == CameraLensDirection.back) {
      return camera;
    }
  }
  return cameras.first;
}

Future<bool> _deletePhoto(String? path, SafeLogger logger) async {
  if (path == null || path.isEmpty) {
    return true;
  }
  try {
    final file = File(path);
    if (!await file.exists()) {
      return true;
    }
    await file.delete();
    if (await file.exists()) {
      logger.event('photo_not_deleted');
      return false;
    }
    return true;
  } catch (_) {
    logger.event('photo_not_deleted');
    return false;
  }
}

String? _reviewMessage(LabelReading reading, bool deleted) {
  if (!deleted) {
    return 'The photo could not be deleted. Restart MediVault before you scan another pack.';
  }
  if (reading.isEmpty) {
    return 'No medicine details were found. Hold the pack steady and try again.';
  }
  return null;
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.camera,
    required this.busy,
    required this.onRead,
  });

  final CameraController camera;
  final bool busy;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ColoredBox(
            color: Colors.black,
            child: Center(
              child: Semantics(
                label: 'Camera preview. Fill the frame with the name and the expiry date.',
                child: CameraPreview(camera),
              ),
            ),
          ),
        ),
        ColoredBox(
          color: _ink,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: busy
                  ? const SizedBox(
                      height: 56,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          semanticsLabel: 'Reading the pack',
                        ),
                      ),
                    )
                  : FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _ink,
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: onRead,
                      child: const Text('Read this pack'),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({
    required this.message,
    this.busy = false,
    this.action,
    this.onAction,
  });

  final String message;
  final bool busy;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (busy) ...[
              const LinearProgressIndicator(
                semanticsLabel: 'Opening the camera',
              ),
              const SizedBox(height: 24),
            ],
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            if (action != null)
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: onAction,
                child: Text(action!),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shows the extracted fields. The reading is not written to the cabinet.
class LabelReview extends StatelessWidget {
  const LabelReview({
    required this.reading,
    required this.onScanAgain,
    this.message,
    super.key,
  });

  final LabelReading reading;
  final String? message;
  final VoidCallback onScanAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (message != null) ...[
                Text(message!, style: theme.textTheme.titleMedium),
                const SizedBox(height: 24),
              ],
              _row(
                theme,
                'Medicine name',
                reading.name?.value,
                reading.name?.confidenceMilli,
              ),
              _row(
                theme,
                'Strength',
                reading.strength == null
                    ? null
                    : _strengthText(reading.strength!.value),
                reading.strength?.confidenceMilli,
              ),
              _row(
                theme,
                'Dosage',
                reading.dosage?.value,
                reading.dosage?.confidenceMilli,
              ),
              _row(
                theme,
                'Expiry date',
                reading.expiration == null
                    ? null
                    : _expiryText(reading.expiration!.value),
                reading.expiration?.confidenceMilli,
              ),
              _row(
                theme,
                'Batch number',
                reading.batchNumber?.value,
                reading.batchNumber?.confidenceMilli,
              ),
              Text(
                'This reading stays on this screen. It is not saved in the cabinet.',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            onPressed: onScanAgain,
            child: const Text('Scan again'),
          ),
        ),
      ],
    );
  }

  Widget _row(
    ThemeData theme,
    String label,
    String? value,
    int? confidenceMilli,
  ) {
    final shown = value ?? 'Not found';
    final check =
        value == null ||
        confidenceMilli == null ||
        confidenceMilli < _sureEnough;
    final certainty = check
        ? 'Please check'
        : '${(confidenceMilli / 10).round()}% sure';
    return Semantics(
      excludeSemantics: true,
      label: '$label. $shown. $certainty.',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(shown, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              certainty,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: check ? _check : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _strengthText(Strength strength) {
  return '${formatMilliUnits(strength.milli)} ${strength.unit.name}';
}

String _expiryText(ExpirationDate date) {
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  if (date.day == null) {
    return '$month/$year';
  }
  final day = date.day!.toString().padLeft(2, '0');
  return '$day/$month/$year';
}
