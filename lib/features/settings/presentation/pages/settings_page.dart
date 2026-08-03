import 'package:flutter/material.dart';

/// Экран настроек.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: const Center(
        child: Text(
          'Настройки приложения',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}