/// Base of every exception thrown by the fluxer.dart ecosystem.
///
/// Sealed so callers can exhaustively `switch` over the concrete subtypes
/// instead of guessing at string-typed error codes.
sealed class FluxerException implements Exception {
  const FluxerException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// A REST API call failed. Thrown by `fluxer_rest`.
final class FluxerApiException extends FluxerException {
  const FluxerApiException(
    super.message, {
    required this.statusCode,
    this.errorCode,
    this.retryAfter,
  });

  /// The HTTP status code returned by the API.
  final int statusCode;

  /// Fluxer's own machine-readable error code from the response body, if
  /// present (e.g. `"RATE_LIMITED"`).
  final String? errorCode;

  /// How long to wait before retrying, if the API included a
  /// `Retry-After` value (present on `429` responses).
  final Duration? retryAfter;

  @override
  String toString() =>
      'FluxerApiException($statusCode${errorCode != null ? ', $errorCode' : ''}): $message';
}

/// The gateway connection failed or was closed with an error. Thrown by
/// `fluxer_gateway`.
final class FluxerGatewayException extends FluxerException {
  const FluxerGatewayException(super.message, {this.closeCode});

  /// The gateway close code, if the connection was closed by the server
  /// (see Fluxer's `GatewayCloseCodes`, 4000–4012).
  final int? closeCode;

  @override
  String toString() =>
      'FluxerGatewayException${closeCode != null ? '($closeCode)' : ''}: $message';
}
