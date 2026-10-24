import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/ml_service.dart';

class SkillCardScreen extends StatefulWidget {
  const SkillCardScreen({super.key});
  @override
  State<SkillCardScreen> createState() => _SkillCardScreenState();
}

class _SkillCardScreenState extends State<SkillCardScreen> {
  final _controller = TextEditingController(
    text: 'Main 8 saal se raj mistri hoon. Karni aur level use karta hoon. '
        'Pichhle saal 40 ghar banaye.',
  );
  Map<String, String>? _result;

  // Same lightweight rule-based extraction as the HTML prototype.
  // Replace with NLP entity extraction on the ASR transcript later
  // (see proposal doc: "Skill / Resume Analyzer").
  // Tries the pretrained-model server first; falls back to local rules.
  Future<void> _analyze() async {
    try {
      final r = await MlService().analyze(_controller.text);
      final tools = (r['tools'] as List).join(', ');
      setState(() {
        _result = {
          'Trade': (r['trade'] ?? 'not detected').toString(),
          'Experience': r['years'] != null ? '${r['years']} years' : 'not detected',
          'Past work': r['jobs'] != null ? '${r['jobs']} jobs' : 'not detected',
          'Tools': tools.isEmpty ? 'none detected' : tools,
        };
      });
    } catch (_) {
      _analyzeLocal();
    }
  }

  void _analyzeLocal() {
    final text = _controller.text;
    final trades = {
      'Mason': RegExp(r'mason|mistri|mistry|raj|मिस्त्री|राज', caseSensitive: false),
      'Painter': RegExp(r'paint|rang|पेंट|रंग|पुताई', caseSensitive: false),
      'Carpenter': RegExp(r'carpent|badhai|barhai|बढ़ई', caseSensitive: false),
      'Farm Worker': RegExp(r'farm|khet|kisan|khet', caseSensitive: false),
    };
    final tools = {
      'Trowel': RegExp(r'karni|trowel', caseSensitive: false),
      'Spirit level': RegExp(r'level', caseSensitive: false),
      'Brush & roller': RegExp(r'brush|roller', caseSensitive: false),
    };
    String? trade;
    trades.forEach((k, re) { if (trade == null && re.hasMatch(text)) trade = k; });
    final years = RegExp(r'(\d+)\s*(saal|sal|year|years)', caseSensitive: false).firstMatch(text)?.group(1);
    final jobs = RegExp(r'(\d+)\s*(ghar|house|houses|jobs)', caseSensitive: false).firstMatch(text)?.group(1);
    final foundTools = tools.entries.where((e) => e.value.hasMatch(text)).map((e) => e.key).join(', ');

    setState(() {
      _result = {
        'Trade': trade ?? 'not detected',
        'Experience': years != null ? '$years years' : 'not detected',
        'Past work': jobs != null ? '$jobs jobs' : 'not detected',
        'Tools': foundTools.isEmpty ? 'none detected' : foundTools,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Voice Resume / Skill Analyzer', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 4,
            style: const TextStyle(color: KColors.text),
            decoration: InputDecoration(
              filled: true,
              fillColor: KColors.card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _analyze, child: const Text('Analyze transcript')),
          if (_result != null) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📇 Digital Skill Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    ..._result!.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text('${e.key}: ${e.value}'),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
