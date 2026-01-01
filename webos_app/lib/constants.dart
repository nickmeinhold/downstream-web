// Shared constants - see SCHEMA.md at repo root for full documentation
// Keep in sync with server/lib/src/constants.dart and downstream-cli

/// Request status values
/// See SCHEMA.md for status transition diagram
class RequestStatus {
  static const pending = 'pending';
  static const downloaded = 'downloaded'; // Ready for transcoding (skips search/download)
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

  /// Check if a status indicates the request needs to be picked up
  static bool needsPickup(String status) =>
      status == pending || status == downloaded;
}

/// Media type values
class MediaType {
  static const movie = 'movie';
  static const tv = 'tv';
}
