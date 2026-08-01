import 'package:flutter/material.dart';
import '../models/drama.dart';

class PosterCard extends StatelessWidget {
  final Drama drama;
  final VoidCallback onTap;

  const PosterCard({super.key, required this.drama, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 168,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: drama.posterUrl.isEmpty
                  ? Icon(Icons.movie_outlined, color: scheme.onPrimaryContainer, size: 32)
                  : Image.network(
                      drama.posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.movie_outlined,
                          color: scheme.onPrimaryContainer, size: 32),
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              drama.judul,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
