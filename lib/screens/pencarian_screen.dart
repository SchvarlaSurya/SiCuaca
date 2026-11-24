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
import '../widgets/app_chrome.dart';
import 'pilih_wilayah_screen.dart';

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
      body: LatarAtmosfer(
        gelap: false,
        child: Column(
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
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        MasukLembut(
          child: Card(
            child: ListTile(
              leading: const IkonDuo(IkonApp.lokasiSaya),
              title: Text(context.l10n.gunakanLokasiSaya),
              onTap: onGps,
            ),
          ),
        ),
        const SizedBox(height: 8),
        MasukLembut(
          delay: const Duration(milliseconds: 70),
          child: Card(
            child: ListTile(
              leading: const IkonDuo(IkonApp.daftarWilayah),
              title: Text(context.l10n.pilihDariDaftar),
              subtitle: Text(context.l10n.pilihDariDaftarKeterangan),
              trailing: const IkonDuo(IkonApp.selengkapnya),
              onTap: () async {
                final lokasi = await bukaPilihWilayah(context);
                if (lokasi != null) onPilih(lokasi);
              },
            ),
          ),
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
            Card(
              child: _BarisWilayah(lokasi: l, onTap: () => onPilih(l)),
            ),
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
      leading: const IkonDuo(IkonApp.tempat),
      title: Text(lokasi.desa),
      subtitle: Text(induk),
      trailing: TombolFavorit(lokasi: lokasi),
      onTap: onTap,
    );
  }
}
