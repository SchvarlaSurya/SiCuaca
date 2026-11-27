import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../core/detektor_lag.dart';
import '../core/l10n.dart';
import '../core/navigasi.dart';
import '../providers/pengaturan_provider.dart';
import 'pencet_lembut.dart';

/// Dialog tawaran mematikan efek kaca cair. Hasil: true = matikan,
/// false = tetap nyalakan.
Future<bool?> bukaTawaranKacaLag(BuildContext konteks) => showDialog<bool>(
  context: konteks,
  barrierDismissible: false,
  builder: (context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.kacaLagJudul),
      content: Text(l.kacaLagIsi),
      actions: [
        TextButton(
          key: const ValueKey('kacaLag.tetap'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l.kacaLagTetap),
        ),
        PencetLembut(
          child: FilledButton(
            key: const ValueKey('kacaLag.matikan'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.kacaLagMatikan),
          ),
        ),
      ],
    );
  },
);

/// Memantau kelancaran tampilan. Bila efek kaca cair menyala dan aplikasi
/// terus-menerus tersendat, menawarkan SEKALI untuk mematikannya (lihat
/// [DetektorLag]). Tidak menampilkan apa pun selain dialog tawaran itu.
///
/// Pemantauan hanya aktif di build rilis/profil: build debug memang lambat
/// dan akan selalu memicu tawaran. Pengguna yang menolak tidak ditawari lagi.
class PantauLagKaca extends StatefulWidget {
  const PantauLagKaca({
    super.key,
    required this.child,
    this.aktif = !kDebugMode,
    this.jedaAwal = const Duration(seconds: 8),
    this.sumberFrame,
    DetektorLag? detektor,
    // ignore: prefer_initializing_formals
  }) : _detektor = detektor;

  final Widget child;

  /// Mati = tidak memantau sama sekali.
  final bool aktif;

  /// Frame sesaat setelah aplikasi dibuka diabaikan: pemuatan shader dan
  /// animasi pembuka memang berat dan bukan cerminan kelancaran sehari-hari.
  final Duration jedaAwal;

  /// Pengganti sumber durasi frame (untuk pengujian). Bawaan: pewaktuan
  /// frame dari mesin Flutter.
  final Stream<Duration>? sumberFrame;

  final DetektorLag? _detektor;

  @override
  State<PantauLagKaca> createState() => _PantauLagKacaState();
}

class _PantauLagKacaState extends State<PantauLagKaca> {
  late final DetektorLag _detektor = widget._detektor ?? DetektorLag();
  late final DateTime _mulai = DateTime.now();
  StreamSubscription<Duration>? _langganan;
  bool _dialogTampil = false;

  @override
  void initState() {
    super.initState();
    if (!widget.aktif) return;
    final sumber = widget.sumberFrame;
    if (sumber != null) {
      _langganan = sumber.listen(_frame);
    } else {
      SchedulerBinding.instance.addTimingsCallback(_pewaktuan);
    }
  }

  @override
  void dispose() {
    _langganan?.cancel();
    if (widget.aktif && widget.sumberFrame == null) {
      SchedulerBinding.instance.removeTimingsCallback(_pewaktuan);
    }
    super.dispose();
  }

  void _pewaktuan(List<FrameTiming> daftar) {
    for (final f in daftar) {
      _frame(f.totalSpan);
    }
  }

  void _frame(Duration lama) {
    if (_dialogTampil || !mounted) return;
    final pengaturan = context.read<PengaturanProvider>();
    if (!pengaturan.kacaCair || pengaturan.tawaranKacaDijawab) {
      _detektor.ulang();
      return;
    }
    if (DateTime.now().difference(_mulai) < widget.jedaAwal) return;
    if (_detektor.catat(lama)) _tawarkan(pengaturan);
  }

  Future<void> _tawarkan(PengaturanProvider pengaturan) async {
    // Navigator ada DI BAWAH widget ini (di dalam MaterialApp), jadi dialog
    // dibuka lewat konteks navigator global.
    final konteks = Navigasi.navigatorKey.currentContext;
    if (konteks == null || !konteks.mounted) return;
    _dialogTampil = true;
    final matikan = await bukaTawaranKacaLag(konteks);
    _dialogTampil = false;
    _detektor.ulang();
    // Apa pun jawabannya, tidak ditanya lagi.
    await pengaturan.catatTawaranKacaDijawab();
    if (matikan == true) await pengaturan.aturKacaCair(false);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
