import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/strings.dart';
import '../models/lokasi.dart';
import '../providers/favorit_provider.dart';

class TombolFavorit extends StatelessWidget {
  const TombolFavorit({super.key, required this.lokasi});

  final Lokasi lokasi;

  @override
  Widget build(BuildContext context) {
    final favorit = context.watch<FavoritProvider>();
    final aktif = favorit.isFavorit(lokasi);
    return IconButton(
      tooltip: aktif ? Str.hapusFavorit : Str.tambahFavorit,
      isSelected: aktif,
      onPressed: () => favorit.toggle(lokasi),
      icon: const Icon(Icons.star_border),
      selectedIcon: Icon(
        Icons.star,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
