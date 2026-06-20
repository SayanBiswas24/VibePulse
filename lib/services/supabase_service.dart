import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post.dart';

class SupabaseService {
  static const String userId = 'user_123'; // Hardcoded as per requirements

  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Post>> fetchPosts({int offset = 0, int limit = 10}) async {
    final response = await _client
        .from('posts')
        .select('*')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final List<dynamic> data = response as List<dynamic>;
    print('Fetched ${data.length} posts from Supabase');

    // Fetch user's likes to determine isLiked status
    final likedPostIds = await _getLikedPostIds(data.map((p) => p['id'] as String).toList());

    return data.map((json) {
      final id = json['id'] as String;
      return Post.fromJson(json, currentIsLiked: likedPostIds.contains(id));
    }).toList();
  }

  Future<Set<String>> _getLikedPostIds(List<String> postIds) async {
    if (postIds.isEmpty) return {};

    final response = await _client
        .from('user_likes')
        .select('post_id')
        .eq('user_id', userId)
        .inFilter('post_id', postIds);

    final List<dynamic> data = response as List<dynamic>;
    return data.map((item) => item['post_id'] as String).toSet();
  }

  Future<void> toggleLike(String postId) async {
    await _client.rpc('toggle_like', params: {
      'p_post_id': postId,
      'p_user_id': userId,
    });
  }
}
