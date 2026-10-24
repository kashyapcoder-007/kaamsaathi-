import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/speech_service.dart';

class VoiceHomeScreen extends StatefulWidget {
  const VoiceHomeScreen({super.key});
  @override
  State<VoiceHomeScreen> createState() => _VoiceHomeScreenState();
}

class _VoiceHomeScreenState extends State<VoiceHomeScreen> {
  final _speech = SpeechService();
  String _heard = 'Tap the mic and speak';
  bool _listening = false;

  static const trades = {
    'Mason': Icons.construction,
    'Painter': Icons.format_paint,
    'Carpenter': Icons.carpenter,
    'Farm Worker': Icons.grass,
    'Helper': Icons.handyman,
  };

  Future<void> _onMicTap() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    setState(() {
      _listening = true;
      _heard = 'Listening…';
    });
    await _speech.listen(onResult: (text) {
      setState(() {
        _heard = '"$text"';
        _listening = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text('KaamSaathi', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 32)),
          const SizedBox(height: 4),
          const Text('No forms. No resume. Just speak.', style: TextStyle(color: KColors.muted)),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _onMicTap,
            child: CircleAvatar(
              radius: 48,
              backgroundColor: KColors.violet,
              child: Icon(_listening ? Icons.mic : Icons.mic_none, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(_heard, style: const TextStyle(color: KColors.muted)),
          const SizedBox(height: 32),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: trades.entries.map((e) {
              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.pushNamed(context, '/jobs', arguments: e.key),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(e.value, color: KColors.teal, size: 28),
                        const SizedBox(height: 6),
                        Text(e.key, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
