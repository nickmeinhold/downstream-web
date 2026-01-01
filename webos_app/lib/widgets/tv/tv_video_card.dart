import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/video.dart';
import 'focusable_card.dart';

/// A large TV-optimized video poster card.
/// Displays the poster image with title and metadata overlay when focused.
class TvVideoCard extends StatelessWidget {
  final Video video;
  final VoidCallback onSelect;
  final bool autofocus;
  final FocusNode? focusNode;

  /// Card dimensions optimized for 10-foot viewing
  static const double cardWidth = 200.0;
  static const double cardHeight = 300.0;

  const TvVideoCard({
    super.key,
    required this.video,
    required this.onSelect,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableCard(
      onSelect: onSelect,
      autofocus: autofocus,
      focusNode: focusNode,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: _buildCardContent(context),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Poster image
        _buildPoster(),

        // Gradient overlay for text readability
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black87,
                ],
              ),
            ),
          ),
        ),

        // Title and metadata
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                video.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (video.subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  video.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        // Rating badge
        if (video.rating != null)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRatingColor(video.rating!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                video.rating!.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPoster() {
    if (video.thumbnail != null) {
      return CachedNetworkImage(
        imageUrl: video.thumbnail!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[850],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                video.title,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 8.0) return Colors.green[700]!;
    if (rating >= 6.0) return Colors.amber[700]!;
    if (rating >= 4.0) return Colors.orange[700]!;
    return Colors.red[700]!;
  }
}
