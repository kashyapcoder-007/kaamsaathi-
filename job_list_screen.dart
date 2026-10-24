import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/firestore_service.dart';
import '../services/speech_service.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});
  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final _db = FirestoreService();
  final _speech = SpeechService();
  final _trade = 'Mason'; // in a full build, read this from nav arguments

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<JobPosting>>(
      stream: _db.jobsForTrade(_trade),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final jobs = snap.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final j = jobs[i];
            final total = j.dailyWage * j.days;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(j.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: Text('₹${j.dailyWage}/day')),
                        Chip(label: Text('${j.days} days')),
                        Chip(
                          label: Text('Total ₹$total', style: const TextStyle(color: KColors.bg, fontWeight: FontWeight.bold)),
                          backgroundColor: KColors.teal,
                        ),
                        Chip(label: Text('${j.distanceKm} km')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _speech.speak(
                            '${j.title}. ${j.dailyWage} rupees per day for ${j.days} days, total $total rupees.',
                          ),
                          icon: const Icon(Icons.volume_up, size: 18),
                          label: const Text('Listen'),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () async {
                            await _db.applyToJob(j.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Application sent')),
                              );
                            }
                          },
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
