import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../core/localization/app_localizations.dart';
import '../data/firestore_service.dart';

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final firestoreService = ref.watch(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('records_title')),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: FutureBuilder<List<String>>(
            future: firestoreService.getSolvedPlates(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Mandatory: Custom progress indicator (loading_animation_widget)
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LoadingAnimationWidget.staggeredDotsWave(
                        color: theme.colorScheme.primary,
                        size: 50,
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.translate('loading')),
                    ],
                  ),
                );
              }

              final plates = snapshot.data ?? [];
              if (plates.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: theme.disabledColor),
                      const SizedBox(height: 12),
                      Text(
                        l10n.translate('no_records'),
                        style: theme.textTheme.titleMedium?.copyWith(color: theme.disabledColor),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: plates.length,
                itemBuilder: (context, index) {
                  final plate = plates[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        'Placa: $plate',
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
