import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../widgets/app_chrome.dart';

/// Panduan kesiapsiagaan gempa dan checklist tas siaga (tersimpan di
/// perangkat).
class SiagaGempaScreen extends StatefulWidget {
  const SiagaGempaScreen({super.key});

  @override
  State<SiagaGempaScreen> createState() => _SiagaGempaScreenState();
}

class _SiagaGempaScreenState extends State<SiagaGempaScreen> {
  static const _key = 'checklist_tas_siaga';

  /// Indeks butir disimpan, jadi urutan teks tas siaga tidak boleh diubah.
  static List<String> _items(AppLocalizations l) => [
    l.tas1,
    l.tas2,
    l.tas3,
    l.tas4,
    l.tas5,
    l.tas6,
    l.tas7,
    l.tas8,
  ];

  Set<int> _selesai = {};

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) {
      setState(
        () => _selesai = (p.getStringList(_key) ?? []).map(int.parse).toSet(),
      );
    }
  }

  Future<void> _toggle(int i) async {
    final next = {..._selesai};
    next.contains(i) ? next.remove(i) : next.add(i);
    setState(() => _selesai = next);
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_key, next.map((e) => '$e').toList());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = _items(l);
    return Scaffold(
      appBar: AppBar(title: Text(l.siagaJudul)),
      body: LatarAtmosfer(
        gelap: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const MasukLembut(child: _SiagaHero()),
            const SizedBox(height: 12),
            MasukLembut(
              delay: const Duration(milliseconds: 70),
              child: _Panduan(
                title: l.siagaSebelum,
                items: [l.siagaSebelum1, l.siagaSebelum2, l.siagaSebelum3],
              ),
            ),
            MasukLembut(
              delay: const Duration(milliseconds: 120),
              child: _Panduan(
                title: l.siagaSaat,
                items: [l.siagaSaat1, l.siagaSaat2, l.siagaSaat3],
              ),
            ),
            MasukLembut(
              delay: const Duration(milliseconds: 170),
              child: _Panduan(
                title: l.siagaSetelah,
                items: [l.siagaSetelah1, l.siagaSetelah2, l.siagaSetelah3],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.tasSiagaJudul('${_selesai.length}', '${items.length}'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            for (var i = 0; i < items.length; i++)
              CheckboxListTile(
                value: _selesai.contains(i),
                onChanged: (_) => _toggle(i),
                title: Text(items[i]),
                contentPadding: EdgeInsets.zero,
              ),
            const SizedBox(height: 8),
            Text(l.siagaCatatan, style: Theme.of(context).textTheme.bodySmall),
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
          const Icon(IkonApp.siaga, color: Colors.white, size: 30),
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

class _Panduan extends StatelessWidget {
  const _Panduan({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) => Card(
    child: ExpansionTile(
      title: Text(title),
      children: [
        for (final item in items)
          ListTile(leading: const Icon(IkonApp.panduan), title: Text(item)),
      ],
    ),
  );
}
