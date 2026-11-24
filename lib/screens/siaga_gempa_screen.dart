import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/panduan_siaga.dart';
import '../providers/siaga_provider.dart';
import '../widgets/app_chrome.dart';
import '../widgets/status_data.dart';

/// Siap siaga gempa: panduan Sebelum/Saat/Setelah, checklist tas siaga,
/// dan istilah gempa. Seluruh isi berasal dari sumber resmi (BMKG, BNPB);
/// setiap bagian menampilkan nama dan alamat sumbernya. Bersifat edukasi dan
/// bukan pengganti arahan resmi.
class SiagaGempaScreen extends StatelessWidget {
  const SiagaGempaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final siaga = context.watch<SiagaProvider>();
    final panduan = panduanSiaga(l);
    final tas = tasSiaga(l);
    final istilah = istilahGempa(l);
    final progres = l.tasProgres('${siaga.jumlahSelesai}', '${siaga.total}');

    return Scaffold(
      appBar: AppBar(title: Text(l.siagaJudul)),
      body: LatarAtmosfer(
        gelap: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            const MasukLembut(child: _SiagaHero()),
            const SizedBox(height: 12),
            for (final (i, bagian) in panduan.indexed)
              MasukLembut(
                delay: Duration(milliseconds: 70 + 50 * i),
                child: _Bagian(
                  key: ValueKey('siaga.${bagian.id}'),
                  judul: bagian.judul,
                  sumber: bagian.sumber,
                  anak: [
                    for (final k in bagian.kelompok) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Semantics(
                          header: true,
                          child: Text(
                            k.judul,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                      ),
                      for (final b in k.butir) _Butir(b),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 12),
            JudulBagian(
              l.tasSiagaJudul('${siaga.jumlahSelesai}', '${siaga.total}'),
            ),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(progres, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Semantics(
                      label: progres,
                      child: ExcludeSemantics(
                        child: LinearProgressIndicator(
                          value: siaga.progres,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    for (final item in tas)
                      CheckboxListTile(
                        key: ValueKey('tas.${item.id}'),
                        value: siaga.sudah(item.id),
                        onChanged: (_) => siaga.toggle(item.id),
                        title: Text(item.teks),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    const Divider(),
                    Text(
                      l.tasSumberCatatan,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const _BarisSumber(sumber: sumberBnpbTas),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _Bagian(
              key: const ValueKey('siaga.istilah'),
              judul: l.siagaIstilahJudul,
              sumber: sumberBmkgIstilah,
              anak: [
                for (final t in istilah) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 2),
                    child: Text(t.nama, style: theme.textTheme.titleSmall),
                  ),
                  Text(t.isi, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l.siagaTerjemahan,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(l.siagaCatatan, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              l.bukanResmi,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SiagaHero extends StatelessWidget {
  const _SiagaHero();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF2B1C78), Color(0xFF6651D7)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IkonDuo(IkonApp.siaga, color: Colors.white, size: 30),
          const SizedBox(height: 14),
          Text(
            l.siagaHeroJudul,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            l.siagaHeroKeterangan,
            style: const TextStyle(color: Color(0xFFF3F1FF)),
          ),
        ],
      ),
    );
  }
}

/// Satu bagian yang bisa dibuka-tutup, dengan baris sumber di bawahnya.
class _Bagian extends StatelessWidget {
  const _Bagian({
    super.key,
    required this.judul,
    required this.sumber,
    required this.anak,
  });

  final String judul;
  final SumberPanduan sumber;
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: ExpansionTile(
      title: Text(judul),
      shape: const Border(),
      collapsedShape: const Border(),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        ...anak,
        const SizedBox(height: 12),
        _BarisSumber(sumber: sumber),
      ],
    ),
  );
}

class _Butir extends StatelessWidget {
  const _Butir(this.teks);

  final String teks;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: IkonDuo(
            IkonApp.panduan,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(teks)),
      ],
    ),
  );
}

/// "Sumber: nama" + alamat. Alamat bisa diseleksi dan disalin (tanpa
/// membuka peramban, karena aplikasi tidak memakai paket tautan luar).
class _BarisSumber extends StatelessWidget {
  const _BarisSumber({required this.sumber});

  final SumberPanduan sumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.siagaSumber(sumber.nama),
          style: theme.textTheme.labelMedium,
        ),
        SelectableText(
          sumber.url,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
