import 'package:flutter/material.dart';
import 'package:flutter_demo/ui/demos/settings/settings_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final manager = SettingsManager();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: manager.appState,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            children: [
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(manager.currentThemeTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showThemeDialog,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showThemeDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose theme'),
        content: SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode),
              label: Text('Light'),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              icon: Icon(Icons.smartphone),
              label: Text('System'),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode),
              label: Text('Dark'),
            ),
          ],
          selected: {manager.currentTheme},
          onSelectionChanged: (selection) {
            manager.setTheme(selection.first);
            Navigator.of(dialogContext).pop();
          },
        ),
      ),
    );
  }
}
