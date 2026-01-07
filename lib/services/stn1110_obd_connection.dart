import 'dart:async';

import 'obd_chip.dart';
import 'obd_connection.dart';

/// STN1110 OBD2 adapter implementation
/// Supports J1939 and ISO14229 in addition to standard OBD2
class STN1110ObdConnection implements ObdConnection {
  final Stream<String> _inputStream;
  final Function(String) _sendOutput;

  late StreamSubscription _listener;
  final _lineController = StreamController<String>.broadcast();
  final _buffer = StringBuffer();

  OBDChipInfo? _chipInfo;

  STN1110ObdConnection({
    required Stream<String> inputStream,
    required Function(String) sendOutput,
  }) : _inputStream = inputStream,
       _sendOutput = sendOutput;

  @override
  Stream<String> get lines => _lineController.stream;

  @override
  Future<void> connect() async {
    _listener = _inputStream.listen(
      _onData,
      onError: (e) => _lineController.addError(e),
      onDone: () => _lineController.close(),
    );

    // Initialize STN1110
    await _initialize();
  }

  Future<void> _initialize() async {
    // Reset device
    _sendOutput('ATZ\r');
    await Future.delayed(const Duration(milliseconds: 500));

    // Set echo off
    _sendOutput('ATE0\r');
    await Future.delayed(const Duration(milliseconds: 100));

    // Set spaces off
    _sendOutput('ATS0\r');
    await Future.delayed(const Duration(milliseconds: 100));

    // Set line endings
    _sendOutput('ATH1\r');
    await Future.delayed(const Duration(milliseconds: 100));

    // Get device info
    _sendOutput('AT@1\r');
    await Future.delayed(const Duration(milliseconds: 200));

    // Auto-select protocol
    _sendOutput('ATSP0\r');
    await Future.delayed(const Duration(milliseconds: 200));
  }

  void _onData(String data) {
    _buffer.write(data);
    String text = _buffer.toString();

    // Split by '>' (STN1110 prompt) or CR
    int idx;
    while ((idx = text.indexOf('>')) != -1) {
      final line = text.substring(0, idx).trim();
      if (line.isNotEmpty) {
        _lineController.add(line);
      }
      text = text.substring(idx + 1);
    }

    // Also handle CR-based lines
    while ((idx = text.indexOf('\r')) != -1) {
      final line = text.substring(0, idx).trim();
      if (line.isNotEmpty && !line.startsWith('>')) {
        _lineController.add(line);
      }
      text = text.substring(idx + 1);
    }

    _buffer.clear();
    _buffer.write(text);
  }

  @override
  Future<void> write(String command) async {
    final cmd = command.endsWith('\r') ? command : '$command\r';
    _sendOutput(cmd);
  }

  @override
  Future<void> disconnect() async {
    await _listener.cancel();
    await _lineController.close();
  }
}
