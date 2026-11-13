import 'package:flutter/material.dart';

import '../core/l10n.dart';

/// Keterangan "Sumber: BMKG" di bawah setiap tampilan data.
class SumberBmkg extends StatelessWidget {
  const SumberBmkg({super.key, this.align = TextAlign.start});

  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      context.l10n.sumberBmkg,
      textAlign: align,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
