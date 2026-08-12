import 'snowflake.dart';

/// A file attached to a message. Modeled after `MessageAttachmentResponse`
/// in Fluxer's OpenAPI spec — decode-only for now. Sending an attachment
/// needs the presigned-upload flow (`POST /channels/{id}/attachments` +
/// uploading the bytes + `.../attachments/complete`), which nothing in
/// this ecosystem drives yet, so there's no matching `toJson`/builder
/// side of this type until something actually needs to send a file.
final class Attachment {
  const Attachment({
    required this.id,
    required this.filename,
    required this.size,
    this.description,
    this.contentType,
    this.url,
    this.proxyUrl,
    this.width,
    this.height,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
    id: Snowflake.parse(json['id'] as String),
    filename: json['filename'] as String,
    size: json['size'] as int,
    description: json['description'] as String?,
    contentType: json['content_type'] as String?,
    url: json['url'] as String?,
    proxyUrl: json['proxy_url'] as String?,
    width: json['width'] as int?,
    height: json['height'] as int?,
  );

  final Snowflake id;
  final String filename;
  final int size;
  final String? description;
  final String? contentType;
  final String? url;
  final String? proxyUrl;
  final int? width;
  final int? height;

  @override
  bool operator ==(Object other) => other is Attachment && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Attachment($id, $filename)';
}
