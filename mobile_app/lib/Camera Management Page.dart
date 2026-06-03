import 'package:flutter/material.dart';

class CameraManagementPage extends StatefulWidget {
  const CameraManagementPage({super.key});

  @override
  State<CameraManagementPage> createState() => _CameraManagementPageState();
}

class _CameraManagementPageState extends State<CameraManagementPage> {
  final List<Map<String, dynamic>> cameras = [
    {
      "id": 1,
      "name": "Camera 1 - Main Entrance",
      "loc": "Building A - Entrance",
      "status": "live",
      "time": "Active now",
      "alerts": 12,
    },
    {
      "id": 2,
      "name": "Camera 2 - Office Floor",
      "loc": "Building A - Floor 2",
      "status": "live",
      "time": "Active now",
      "alerts": 5,
    },
    {
      "id": 3,
      "name": "Camera 3 - Warehouse",
      "loc": "Building B - Warehouse",
      "status": "live",
      "time": "Active now",
      "alerts": 8,
    },
    {
      "id": 4,
      "name": "Camera 4 - Storage",
      "loc": "Building B - Storage",
      "status": "live",
      "time": "Active now",
      "alerts": 2,
    },
    {
      "id": 5,
      "name": "Camera 5 - Production Area",
      "loc": "Building C - Production",
      "status": "offline",
      "time": "2 hours ago",
      "alerts": 0,
    },
    {
      "id": 6,
      "name": "Camera 6 - Lobby",
      "loc": "Building A - Lobby",
      "status": "live",
      "time": "Active now",
      "alerts": 3,
    },
    {
      "id": 7,
      "name": "Camera 7 - Parking Lot",
      "loc": "Outdoor - Parking",
      "status": "live",
      "time": "Active now",
      "alerts": 15,
    },
    {
      "id": 8,
      "name": "Camera 8 - Server Room",
      "loc": "Building A - Floor 3",
      "status": "live",
      "time": "Active now",
      "alerts": 4,
    },
  ];

  Color statusColor(String status) {
    switch (status) {
      case "live":
        return Colors.green;
      case "offline":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final online = cameras.where((c) => c["status"] == "live").length;
    final offline = cameras.length - online;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text("Camera Management"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                statCard(
                  cameras.length.toString(),
                  "Total Cameras",
                  Colors.white,
                ),
                statCard(online.toString(), "Online", Colors.green),
              ],
            ),
            Row(
              children: [
                statCard(offline.toString(), "Offline", Colors.red),
                statCard("63", "Total Alerts", Colors.orange),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: cameras.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final cam = cameras[index];
                  final isLive = cam["status"] == "live";

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.videocam,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          cam["name"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cam["loc"],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cam["time"],
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor(
                                  cam["status"],
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isLive ? "LIVE" : "OFFLINE",
                                style: TextStyle(
                                  color: statusColor(cam["status"]),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Alerts: ${cam["alerts"]}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
