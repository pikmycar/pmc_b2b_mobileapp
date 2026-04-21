import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_state.dart';
import '../models/settings_models.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Documents",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final docs = state.documents;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 80,
                    color: colorScheme.outlineVariant, // ✅ FIXED
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No documents found",
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant, // ✅ FIXED
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final doc = docs[index];
              return _buildDocumentCard(context, doc);
            },
          );
        },
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, DocumentModel doc) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),

        // ✅ FIXED shadow for dark mode
        boxShadow: theme.brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer, // ✅ FIXED
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: colorScheme.onPrimaryContainer, // ✅ FIXED
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildStatusBadge(context, doc.status),
                  ],
                ),
              ),

              IconButton(
                icon: Icon(
                  Icons.remove_red_eye_outlined,
                  color: colorScheme.onSurfaceVariant, // ✅ FIXED
                ),
                onPressed: () {},
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(
              color: colorScheme.outlineVariant, // ✅ FIXED
            ),
          ),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text("REPLACE DOCUMENT"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, DocumentStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    late Color color;
    late String text;
    late IconData icon;

    switch (status) {
      case DocumentStatus.verified:
        color = colorScheme.secondary;
        text = "Verified";
        icon = Icons.check_circle_rounded;
        break;

      case DocumentStatus.pending:
        color = colorScheme.tertiary; // ✅ FIXED (no hardcoded orange)
        text = "Pending Verification";
        icon = Icons.hourglass_top_rounded;
        break;

      case DocumentStatus.rejected:
        color = colorScheme.error;
        text = "Rejected";
        icon = Icons.error_rounded;
        break;

      case DocumentStatus.notUploaded:
        color = colorScheme.onSurfaceVariant; // ✅ FIXED
        text = "Not Uploaded";
        icon = Icons.cloud_upload_outlined;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}