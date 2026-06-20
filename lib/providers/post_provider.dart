import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../services/supabase_service.dart';

final supabaseServiceProvider = Provider((ref) => SupabaseService());

class PostListState {
  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  PostListState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  PostListState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return PostListState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}

class PostListNotifier extends Notifier<PostListState> {
  late final SupabaseService _service;
  int _offset = 0;
  static const int _limit = 10;
  bool _hasMore = true;

  // For debouncing likes
  final Map<String, Timer> _likeDebouncers = {};

  @override
  PostListState build() {
    _service = ref.watch(supabaseServiceProvider);
    return PostListState();
  }

  Future<void> init() async {
    if (state.posts.isNotEmpty) return;
    await fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      _offset = 0;
      final posts = await _service.fetchPosts(offset: _offset, limit: _limit);
      _hasMore = posts.length == _limit;
      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || state.isLoadingMore || !_hasMore) return;
    
    state = state.copyWith(isLoadingMore: true);
    try {
      _offset += _limit;
      final newPosts = await _service.fetchPosts(offset: _offset, limit: _limit);
      _hasMore = newPosts.length == _limit;
      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> toggleLike(String postId) async {
    final postIndex = state.posts.indexWhere((p) => p.id == postId);
    if (postIndex == -1) return;

    final oldPost = state.posts[postIndex];
    final isLiked = !oldPost.isLiked;
    final newCount = isLiked ? oldPost.likeCount + 1 : oldPost.likeCount - 1;

    // 1. Optimistic Update
    final updatedPosts = List<Post>.from(state.posts);
    updatedPosts[postIndex] = oldPost.copyWith(
      isLiked: isLiked,
      likeCount: newCount,
    );
    state = state.copyWith(posts: updatedPosts);

    // 2. Debounced API Call
    _likeDebouncers[postId]?.cancel();
    _likeDebouncers[postId] = Timer(const Duration(milliseconds: 500), () async {
      try {
        await _service.toggleLike(postId);
      } catch (e) {
        // 3. Revert on Error
        final revertPosts = List<Post>.from(state.posts);
        final currentPostIndex = revertPosts.indexWhere((p) => p.id == postId);
        if (currentPostIndex != -1) {
          revertPosts[currentPostIndex] = oldPost; // Revert to previous state
          state = state.copyWith(posts: revertPosts, error: 'Failed to update like. Offline?');
        }
      } finally {
        _likeDebouncers.remove(postId);
      }
    });
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final postListProvider = NotifierProvider<PostListNotifier, PostListState>(PostListNotifier.new);
