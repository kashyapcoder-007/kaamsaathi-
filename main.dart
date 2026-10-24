import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/voice_home_screen.dart';
import 'screens/job_list_screen.dart';
import 'screens/skill_card_screen.dart';

// TODO after `flutterfire configure` generates firebase_options.dart:
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const KaamSaathiApp());
// }

void main() {
  runApp(const KaamSaathiApp());
}

class KaamSaathiApp extends StatelessWidget {
  const KaamSaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KaamSaathi',
      debugShowCheckedModeBanner: false,
      theme: kaamSaathiTheme(),
      home: const RootNav(),
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key});
  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  final _screens = const [
    VoiceHomeScreen(),
    JobListScreen(),
    SkillCardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: KColors.card,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.mic_none), label: 'Speak'),
          NavigationDestination(icon: Icon(Icons.work_outline), label: 'Jobs'),
          NavigationDestination(icon: Icon(Icons.badge_outlined), label: 'Skill Card'),
        ],
      ),
    );
  }
}
