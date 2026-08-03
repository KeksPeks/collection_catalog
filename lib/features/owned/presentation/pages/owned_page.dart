import 'package:flutter/material.dart';

/// Экран коллекции пользователя.
class OwnedPage extends StatelessWidget {
  const OwnedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Моя коллекция'),
      ),
      body: const Center(
        child: Text(
          'Коллекция пока пуста',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}