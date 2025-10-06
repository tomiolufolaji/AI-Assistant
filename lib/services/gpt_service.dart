import 'dart:async';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GptService {
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('OPENAI_API_KEY is missing. Add it to .env');
    }
    OpenAI.apiKey = apiKey;
    _initialized = true;
  }

  Future<String> promptWithText(String transcript) async {
    await initialize();
    if (transcript.trim().isEmpty) return '';

    final messages = [
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            'You are a helpful assistant. Summarize or answer succinctly based on the user speech.'
          ),
        ],
      ),
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(transcript),
        ],
      ),
    ];

    final chat = await OpenAI.instance.chat.create(
      model: 'gpt-4o-mini',
      messages: messages,
      temperature: 0.3,
    );

    return chat.choices.first.message.content?.map((c) => c.text).join('\n').trim() ?? '';
  }
}


