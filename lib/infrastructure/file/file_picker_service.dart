import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for picking workout and route files from the user's filesystem.
///
/// On macOS/iOS the system document picker handles access — no runtime
/// permission request is needed.  On Android < 13, READ_EXTERNAL_STORAGE
/// is requested at runtime; on Android 13+ the Storage Access Framework
/// (used internally by file_picker) does not require a permission.
///
/// All methods return `null` on cancel, permission denial, or any error —
/// they never throw.
class FilePickerService {
  /// Opens a file picker filtered to workout formats (.zwo, .erg, .fit, .mrc).
  Future<File?> pickWorkoutFile() async {
    if (!await _requestStorageIfNeeded()) return null;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zwo', 'erg', 'fit', 'mrc'],
        withData: false,
        withReadStream: false,
      );
      return _fileFromResult(result);
    } catch (_) {
      return null;
    }
  }

  /// Opens a file picker filtered to route formats (.gpx, .tcx).
  Future<File?> pickGpxFile() async {
    if (!await _requestStorageIfNeeded()) return null;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gpx', 'tcx'],
        withData: false,
        withReadStream: false,
      );
      return _fileFromResult(result);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------

  File? _fileFromResult(FilePickerResult? result) {
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.single.path;
    if (path == null) return null;
    return File(path);
  }

  /// On Android < 13 requests READ_EXTERNAL_STORAGE at runtime.
  /// On all other platforms returns `true` immediately.
  Future<bool> _requestStorageIfNeeded() async {
    if (!Platform.isAndroid) return true;
    // On Android 13+ (API 33+) permission_handler reports the legacy
    // READ_EXTERNAL_STORAGE as granted automatically; SAF needs no extra step.
    final status = await Permission.storage.status;
    if (status.isGranted) return true;
    final result = await Permission.storage.request();
    return result.isGranted;
  }
}
