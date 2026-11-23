import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../widgets/status_data.dart';

/// Panduan kesiapsiagaan gempa dan checklist tas siaga (tersimpan di
/// perangkat).
class SiagaGempaScreen extends StatefulWidget {
  const SiagaGempaScreen({super.key});

  @override
  State<SiagaGempaScreen> createState() => _SiagaGempaScreenState();
}

class _SiagaGempaScreenState extends State<SiagaGempaScreen> {
  static const _key = 'checklist_tas_siaga';

  /// Jumlah butir tas siaga. Indeks butir disimpan, jadi urutan teks di
  /// [_tas] tidak boleh diubah.
  static const _jumlahTas = 8;

  Set<int> _selesai = {};

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    final p = await SharedPreferences.getInstance();
    final tersimpan = (p.getStringList(_key) ?? []).map(int.parse).toSet();
    if (mounted) setState(() => _selesai = tersimpan);
  }

  Future<void> _toggle(int i) async {
    final next = {..._selesai};
    next.contains(i) ? next.remove(i) : next.add(i);
    setState(() => _selesai = next);
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_key, next.map((e) => '$e').toList());
  }

  static List<String> _tas(AppLocalizations l) => [
    l.tas1,
    l.tas2,
    l.tas3,
    l.tas4,
    l.tas5,
    l.tas6,
    l.tas7,
    l.tas8,
  ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final tas = _tas(l);
    assert(tas.length == _jumlahTas);

    return Scaffold(
      appBar: AppBar(title: Text(l.siagaJudul)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _Panduan(
            judul: l.siagaSebelum,
            butir: [l.siagaSebelum1, l.siagaSebelum2, l.siagaSebelum3],
            terbuka: true,
          ),
          const SizedBox(height: 8),
          _Panduan(
            judul: l.siagaSaat,
            butir: [l.siagaSaat1, l.siagaSaat2, l.siagaSaat3],
          ),
          const SizedBox(height: 8),
          _Panduan(
            judul: l.siagaSetelah,
            butir: [l.siagaSetelah1, l.siagaSetelah2, l.siagaSetelah3],
          ),
          const SizedBox(height: 8),
          JudulBagian(l.tasSiagaJudul('${_selesai.length}', '$_jumlahTas')),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < tas.length; i++) ...[
                  if (i > 0) const Divider(indent: 16, endIndent: 16),
                  CheckboxListTile(
                    value: _selesai.contains(i),
                    onChanged: (_) => _toggle(i),
                    title: Text(tas[i]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.siagaCatatan,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Panduan extends StatelessWidget {
  const _Panduan({
    required this.judul,
    required this.butir,
    this.terbuka = false,
  });

  final String judul;
  final List<String> butir;
  final bool terbuka;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: terbuka,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(judul, style: theme.textTheme.titleMedium),
        children: [
          for (final teks in butir)
            ListTile(
              leading: Icon(IkonApp.panduan, color: theme.colorScheme.primary),
              title: Text(teks),
            ),
        ],
      ),
    );
  }
}
