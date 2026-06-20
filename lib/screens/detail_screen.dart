import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final Post post;

  const DetailScreen({super.key, required this.post});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool _showRaw = false;

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postListProvider).posts;
    // Find the live version of this post in the global state
    final post = posts.firstWhere((p) => p.id == widget.post.id, orElse: () => widget.post);
    final isLiked = post.isLiked;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.width,
                pinned: true,
                backgroundColor: const Color(0xFF0A0A0C),
                leading: const SizedBox.shrink(),
                flexibleSpace: FlexibleSpaceBar(
                  background: RepaintBoundary(
                    child: Hero(
                      tag: 'image_${post.id}',
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: post.thumbUrl,
                            fit: BoxFit.cover,
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            memCacheWidth: (MediaQuery.of(context).size.width *
                                    MediaQuery.of(context).devicePixelRatio)
                                .round(),
                          ),
                          CachedNetworkImage(
                            imageUrl: post.mobileUrl,
                            fit: BoxFit.cover,
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            memCacheWidth: (MediaQuery.of(context).size.width *
                                    MediaQuery.of(context).devicePixelRatio)
                                .round(),
                          ),
                          if (_showRaw)
                            CachedNetworkImage(
                              imageUrl: post.rawUrl,
                              fit: BoxFit.cover,
                              fadeInDuration: Duration.zero,
                              fadeOutDuration: Duration.zero,
                              memCacheWidth: (MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).devicePixelRatio)
                                  .round(),
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFFE9B3FF)),
                              ),
                            ),
                          // Bottom Fade
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Auth Metadata
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: Color(0xFFE9B3FF),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Alex Rivera',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '2 hours ago',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFFD2C1D4),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => ref.read(postListProvider.notifier).toggleLike(post.id),
                            child: Column(
                              children: [
                                Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? const Color(0xFFFFB2B7) : const Color(0xFFD2C1D4),
                                  size: 30,
                                ),
                                Text(
                                  post.likeCount > 999 ? '${(post.likeCount / 1000).toStringAsFixed(1)}k' : post.likeCount.toString(),
                                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFD2C1D4)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Description Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131315).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cyberpunk Echoes',
                              style: GoogleFonts.montserrat(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE9B3FF),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Exploring the intersection of neon-lit nights and digital distortion. This captures the true "Pulse" of the vibe we\'re building here.',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: const Color(0xFFD2C1D4),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              children: ['#aesthetic', '#neonpulse', '#future'].map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE9B3FF).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tag,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFFE9B3FF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // CTA Buttons
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC863FB), Color(0xFFFFB2B7)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC863FB).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
  if (!_showRaw) {
    setState(() => _showRaw = true);
  }
},
                          borderRadius: BorderRadius.circular(16),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Download High-Res',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _SmallButton(icon: Icons.share, label: 'Share'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SmallButton(icon: Icons.bookmark_border, label: 'Save'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // More from Creator
                      Text(
                        'MORE FROM ALEX',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: const Color(0xFFD2C1D4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: List.generate(2, (index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF131315),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: widget.post.thumbUrl,
                                fit: BoxFit.cover,
                                fadeInDuration: Duration.zero,
                                fadeOutDuration: Duration.zero,
                                memCacheWidth: (MediaQuery.of(context).size.width /
                                        2 *
                                        MediaQuery.of(context).devicePixelRatio)
                                    .round(),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Top Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFFE9B3FF), size: 24),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Text(
              'Post Details',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE9B3FF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SmallButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
