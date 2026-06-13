import 'package:flutter/material.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/camera_stream.dart';
import '../../providers/cameras_provider.dart';
import '../../models/camera.dart';

class CameraManagementScreen extends ConsumerStatefulWidget {
  const CameraManagementScreen({super.key});

  @override
  ConsumerState<CameraManagementScreen> createState() =>
      _CameraManagementScreenState();
}

class _CameraManagementScreenState
    extends ConsumerState<CameraManagementScreen> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(camerasProvider.notifier).fetch());
    
    // Start sliding window polling
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        ref.read(camerasProvider.notifier).fetch(background: true);
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _showAddDialog() {
    final form = CameraFormData();
    _showCameraFormDialog(form: form, isEdit: false);
  }

  void _showEditDialog(Camera cam) {
    final form = CameraFormData.fromCamera(cam);
    _showCameraFormDialog(form: form, isEdit: true, cameraId: cam.id);
  }

  void _showCameraFormDialog({
    required CameraFormData form,
    required bool isEdit,
    int? cameraId,
  }) {
    final nameC = TextEditingController(text: form.name);
    final locC = TextEditingController(text: form.location);
    final ipC = TextEditingController(text: form.ipAddress);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isSaving = ref.watch(camerasProvider).isSaving;
          return AlertDialog(
            title: Text(isEdit ? "Edit Camera" : "Add New Camera"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameC,
                    decoration: const InputDecoration(
                      labelText: "Camera Name *",
                      hintText: "e.g. Main Entrance Cam",
                    ),
                    onChanged: (v) => form.name = v,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locC,
                    decoration: const InputDecoration(
                      labelText: "Location *",
                      hintText: "e.g. Building A - Entrance",
                    ),
                    onChanged: (v) => form.location = v,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ipC,
                    decoration: const InputDecoration(
                      labelText: "IP Address / Stream URL",
                      hintText: "e.g. 192.168.1.100 or rtsp://...",
                    ),
                    onChanged: (v) => form.ipAddress = v,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: form.status,
                    decoration: const InputDecoration(labelText: "Status"),
                    items: const [
                      DropdownMenuItem(
                          value: "online", child: Text("Online")),
                      DropdownMenuItem(
                          value: "offline", child: Text("Offline")),
                    ],
                    onChanged: (v) =>
                        setDialogState(() => form.status = v!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        form.name = nameC.text;
                        form.location = locC.text;
                        form.ipAddress = ipC.text;

                        bool success;
                        if (isEdit) {
                          success = await ref
                              .read(camerasProvider.notifier)
                              .updateCamera(cameraId!, form);
                        } else {
                          success = await ref
                              .read(camerasProvider.notifier)
                              .addCamera(form);
                        }
                        if (!ctx.mounted) return;
                        if (success) {
                          Navigator.pop(ctx);
                        } else {
                          final error = ref.read(camerasProvider).error;
                          if (error != null && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(error),
                                  backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                child: Text(isSaving
                    ? "Saving..."
                    : (isEdit ? "Save Changes" : "Add Camera")),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(Camera cam) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Camera"),
        content: Text("Are you sure you want to delete '${cam.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(camerasProvider.notifier).deleteCamera(cam.id);
    }
  }

  void _showCameraPreview(Camera cam) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  const Text('Camera Preview',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Stream preview
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Try to load the stream if URL is available
                    if (cam.effectiveStreamUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CameraStreamWidget(
                          streamUrl: cam.effectiveStreamUrl!,
                          isOnline: cam.isOnline,
                        ),
                      )
                    else
                      const Center(
                        child: Icon(Icons.videocam_off, size: 48, color: Colors.grey),
                      ),

                    // LIVE / OFFLINE badge
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cam.isOnline
                              ? AppColors.success
                              : AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              cam.isOnline ? "LIVE" : "OFFLINE",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Camera info
              _infoRow(Icons.videocam, "Name", cam.name),
              _infoRow(Icons.location_on, "Location", cam.location),
              if (cam.ipAddress != null)
                _infoRow(Icons.lan, "IP Address", cam.ipAddress!),
              _infoRow(Icons.access_time, "Last Active",
                  cam.formattedLastActive),
              _infoRow(Icons.warning_amber, "Total Alerts",
                  '${cam.totalAlerts}'),

              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showEditDialog(cam);
                      },
                      icon: const Icon(Icons.settings, size: 16),
                      label: const Text("Settings"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(camerasProvider.notifier)
                            .toggleStatus(cam.id);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      icon: Icon(
                          cam.isOnline
                              ? Icons.power_off
                              : Icons.power,
                          size: 16),
                      label: Text(cam.isOnline
                          ? "Go Offline"
                          : "Go Online"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cam.isOnline
                            ? AppColors.warning
                            : AppColors.success,
                        foregroundColor: Colors.white,
                      ),
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

  Widget _infoRow(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          const SizedBox(width: 8),
          Text('$label: ',
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final state = ref.watch(camerasProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(camerasProvider.notifier).fetch(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Cameras",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                          "Manage surveillance cameras and live feeds",
                          style:
                              TextStyle(color: secondaryText, fontSize: 14)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.pickFiles(
                      type: FileType.video,
                    );
                    if (result != null) {
                      final success = await ref.read(camerasProvider.notifier).uploadTestVideo(result.files.first);
                      if (mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Test Video Uploaded as Camera successfully!'), backgroundColor: AppColors.success),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.upload_file, size: 18, color: Colors.white),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                  label: const Text("Upload Video", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add"),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats
            Row(
              children: [
                Expanded(
                    child: StatCard(
                        value: '${state.stats.total}',
                        label: "Total",
                        icon: Icons.videocam,
                        color: AppColors.primary)),
                const SizedBox(width: 10),
                Expanded(
                    child: StatCard(
                        value: '${state.stats.online}',
                        label: "Online",
                        icon: Icons.check_circle_outline,
                        color: AppColors.success)),
                const SizedBox(width: 10),
                Expanded(
                    child: StatCard(
                        value: '${state.stats.offline}',
                        label: "Offline",
                        icon: Icons.cancel_outlined,
                        color: AppColors.error)),
              ],
            ),
            const SizedBox(height: 20),

            // Camera grid
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: ListShimmer(itemCount: 4),
              )
            else if (state.cameras.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text("No cameras configured.",
                      style: TextStyle(color: secondaryText, fontSize: 14)),
                ),
              )
            else
              AnimationLimiter(
                child: Column(
                  children: state.cameras.asMap().entries.map((entry) {
                    final index = entry.key;
                    final cam = entry.value;
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _cameraCard(cam, isDark, secondaryText),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cameraCard(Camera cam, bool isDark, Color secondaryText) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: InkWell(
        onTap: () => _showCameraPreview(cam),
        child: Column(
          children: [
            // Preview area
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14)),
              ),
              child: Stack(
                children: [
                  // Try to load stream
                  if (cam.effectiveStreamUrl != null &&
                      !Camera.isVideoUrl(cam.effectiveStreamUrl))
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14)),
                      child: Image.network(
                        cam.effectiveStreamUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 120,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.videocam,
                              size: 36, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: Icon(Icons.videocam,
                          size: 36, color: Colors.grey),
                    ),

                  // Status badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cam.isOnline
                            ? AppColors.success
                            : AppColors.error,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            cam.isOnline ? "LIVE" : "OFFLINE",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Live AI Violence Telemetry Bar
                  if (cam.isAiEnabled && !cam.isEntrance && cam.isOnline)
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "AI RISK LEVEL",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  shadows: [Shadow(color: Colors.black87, blurRadius: 3, offset: Offset(0, 1))],
                                ),
                              ),
                              Text(
                                "${((cam.currentViolenceScore ?? 0) * 100).round()}%",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: (cam.currentViolenceScore ?? 0) >= 0.70 
                                      ? Colors.redAccent 
                                      : (cam.currentViolenceScore ?? 0) >= 0.40 ? Colors.orange : Colors.greenAccent,
                                  shadows: const [Shadow(color: Colors.black87, blurRadius: 3, offset: Offset(0, 1))],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 4,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(50),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 4,
                                  width: MediaQuery.of(context).size.width * 
                                        ((cam.currentViolenceScore ?? 0).clamp(0.0, 1.0)) * 0.4, // Approximation based on parent size
                                  decoration: BoxDecoration(
                                    color: (cam.currentViolenceScore ?? 0) >= 0.70 
                                      ? Colors.redAccent 
                                      : (cam.currentViolenceScore ?? 0) >= 0.40 ? Colors.orange : Colors.greenAccent,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: (cam.currentViolenceScore ?? 0) >= 0.70 
                                      ? [const BoxShadow(color: Colors.redAccent, blurRadius: 8)] 
                                      : [],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cam.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: secondaryText),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(cam.location,
                            style: TextStyle(
                                color: secondaryText, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.warning_amber,
                          size: 14, color: secondaryText),
                      const SizedBox(width: 4),
                      Text('${cam.totalAlerts} alerts',
                          style: TextStyle(
                              color: secondaryText, fontSize: 12)),
                      const Spacer(),
                      // Delete button
                      InkWell(
                        onTap: () => _confirmDelete(cam),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.error.withAlpha(80)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.delete_outline,
                              size: 16, color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
