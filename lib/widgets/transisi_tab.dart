import 'package:flutter/material.dart';

/// Tumpukan tab yang tetap hidup (state dan posisi scroll tidak hilang),
/// dengan transisi saat pindah: tab baru memudar masuk sambil bergeser tipis
/// searah perpindahan, tab lama tetap penuh di bawahnya lalu dilepas.
///
/// Tab yang tidak terlihat dimatikan tickernya, jadi animasi masuk di tab itu
/// baru berjalan saat pertama kali dibuka. Tanpa gerak (pengaturan "kurangi
/// gerakan") perpindahan langsung.
class TransisiTab extends StatefulWidget {
  const TransisiTab({super.key, required this.indeks, required this.anak});

  final int indeks;
  final List<Widget> anak;

  @override
  State<TransisiTab> createState() => _TransisiTabState();
}

class _TransisiTabState extends State<TransisiTab>
    with SingleTickerProviderStateMixin {
  static const _durasi = Duration(milliseconds: 280);

  late final AnimationController _kontrol;
  late final Animation<double> _kurva;

  int? _sebelumnya;
  double _arah = 1;

  @override
  void initState() {
    super.initState();
    _kontrol = AnimationController(vsync: this, duration: _durasi, value: 1);
    _kurva = CurvedAnimation(parent: _kontrol, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(TransisiTab lama) {
    super.didUpdateWidget(lama);
    if (lama.indeks == widget.indeks) return;
    if (MediaQuery.of(context).disableAnimations) {
      _kontrol.value = 1;
      _sebelumnya = null;
      return;
    }
    _sebelumnya = lama.indeks;
    _arah = widget.indeks > lama.indeks ? 1 : -1;
    _kontrol.forward(from: 0).whenComplete(() {
      if (mounted && _kontrol.isCompleted) setState(() => _sebelumnya = null);
    });
  }

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  Widget _lapis(int i) {
    final aktif = i == widget.indeks;
    final keluar = i == _sebelumnya;
    final terlihat = aktif || keluar;
    final bergerak = _sebelumnya != null;

    // Rantai pembungkus selalu sama, apa pun keadaannya, supaya state anak
    // tidak hilang saat transisi mulai atau selesai.
    final Animation<double> opasitas = aktif && bergerak
        ? _kurva
        : const AlwaysStoppedAnimation<double>(1);
    // Tab baru bergeser masuk dari sisi perpindahan. Tab lama tetap penuh di
    // bawah dan hanya bergeser sedikit ke arah berlawanan, jadi tidak ada
    // kedipan latar di tengah transisi.
    final Animation<Offset> posisi = aktif && bergerak
        ? Tween<Offset>(
            begin: Offset(.06 * _arah, 0),
            end: Offset.zero,
          ).animate(_kurva)
        : keluar
        ? Tween<Offset>(
            begin: Offset.zero,
            end: Offset(-.04 * _arah, 0),
          ).animate(_kurva)
        : const AlwaysStoppedAnimation<Offset>(Offset.zero);

    return Offstage(
      key: ValueKey('tab.$i'),
      offstage: !terlihat,
      child: TickerMode(
        enabled: terlihat,
        child: IgnorePointer(
          ignoring: keluar,
          child: FadeTransition(
            opacity: opasitas,
            child: SlideTransition(position: posisi, child: widget.anak[i]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tab aktif digambar paling atas selama transisi.
    final urutan = [
      for (var i = 0; i < widget.anak.length; i++)
        if (i != widget.indeks) i,
      widget.indeks,
    ];
    return Stack(
      fit: StackFit.expand,
      children: [for (final i in urutan) _lapis(i)],
    );
  }
}
