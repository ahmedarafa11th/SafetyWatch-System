import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/camera.dart';

class CameraStreamWidget extends StatefulWidget {
  final String streamUrl;
  final bool isOnline;

  const CameraStreamWidget({
    super.key,
    required this.streamUrl,
    required this.isOnline,
  });

  @override
  State<CameraStreamWidget> createState() => _CameraStreamWidgetState();
}

class _CameraStreamWidgetState extends State<CameraStreamWidget> {
  VideoPlayerController? _videoController;
  WebViewController? _webViewController;
  bool _isVideoInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  @override
  void didUpdateWidget(CameraStreamWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamUrl != widget.streamUrl || oldWidget.isOnline != widget.isOnline) {
      _initStream();
    }
  }

  void _initStream() {
    _hasError = false;
    if (_videoController != null) {
      _videoController!.dispose();
      _videoController = null;
      _isVideoInitialized = false;
    }
    _webViewController = null;

    if (!widget.isOnline) return;

    if (Camera.isVideoUrl(widget.streamUrl)) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.streamUrl))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
            _videoController!.setLooping(true);
            _videoController!.setVolume(0.0);
            _videoController!.play();
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
        });
    } else {
      // MJPEG Webview
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..loadHtmlString('''
          <html>
            <body style="margin:0;padding:0;background-color:black;display:flex;justify-content:center;align-items:center;height:100vh;">
              <img src="${widget.streamUrl}" style="width:100%;height:100%;object-fit:cover;" onerror="document.getElementById('err').style.display='block';this.style.display='none';" />
              <div id="err" style="display:none;color:white;font-family:sans-serif;">Stream Offline</div>
            </body>
          </html>
        ''');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOnline) {
      return const Center(
        child: Icon(Icons.videocam_off, size: 48, color: Colors.grey),
      );
    }

    if (_hasError) {
      return const Center(
        child: Icon(Icons.error_outline, size: 48, color: Colors.red),
      );
    }

    if (Camera.isVideoUrl(widget.streamUrl)) {
      if (_isVideoInitialized && _videoController != null) {
        return SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
          ),
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    } else {
      // MJPEG Stream via WebView
      if (_webViewController != null) {
        return WebViewWidget(controller: _webViewController!);
      }
      return const Center(child: CircularProgressIndicator());
    }
  }
}

