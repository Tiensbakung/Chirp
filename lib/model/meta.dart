class MetaModel {
  final String newestId;
  final String oldestId;
  final String? nextToken;
  final int resultCount;
  MetaModel({
    required this.newestId,
    required this.oldestId,
    required this.resultCount,
    this.nextToken,
  });
  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      newestId: json['newest_id'],
      oldestId: json['oldest_id'],
      nextToken: json['next_token'],
      resultCount: json['result_count'],
    );
  }
}
