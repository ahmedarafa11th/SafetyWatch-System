import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/stat_card.dart';

class CameraManagementScreen extends StatefulWidget {
  const CameraManagementScreen({super.key});

  @override
  State<CameraManagementScreen> createState() => _CameraManagementScreenState();
}

class _CameraManagementScreenState extends State<CameraManagementScreen> {
  final List<Map<String, dynamic>> _cameras = [
    {"name": "Camera 1 - Main Entrance", "loc": "Building A - Entrance", "status": "live", "time": "Active now", "alerts": 12},
    {"name": "Camera 2 - Office Floor", "loc": "Building A - Floor 2", "status": "live", "time": "Active now", "alerts": 5},
    {"name": "Camera 3 - Warehouse", "loc": "Building B - Warehouse", "status": "live", "time": "Active now", "alerts": 8},
    {"name": "Camera 4 - Storage", "loc": "Building B - Storage", "status": "live", "time": "Active now", "alerts": 2},
    {"name": "Camera 5 - Production Area", "loc": "Building C - Production", "status": "offline", "time": "2 hours ago", "alerts": 0},
    {"name": "Camera 6 - Lobby", "loc": "Building A - Lobby", "status": "live", "time": "Active now", "alerts": 3},
    {"name": "Camera 7 - Parking Lot", "loc": "Outdoor - Parking", "status": "live", "time": "Active now", "alerts": 15},
    {"name": "Camera 8 - Server Room", "loc": "Building A - Floor 3", "status": "live", "time": "Active now", "alerts": 4},
    {"name": "Camera 9 - Cafeteria", "loc": "Building A - Floor 1", "status": "live", "time": "Active now", "alerts": 1},
    {"name": "Camera 10 - Loading Dock", "loc": "Building B - Dock", "status": "live", "time": "Active now", "alerts": 6},
    {"name": "Camera 11 - Emergency Exit", "loc": "Building C - Exit", "status": "live", "time": "Active now", "alerts": 0},
    {"name": "Camera 12 - Reception", "loc": "Building A - Reception", "status": "live", "time": "Active now", "alerts": 7},
  ];

  void _deleteCamera(int index) {
    setState(() {
      _cameras.removeAt(index);
    });
  }

  void _showCameraSettings(BuildContext context, Map<String, dynamic> cam, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLive = cam["status"] == "live";
    final labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Camera Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),

              // Camera preview
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(Icons.videocam, size: 48, color: Colors.grey),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLive ? AppColors.success : AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6, height: 6,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isLive ? "LIVE" : "OFFLINE",
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Camera Name
              Text('CAMERA NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: labelColor, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text(
                cam["name"] as String,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 16),

              // Location
              Text('LOCATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: labelColor, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text(
                cam["loc"] as String,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 16),

              // Alerts
              Text('ALERTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: labelColor, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text(
                '${cam["alerts"]}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showDeleteConfirmation(context, cam["name"] as String, index);
                      },
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Delete Camera', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: AppColors.error.withAlpha(120)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Close', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String cameraName, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            const SizedBox(width: 8),
            Text(
              'Delete Camera',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$cameraName"? This action cannot be undone.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteCamera(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$cameraName deleted successfully'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showAddCameraDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final urlController = TextEditingController();
    String selectedStatus = "Online";
    final labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          backgroundColor: isDark ? const Color(0xFF141C2F) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Add New Camera',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Camera Name Field
                  Text('CAMERA NAME *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: labelColor, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. Camera 1 - Main Entrance',
                      hintStyle: TextStyle(color: labelColor.withAlpha(120), fontSize: 13),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location Field
                  Text('LOCATION *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: labelColor, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: locationController,
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. Building A - Floor 2',
                      hintStyle: TextStyle(color: labelColor.withAlpha(120), fontSize: 13),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // IP Address / URL Field
                  Text('IP ADDRESS OR VIDEO URL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: labelColor, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: urlController,
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: '192.168.1.100  or  https://example.com/video.mp4',
                      hintStyle: TextStyle(color: labelColor.withAlpha(120), fontSize: 13),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status Radio Buttons
                  Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: labelColor, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Online Option
                      GestureDetector(
                        onTap: () => setStateDialog(() => selectedStatus = "Online"),
                        child: Row(
                          children: [
                            Container(
                              width: 16, height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: selectedStatus == "Online" ? const Color(0xFF3B82F6) : Colors.grey,
                                  width: selectedStatus == "Online" ? 4 : 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Online', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Offline Option
                      GestureDetector(
                        onTap: () => setStateDialog(() => selectedStatus = "Offline"),
                        child: Row(
                          children: [
                            Container(
                              width: 16, height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: selectedStatus == "Offline" ? const Color(0xFF3B82F6) : Colors.grey,
                                  width: selectedStatus == "Offline" ? 4 : 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Offline', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final loc = locationController.text.trim();
                          if (name.isEmpty || loc.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Please fill in required fields'),
                                backgroundColor: AppColors.warning,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                            return;
                          }
                          Navigator.pop(ctx);
                          setState(() {
                            _cameras.add({
                              "name": name,
                              "loc": loc,
                              "status": selectedStatus == "Online" ? "live" : "offline",
                              "time": selectedStatus == "Online" ? "Active now" : "Just now",
                              "alerts": 0,
                            });
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$name added successfully'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF60A5FA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Add Camera', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final online = _cameras.where((c) => c["status"] == "live").length;
    final offline = _cameras.length - online;
    final totalAlerts = _cameras.fold<int>(0, (sum, c) => sum + (c["alerts"] as int));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Add button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Camera Management", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Monitor and manage all security cameras", style: TextStyle(color: secondaryText, fontSize: 14)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddCameraDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: StatCard(value: _cameras.length.toString(), label: "Total Cameras", icon: Icons.videocam, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(value: online.toString(), label: "Online", icon: Icons.wifi, color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatCard(value: offline.toString(), label: "Offline", icon: Icons.wifi_off, color: AppColors.error)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(value: totalAlerts.toString(), label: "Total Alerts", icon: Icons.warning_amber, color: AppColors.warning)),
            ],
          ),
          const SizedBox(height: 24),

          // Camera grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _cameras.length,
            itemBuilder: (context, i) {
              final cam = _cameras[i];
              final isLive = cam["status"] == "live";

              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Camera preview
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBg : AppColors.lightBg,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      child: Stack(
                        children: [
                          const Center(child: Icon(Icons.videocam, size: 36, color: Colors.grey)),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isLive ? AppColors.success : AppColors.error,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                                  const SizedBox(width: 4),
                                  Text(isLive ? "LIVE" : "OFFLINE", style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cam["name"] as String,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(cam["loc"] as String, style: TextStyle(color: secondaryText, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(cam["time"] as String, style: TextStyle(color: secondaryText, fontSize: 10)),
                                Text("${cam["alerts"]} alerts", style: TextStyle(color: (cam["alerts"] as int) > 0 ? AppColors.warning : secondaryText, fontSize: 10, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showCameraSettings(context, cam, i),
                                icon: const Icon(Icons.settings, size: 14),
                                label: const Text("Settings", style: TextStyle(fontSize: 11)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
