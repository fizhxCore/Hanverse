import 'package:flutter/material.dart';
import '../data/mock_dramas.dart';
import '../widgets/drama_card.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final comingSoon = mockDramas.where((d) => d.status == 'coming_soon').toList();
    final ongoing = mockDramas.where((d) => d.status == 'ongoing').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('HanVerse')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Coming Soon'),
          const SizedBox(height: 8),
          ...comingSoon.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DramaCard(
                  drama: d,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DetailScreen(drama: d)),
                  ),
                ),
              )),
          const SizedBox(height: 20),
          _SectionTitle('Sedang Tayang'),
          const SizedBox(height: 8),
          ...ongoing.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DramaCard(
                  drama: d,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DetailScreen(drama: d)),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700));
  }
}
