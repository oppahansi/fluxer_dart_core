/// A rich embed attached to a message. Modeled after `RichEmbedRequest`
/// (outgoing) and `MessageEmbedResponse` (incoming) in Fluxer's OpenAPI
/// spec — the two shapes mostly overlap, so this one class covers both
/// directions rather than a separate request/response pair; [toJson]
/// only emits the fields the request schema actually accepts.
final class Embed {
  const Embed({
    this.title,
    this.description,
    this.url,
    this.color,
    this.timestamp,
    this.author,
    this.footer,
    this.image,
    this.thumbnail,
    this.fields = const [],
  });

  factory Embed.fromJson(Map<String, dynamic> json) => Embed(
    title: json['title'] as String?,
    description: json['description'] as String?,
    url: json['url'] as String?,
    color: json['color'] as int?,
    timestamp: (json['timestamp'] as String?)?.let(DateTime.parse),
    author: (json['author'] as Map<String, dynamic>?)?.let(
      EmbedAuthor.fromJson,
    ),
    footer: (json['footer'] as Map<String, dynamic>?)?.let(
      EmbedFooter.fromJson,
    ),
    image: (json['image'] as Map<String, dynamic>?)?.let(EmbedMedia.fromJson),
    thumbnail: (json['thumbnail'] as Map<String, dynamic>?)?.let(
      EmbedMedia.fromJson,
    ),
    fields: (json['fields'] as List<dynamic>? ?? const [])
        .map((f) => EmbedField.fromJson(f as Map<String, dynamic>))
        .toList(growable: false),
  );

  final String? title;
  final String? description;
  final String? url;

  /// RGB, packed as `0xRRGGBB`.
  final int? color;
  final DateTime? timestamp;
  final EmbedAuthor? author;
  final EmbedFooter? footer;
  final EmbedMedia? image;
  final EmbedMedia? thumbnail;
  final List<EmbedField> fields;

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (url != null) 'url': url,
    if (color != null) 'color': color,
    if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    if (author != null) 'author': author!.toJson(),
    if (footer != null) 'footer': footer!.toJson(),
    if (image != null) 'image': image!.toJson(),
    if (thumbnail != null) 'thumbnail': thumbnail!.toJson(),
    if (fields.isNotEmpty)
      'fields': fields.map((f) => f.toJson()).toList(growable: false),
  };
}

final class EmbedAuthor {
  const EmbedAuthor({required this.name, this.url, this.iconUrl});

  factory EmbedAuthor.fromJson(Map<String, dynamic> json) => EmbedAuthor(
    name: json['name'] as String,
    url: json['url'] as String?,
    iconUrl: json['icon_url'] as String?,
  );

  final String name;
  final String? url;
  final String? iconUrl;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (url != null) 'url': url,
    if (iconUrl != null) 'icon_url': iconUrl,
  };
}

final class EmbedFooter {
  const EmbedFooter({required this.text, this.iconUrl});

  factory EmbedFooter.fromJson(Map<String, dynamic> json) => EmbedFooter(
    text: json['text'] as String,
    iconUrl: json['icon_url'] as String?,
  );

  final String text;
  final String? iconUrl;

  Map<String, dynamic> toJson() => {
    'text': text,
    if (iconUrl != null) 'icon_url': iconUrl,
  };
}

/// An image/thumbnail attached to an [Embed]. `proxyUrl`/`contentType`/
/// `width`/`height` are only ever populated on a decoded (incoming) embed
/// — sending one only needs [url] and optionally [description] as alt
/// text, which is all [toJson] emits.
final class EmbedMedia {
  const EmbedMedia({
    required this.url,
    this.description,
    this.proxyUrl,
    this.contentType,
    this.width,
    this.height,
  });

  factory EmbedMedia.fromJson(Map<String, dynamic> json) => EmbedMedia(
    url: json['url'] as String,
    description: json['description'] as String?,
    proxyUrl: json['proxy_url'] as String?,
    contentType: json['content_type'] as String?,
    width: json['width'] as int?,
    height: json['height'] as int?,
  );

  final String url;
  final String? description;
  final String? proxyUrl;
  final String? contentType;
  final int? width;
  final int? height;

  Map<String, dynamic> toJson() => {
    'url': url,
    if (description != null) 'description': description,
  };
}

final class EmbedField {
  const EmbedField({
    required this.name,
    required this.value,
    this.inline = false,
  });

  factory EmbedField.fromJson(Map<String, dynamic> json) => EmbedField(
    name: json['name'] as String,
    value: json['value'] as String,
    inline: json['inline'] as bool? ?? false,
  );

  final String name;
  final String value;
  final bool inline;

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'inline': inline,
  };
}

extension _Let<T> on T? {
  R? let<R>(R Function(T) f) {
    final self = this;
    return self == null ? null : f(self);
  }
}
