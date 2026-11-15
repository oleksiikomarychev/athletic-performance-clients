import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/models/progression_template.dart';
import 'package:workout_app/services/progression_service.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/error_message.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

class ProgressionDetailScreen extends StatefulWidget {
  final int templateId;
  const ProgressionDetailScreen({super.key, required this.templateId});

  @override
  State<ProgressionDetailScreen> createState() =>
      _ProgressionDetailScreenState();
}

class _ProgressionDetailScreenState extends State<ProgressionDetailScreen> {
  late Future<ProgressionTemplate> _templateFuture;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTemplate();
  }

  Future<void> _loadTemplate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final service = Provider.of<ProgressionService>(context, listen: false);
      final template = await service.getTemplate(widget.templateId);
      if (mounted) {
        setState(() {
          _templateFuture = Future.value(template);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки шаблона: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = UiDimensions.of(context);
    return AssistantChatHost(
      contextBuilder: () async => {
        'screen': 'progression_detail',
        'entities': {'template_id': widget.templateId},
      },
      builder: (context, openChat) {
        return Scaffold(
          appBar: PrimaryAppBar(
            title: 'Детали шаблона',
            onTitleTap: openChat,
            showBack: true,
            actions: [
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  tooltip: 'Обновить',
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _loadTemplate,
                ),
              ),
            ],
          ),
          body: _buildBody(dimensions),
        );
      },
    );
  }

  Widget _buildBody(UiDimensions dimensions) {
    if (_isLoading) {
      return const LoadingIndicator();
    }
    if (_error != null) {
      return ErrorMessage(
        message: 'Ошибка: $_error',
        onRetry: _loadTemplate,
      );
    }

    return FutureBuilder<ProgressionTemplate>(
      future: _templateFuture,
      builder: (context, templateSnapshot) {
        if (templateSnapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }
        if (templateSnapshot.hasError) {
          return ErrorMessage(
            message: 'Ошибка: ${templateSnapshot.error}',
            onRetry: _loadTemplate,
          );
        }

        final template = templateSnapshot.data!;
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final instrument = InstrumentTheme.of(context);
        final rpeColor = instrument.colorForRpe(template.effort.toDouble(), colors);

        return SingleChildScrollView(
          padding: EdgeInsets.all(dimensions.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(dimensions.cardPadding),
                decoration: InstrumentTheme.cardDecoration(
                  context,
                  color: colors.surfaceContainerLow,
                  radius: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROGRESSION TEMPLATE',
                      style: InstrumentTheme.microLabel(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: dimensions.sectionGap),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: InstrumentTheme.cardDecoration(
                        context,
                        color: colors.surfaceContainerHighest.withValues(
                          alpha: 0.45,
                        ),
                        radius: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SpecTile(
                              label: 'INTENSITY',
                              value: '${template.intensity}%',
                            ),
                          ),
                          Expanded(
                            child: _SpecTile(
                              label: 'RPE',
                              value: '${template.effort}',
                              valueColor: rpeColor,
                            ),
                          ),
                          Expanded(
                            child: _SpecTile(
                              label: 'REPS',
                              value: template.volume?.toString() ?? '—',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (template.description != null &&
                  template.description!.isNotEmpty) ...[
                SizedBox(height: dimensions.sectionGap),
                Container(
                  padding: EdgeInsets.all(dimensions.cardPadding),
                  decoration: InstrumentTheme.cardDecoration(
                    context,
                    color: colors.surfaceContainerLow,
                    radius: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ОПИСАНИЕ',
                        style: InstrumentTheme.microLabel(context),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        template.description!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SpecTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SpecTile({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: InstrumentTheme.microLabel(context)),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: InstrumentTheme.tabular(
            (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
