// lib/widgets/offline_banner.dart

import 'package:flutter/material.dart';

/// A slim banner shown above the course list when the data on screen came from
/// the local cache (i.e. the network was unreachable).
class OfflineBanner extends StatelessWidget {
  final DateTime? lastSync;

  const OfflineBanner({super.key, this.lastSync});

  String _formatSync(DateTime time) {
    final local = time.toLocal();
    final d = '${local.year}-${_two(local.month)}-${_two(local.day)}';
    final t = '${_two(local.hour)}:${_two(local.minute)}';
    return '$d $t';
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF4A3A00),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 18, color: Color(0xFFFFC107)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              lastSync == null
                  ? 'Offline — showing saved courses'
                  : 'Offline — showing saved courses (last synced '
                      '${_formatSync(lastSync!)})',
              style: const TextStyle(
                color: Color(0xFFFFE082),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
