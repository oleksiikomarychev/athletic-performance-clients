import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/config/api_config.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/responsive_container.dart';

class SettingsImportScreen extends StatefulWidget {
  const SettingsImportScreen({super.key});

  @override
  State<SettingsImportScreen> createState() => _SettingsImportScreenState();
}

class _SettingsImportScreenState extends State<SettingsImportScreen> {
  bool _importing = false;
  String? _selectedFileName;
  PlatformFile? _selectedFile;
  _ImportResult? _result;
  String? _error;

  Future<void> _pickFile() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      allowMultiple: false,
      withData: true,
    );
    final file = picked?.files.single;
    if (file == null) return;

    setState(() {
      _selectedFile = file;
      _selectedFileName = file.name;
      _result = null;
      _error = null;
    });
  }

  Future<void> _startImport() async {
    final file = _selectedFile;
    if (file == null) return;

    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      setState(() => _error = 'Failed to read file bytes');
      return;
    }

    setState(() {
      _importing = true;
      _error = null;
      _result = null;
    });

    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final response = await apiClient.postMultipart(
        ApiConfig.importHevyCsvEndpoint,
        bytes: bytes,
        fileField: 'file',
        filename: file.name,
        contentType: MediaType('text', 'csv'),
        context: 'SettingsImport.importHevy',
        timeout: const Duration(minutes: 5),
      );

      if (response is! Map<String, dynamic>) {
        throw Exception('Invalid response: expected JSON object');
      }

      final taskId = response['task_id'];
      if (taskId is! String || taskId.isEmpty) {
        throw Exception('Missing task_id in response');
      }

      if (!mounted) return;

      await _pollTask(apiClient, taskId);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _importing = false);
    }
  }

  Future<void> _pollTask(ApiClient apiClient, String taskId) async {
    const pollInterval = Duration(seconds: 2);
    final deadline = DateTime.now().add(const Duration(minutes: 60));

    while (DateTime.now().isBefore(deadline)) {
      final statusJson = await apiClient.get(
        ApiConfig.importHevyTaskStatusEndpoint(taskId),
        timeout: const Duration(seconds: 30),
        context: 'SettingsImport.importHevy.status',
      );

      if (statusJson is! Map<String, dynamic>) {
        throw Exception('Invalid task status response');
      }

      final status = (statusJson['status'] ?? '').toString().toUpperCase();
      if (status == 'SUCCESS') {
        final result = statusJson['result'];
        if (result is Map<String, dynamic>) {
          if (!mounted) return;
          setState(() {
            _result = _ImportResult(
              createdWorkouts: result['created_workouts'] ?? 0,
              totalInFile: result['total_in_file'] ?? 0,
              errors: (result['errors'] as List?)?.length ?? 0,
            );
          });
          return;
        }
        if (!mounted) return;
        setState(() {
          _result = const _ImportResult(
            createdWorkouts: 0,
            totalInFile: 0,
            errors: 0,
          );
        });
        return;
      }

      if (status == 'FAILURE') {
        final err = statusJson['error']?.toString() ?? 'Import failed';
        throw Exception(err);
      }

      await Future.delayed(pollInterval);
    }

    throw Exception('Import timed out (task did not finish in time)');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final dimensions = UiDimensions.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hairline =
        (isDark ? instrument.hairlineBorder : scheme.outlineVariant)
            .withValues(alpha: isDark ? 0.85 : 0.55);

    return AmbientScaffoldShell(
      appBar: const PrimaryAppBar.detail(title: 'Import workouts'),
      body: ResponsiveContainer(
        maxWidth: Breakpoints.maxContentWidthNarrow,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            dimensions.pagePadding,
            AmbientScaffoldShell.topContentInset(context),
            dimensions.pagePadding,
            MediaQuery.paddingOf(context).bottom + 28,
          ),
          children: [
            Container(
              decoration: InstrumentTheme.instrumentCardDecoration(
                context,
                accentColor: instrument.deloadAura,
                radius: 22,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.all(dimensions.cardPadding + 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.fitness_center_rounded,
                              size: 18,
                              color: instrument.deloadAura,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'CSV DATA PIPELINE',
                                style: InstrumentTheme.microLabel(
                                  context,
                                  color: instrument.deloadAura,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Hevy Workout Export',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Import workout history from a Hevy CSV export file. '
                          'Go to Hevy app → Settings → Export data to get the file.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 1, color: hairline),
                  Padding(
                    padding: EdgeInsets.all(dimensions.cardPadding + 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InstrumentActionButton(
                          label: _selectedFileName ?? 'Select CSV file',
                          icon: Icons.file_upload_outlined,
                          variant: InstrumentActionVariant.secondary,
                          expanded: true,
                          onPressed: _importing ? null : _pickFile,
                        ),
                        if (_selectedFile != null && _result == null) ...[
                          const SizedBox(height: 12),
                          InstrumentActionButton(
                            label: _importing ? 'Importing...' : 'Start import',
                            icon: Icons.cloud_upload_rounded,
                            variant: InstrumentActionVariant.primary,
                            accentColor: instrument.deloadAura,
                            loading: _importing,
                            expanded: true,
                            onPressed: _importing ? null : _startImport,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_importing) ...[
                    Container(height: 1, color: hairline),
                    Padding(
                      padding: EdgeInsets.all(dimensions.cardPadding + 2),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 4,
                              backgroundColor: hairline,
                              color: instrument.deloadAura,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'This may take a few minutes for large files...',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                decoration: InstrumentTheme.instrumentCardDecoration(
                  context,
                  accentColor: instrument.peakEffortColor,
                  radius: 20,
                ),
                padding: EdgeInsets.all(dimensions.cardPadding + 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: instrument.peakEffortColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: instrument.peakEffortColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 16),
              Container(
                decoration: InstrumentTheme.instrumentCardDecoration(
                  context,
                  accentColor: instrument.successColor,
                  radius: 20,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(dimensions.cardPadding + 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: instrument.successColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Import complete',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 1, color: hairline),
                    _ImportMetricRow(
                      label: 'Created workouts',
                      value: '${_result!.createdWorkouts}',
                      color: instrument.successColor,
                    ),
                    Container(height: 1, color: hairline),
                    _ImportMetricRow(
                      label: 'Total rows in file',
                      value: '${_result!.totalInFile}',
                    ),
                    if (_result!.errors > 0) ...[
                      Container(height: 1, color: hairline),
                      _ImportMetricRow(
                        label: 'Row errors',
                        value: '${_result!.errors}',
                        color: instrument.peakEffortColor,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImportMetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _ImportMetricRow({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: InstrumentTheme.tabular(
              (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
                fontWeight: FontWeight.w700,
                color: color ?? scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportResult {
  final int createdWorkouts;
  final int totalInFile;
  final int errors;

  const _ImportResult({
    required this.createdWorkouts,
    required this.totalInFile,
    required this.errors,
  });
}
