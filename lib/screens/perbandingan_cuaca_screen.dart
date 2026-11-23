import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../models/lokasi.dart';
import '../models/prakiraan.dart';
import '../providers/favorit_provider.dart';
import '../services/bmkg_repository.dart';
import '../services/preferences_service.dart';
import '../widgets/ikon_cuaca.dart';
import '../widgets/sumber_bmkg.dart';
import '../widgets/app_chrome.dart';

class PerbandinganCuacaScreen extends StatefulWidget {
  const PerbandinganCuacaScreen({super.key});

  @override
  State<PerbandinganCuacaScreen> createState() =>
      _PerbandinganCuacaScreenState();
}

class _PerbandinganCuacaScreenState extends State<PerbandinganCuacaScreen> {
  final Map<String, Future<_HasilWilayah>> _permintaan = {};

  Future<_HasilWilayah> _ambil(Lokasi lokasi) {
    final repo = context.read<BmkgRepository>();
    final prefs = context.read<PreferencesService>();
    return _permintaan.putIfAbsent(lokasi.adm4, () async {
      try {
        final favorit = await prefs.favorit();
        final hasil = await repo.prakiraan(
          lokasi.adm4,
          dipertahankan: {for (final f in favorit) f.adm4},
        );
        return _HasilWilayah(data: hasil, prakiraan: hasil.data, galat: null);
      } catch (e) {
        return _HasilWilayah(data: null, prakiraan: null, galat: e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final semua = context.watch<FavoritProvider>().daftar;
    final dipilih = semua.take(3).toList();
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.bandingkanJudul)),
      body: LatarAtmosfer(
        gelap: false,
        child: dipilih.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.belumAdaFavorit,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(context.l10n.cariWilayah),
                      ),
                    ],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    context.l10n.bandingkanKeterangan('${dipilih.length}'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  for (var index = 0; index < dipilih.length; index++)
                    MasukLembut(
                      delay: Duration(milliseconds: 80 * index),
                      child: FutureBuilder<_HasilWilayah>(
                        future: _ambil(dipilih[index]),
                        builder: (context, snapshot) {
                          final lokasi = dipilih[index];
                          if (!snapshot.hasData) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(lokasi.labelLengkap)),
                                  ],
                                ),
                              ),
                            );
                          }
                          final hasil = snapshot.data!;
                          final prakiraan = hasil.prakiraan;
                          final entri = prakiraan?.entriTerdekat(
                            DateTime.now(),
                          );
                          if (hasil.galat != null ||
                              prakiraan == null ||
                              entri == null) {
                            return Card(
                              child: ListTile(
                                title: Text(lokasi.labelLengkap),
                                subtitle: Text(
                                  hasil.galat != null
                                      ? context.l10n.pesanGalat(hasil.galat)
                                      : context.l10n.dataTidakTersedia,
                                ),
                                trailing: IconButton(
                                  tooltip: context.l10n.cobaLagi,
                                  icon: const Icon(IkonApp.muatUlang),
                                  onPressed: () => setState(
                                    () => _permintaan.remove(lokasi.adm4),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  IkonCuaca(
                                    deskripsi: entri.deskripsi,
                                    malam: entri.malam,
                                    size: 38,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lokasi.desa,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                        Text(
                                          lokasi.labelInduk,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                        Text(
                                          context.l10n.deskripsiCuaca(entri),
                                        ),
                                        if (hasil.data!.dariCache)
                                          Text(
                                            context.l10n.modeOffline,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    Format.suhu(entri.suhu),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  const SumberBmkg(),
                ],
              ),
      ),
    );
  }
}

class _HasilWilayah {
  const _HasilWilayah({
    required this.data,
    required this.prakiraan,
    required this.galat,
  });
  final DataBmkg<Prakiraan>? data;
  final Prakiraan? prakiraan;
  final Object? galat;
}
