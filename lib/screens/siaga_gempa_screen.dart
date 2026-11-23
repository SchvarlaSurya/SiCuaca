import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_chrome.dart';

class SiagaGempaScreen extends StatefulWidget {
  const SiagaGempaScreen({super.key});
  @override
  State<SiagaGempaScreen> createState() => _SiagaGempaScreenState();
}

class _SiagaGempaScreenState extends State<SiagaGempaScreen> {
  static const _key = 'checklist_tas_siaga';
  final _items = const [
    'Air minum',
    'Makanan tahan lama',
    'Senter dan baterai',
    'Kotak P3K dan obat pribadi',
    'Dokumen penting',
    'Peluit',
    'Masker',
    'Power bank',
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Siaga Gempa')),
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
              title: 'Sebelum gempa',
              items: const [
                'Kenali jalur evakuasi dan titik kumpul.',
                'Amankan benda berat agar tidak jatuh.',
                'Siapkan tas siaga dan simpan nomor darurat.',
              ],
            ),
          ),
          MasukLembut(
            delay: const Duration(milliseconds: 120),
            child: _Panduan(
              title: 'Saat gempa',
              items: const [
                'Merunduk, lindungi kepala, dan bertahan.',
                'Jauhi kaca, lemari, dan benda yang mudah jatuh.',
                'Jangan menggunakan lift.',
              ],
            ),
          ),
          MasukLembut(
            delay: const Duration(milliseconds: 170),
            child: _Panduan(
              title: 'Setelah gempa',
              items: const [
                'Keluar dengan tertib setelah guncangan berhenti.',
                'Periksa kondisi diri dan orang sekitar.',
                'Jika berada di pantai dan guncangan kuat, segera menuju tempat tinggi.',
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Checklist tas siaga (${_selesai.length}/${_items.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < _items.length; i++)
            CheckboxListTile(
              value: _selesai.contains(i),
              onChanged: (_) => _toggle(i),
              title: Text(_items[i]),
              contentPadding: EdgeInsets.zero,
            ),
          const SizedBox(height: 8),
          Text(
            'Panduan ini bersifat edukasi. Ikuti arahan resmi pemerintah dan BMKG saat keadaan darurat.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

class _SiagaHero extends StatelessWidget {
  const _SiagaHero();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(26),
      gradient: const LinearGradient(
        colors: [Color(0xFF2B1C78), Color(0xFF6651D7)],
      ),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 30),
        SizedBox(height: 14),
        Text(
          'Kesiapsiagaan dimulai sebelum terjadi gempa.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Pelajari langkah aman dan lengkapi tas siaga secara bertahap.',
          style: TextStyle(color: Color(0xFFE5E0FF)),
        ),
      ],
    ),
  );
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
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(item),
          ),
      ],
    ),
  );
}
