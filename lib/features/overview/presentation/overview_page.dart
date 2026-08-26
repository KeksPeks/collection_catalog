import 'package:flutter/material.dart';

import '../../collections/presentation/pages/collection_tools_page.dart';

/// Обзор — единая страница инструментов коллекционера.
///
/// Вся статистика, достижения, XP, поиск, сканирование, уведомления,
/// история и остаток коллекций находятся в одном месте и работают локально.
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) => const CollectionToolsPage();
}
