import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../models/lokasi.dart';
import '../providers/favorit_provider.dart';
import 'tombol_kaca.dart';

class TombolFavorit extends StatelessWidget {
  const TombolFavorit({super.key, required this.lokasi});

  final Lokasi lokasi;

  @override
  Widget build(BuildContext context) {
    final favorit = context.watch<FavoritProvider>();
    final aktif = favorit.isFavorit(lokasi);
    return TombolKaca(
      tooltip: aktif ? context.l10n.hapusFavorit : context.l10n.tambahFavorit,
      aktif: aktif,
      onPressed: () => favorit.toggle(lokasi),
      icon: IkonDuo(aktif ? IkonApp.favorit : IkonApp.bukanFavorit),
    );
  }
}
