import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/video.dart';
import '../widgets/tv/focusable_card.dart';
import '../widgets/tv/tv_keyboard_handler.dart';
import '../widgets/hls_video_player.dart';

/// Full-screen video detail screen for TV platforms.
/// Shows video metadata and a prominent Play button.
class TvVideoDetailScreen extends StatefulWidget {
  final Video video;

  const TvVideoDetailScreen({
    super.key,
    required this.video,
  });

  @override
  State<TvVideoDetailScreen> createState() => _TvVideoDetailScreenState();
}

class _TvVideoDetailScreenState extends State<TvVideoDetailScreen> {
  final FocusNode _playButtonFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the play button
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playButtonFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _playButtonFocus.dispose();
    super.dispose();
  }

  void _playVideo() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HlsVideoPlayer(
          streamUrl: widget.video.url,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TvKeyboardHandler(
      onBack: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            _buildBackground(),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // Left-to-right gradient for content area
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.9),
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 0.7],
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left side: metadata and controls
                    Expanded(
                      flex: 3,
                      child: _buildMetadata(),
                    ),

                    // Right side: poster (optional on TV, background serves purpose)
                    const Expanded(
                      flex: 2,
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),
            ),

            // Back button
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  iconSize: 32,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    if (widget.video.thumbnail != null) {
      return CachedNetworkImage(
        imageUrl: widget.video.thumbnail!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey[900]),
        errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
      );
    }
    return Container(color: Colors.grey[900]);
  }

  Widget _buildMetadata() {
    return TvFocusTraversalGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Text(
            widget.video.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          // Metadata row: year, duration, rating
          _buildMetadataRow(),

          const SizedBox(height: 24),

          // Overview
          if (widget.video.overview != null) ...[
            Text(
              widget.video.overview!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 32),
          ],

          // Genre chips
          if (widget.video.genre != null) ...[
            _buildGenreChips(),
            const SizedBox(height: 32),
          ],

          // Play button
          _buildPlayButton(),
        ],
      ),
    );
  }

  Widget _buildMetadataRow() {
    final items = <Widget>[];

    if (widget.video.year != null) {
      items.add(_buildMetadataItem(widget.video.year!));
    }

    if (widget.video.duration != null) {
      items.add(_buildMetadataItem(widget.video.formattedDuration));
    }

    if (widget.video.rating != null) {
      items.add(_buildRatingBadge(widget.video.rating!));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items,
    );
  }

  Widget _buildMetadataItem(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getRatingColor(rating),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 18),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChips() {
    final genres = widget.video.genre!.split(',').map((g) => g.trim()).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            genre,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayButton() {
    return FocusableCard(
      focusNode: _playButtonFocus,
      autofocus: true,
      onSelect: _playVideo,
      focusScale: 1.05,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(width: 8),
            Text(
              'Play',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
