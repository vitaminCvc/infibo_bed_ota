import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

typedef LightCommandHandler = Future<void> Function(bool on);

class LanLightTestServer {
  LanLightTestServer({
    required this.onLightCommand,
    this.port = 8787,
    InternetAddress? bindAddress,
  }) : bindAddress = bindAddress ?? InternetAddress.anyIPv4;

  final LightCommandHandler onLightCommand; //处理灯光的命令
  final int port; //服务器监听的端口号
  final InternetAddress bindAddress; //服务器绑定的IP地址

  HttpServer? _server;

  int get boundPort {
    final server = _server;
    if (server == null) {
      throw StateError('LAN light test server has not started.');
    }
    return server.port;
  }

  Future<void> start() async {
    if (_server != null) return;

    final server = await HttpServer.bind(bindAddress, port);
    _server = server;
    unawaited(_serve(server));

    debugPrint('[LAN LIGHT TEST] listening on port ${server.port}');
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        debugPrint(
          '[LAN LIGHT TEST] tablet URL: '
          'http://${address.address}:${server.port}',
        );
      }
    }
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    await server?.close(force: true);
  }

  Future<void> _serve(HttpServer server) async {
    await for (final request in server) {
      await _handleRequest(request);
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final response = request.response;
    response.headers.contentType = ContentType.json;

    try {
      if (request.method != 'POST' || request.uri.path != '/test/light') {
        response.statusCode = HttpStatus.notFound;
        _writeJson(response, <String, Object?>{
          'ok': false,
          'error': 'not_found',
        });
        return;
      }

      final body = await utf8.decoder.bind(request).join();
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic> || decoded['on'] is! bool) {
        response.statusCode = HttpStatus.badRequest;
        _writeJson(response, <String, Object?>{
          'ok': false,
          'error': 'invalid_payload',
        });
        return;
      }

      final lightOn = decoded['on'] as bool;
      await onLightCommand(lightOn);
      debugPrint('[LAN LIGHT TEST] received lightOn=$lightOn');

      response.statusCode = HttpStatus.ok;
      _writeJson(response, <String, Object?>{'ok': true, 'lightOn': lightOn});
    } on FormatException {
      response.statusCode = HttpStatus.badRequest;
      _writeJson(response, <String, Object?>{
        'ok': false,
        'error': 'invalid_json',
      });
    } catch (error, stackTrace) {
      debugPrint('[LAN LIGHT TEST] receiver failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      response.statusCode = HttpStatus.internalServerError;
      _writeJson(response, <String, Object?>{
        'ok': false,
        'error': 'receiver_failed',
      });
    } finally {
      await response.close();
    }
  }

  void _writeJson(HttpResponse response, Map<String, Object?> body) {
    response.write(jsonEncode(body));
  }
}
