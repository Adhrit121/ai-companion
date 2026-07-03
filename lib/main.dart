import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'services/db_service.dart';
import 'models/companion.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/memory_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/character_creator_screen.dart';
import 'screens/model_setup_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AiCompanionApp());
}

class AiCompanionApp extends StatelessWidget {
  const AiCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'AI Companion',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const RootGate(),
      ),
    );
  }
}

/// Decides what the user sees on launch: model download flow,
/// character creator (if no companion exists yet), or the main app shell.
class RootGate extends StatefulWidget {
  const RootGate({super.key});
  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  bool _loading = true;
  bool _needsModelSetup = false;
  List<Companion> _companions = [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final companions = await DbService.instance.getCompanions();
    setState(() {
      _companions = companions;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ModelSetupScreen(
      onReady: () {
        if (_companions.isEmpty) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => CharacterCreatorScreen(
              onDone: (companion) async {
                await DbService.instance.saveCompanion(companion);
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => AppShell(initialCompanion: companion)),
                  );
                }
              },
            ),
          ));
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => AppShell(initialCompanion: _companions.first)),
          );
        }
      },
    );
  }
}

/// Simple global-ish state: which companion is currently active.
class AppState extends ChangeNotifier {
  Companion? activeCompanion;

  void setActive(Companion c) {
    activeCompanion = c;
    notifyListeners();
  }
}

class AppShell extends StatefulWidget {
  final Companion initialCompanion;
  const AppShell({super.key, required this.initialCompanion});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().setActive(widget.initialCompanion);
    });
  }

  @override
  Widget build(BuildContext context) {
    final companion = context.watch<AppState>().activeCompanion ?? widget.initialCompanion;

    final screens = [
      HomeScreen(companion: companion),
      ChatScreen(companion: companion),
      const GalleryScreen(),
      MemoryScreen(companion: companion),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_index]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library_rounded), label: 'Gallery'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories_rounded), label: 'Memory'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
