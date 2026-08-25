import 'package:flutter/material.dart';

import '../../collections/presentation/pages/collection_tools_page.dart';

/// Обзор полностью использует инструменты коллекционера.
/// Все расчёты, достижения и локальные инструменты находятся на странице инструментов.
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CollectionToolsPage();
  }
}
