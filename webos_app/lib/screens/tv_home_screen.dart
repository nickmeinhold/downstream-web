import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants.dart';
import '../models/video.dart';
import '../services/video_service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/tv/tv_video_row.dart';
import '../widgets/tv/tv_keyboard_handler.dart';
import '../widgets/tv/focusable_card.dart';
import '../widgets/hls_video_player.dart';
import 'tv_video_detail_screen.dart';

/// Netflix-style home screen for TV platforms with full functionality.
class TvHomeScreen extends StatefulWidget {
  const TvHomeScreen({super.key});

  @override
  State<TvHomeScreen> createState() => _TvHomeScreenState();
}

class _TvHomeScreenState extends State<TvHomeScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideoService>().loadVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return TvKeyboardHandler(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            _buildNavBar(),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return const _LibraryTab();
      case 1:
        return const _NewReleasesTab();
      case 2:
        return const _TrendingTab();
      case 3:
        return const _SearchTab();
      case 4:
        return const _QueueTab();
      default:
        return const _LibraryTab();
    }
  }

  Widget _buildNavBar() {
    final auth = context.watch<AuthService>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Text(
            'Downstream',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 48),
          _TabButton(
            label: 'Library',
            icon: Icons.video_library,
            isSelected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
            autofocus: true,
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: 'New',
            icon: Icons.new_releases,
            isSelected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: 'Trending',
            icon: Icons.trending_up,
            isSelected: _selectedTab == 2,
            onTap: () => setState(() => _selectedTab = 2),
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: 'Search',
            icon: Icons.search,
            isSelected: _selectedTab == 3,
            onTap: () => setState(() => _selectedTab = 3),
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: 'Queue',
            icon: Icons.download,
            isSelected: _selectedTab == 4,
            onTap: () => setState(() => _selectedTab = 4),
          ),
          const Spacer(),
          if (auth.photoUrl != null)
            CircleAvatar(
              backgroundImage: NetworkImage(auth.photoUrl!),
              radius: 18,
            )
          else
            CircleAvatar(
              radius: 18,
              child: Text(auth.username.isNotEmpty ? auth.username[0].toUpperCase() : '?'),
            ),
          const SizedBox(width: 12),
          Text(auth.username, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool autofocus;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableCard(
      onSelect: onTap,
      autofocus: autofocus,
      focusScale: 1.0,
      focusBorderWidth: 2,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// LIBRARY TAB - Your B2 videos
// ============================================================================

class _LibraryTab extends StatelessWidget {
  const _LibraryTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoService>(
      builder: (context, videoService, child) {
        if (videoService.isLoading && videoService.videos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (videoService.error != null && videoService.videos.isEmpty) {
          return _buildErrorState(context, videoService);
        }

        if (videoService.videos.isEmpty) {
          return _buildEmptyState(context);
        }

        return _buildVideoRows(context, videoService);
      },
    );
  }

  Widget _buildErrorState(BuildContext context, VideoService videoService) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Failed to load videos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(videoService.error ?? 'Unknown error', style: TextStyle(color: Colors.grey[400])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => videoService.refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_outlined, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'No videos available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text('Check back later for new content', style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildVideoRows(BuildContext context, VideoService videoService) {
    final videosByGenre = videoService.videosByGenre;
    final genres = videosByGenre.keys.toList();
    genres.sort((a, b) {
      if (a == 'Other') return 1;
      if (b == 'Other') return -1;
      return a.compareTo(b);
    });

    final hasMultipleGenres = genres.length > 1;

    return TvFocusTraversalGroup(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 24),
        itemCount: hasMultipleGenres ? genres.length + 1 : genres.length,
        itemBuilder: (context, index) {
          if (hasMultipleGenres && index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: TvVideoRow(
                title: 'Top Rated',
                videos: videoService.videosSortedByRating.take(20).toList(),
                onVideoSelected: (video) => _openVideo(context, video),
                autofocusFirstItem: true,
              ),
            );
          }

          final genreIndex = hasMultipleGenres ? index - 1 : index;
          final genre = genres[genreIndex];
          final videos = videosByGenre[genre] ?? [];

          return Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: TvVideoRow(
              title: genre,
              videos: videos,
              onVideoSelected: (video) => _openVideo(context, video),
              autofocusFirstItem: !hasMultipleGenres && index == 0,
            ),
          );
        },
      ),
    );
  }

  void _openVideo(BuildContext context, Video video) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TvVideoDetailScreen(video: video)),
    );
  }
}

