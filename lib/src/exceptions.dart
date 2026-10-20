/// Base of every exception thrown by the fluxer_dart ecosystem.
///
/// Sealed so callers can exhaustively `switch` over the concrete subtypes
/// instead of guessing at string-typed error codes.
sealed class FluxerException implements Exception {
  const FluxerException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// A REST API call failed. Thrown by `fluxer_dart_rest`.
final class FluxerApiException extends FluxerException {
  const FluxerApiException(
    super.message, {
    required this.statusCode,
    this.errorCode,
    this.retryAfter,
    this.fieldErrors = const [],
  });

  /// The HTTP status code returned by the API.
  final int statusCode;

  /// Fluxer's own machine-readable error code from the response body, if
  /// present (e.g. `"RATE_LIMITED"`).
  final String? errorCode;

  /// How long to wait before retrying, if the API included a
  /// `Retry-After` value (present on `429` responses).
  final Duration? retryAfter;

  /// The fields a `400 INVALID_FORM_BODY` rejected, each with its own
  /// reason; empty for any other error.
  final List<FluxerFieldError> fieldErrors;

  @override
  String toString() =>
      'FluxerApiException($statusCode${errorCode != null ? ', $errorCode' : ''}): $message'
      '${fieldErrors.isEmpty ? '' : ' ${fieldErrors.join('; ')}'}';
}

/// One rejected field of a request body.
final class FluxerFieldError {
  const FluxerFieldError({
    required this.path,
    required this.message,
    this.code,
  });

  /// Decodes the `errors` array of an error response, skipping entries
  /// that are not objects.
  static List<FluxerFieldError> listFromJson(Object? errors) => [
    if (errors is List)
      for (final e in errors)
        if (e is Map<String, dynamic>)
          FluxerFieldError(
            path: e['path'] as String? ?? '',
            message: e['message'] as String? ?? '',
            code: e['code'] as String?,
          ),
  ];

  /// Dotted path to the field, with array indexes: `emojis.1.name`.
  final String path;
  final String message;

  /// Machine-readable reason, e.g. `STRING_LENGTH_INVALID`.
  final String? code;

  @override
  String toString() => '$path: $message';
}

/// The gateway connection failed or was closed with an error. Thrown by
/// `fluxer_dart_gateway`.
final class FluxerGatewayException extends FluxerException {
  const FluxerGatewayException(super.message, {this.closeCode});

  /// The gateway close code, if the connection was closed by the server
  /// (see Fluxer's `GatewayCloseCodes`, 4000–4012).
  final int? closeCode;

  @override
  String toString() =>
      'FluxerGatewayException${closeCode != null ? '($closeCode)' : ''}: $message';
}

/// The gateway refused a command for exceeding its budget, reported by a
/// `RATE_LIMITED` dispatch. Thrown by `fluxer_dart`.
///
/// Only Request Guild Members (opcode 8) is ever refused this way: a bot
/// may request a guild's full member list once per 30 seconds. Every
/// other command refusal is silent.
final class FluxerGatewayRateLimitException extends FluxerException {
  const FluxerGatewayRateLimitException(
    super.message, {
    required this.opcode,
    required this.retryAfter,
  });

  /// The refused command's opcode.
  final int opcode;

  final Duration retryAfter;

  @override
  String toString() =>
      'FluxerGatewayRateLimitException(op $opcode, retry after $retryAfter): $message';
}
