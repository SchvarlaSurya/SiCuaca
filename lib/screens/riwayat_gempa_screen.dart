import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../models/gempa.dart';
import '../providers/gempa_provider.dart';
import '../providers/riwayat_gempa_provider.dart';
import '../widgets/ajak_lokasi.dart';
import '../widgets/app_chrome.dart';
import '../widgets/filter_gempa_sheet.dart';
import '../widgets/gempa_item.dart';
import '../widgets/status_data.dart';
import '../widgets/sumber_bmkg.dart';
import '../widgets/tombol_kaca.dart';

/// Riwayat gempa yang pernah dimuat atau diterima di perangkat ini.
///
/// Riwayat BUKAN catatan lengkap kejadian BMKG (BMKG hanya memberi daftar
/// pendek), jadi setiap angka diberi label "dari data yang tersimpan di
/// perangkat ini" beserta rentang tanggal data yang benar-benar ada.
class RiwayatGempaScreen extends StatefulWidget {
  const RiwayatGempaScreen({super.key});

  @override
  State<RiwayatGempaScreen> createState() => _RiwayatGempaScreenState();
}

class _RiwayatGempaScreenState extends State<RiwayatGempaScreen> {
  final TextEditingController _cari = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cari.text = context.read<RiwayatGempaProvider>().filter.kataKunci;
  }

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  Future<void> _bukaFilter(RiwayatGempaProvider p) async {
    final baru = await bukaFilterRiwayat(
      context,
      awal: p.filter,
      adaLokasi: p.adaLokasi,
      rentang: p.rentangData,
    );
    if (baru == null) return;
    // Kata kunci dikelola kolom cari, bukan lembar filter.
    p.aturFilter(baru.denganKataKunci(p.filter.kataKunci));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.watch<RiwayatGempaProvider>();
    final gempa = context.watch<GempaProvider>();
    final n = p.filter.jumlahSaringan;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.riwayatJudul),
        actions: [
          Builder(
            builder: (tombol) => TombolKaca(
              tooltip: l.rentangGrafik,
              icon: const IkonDuo(IkonApp.grafik),
              onPressed: () async {
                // Menu muncul tepat di bawah tombol kaca.
                final kotak = tombol.findRenderObject()! as RenderBox;
                final layar =
                    Navigator.of(tombol).overlay!.context.findRenderObject()!
                        as RenderBox;
                final kiriAtas = kotak.localToGlobal(
                  Offset(0, kotak.size.height),
                  ancestor: layar,
                );
                final v = await showMenu<String>(
                  context: tombol,
                  position: RelativeRect.fromRect(
                    kiriAtas & kotak.size,
                    Offset.zero & layar.size,
                  ),
                  items: [
                    PopupMenuItem(value: 'hari', child: Text(l.grafikPerHari)),
                    PopupMenuItem(
                      value: 'minggu',
                      child: Text(l.grafikPerMinggu),
                    ),
                  ],
                );
                if (v != null && context.mounted) _bukaGrafik(context, p, v);
              },
            ),
          ),
          Badge(
            isLabelVisible: n > 0,
            label: Text('$n'),
            offset: const Offset(-6, 6),
            child: TombolKaca(
              tooltip: n > 0 ? l.filterAktifJumlah('$n') : l.filterJudul,
              icon: const IkonDuo(IkonApp.saring),
              onPressed: () => _bukaFilter(p),
            ),
          ),
        ],
      ),
      body: LatarAtmosfer(
        gelap: false,
        child: RefreshIndicator(
          onRefresh: () => context.read<GempaProvider>().muatSemua(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              24 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              if (gempa.terbaru.dariCache) ...[
                BannerOffline(diperbarui: gempa.terbaru.diperbarui),
                const SizedBox(height: 12),
              ],
              ..._isi(context, p),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _isi(BuildContext context, RiwayatGempaProvider p) {
    final l = context.l10n;
    final theme = Theme.of(context);

    switch (p.status) {
      case StatusRiwayat.memuat:
        return [
          MemuatData(pesan: l.memuatGempa, bentuk: BentukKerangka.daftar),
        ];
      case StatusRiwayat.gagal:
        return [GagalMuat(pesan: l.riwayatGagalMuat, onCobaLagi: p.muat)];
      case StatusRiwayat.siap:
        break;
    }

    final kartuBias = _KartuBias(rentang: p.rentangData);
    if (p.jumlahTersimpan == 0) {
      return [
        kartuBias,
        const SizedBox(height: 8),
        KosongData(pesan: l.riwayatKosong),
        Text(
          l.riwayatKosongCatatan,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        const _Atribusi(),
      ];
    }

    final s = p.statistik;
    return [
      kartuBias,
      const SizedBox(height: 12),
      MasukLembut(
        child: TextField(
          controller: _cari,
          decoration: InputDecoration(
            prefixIcon: const IkonDuo(IkonApp.cari),
            hintText: l.cariWilayahGempa,
            suffixIcon: p.filter.kataKunci.isEmpty
                ? null
                : IconButton(
                    tooltip: l.hapusPencarian,
                    icon: const IkonDuo(IkonApp.hapus),
                    onPressed: () {
                      _cari.clear();
                      p.aturFilter(p.filter.denganKataKunci(''));
                    },
                  ),
            border: const OutlineInputBorder(),
          ),
          onChanged: (v) => p.aturFilter(p.filter.denganKataKunci(v)),
        ),
      ),
      if (p.filter.jumlahSaringan > 0) ...[
        const SizedBox(height: 8),
        _SaringanAktif(provider: p),
      ],
      const SizedBox(height: 16),
      Text(
        l.statLabelBias,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 8),
      KisiTile(
        children: [
          TileInfo(
            ikon: IkonApp.riwayat,
            label: l.statJumlahGempa,
            nilai: '${s.jumlah}',
          ),
          TileInfo(
            ikon: IkonApp.gempa,
            label: l.statTerbesar,
            nilai: s.terbesar == null
                ? Format.tandaKosong
                : 'M${s.terbesar!.magnitudo}',
          ),
          TileInfo(
            ikon: IkonApp.jarak,
            label: l.statTerdekat,
            nilai: !s.adaLokasi
                ? l.statLokasiTidakAda
                : s.jarakTerdekatKm == null
                ? Format.tandaKosong
                : l.jarakKm(Format.jarak(l, s.jarakTerdekatKm!)),
          ),
        ],
      ),
      if (!s.adaLokasi) ...[const SizedBox(height: 8), const AjakLokasi()],
      const SizedBox(height: 12),
      Text(
        l.riwayatDariTotal('${p.hasil.length}', '${p.jumlahTersimpan}'),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 8),
      if (p.hasil.isEmpty)
        KosongData(pesan: l.riwayatTidakCocok)
      else
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < p.hasil.length; i++) ...[
                if (i > 0) const Divider(indent: 92, endIndent: 16),
                GempaItem(gempa: p.hasil[i].gempa),
              ],
            ],
          ),
        ),
      const SizedBox(height: 16),
      const _Atribusi(),
    ];
  }

  void _bukaGrafik(BuildContext context, RiwayatGempaProvider p, String mode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GrafikGempaScreen(
          daftar: [for (final b in p.hasil) b.gempa],
          mingguan: mode == 'minggu',
          rentang: p.rentangData,
        ),
      ),
    );
  }
}

