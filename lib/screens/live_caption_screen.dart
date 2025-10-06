import 'package:flutter/material.dart';
import '../services/speech_caption_service.dart';
import '../services/gpt_service.dart';

class LiveCaptionScreen extends StatefulWidget {
  const LiveCaptionScreen({super.key});

  @override
  State<LiveCaptionScreen> createState() => _LiveCaptionScreenState();
}

class _LiveCaptionScreenState extends State<LiveCaptionScreen> {
  final SpeechCaptionService _captionService = SpeechCaptionService();
  final GptService _gptService = GptService();

  String _liveCaption = '';
  String _gptResponse = '';
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _captionService.initialize();
    _captionService.captions.listen((text) {
      setState(() {
        _liveCaption = text;
      });
    });
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _captionService.stopListening();
      setState(() {
        _listening = false;
      });
    } else {
      await _captionService.startListening();
      setState(() {
        _listening = true;
      });
    }
  }

  Future<void> _askGpt() async {
    final response = await _gptService.promptWithText(_liveCaption);
    setState(() {
      _gptResponse = response;
    });
  }

  @override
  void dispose() {
    _captionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Caption'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleListening,
                  icon: Icon(_listening ? Icons.mic_off : Icons.mic),
                  label: Text(_listening ? 'Stop' : 'Start'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _liveCaption.trim().isEmpty ? null : _askGpt,
                  icon: const Icon(Icons.send),
                  label: const Text('Ask GPT'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Live Caption', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _liveCaption.isEmpty ? 'Tap Start to begin live captions.' : _liveCaption,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('GPT Response', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _gptResponse.isEmpty ? 'Results will appear here.' : _gptResponse,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


