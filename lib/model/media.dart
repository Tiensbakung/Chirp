enum MediaType {
  video,
  animatedGif,
  photo;

  factory MediaType.parse(String value) {
    return MediaType.values.byName(value);
  }
}

class MediaModel {
  final String mediaKey;
  final MediaType type;
  final String url;
  final int durationMs;
  final int height;
  final int width;

  const MediaModel({
    required this.mediaKey,
    required this.type,
    required this.url,
    required this.durationMs,
    required this.height,
    required this.width,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      mediaKey: json['media_key'],
      type: MediaType.parse(json['type']),
      url: json['url'] ?? json['preview_image_url'],
      durationMs: json['duration_ms'] ?? 0,
      height: json['height'],
      width: json['width'],
    );
  }
}
