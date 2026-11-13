import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';
import 'hero_cuaca.dart';
import 'status_cuaca_view.dart';
import 'status_data.dart';
import 'sumber_bmkg.dart';
import 'tombol_favorit.dart';

/// Bagian cuaca di Beranda: kartu hero pada jam prakiraan terdekat dengan
/// sekarang, tile kelembapan/angin, dan sumber data.
class CuacaSaatIniCard extends StatelessWidget {
  const CuacaSaatIniCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cuaca = context.watch<WeatherProvider>();
    final prakiraan = cuaca.prakiraan;
    final wilayah = cuaca.wilayah;
    final entri = prakiraan?.entriTerdekat(DateTime.now());

    if (cuaca.status != StatusCuaca.berhasil ||
        prakiraan == null ||
        wilayah == null) {
      return const Card(
        child: Padding(padding: EdgeInsets.all(16), child: StatusCuacaView()),
      );
    }
    if (entri == null || !prakiraanCocok(prakiraan, wilayah)) {
      return const Card(
        child: Padding(padding: EdgeInsets.all(16), child: DataTidakTersedia()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroCuaca(
          wilayah: wilayah,
          entri: entri,
          selisihZona: prakiraan.selisihZona,
          aksi: TombolFavorit(lokasi: wilayah),
        ),
        const SizedBox(height: 8),
        KisiTile(children: tileCuaca(context, entri)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: LabelDiperbarui(waktu: cuaca.diperbarui)),
            const SumberBmkg(),
          ],
        ),
      ],
    );
  }
}
