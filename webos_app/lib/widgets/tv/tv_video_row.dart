import 'package:flutter/material.dart';
import '../../models/video.dart';
import 'tv_video_card.dart';
import 'tv_keyboard_handler.dart';

/// A horizontal scrolling row of video cards with a genre title.
/// Netflix-style layout for TV interfaces.
class TvVideoRow extends StatefulWidget {
  final String title;
  final List<Video> videos;
  final void Function(Video video) onVideoSelected;
  final bool autofocusFirstItem;

  const TvVideoRow({
    super.key,
    required this.title,
    required this.videos,
    required this.onVideoSelected,
    this.autofocusFirstItem = false,
  });

  @override
  State<TvVideoRow> createState() => _TvVideoRowState();
}

class _TvVideoRowState extends State<TvVideoRow> {
  final ScrollController _scrollController = ScrollController();
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _initFocusNodes();
  }

  @override
  void didUpdateWidget(TvVideoRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videos.length != widget.videos.length) {
      _initFocusNodes();
    }
  }

  void _initFocusNodes() {
    // Dispose old focus nodes
    for (final node in _focusNodes) {
      node.dispose();
    }
    _focusNodes.clear();

    // Create new focus nodes
    for (var i = 0; i < widget.videos.length; i++) {
      final node = FocusNode();
      node.addListener(() {
        if (node.hasFocus) {
          _scrollToIndex(i);
        }
      });
      _focusNodes.add(node);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _scrollToIndex(int index) {
    const cardWidth = TvVideoCard.cardWidth + 16; // Card width + padding
    final targetOffset = index * cardWidth - 100; // Offset to show some context

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row title
        Padding(
          padding: const EdgeInsets.only(left: 48, bottom: 16),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),

        // Horizontal scrolling video list
        SizedBox(
          height: TvVideoCard.cardHeight + 16,
          child: HorizontalTvFocusGroup(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 48),
              itemCount: widget.videos.length,
              itemBuilder: (context, index) {
                final video = widget.videos[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TvVideoCard(
                    video: video,
                    onSelect: () => widget.onVideoSelected(video),
                    autofocus: widget.autofocusFirstItem && index == 0,
                    focusNode:
                        index < _focusNodes.length ? _focusNodes[index] : null,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
