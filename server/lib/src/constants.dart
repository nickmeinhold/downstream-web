// Shared constants - see SCHEMA.md at repo root for full documentation
// Keep in sync with downstream-cli/lib/constants.dart

/// Firestore collection names
class Collections {
  static const requests = 'requests';
  static const users = 'users';
  static const watched = 'watched';
}

/// Request status values
/// See SCHEMA.md for status transition diagram
class RequestStatus {
  static const pending = 'pending';
  static const downloading = 'downloading';
  static const transcoding = 'transcoding';
  static const uploading = 'uploading';
  static const available = 'available';
  static const failed = 'failed';

  /// Status values in processing order
  static const phaseOrder = [pending, downloading, transcoding, uploading, available];

  /// Check if a status indicates the request is still being processed
  static bool isProcessing(String status) =>
      status == downloading || status == transcoding || status == uploading;

  /// Check if a status indicates the request is complete (success or failure)
  static bool isComplete(String status) =>
      status == available || status == failed;
}

/// Media type values
class MediaType {
  static const movie = 'movie';
  static const tv = 'tv';
}