// ============================================================================
// NEW RELEASES TAB - TMDB new releases with filters
// ============================================================================

class _NewReleasesTab extends StatefulWidget {
  const _NewReleasesTab();

  @override
  State<_NewReleasesTab> createState() => _NewReleasesTabState();
}

class _NewReleasesTabState extends State<_NewReleasesTab> {
  String _contentType = 'all';
  int _days = 30;
  double _minRating = 6.0;
  int _minVotes = 50;
  int? _selectedGenre;
  List<dynamic> _items = [];
  bool _isLoading = false;
  String? _error;

  static const _genres = <int, String>{
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    27: 'Horror',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Sci-Fi',
    53: 'Thriller',
  };

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiService>();
      final items = await api.getNewReleases(
        type: _contentType == 'all' ? null : _contentType,
        days: _days,
        minRating: _minRating,
        minVotes: _minVotes,
        genre: _selectedGenre,
      );
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilters(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: _contentType == 'all' ? 'All' : _contentType == 'movie' ? 'Movies' : 'TV',
              onTap: () => _showContentTypePicker(),
            ),
            const SizedBox(width: 12),
            _FilterChip(
              label: 'Last $_days days',
              onTap: () => _showDaysPicker(),
            ),
            const SizedBox(width: 12),
            _FilterChip(
              label: _selectedGenre == null ? 'All Genres' : _genres[_selectedGenre] ?? 'Genre',
              onTap: () => _showGenrePicker(),
            ),
            const SizedBox(width: 12),
            _FilterChip(
              label: 'Rating ${_minRating.toStringAsFixed(1)}+',
              onTap: () => _showRatingPicker(),
            ),
            const SizedBox(width: 24),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadContent,
            ),
          ],
        ),
      ),
    );
  }

  void _showContentTypePicker() {
    _showPicker(
      title: 'Content Type',
      options: ['all', 'movie', 'tv'],
      labels: ['All', 'Movies', 'TV Shows'],
      selected: _contentType,
      onSelect: (value) {
        setState(() => _contentType = value);
        _loadContent();
      },
    );
  }

  void _showDaysPicker() {
    _showPicker(
      title: 'Time Period',
      options: [7, 14, 30, 90, 180, 365],
      labels: ['7 days', '14 days', '30 days', '90 days', '6 months', '1 year'],
      selected: _days,
      onSelect: (value) {
        setState(() => _days = value);
        _loadContent();
      },
    );
  }

  void _showGenrePicker() {
    final options = [null, ..._genres.keys];
    final labels = ['All Genres', ..._genres.values];
    _showPicker(
      title: 'Genre',
      options: options,
      labels: labels,
      selected: _selectedGenre,
      onSelect: (value) {
        setState(() => _selectedGenre = value);
        _loadContent();
      },
    );
  }

  void _showRatingPicker() {
    _showPicker(
      title: 'Minimum Rating',
      options: [0.0, 5.0, 6.0, 7.0, 8.0],
      labels: ['Any', '5.0+', '6.0+', '7.0+', '8.0+'],
      selected: _minRating,
      onSelect: (value) {
        setState(() => _minRating = value);
        _loadContent();
      },
    );
  }

  void _showPicker<T>({
    required String title,
    required List<T> options,
    required List<String> labels,
    required T selected,
    required void Function(T) onSelect,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(options.length, (i) {
            final isSelected = options[i] == selected;
            return ListTile(
              title: Text(labels[i]),
              selected: isSelected,
              leading: isSelected ? const Icon(Icons.check) : null,
              onTap: () {
                Navigator.pop(context);
                onSelect(options[i]);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadContent, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text('No new releases found', style: TextStyle(color: Colors.white)),
      );
    }

    return _TmdbGrid(items: _items, onRequest: _requestDownload);
  }

  Future<void> _requestDownload(Map<String, dynamic> item) async {
    final api = context.read<ApiService>();
    final title = item['title'] ?? item['name'] ?? 'Unknown';
    try {
      await api.createRequest(
        mediaType: item['mediaType'] ?? (item['title'] != null ? 'movie' : 'tv'),
        id: item['id'],
        title: title,
        posterPath: item['posterPath'],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Requested: $title')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }
}

// ============================================================================
// TRENDING TAB - TMDB trending content
// ============================================================================

class _TrendingTab extends StatefulWidget {
  const _TrendingTab();

  @override
  State<_TrendingTab> createState() => _TrendingTabState();
}

class _TrendingTabState extends State<_TrendingTab> {
  String _contentType = 'all';
  String _timeWindow = 'week';
  List<dynamic> _items = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiService>();
      final items = await api.getTrending(
        window: _timeWindow,
        type: _contentType == 'all' ? null : _contentType,
      );
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilters(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          _FilterChip(
            label: _contentType == 'all' ? 'All' : _contentType == 'movie' ? 'Movies' : 'TV',
            onTap: () {
              final types = ['all', 'movie', 'tv'];
              final next = types[(types.indexOf(_contentType) + 1) % 3];
              setState(() => _contentType = next);
              _loadContent();
            },
          ),
          const SizedBox(width: 12),
          _FilterChip(
            label: _timeWindow == 'day' ? 'Today' : 'This Week',
            onTap: () {
              setState(() => _timeWindow = _timeWindow == 'day' ? 'week' : 'day');
              _loadContent();
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadContent,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadContent, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text('No trending content found', style: TextStyle(color: Colors.white)),
      );
    }

    return _TmdbGrid(items: _items, onRequest: _requestDownload);
  }

  Future<void> _requestDownload(Map<String, dynamic> item) async {
    final api = context.read<ApiService>();
    final title = item['title'] ?? item['name'] ?? 'Unknown';
    try {
      await api.createRequest(
        mediaType: item['mediaType'] ?? (item['title'] != null ? 'movie' : 'tv'),
        id: item['id'],
        title: title,
        posterPath: item['posterPath'],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Requested: $title')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }
}

// ============================================================================
// SEARCH TAB - Search TMDB
// ============================================================================

class _SearchTab extends StatefulWidget {
  const _SearchTab();

  @override
  State<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<_SearchTab> {
  final _searchController = TextEditingController();
  List<dynamic> _results = [];
  bool _isSearching = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final api = context.read<ApiService>();
      final results = await api.search(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search movies and TV shows...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.search, size: 28),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                  ),
                  onSubmitted: _search,
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: () => _search(_searchController.text),
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.grey[600]),
                      const SizedBox(height: 16),
                      Text(
                        'Search for movies and TV shows',
                        style: TextStyle(color: Colors.grey[400], fontSize: 18),
                      ),
                    ],
                  ),
                )
              : _TmdbGrid(items: _results, onRequest: _requestDownload),
        ),
      ],
    );
  }

  Future<void> _requestDownload(Map<String, dynamic> item) async {
    final api = context.read<ApiService>();
    final title = item['title'] ?? item['name'] ?? 'Unknown';
    try {
      await api.createRequest(
        mediaType: item['mediaType'] ?? (item['title'] != null ? 'movie' : 'tv'),
        id: item['id'],
        title: title,
        posterPath: item['posterPath'],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Requested: $title')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }
}

// ============================================================================
// QUEUE TAB - Request queue with status
// ============================================================================

class _QueueTab extends StatefulWidget {
  const _QueueTab();

  @override
  State<_QueueTab> createState() => _QueueTabState();
}

class _QueueTabState extends State<_QueueTab> {
  List<dynamic> _requests = [];
  bool _isLoading = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadRequests();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _silentRefresh());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiService>();
      final requests = await api.getRequests();
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _silentRefresh() async {
    try {
      final api = context.read<ApiService>();
      final requests = await api.getRequests();
      if (mounted) {
        setState(() => _requests = requests);
      }
    } catch (_) {}
  }

  Future<void> _retryRequest(String mediaType, int id) async {
    try {
      final api = context.read<ApiService>();
      await api.resetRequest(mediaType, id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request reset to pending')),
        );
      }
      _loadRequests();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to retry: $e')),
        );
      }
    }
  }

  void _playVideo(String streamUrl, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HlsVideoPlayer(
          streamUrl: streamUrl,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_outlined, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No items in queue',
              style: TextStyle(color: Colors.grey[400], fontSize: 18),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Text(
                'Download Queue',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadRequests,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _requests.length,
            itemBuilder: (context, index) {
              final request = _requests[index] as Map<String, dynamic>;
              return _QueueItem(
                request: request,
                onRetry: () => _retryRequest(
                  request['mediaType'] ?? 'movie',
                  request['id'] ?? 0,
                ),
                onPlay: request['streamUrl'] != null
                    ? () => _playVideo(request['streamUrl'], request['title'] ?? 'Video')
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QueueItem extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onRetry;
  final VoidCallback? onPlay;

  const _QueueItem({
    required this.request,
    required this.onRetry,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final title = request['title'] ?? 'Unknown';
    final status = request['status'] as String? ?? 'pending';
    final posterPath = request['posterPath'] as String?;
    final progress = request['progress'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 90,
              child: posterPath != null
                  ? CachedNetworkImage(
                      imageUrl: 'https://image.tmdb.org/t/p/w92$posterPath',
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusChip(status),
                if (progress != null && status == RequestStatus.downloading) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: (progress as num).toDouble() / 100),
                ],
              ],
            ),
          ),
          if (status == RequestStatus.failed)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.orange),
              onPressed: onRetry,
              tooltip: 'Retry',
            ),
          if (status == RequestStatus.available && onPlay != null)
            IconButton(
              icon: const Icon(Icons.play_circle, color: Colors.green, size: 40),
              onPressed: onPlay,
              tooltip: 'Play',
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final (color, icon, label) = switch (status) {
      RequestStatus.pending => (Colors.amber, Icons.hourglass_empty, 'Pending'),
      RequestStatus.downloading => (Colors.blue, Icons.download, 'Downloading'),
      RequestStatus.transcoding => (Colors.purple, Icons.transform, 'Transcoding'),
      RequestStatus.uploading => (Colors.cyan, Icons.cloud_upload, 'Uploading'),
      RequestStatus.available => (Colors.green, Icons.check_circle, 'Available'),
      RequestStatus.failed => (Colors.red, Icons.error, 'Failed'),
      _ => (Colors.grey, Icons.help, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

// ============================================================================
// SHARED WIDGETS
// ============================================================================

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

class _TmdbGrid extends StatelessWidget {
  final List<dynamic> items;
  final Future<void> Function(Map<String, dynamic>) onRequest;

  const _TmdbGrid({required this.items, required this.onRequest});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index] as Map<String, dynamic>;
        return _TmdbCard(item: item, onTap: () => onRequest(item));
      },
    );
  }
}

class _TmdbCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _TmdbCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = item['title'] ?? item['name'] ?? 'Unknown';
    // Server returns camelCase: posterPath, posterUrl, voteAverage, mediaType
    final posterPath = item['posterPath'] as String?;
    final posterUrl = item['posterUrl'] as String?;
    final rating = item['voteAverage'] as num?;
    final mediaType = item['mediaType'] as String?;
    final year = item['year'] as String?;

    return FocusableCard(
      onSelect: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (posterUrl != null || posterPath != null)
            CachedNetworkImage(
              imageUrl: posterUrl ?? 'https://image.tmdb.org/t/p/w342$posterPath',
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[850]),
              errorWidget: (_, __, ___) => _buildPlaceholder(title),
            )
          else
            _buildPlaceholder(title),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (mediaType != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          mediaType == 'tv' ? 'TV' : 'Movie',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (year != null)
                      Text(year, style: TextStyle(color: Colors.white70, fontSize: 12)),
                    if (rating != null) ...[
                      const Spacer(),
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Container(
      color: Colors.grey[850],
      child: Center(
        child: Icon(Icons.movie_outlined, size: 48, color: Colors.grey[600]),
      ),
    );
  }
}
