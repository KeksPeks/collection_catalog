import 'package:flutter/material.dart';

/// Экран загрузок.
class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Загрузки'),
      ),
      body: const Center(
        child: Text(
          'Нет доступных загрузок',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}