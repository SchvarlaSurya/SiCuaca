import 'package:flutter/material.dart';

import '../core/strings.dart';

/// Keterangan "Sumber: BMKG" di bawah setiap tampilan data.
class SumberBmkg extends StatelessWidget {
  const SumberBmkg({super.key, this.align = TextAlign.start});

  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      Str.sumberBmkg,
      textAlign: align,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
