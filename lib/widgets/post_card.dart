import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import '../screens/detail_screen.dart';

// ─── Author names and usernames to cycle through for variety ─────────────────
const _authors = [
  {'name': 'Alex_Vibe', 'time': 'Just now'},
  {'name': 'Nova_Creator', 'time': '2h ago'},
  {'name': 'Pulse_K', 'time': '5h ago'},
  {'name': 'Zoe_Arch', 'time': '1d ago'},
];

const _captions = [
  'Catching those midnight frequencies 🌆 #vibepulse #nightglow',
  'Exploring the intersection of light and code 🔬✨ #generativeart #digitalvibes',
  'Where architecture meets the cosmos 🌌 #futurist #design',
  'In the electric city, every pixel tells a story ⚡ #neonlife #aesthetic',
];

class PostCard extends ConsumerStatefulWidget {
  final Post post;
  final int index;

  const PostCard({super.key, required this.post, this.index = 0});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.1), weight: 50),
    ]).animate(CurvedAnimation(parent: _heartController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    ref.read(postListProvider.notifier).toggleLike(widget.post.id);
    if (!widget.post.isLiked) {
      _heartController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authorData = _authors[widget.index % _authors.length];
    final caption = _captions[widget.index % _captions.length];
    final authorName = authorData['name']!;
    final timeAgo = authorData['time']!;
    final isLiked = widget.post.isLiked;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF131315),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 32,
              offset: const Offset(0, 16),
              spreadRadius: -8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // ── Author Header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  _GradientAvatar(index: widget.index),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: const Color(0xFFE5E1E4),
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF9B8C9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert,
                        color: Color(0xFF9B8C9E), size: 20),
                  ),
                ],
              ),
            ),

            // ── Post Image ────────────────────────────────────────────────
            GestureDetector(
              onDoubleTap: _toggleLike,
              onTap: () => Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => DetailScreen(post: widget.post),
                  transitionsBuilder: (_, anim, __, child) =>
                      FadeTransition(opacity: anim, child: child),
                ),
              ),
              child: RepaintBoundary(
                child: Hero(
                  tag: 'image_${widget.post.id}',
                  child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width * 1.05,
                    child: CachedNetworkImage(
                      imageUrl: widget.post.thumbUrl,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      // RAM Protection: decoded size matches display size
                      memCacheWidth: (MediaQuery.of(context).size.width *
                              MediaQuery.of(context).devicePixelRatio)
                          .round(),
                      placeholder: (context, url) => Container(
                        color: const Color(0xFF131315),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFE9B3FF),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFF131315),
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined,
                              color: Color(0xFF4F4352), size: 48),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Action Row ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Row(
                children: [
                  // Like
                  AnimatedBuilder(
                    animation: _heartScale,
                    builder: (context, child) => Transform.scale(
                      scale: _heartScale.value,
                      child: GestureDetector(
                        onTap: _toggleLike,
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? const Color(0xFFFFB2B7) : const Color(0xFFE5E1E4),
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  if (isLiked)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '${widget.post.likeCount > 999 ? (widget.post.likeCount / 1000).toStringAsFixed(1) + 'k' : widget.post.likeCount}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFFFFB2B7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 16),
                  // Comment
                  const Icon(Icons.chat_bubble_outline,
                      color: Color(0xFFE5E1E4), size: 24),
                  if (isLiked)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '86',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFFD2C1D4),
                        ),
                      ),
                    ),
                  const SizedBox(width: 16),
                  // Share
                  const Icon(Icons.send_outlined,
                      color: Color(0xFFE5E1E4), size: 24),
                  const Spacer(),
                  // Bookmark
                  const Icon(Icons.bookmark_border,
                      color: Color(0xFFE5E1E4), size: 26),
                ],
              ),
            ),

            // ── Caption ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$authorName ',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: const Color(0xFFE5E1E4),
                      ),
                    ),
                    TextSpan(
                      text: caption,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFFD2C1D4),
                      ),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ── Divider ───────────────────────────────────────────────────
            Divider(
              height: 0.5,
              color: Colors.white.withOpacity(0.05),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

// ─── Gradient Avatar ─────────────────────────────────────────────────────────
class _GradientAvatar extends StatelessWidget {
  final int index;
  const _GradientAvatar({required this.index});

  @override
  Widget build(BuildContext context) {
    final gradients = [
      [const Color(0xFFC863FB), const Color(0xFFFFB2B7)],
      [const Color(0xFF8382FF), const Color(0xFFE9B3FF)],
      [const Color(0xFFFF6B6B), const Color(0xFFC863FB)],
      [const Color(0xFFE9B3FF), const Color(0xFF8382FF)],
    ];
    final g = gradients[index % gradients.length];

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: g, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF1C1B1D),
          ),
          child: Icon(Icons.person, color: g[0], size: 20),
        ),
      ),
    );
  }
}
