import 'package:flutter/foundation.dart';

@immutable
class Post {
  final String id;
  final DateTime createdAt;
  final String thumbUrl;
  final String mobileUrl;
  final String rawUrl;
  final int likeCount;
  final bool isLiked; // Local state for optimistic UI

  const Post({
    required this.id,
    required this.createdAt,
    required this.thumbUrl,
    required this.mobileUrl,
    required this.rawUrl,
    required this.likeCount,
    this.isLiked = false,
  });

  Post copyWith({
    String? id,
    DateTime? createdAt,
    String? thumbUrl,
    String? mobileUrl,
    String? rawUrl,
    int? likeCount,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      mobileUrl: mobileUrl ?? this.mobileUrl,
      rawUrl: rawUrl ?? this.rawUrl,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json, {bool currentIsLiked = false}) {
    return Post(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      thumbUrl: json['media_thumb_url'] as String,
      mobileUrl: json['media_mobile_url'] as String,
      rawUrl: json['media_raw_url'] as String,
      likeCount: json['like_count'] as int,
      isLiked: currentIsLiked,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          likeCount == other.likeCount &&
          isLiked == other.isLiked;

  @override
  int get hashCode => id.hashCode ^ likeCount.hashCode ^ isLiked.hashCode;
}
