import 'package:flutter/material.dart';

/// Status indicator widget showing connection and device information
class StatusIndicator extends StatelessWidget {
  final String status;
  final String transport;
  final bool isConnected;
  final Color statusColor;

  const StatusIndicator({
    Key? key,
    required this.status,
    required this.transport,
    required this.isConnected,
    required this.statusColor,
  }) : super(key: key);

  String _getStatusIcon() {
    if (status.contains('Connecting')) return '⏳';
    if (status.contains('Error') || status.contains('error')) return '❌';
    if (status.contains('Done') || status.contains('Connected')) return '✅';
    if (status.contains('Idle') || status.contains('Simulation')) return '⭘';
    if (status.contains('Sending') || status.contains('Sampling')) return '📤';
    return '🔍';
  }

  String _getDeviceType() {
    if (transport.contains('STN1110')) return 'STN1110 (Premium)';
    if (transport.contains('LTC1260')) return 'LTC1260 (Generic)';
    if (transport.contains('ELM327')) return 'ELM327 (Standard)';
    if (transport.contains('Generic')) return 'Generic OBD2';
    if (transport.contains('Simulation')) return 'Simulation (Dev)';
    return transport;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              _getStatusIcon(),
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 12),
          // Status info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connection Status',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getDeviceType(),
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Connection indicator dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isConnected ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              boxShadow: isConnected
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini status bar for quick overview
class MiniStatusBar extends StatelessWidget {
  final String status;
  final bool isConnected;
  final String chipType;

  const MiniStatusBar({
    Key? key,
    required this.status,
    required this.isConnected,
    required this.chipType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isConnected ? 'Connected • $chipType' : 'Disconnected',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Get appropriate color for status
Color getStatusColor(String status) {
  if (status.contains('Error') || status.contains('error')) {
    return Colors.red;
  } else if (status.contains('Connected') || status.contains('Done')) {
    return Colors.green;
  } else if (status.contains('Connecting') || status.contains('Sampling') || status.contains('Sending')) {
    return Colors.orange;
  } else {
    return Colors.blue;
  }
}
