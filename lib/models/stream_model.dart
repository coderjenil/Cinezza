class StreamList {
  final String label;
  final String format;
  final String url;
  final String originalUrl;
  final String quality;
  final int? width;
  final int? height;

  StreamList({
    required this.label,
    required this.format,
    required this.url,
    required this.originalUrl,
    this.quality = 'Unknown',
    this.width,
    this.height,
  });

  String get qualityDisplay {
    if (width != null && height != null) {
      return '${width}x$height';
    }
    return quality;
  }
}
