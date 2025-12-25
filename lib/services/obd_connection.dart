import 'dart:async';

abstract class ObdConnection {
  Future<void> connect();
  Future<void> disconnect();
  Future<void> write(String command);
  Stream<String> get lines; // CRLF-delimited lines from adapter
}
