import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../models/lokasi.dart';
import '../providers/favorit_provider.dart';
import '../providers/pencarian_provider.dart';
import '../providers/weather_provider.dart';
import '../services/wilayah_service.dart';
import '../widgets/status_data.dart';
import '../widgets/tombol_favorit.dart';

/// Membuka layar pencarian wilayah.
Future<void> bukaPencarian(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider(
        create: (context) => PencarianProvider(context.read<WilayahService>()),
        child: const PencarianScreen(),
      ),
    ),
  );
}

class PencarianScreen extends StatelessWidget {
  const PencarianScreen({super.key});

  void _pilih(BuildContext context, Lokasi lokasi) {
    context.read<WeatherProvider>().pilihWilayah(lokasi);
    Navigator.of(context).pop();
  }

  void _pakaiGps(BuildContext context) {
    context.read<WeatherProvider>().pakaiLokasiGps();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cari = context.watch<PencarianProvider>();
    final terlaluPendek =
        cari.query.trim().length < WilayahConstants.minimalHurufCari;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: cari.ubahQuery,
          decoration: InputDecoration(
            hintText: context.l10n.cariHint,
            border: InputBorder.none,
          ),
        ),
      ),
      body: Column(
        children: [
          if (cari.status == StatusDataWilayah.memuat)
            const LinearProgressIndicator(),
          Expanded(
            child: switch (cari.status) {
              StatusDataWilayah.gagal => KosongData(
                pesan: context.l10n.gagalMemuatDataWilayah,
              ),
              StatusDataWilayah.memuat when !terlaluPendek => KosongData(
                pesan: context.l10n.memuatDataWilayah,
              ),
              _ when terlaluPendek => _Awal(
                onGps: () => _pakaiGps(context),
                onPilih: (l) => _pilih(context, l),
              ),
              _ when cari.hasil.isEmpty => KosongData(
                pesan: context.l10n.cariTidakAdaHasil,
              ),
              _ => ListView.builder(
                itemCount: cari.hasil.length,
                itemBuilder: (context, i) => _BarisWilayah(
                  lokasi: cari.hasil[i],
                  onTap: () => _pilih(context, cari.hasil[i]),
                ),
              ),
            },
          ),
        ],
      ),
    );
  }
}

/// Isi sebelum pengguna mengetik: tombol GPS dan daftar favorit.
class _Awal extends StatelessWidget {
  const _Awal({required this.onGps, required this.onPilih});

  final VoidCallback onGps;
  final ValueChanged<Lokasi> onPilih;

  @override
  Widget build(BuildContext context) {
    final favorit = context.watch<FavoritProvider>().daftar;
    final theme = Theme.of(context);

    return ListView(
      children: [
        ListTile(
          leading: const Icon(IkonApp.lokasiSaya),
          title: Text(context.l10n.gunakanLokasiSaya),
          onTap: onGps,
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(context.l10n.favorit, style: theme.textTheme.titleSmall),
        ),
        if (favorit.isEmpty)
          KosongData(pesan: context.l10n.belumAdaFavorit, rataTengah: false)
        else
          for (final l in favorit)
            _BarisWilayah(lokasi: l, onTap: () => onPilih(l)),
        KosongData(pesan: context.l10n.cariMinimal, rataTengah: false),
      ],
    );
  }
}

class _BarisWilayah extends StatelessWidget {
  const _BarisWilayah({required this.lokasi, required this.onTap});

  final Lokasi lokasi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final induk = [
      lokasi.kecamatan,
      lokasi.kotkab,
      lokasi.provinsi,
    ].where((s) => s.isNotEmpty).join(', ');

    return ListTile(
      leading: const Icon(IkonApp.tempat),
      title: Text(lokasi.desa),
      subtitle: Text(induk),
      trailing: TombolFavorit(lokasi: lokasi),
      onTap: onTap,
    );
  }
}
