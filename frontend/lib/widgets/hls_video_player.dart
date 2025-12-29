import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// JS interop for hls.js
@JS('Hls')
extension type Hls._(JSObject _) implements JSObject {
  external Hls();
  external void loadSource(String src);
  external void attachMedia(web.HTMLVideoElement video);
  external void destroy();
  external void on(String event, JSFunction callback);
  external static bool isSupported();
}

/// HLS Video Player widget for Flutter web
class HlsVideoPlayer extends StatefulWidget {
  final String streamUrl;
  final VoidCallback? onClose;

  const HlsVideoPlayer({
    super.key,
    required this.streamUrl,
    this.onClose,
  });

  @override
  State<HlsVideoPlayer> createState() => _HlsVideoPlayerState();
}

class _HlsVideoPlayerState extends State<HlsVideoPlayer> {
  web.HTMLVideoElement? _videoElement;
  Hls? _hls;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _error;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
  }

  void _onElementCreated(Object element) {
    final video = element as web.HTMLVideoElement;
    video.style.width = '100%';
    video.style.height = '100%';
    video.style.backgroundColor = 'black';
    video.controls = false;
    video.autoplay = true;

    _videoElement = video;
    _setupVideoEvents(video);

    if (Hls.isSupported()) {
      _initHls(video);
    } else if (video.canPlayType('application/vnd.apple.mpegurl').isNotEmpty) {
      // Native HLS support (Safari)
      video.src = widget.streamUrl;
    } else {
      setState(() {
        _error = 'HLS is not supported in this browser';
        _isLoading = false;
      });
    }
  }

  void _initHls(web.HTMLVideoElement video) {
    _hls = Hls();

    _hls!.on(
      'hlsManifestParsed',
      ((JSAny event, JSAny data) {
        video.play();
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isPlaying = true;
          });
        }
      }).toJS,
    );

    // Note: hls.js fires hlsError for non-fatal issues too (network retries, etc.)
    // Fatal errors will be caught by the video element's error event

    _hls!.loadSource(widget.streamUrl);
    _hls!.attachMedia(video);
  }

  void _setupVideoEvents(web.HTMLVideoElement video) {
    video.addEventListener(
      'play',
      ((web.Event event) {
        if (mounted) setState(() => _isPlaying = true);
      }).toJS,
    );

    video.addEventListener(
      'pause',
      ((web.Event event) {
        if (mounted) setState(() => _isPlaying = false);
      }).toJS,
    );

    video.addEventListener(
      'timeupdate',
      ((web.Event event) {
        if (mounted) {
          setState(() {
            _position = Duration(seconds: video.currentTime.toInt());
            if (!video.duration.isNaN) {
              _duration = Duration(seconds: video.duration.toInt());
            }
          });
        }
      }).toJS,
    );

    video.addEventListener(
      'canplay',
      ((web.Event event) {
        if (mounted) setState(() => _isLoading = false);
      }).toJS,
    );

    video.addEventListener(
      'waiting',
      ((web.Event event) {
        if (mounted) setState(() => _isLoading = true);
      }).toJS,
    );

    video.addEventListener(
      'error',
      ((web.Event event) {
        if (mounted) {
          setState(() {
            _error = 'Failed to load video';
            _isLoading = false;
          });
        }
      }).toJS,
    );
  }

  @override
  void dispose() {
    _hls?.destroy();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _videoElement?.pause();
    } else {
      _videoElement?.play();
    }
  }

  void _seek(Duration position) {
    _videoElement?.currentTime = position.inSeconds.toDouble();
  }

  void _seekRelative(int seconds) {
    if (_videoElement == null) return;
    final newTime = _videoElement!.currentTime + seconds;
    _videoElement!.currentTime = newTime.clamp(0, _videoElement!.duration);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video container
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: HtmlElementView.fromTagName(
                tagName: 'video',
                onElementCreated: _onElementCreated,
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Error message
          if (_error != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

          // Controls overlay (tap to toggle play/pause)
          Positioned.fill(
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: Container(color: Colors.transparent),
            ),
          ),

          // Top bar with close button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress bar
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: _duration.inSeconds > 0
                          ? (_position.inSeconds / _duration.inSeconds).clamp(0.0, 1.0)
                          : 0.0,
                      onChanged: (value) {
                        final newPosition = Duration(
                          seconds: (value * _duration.inSeconds).round(),
                        );
                        _seek(newPosition);
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white38,
                    ),
                  ),

                  // Time display and controls
                  Row(
                    children: [
                      // Rewind
                      IconButton(
                        icon: const Icon(Icons.replay_10, color: Colors.white),
                        onPressed: () => _seekRelative(-10),
                      ),

                      // Play/Pause
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: _togglePlayPause,
                      ),

                      // Fast forward
                      IconButton(
                        icon: const Icon(Icons.forward_10, color: Colors.white),
                        onPressed: () => _seekRelative(10),
                      ),

                      const SizedBox(width: 8),

                      // Time
                      Text(
                        '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                        style: const TextStyle(color: Colors.white),
                      ),

                      const Spacer(),

                      // Fullscreen toggle
                      IconButton(
                        icon: const Icon(Icons.fullscreen, color: Colors.white),
                        onPressed: () {
                          _videoElement?.requestFullscreen();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
