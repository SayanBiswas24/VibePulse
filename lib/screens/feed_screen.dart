import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentNavIndex = 0;


  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(postListProvider.notifier).init());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showOfflineError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF93000A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postListProvider);
    final contextRef = context;

    ref.listen<PostListState>(postListProvider, (previous, next) {
      if (next.error != null && (previous == null || previous.error != next.error)) {
        _showOfflineError(next.error!);
        ref.read(postListProvider.notifier).clearError();
      }

      // Pre-cache upcoming images when a new page is loaded
      if (previous != null && next.posts.length > previous.posts.length) {
        final startIndex = previous.posts.length;
        final endIndex = (startIndex + 5).clamp(0, next.posts.length);
        
        for (int i = startIndex; i < endIndex; i++) {
          final imageUrl = next.posts[i].thumbUrl;
          precacheImage(
            ResizeImage(
              CachedNetworkImageProvider(imageUrl),
              width: (MediaQuery.of(contextRef).size.width * 
                      MediaQuery.of(contextRef).devicePixelRatio).round(),
            ),
            contextRef,
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      // ─── AppBar ─────────────────────────────────────────────────────────
      appBar: _buildAppBar(),
      // ─── Body ───────────────────────────────────────────────────────────
      body: RefreshIndicator(
        color: const Color(0xFFE9B3FF),
        backgroundColor: const Color(0xFF201F21),
        onRefresh: () => ref.read(postListProvider.notifier).fetchFirstPage(),
        child: state.isLoading
            ? _buildLoader()
            : state.posts.isEmpty
                ? _buildEmptyState()
                : NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification) {
                        if (notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent - 1000) {
                          ref.read(postListProvider.notifier).fetchNextPage();
                        }
                      }
                      return false;
                    },
                    child: CustomScrollView(
                      controller: _scrollController,
                      cacheExtent: 1000,
                      slivers: [
                        // Feed posts
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index < state.posts.length) {
                                return PostCard(post: state.posts[index], index: index);
                              }
                              return const Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFE9B3FF),
                                  ),
                                ),
                              );
                            },
                            childCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      // ─── Bottom Navigation ───────────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0A0A0C),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFC863FB), Color(0xFFFFB2B7)],
            ),
            border: Border.all(color: const Color(0xFFE9B3FF), width: 1.5),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ),
      title: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFFE9B3FF), Color(0xFFFFB2B7)],
        ).createShader(bounds),
        child: Text(
          'VibePulse',
          style: GoogleFonts.montserrat(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFFE9B3FF), size: 26),
          onPressed: () {},
        ),
      ],
    );
  }


  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFFE9B3FF)),
          const SizedBox(height: 16),
          Text(
            'Loading feed...',
            style: GoogleFonts.inter(color: const Color(0xFFD2C1D4)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: Color(0xFF4F4352)),
          const SizedBox(height: 16),
          Text(
            'No posts yet.\nRun the seeding script to add content.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: const Color(0xFF9B8C9E), fontSize: 15),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFC863FB), Color(0xFFFFB2B7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => ref.read(postListProvider.notifier).fetchFirstPage(),
              child: Text(
                'Retry',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    const activeColor = Color(0xFFE9B3FF);
    const inactiveColor = Color(0xFF9B8C9E);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, active: _currentNavIndex == 0, activeColor: activeColor, inactiveColor: inactiveColor, onTap: () => setState(() => _currentNavIndex = 0)),
              _NavItem(icon: Icons.search_rounded, active: _currentNavIndex == 1, activeColor: activeColor, inactiveColor: inactiveColor, onTap: () => setState(() => _currentNavIndex = 1)),
              const SizedBox(width: 56), // Space for FAB
              _NavItem(icon: Icons.favorite_border_rounded, active: _currentNavIndex == 3, activeColor: activeColor, inactiveColor: inactiveColor, onTap: () => setState(() => _currentNavIndex = 3)),
              _NavItem(icon: Icons.person_outline_rounded, active: _currentNavIndex == 4, activeColor: activeColor, inactiveColor: inactiveColor, onTap: () => setState(() => _currentNavIndex = 4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      width: 52,
      height: 52,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFC863FB), Color(0xFFFFB2B7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC863FB).withOpacity(0.4),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {},
      ),
    );
  }
}


// ─── Bottom Nav Item ───────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: active ? activeColor : inactiveColor,
          size: 26,
        ),
      ),
    );
  }
}
