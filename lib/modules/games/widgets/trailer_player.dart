import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Inline video player for game trailers.
/// - YouTube URLs    → plays inline via [youtube_player_flutter]
/// - Direct MP4 URLs → plays inline via WebView + HTML5 <video>
class TrailerPlayer extends StatefulWidget {
  final String trailerUrl;

  const TrailerPlayer({super.key, required this.trailerUrl});

  @override
  State<TrailerPlayer> createState() => _TrailerPlayerState();
}

class _TrailerPlayerState extends State<TrailerPlayer> {
  WebViewController? _webController; // null for YouTube
  YoutubePlayerController? _ytController; // null for direct MP4
  bool _loaded = false;
  bool _loadError = false;
  String _loadErrorMsg = '';

  /// A standard Chrome Android User-Agent so Steam CDN doesn't reject requests.
  static const String _customUserAgent =
      'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/126.0.6478.122 Mobile Safari/537.36';

  // ── URL helpers ───────────────────────────────────────────────────

  bool get _isYouTube {
    return YoutubePlayer.convertUrlToId(widget.trailerUrl) != null;
  }

  String? get _youTubeVideoId {
    return YoutubePlayer.convertUrlToId(widget.trailerUrl);
  }

  /// HTML5 <video> page for direct URLs only.
  String get _videoHtml =>
      '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { background: #000; display: flex; align-items: center; justify-content: center; height: 100vh; }
video { width: 100%; max-height: 100vh; outline: none; }
</style>
</head>
<body>
<video controls playsinline
  src="${widget.trailerUrl}"
  style="width:100%;max-height:100vh;">
  Your browser does not support the video tag.
</video>
<script>
  const video = document.querySelector('video');
  video.addEventListener('click', () => {
    if (video.paused) { video.play(); } else { video.pause(); }
  });
</script>
</body>
</html>
''';

  @override
  void initState() {
    debugPrint('🎬 trailerUrl: ${widget.trailerUrl}');
    super.initState();

    if (_isYouTube) {
      _initYouTubePlayer();
      return;
    }

    _initWebViewPlayer();
  }

  void _initYouTubePlayer() {
    final videoId = _youTubeVideoId;
    if (videoId == null) {
      setState(() {
        _loadError = true;
        _loadErrorMsg = 'رابط يوتيوب غير صالح';
      });
      return;
    }

    _ytController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        useHybridComposition: true,
        showLiveFullscreenButton: false,
      ),
    );

    _ytController!.addListener(_onYouTubeStateChanged);
  }

  void _onYouTubeStateChanged() {
    if (!mounted) return;

    if (_ytController!.value.isReady && !_loaded) {
      setState(() => _loaded = true);
    }

    if (_ytController!.value.hasError && !_loadError) {
      debugPrint('⚠️ YouTube player error');
      setState(() {
        _loadError = true;
        _loadErrorMsg = 'تعذر تشغيل فيديو يوتيوب';
      });
    }
  }

  void _initWebViewPlayer() {
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent(_customUserAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loaded = true);
          },
          onWebResourceError: (error) {
            debugPrint(
              '⚠️ WebView error: ${error.errorCode} ${error.description}',
            );
            if (mounted) {
              setState(() {
                _loadError = true;
                _loadErrorMsg = 'خطأ ${error.errorCode}';
              });
            }
          },
        ),
      )
      ..loadHtmlString(_videoHtml);
  }

  @override
  void dispose() {
    _ytController?.removeListener(_onYouTubeStateChanged);
    _ytController?.dispose();
    super.dispose();
  }

  Future<void> _openExternally() async {
    final uri = Uri.parse(widget.trailerUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح الرابط خارجياً')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);

    // ── YouTube — inline player ────────────────────────────────────
    if (_isYouTube && _ytController != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: borderRadius,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              YoutubePlayer(
                controller: _ytController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red,
                progressColors: const ProgressBarColors(
                  playedColor: Colors.red,
                  handleColor: Colors.red,
                ),
                onReady: () {
                  debugPrint('✅ YouTube player ready');
                },
              ),
              // Loading overlay
              if (!_loaded && !_loadError)
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 12),
                        Text(
                          'جارٍ تحميل الفيديو...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              // Error overlay
              if (_loadError)
                Container(
                  color: Colors.black87,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.videocam_off,
                            color: Colors.white54,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _loadErrorMsg,
                            style: const TextStyle(color: Colors.white54),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _openExternally,
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('فتح في يوتيوب'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white30),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // External fallback button
              if (!_loadError)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _openExternally,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.open_in_new,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // ── Direct video — WebView + HTML5 <video> ─────────────────────
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: borderRadius,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (_webController != null)
              WebViewWidget(controller: _webController!),

            // Loading overlay
            if (!_loaded && !_loadError)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'جارٍ تحميل الفيديو...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

            // Error overlay
            if (_loadError)
              Container(
                color: Colors.black87,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.videocam_off,
                          color: Colors.white54,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _loadErrorMsg.isNotEmpty
                              ? _loadErrorMsg
                              : 'تعذر تشغيل الفيديو',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _openExternally,
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('فتح خارجياً'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white30),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            // External fallback button (top-right) after successful load
            else if (_loaded)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _openExternally,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.open_in_new,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
