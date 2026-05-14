import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/config/env_config.dart';

sealed class NammaAiSseEvent {
  const NammaAiSseEvent();
}

class NammaAiScopeEvent extends NammaAiSseEvent {
  const NammaAiScopeEvent(this.payload);
  final Map<String, dynamic> payload;
}

class NammaAiToolResultEvent extends NammaAiSseEvent {
  const NammaAiToolResultEvent(this.results, this.rag);
  final List<dynamic> results;
  final List<dynamic> rag;
}

class NammaAiTokenEvent extends NammaAiSseEvent {
  const NammaAiTokenEvent(this.text);
  final String text;
}

class NammaAiDoneEvent extends NammaAiSseEvent {
  const NammaAiDoneEvent();
}

/// POST `/v1/ai/chat` and parse `text/event-stream` frames.
class NammaAiGatewayClient {
  NammaAiGatewayClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _base(),
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(minutes: 5),
              headers: {'Content-Type': 'application/json'},
            ),
          );

  final Dio _dio;

  static String _base() {
    final b = EnvConfig.nammaAiBaseUrl.trim();
    if (b.isEmpty) return 'http://127.0.0.1:8787';
    return b.endsWith('/') ? b.substring(0, b.length - 1) : b;
  }

  static bool get isConfigured => EnvConfig.nammaAiBaseUrl.trim().isNotEmpty;

  Stream<NammaAiSseEvent> chatStream({
    required String message,
    required Map<String, dynamic> context,
    String? conversationId,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      '/v1/ai/chat',
      data: <String, dynamic>{
        'message': message,
        'conversation_id': conversationId,
        'context': context,
      },
      options: Options(responseType: ResponseType.stream),
    );

    final body = response.data;
    if (body == null) return;

    final controller = StreamController<List<int>>();
    final stream = utf8.decoder.bind(controller.stream);
    body.stream.listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );

    var buffer = '';
    await for (final chunk in stream) {
      buffer += chunk;
      while (true) {
        final idx = buffer.indexOf('\n\n');
        if (idx < 0) break;
        final block = buffer.substring(0, idx);
        buffer = buffer.substring(idx + 2);
        String? event;
        final dataLines = <String>[];
        for (final line in block.split('\n')) {
          if (line.startsWith('event:')) {
            event = line.substring(6).trim();
          } else if (line.startsWith('data:')) {
            dataLines.add(line.substring(5).trim());
          }
        }
        if (event == null || dataLines.isEmpty) continue;
        final dataStr = dataLines.join('');
        final json = jsonDecode(dataStr);
        switch (event) {
          case 'scope':
            if (json is Map<String, dynamic>) {
              yield NammaAiScopeEvent(json);
            }
          case 'tool_result':
            if (json is Map<String, dynamic>) {
              yield NammaAiToolResultEvent(
                (json['results'] as List?) ?? const [],
                (json['rag'] as List?) ?? const [],
              );
            }
          case 'token':
            if (json is Map && json['t'] != null) {
              yield NammaAiTokenEvent('${json['t']}');
            }
          case 'done':
            yield const NammaAiDoneEvent();
        }
      }
    }
  }
}
