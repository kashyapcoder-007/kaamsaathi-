// After `flutterfire configure`, uncomment this import and the Firestore
// calls below. Left commented so this file compiles even before Firebase
// is wired up.
//
// import 'package:cloud_firestore/cloud_firestore.dart';

class JobPosting {
  final String id;
  final String title;
  final String trade;
  final num dailyWage;
  final num days;
  final num distanceKm;

  JobPosting({
    required this.id,
    required this.title,
    required this.trade,
    required this.dailyWage,
    required this.days,
    required this.distanceKm,
  });

  // factory JobPosting.fromDoc(DocumentSnapshot doc) {
  //   final d = doc.data() as Map<String, dynamic>;
  //   return JobPosting(
  //     id: doc.id,
  //     title: d['title'] ?? '',
  //     trade: d['trade'] ?? '',
  //     dailyWage: d['dailyWage'] ?? 0,
  //     days: d['days'] ?? 0,
  //     distanceKm: d['distanceKm'] ?? 0,
  //   );
  // }
}

class FirestoreService {
  // final _db = FirebaseFirestore.instance;

  /// Replace this with a real Firestore query once connected:
  /// Stream<List<JobPosting>> jobsForTrade(String trade) {
  ///   return _db
  ///       .collection('jobs')
  ///       .where('trade', isEqualTo: trade)
  ///       .snapshots()
  ///       .map((snap) => snap.docs.map(JobPosting.fromDoc).toList());
  /// }
  Stream<List<JobPosting>> jobsForTrade(String trade) {
    // Placeholder data until Firestore is connected — mirrors the
    // HTML prototype's demo jobs so the UI has something to show.
    return Stream.value([
      JobPosting(id: '1', title: 'Wall plastering, Site A', trade: trade, dailyWage: 700, days: 3, distanceKm: 2),
      JobPosting(id: '2', title: 'Brick laying, new house', trade: trade, dailyWage: 750, days: 5, distanceKm: 4),
    ]);
  }

  Future<void> applyToJob(String jobId) async {
    // await _db.collection('applications').add({
    //   'jobId': jobId,
    //   'appliedAt': FieldValue.serverTimestamp(),
    // });
    print('Applied to job $jobId (stub — connect Firestore to persist)');
  }
}