/// Label bias: dari mana angka-angka ini, dan rentang data yang ada.
class _KartuBias extends StatelessWidget {
  const _KartuBias({required this.rentang});

  final RentangData? rentang;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fmt = DateFormat('d MMM yyyy', l.localeName);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IkonDuo(IkonApp.info, color: scheme.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.riwayatBiasLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                if (rentang != null)
                  Text(
                    l.riwayatRentangData(
                      fmt.format(rentang!.tertua),
                      fmt.format(rentang!.terbaru),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  l.riwayatBiasCatatan,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip saringan yang sedang aktif, masing-masing bisa dilepas.
class _SaringanAktif extends StatelessWidget {
  const _SaringanAktif({required this.provider});

  final RiwayatGempaProvider provider;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final f = provider.filter;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (f.rentangTanggal)
          InputChip(
            label: Text(ringkasTanggal(l, f)),
            onDeleted: () => provider.aturFilter(f.tanpa(tanggal: true)),
          ),
        if (f.magnitudoMin != null)
          InputChip(
            label: Text(l.minimalMagnitudo(f.magnitudoMin!.toStringAsFixed(1))),
            onDeleted: () => provider.aturFilter(f.tanpa(magnitudo: true)),
          ),
        if (f.jarakMaksKm != null)
          InputChip(
            label: Text(l.filterJarakKm(f.jarakMaksKm!.toStringAsFixed(0))),
            onDeleted: () => provider.aturFilter(f.tanpa(jarak: true)),
          ),
        TextButton(
          onPressed: provider.setelUlangFilter,
          child: Text(l.filterSetelUlang),
        ),
      ],
    );
  }
}

class _Atribusi extends StatelessWidget {
  const _Atribusi();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SumberBmkg(),
        Text(
          context.l10n.bukanResmi,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class GrafikGempaScreen extends StatelessWidget {
  const GrafikGempaScreen({
    super.key,
    required this.daftar,
    required this.mingguan,
    this.rentang,
  });

  final List<Gempa> daftar;
  final bool mingguan;
  final RentangData? rentang;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final now = DateTime.now();
    final bins = List<int>.filled(mingguan ? 5 : 7, 0);
    for (final gempa in daftar) {
      final waktu = gempa.waktuUtc?.toLocal();
      if (waktu == null) continue;
      final days = DateTime(
        now.year,
        now.month,
        now.day,
      ).difference(DateTime(waktu.year, waktu.month, waktu.day)).inDays;
      if (days < 0) continue;
      if (mingguan) {
        final index = days ~/ 7;
        if (index < bins.length) bins[bins.length - 1 - index]++;
      } else if (days < bins.length) {
        bins[bins.length - 1 - days]++;
      }
    }
    final maxValue = bins.fold<int>(0, (a, b) => a > b ? a : b);
    final fmt = DateFormat('d MMM yyyy', l.localeName);
    return Scaffold(
      appBar: AppBar(title: Text(mingguan ? l.gempaPerMinggu : l.gempaPerHari)),
      body: LatarAtmosfer(
        gelap: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l.statLabelBias,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (rentang != null)
              Text(
                l.riwayatRentangData(
                  fmt.format(rentang!.tertua),
                  fmt.format(rentang!.terbaru),
                ),
              ),
            const SizedBox(height: 4),
            Text(l.grafikCatatan),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (var i = 0; i < bins.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 72,
                              child: Text(
                                mingguan
                                    ? l.mingguKe('${bins.length - i}')
                                    : DateFormat('dd/MM', l.localeName).format(
                                        DateTime(
                                          now.year,
                                          now.month,
                                          now.day,
                                        ).subtract(
                                          Duration(days: bins.length - 1 - i),
                                        ),
                                      ),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                            Expanded(
                              child: Semantics(
                                label: l.jumlahKejadian(bins[i]),
                                child: LinearProgressIndicator(
                                  value: maxValue == 0 ? 0 : bins[i] / maxValue,
                                  minHeight: 18,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 36,
                              child: Text(
                                '${bins[i]}',
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(l.totalGrafik(bins.fold<int>(0, (a, b) => a + b))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _Atribusi(),
          ],
        ),
      ),
    );
  }
}
