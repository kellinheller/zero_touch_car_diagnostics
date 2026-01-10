import 'dart:async';

import 'obd_connection.dart';

/// LTC1260 (Chinese OBD2 chip) implementation
/// Similar to ELM327 but with some protocol differences
class LTC1260ObdConnection implements ObdConnection {
  final Stream<String> _inputStream;
  final Function(String) _sendOutput;

  late StreamSubscription _listener;
  final _lineController = StreamController<String>.broadcast();
  final _buffer = StringBuffer();

  LTC1260ObdConnection({
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

    await _initialize();
  }

  Future<void> _initialize() async {
    // Reset
    _sendOutput('ATZ\r');
    await Future.delayed(const Duration(milliseconds: 500));

    // Echo off
    _sendOutput('ATE0\r');
    await Future.delayed(const Duration(milliseconds: 100));

    // Spaces off
    _sendOutput('ATS0\r');
    await Future.delayed(const Duration(milliseconds: 100));

    // Headers
    _sendOutput('ATH0\r');
    await Future.delayed(const Duration(milliseconds: 100));

    // Auto protocol (LTC1260 specific)
    _sendOutput('ATSP0\r');
    await Future.delayed(const Duration(milliseconds: 200));

    // Enable CAN extended addressing if available
    _sendOutput('ATCEA\r');
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _onData(String data) {
    _buffer.write(data);
    String text = _buffer.toString();

    int idx;
    while ((idx = text.indexOf('\r')) != -1) {
      final line = text.substring(0, idx).trim();
      if (line.isNotEmpty && line != '>') {
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
