/// One file a client intends to upload, sent when planning an upload.
///
/// [id] is chosen by the caller and only has to be unique within the one
/// request; the plan response echoes it so each result can be matched
/// back to its file. [fileSize] must be the exact byte count — the
/// storage backend rejects a transfer that does not match it.
final class AttachmentUploadRequest {
  const AttachmentUploadRequest({
    required this.id,
    required this.filename,
    required this.fileSize,
    required this.contentType,
  });

  final int id;
  final String filename;
  final int fileSize;
  final String contentType;

  Map<String, dynamic> toJson() => {
    'id': id,
    'filename': filename,
    'file_size': fileSize,
    'content_type': contentType,
  };
}

/// One presigned part of a multipart upload.
final class AttachmentUploadPart {
  const AttachmentUploadPart({
    required this.partNumber,
    required this.uploadUrl,
  });

  factory AttachmentUploadPart.fromJson(Map<String, dynamic> json) =>
      AttachmentUploadPart(
        partNumber: json['part_number'] as int,
        uploadUrl: Uri.parse(json['upload_url'] as String),
      );

  /// One-based index; parts are assembled in this order.
  final int partNumber;

  /// Signed in its query string, so it must be used unmodified.
  final Uri uploadUrl;
}

/// Where and how one planned file should be transferred.
///
/// A file at or below 10 MiB comes back as [AttachmentUploadSinglepart],
/// anything larger as [AttachmentUploadMultipart]. Sealed so a `switch`
/// over the two modes is checked for exhaustiveness.
///
/// [uploadFilename] is the value that later claims the upload on a
/// message, and it can only be claimed once.
sealed class AttachmentUploadTarget {
  const AttachmentUploadTarget({
    required this.id,
    required this.filename,
    required this.uploadFilename,
    required this.fileSize,
    required this.contentType,
  });

  factory AttachmentUploadTarget.fromJson(Map<String, dynamic> json) =>
      switch (json['upload_mode'] as String) {
        'multipart' => AttachmentUploadMultipart.fromJson(json),
        _ => AttachmentUploadSinglepart.fromJson(json),
      };

  /// Echoes the [AttachmentUploadRequest.id] this target answers.
  final int id;
  final String filename;

  /// Single-use key naming the upload in a later message send.
  final String uploadFilename;
  final int fileSize;
  final String contentType;
}

/// A file small enough to transfer with one `PUT`.
final class AttachmentUploadSinglepart extends AttachmentUploadTarget {
  const AttachmentUploadSinglepart({
    required super.id,
    required super.filename,
    required super.uploadFilename,
    required super.fileSize,
    required super.contentType,
    required this.uploadUrl,
  });

  factory AttachmentUploadSinglepart.fromJson(Map<String, dynamic> json) =>
      AttachmentUploadSinglepart(
        id: json['id'] as int,
        filename: json['filename'] as String,
        uploadFilename: json['upload_filename'] as String,
        fileSize: json['file_size'] as int,
        contentType: json['content_type'] as String,
        uploadUrl: Uri.parse(json['upload_url'] as String),
      );

  /// Signed in its query string, so it must be used unmodified.
  final Uri uploadUrl;

  @override
  String toString() => 'AttachmentUploadSinglepart($filename)';
}

/// A file large enough to require per-part transfer, finalised with a
/// separate complete call once every part is uploaded.
final class AttachmentUploadMultipart extends AttachmentUploadTarget {
  const AttachmentUploadMultipart({
    required super.id,
    required super.filename,
    required super.uploadFilename,
    required super.fileSize,
    required super.contentType,
    required this.uploadId,
    required this.partSize,
    required this.parts,
  });

  factory AttachmentUploadMultipart.fromJson(Map<String, dynamic> json) =>
      AttachmentUploadMultipart(
        id: json['id'] as int,
        filename: json['filename'] as String,
        uploadFilename: json['upload_filename'] as String,
        fileSize: json['file_size'] as int,
        contentType: json['content_type'] as String,
        uploadId: json['upload_id'] as String,
        partSize: json['part_size'] as int,
        parts: (json['parts'] as List<dynamic>)
            .map(
              (p) => AttachmentUploadPart.fromJson(p as Map<String, dynamic>),
            )
            .toList(growable: false),
      );

  /// Identifies the multipart upload when completing it.
  final String uploadId;

  /// Byte length of every part except the last, which may be shorter.
  final int partSize;

  final List<AttachmentUploadPart> parts;

  @override
  String toString() =>
      'AttachmentUploadMultipart($filename, ${parts.length} parts)';
}

/// A file already transferred to storage, ready to be claimed by a
/// message send.
///
/// Nothing about an upload becomes visible until a message references it:
/// an upload never claimed is simply discarded.
final class UploadedAttachment {
  const UploadedAttachment({
    required this.id,
    required this.filename,
    required this.uploadFilename,
    required this.fileSize,
    required this.contentType,
    this.title,
    this.description,
  });

  /// Builds the claim for a completed [target].
  factory UploadedAttachment.of(
    AttachmentUploadTarget target, {
    String? title,
    String? description,
  }) => UploadedAttachment(
    id: target.id,
    filename: target.filename,
    uploadFilename: target.uploadFilename,
    fileSize: target.fileSize,
    contentType: target.contentType,
    title: title,
    description: description,
  );

  final int id;
  final String filename;
  final String uploadFilename;
  final int fileSize;
  final String contentType;

  /// 1-1024 characters.
  final String? title;

  /// Alt text, 1-4096 characters.
  final String? description;

  Map<String, dynamic> toJson() => {
    'id': id,
    'filename': filename,
    'upload_filename': uploadFilename,
    'file_size': fileSize,
    'content_type': contentType,
    if (title != null) 'title': title,
    if (description != null) 'description': description,
  };

  @override
  String toString() => 'UploadedAttachment($filename)';
}

/// One attachment URL re-signed so it can be fetched again.
///
/// An attachment URL carries a signature that expires, so a URL stored
/// from an earlier message eventually stops working. Refreshing takes the
/// stored URL and returns the same URL with a current signature.
final class RefreshedAttachmentUrl {
  const RefreshedAttachmentUrl({
    required this.original,
    required this.refreshed,
  });

  factory RefreshedAttachmentUrl.fromJson(Map<String, dynamic> json) =>
      RefreshedAttachmentUrl(
        original: json['original'] as String,
        refreshed: json['refreshed'] as String,
      );

  /// The requested URL, echoed back unchanged.
  final String original;

  /// The same URL with a fresh signature, or [original] unchanged when it
  /// is not an attachment URL this deployment serves.
  final String refreshed;

  /// Whether the URL actually changed.
  bool get wasRefreshed => refreshed != original;

  @override
  String toString() => 'RefreshedAttachmentUrl($original)';
}
