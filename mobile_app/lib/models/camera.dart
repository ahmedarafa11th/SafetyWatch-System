class Camera {
  final int id;
  final String name;
  final String location;
  final String? ipAddress;
  final String? streamUrl;
  final String status; // 'online', 'offline'
  final int totalAlerts;
  final String? lastActiveAt;
  final String? createdAt;

  const Camera({
    required this.id,
    required this.name,
    required this.location,
    this.ipAddress,
    this.streamUrl,
    required this.status,
    this.totalAlerts = 0,
    this.lastActiveAt,
    this.createdAt,
  });

  bool get isOnline => status == 'online';

  /// Build stream URL from IP address, matching the web frontend logic.
  String? get effectiveStreamUrl {
    if (streamUrl != null && streamUrl!.isNotEmpty) return streamUrl;
    return buildStreamUrl(ipAddress);
  }

  /// Port of the web frontend's buildStreamUrl() function.
  static String? buildStreamUrl(String? ip) {
    if (ip == null || ip.isEmpty) return null;
    // Already a full URL
    if (ip.startsWith('http://') || ip.startsWith('https://')) {
      if (_isVideoFile(ip)) return ip;
      try {
        final uri = Uri.parse(ip);
        if (uri.path == '/' || uri.path.isEmpty) {
          return '${ip.replaceAll(RegExp(r'/$'), '')}/video';
        }
        return ip;
      } catch (_) {
        return ip;
      }
    }
    // Bare IP or IP:port
    return 'http://$ip/video';
  }

  static bool _isVideoFile(String url) {
    final lower = url.toLowerCase().split('?')[0];
    return lower.endsWith('.mp4') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.ogg') ||
        lower.endsWith('.m3u8') ||
        lower.endsWith('.mov');
  }

  static bool isVideoUrl(String? url) {
    if (url == null) return false;
    return _isVideoFile(url);
  }

  String get formattedLastActive {
    final dateStr = lastActiveAt ?? createdAt;
    if (dateStr == null) return 'No Activity';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unnamed Camera',
      location: json['location'] as String? ?? '',
      ipAddress: json['ip_address'] as String?,
      streamUrl: json['stream_url'] as String?,
      status: json['status'] as String? ?? 'offline',
      totalAlerts: json['total_alerts'] as int? ?? 0,
      lastActiveAt: json['last_active_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}

class CameraStats {
  final int total;
  final int online;
  final int offline;
  final int totalAlerts;

  const CameraStats({
    this.total = 0,
    this.online = 0,
    this.offline = 0,
    this.totalAlerts = 0,
  });

  factory CameraStats.fromJson(Map<String, dynamic> json) {
    return CameraStats(
      total: json['total'] as int? ?? 0,
      online: json['online'] as int? ?? 0,
      offline: json['offline'] as int? ?? 0,
      totalAlerts: json['total_alerts'] as int? ?? 0,
    );
  }
}

class CameraFormData {
  String name;
  String location;
  String ipAddress;
  String status;

  CameraFormData({
    this.name = '',
    this.location = '',
    this.ipAddress = '',
    this.status = 'online',
  });

  Map<String, dynamic> toJson() {
    final streamUrl = ipAddress.isNotEmpty ? Camera.buildStreamUrl(ipAddress) : null;
    return {
      'name': name,
      'location': location,
      'ip_address': ipAddress.isNotEmpty ? ipAddress : null,
      'stream_url': streamUrl,
      'status': status,
    };
  }

  factory CameraFormData.fromCamera(Camera cam) {
    return CameraFormData(
      name: cam.name,
      location: cam.location,
      ipAddress: cam.ipAddress ?? '',
      status: cam.status,
    );
  }
}
