import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workout_app/config/constants/legal_constants.dart';
import 'package:workout_app/config/constants/route_names.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/responsive_container.dart';

class SettingsLegalScreen extends StatefulWidget {
  final LegalDocumentType? initialDocument;
  final String? initialLanguageCode;

  const SettingsLegalScreen({
    super.key,
    this.initialDocument,
    this.initialLanguageCode,
  });

  @override
  State<SettingsLegalScreen> createState() => _SettingsLegalScreenState();
}

class _SettingsLegalScreenState extends State<SettingsLegalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedLanguageOverride;
  bool _didInitFromRoute = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguageOverride = widget.initialLanguageCode;
    final initialIndex = _indexForType(widget.initialDocument);
    _tabController = TabController(
      length: LegalDocumentType.values.length,
      vsync: this,
      initialIndex: initialIndex,
    )..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitFromRoute) {
      _didInitFromRoute = true;
      if (widget.initialDocument == null) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is LegalDocumentType) {
          _tabController.index = _indexForType(args);
        }
      }
    }
  }

  int _indexForType(LegalDocumentType? type) {
    switch (type) {
      case LegalDocumentType.privacy:
      case null:
        return 0;
      case LegalDocumentType.terms:
        return 1;
      case LegalDocumentType.healthDisclaimer:
        return 2;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _activeLang(BuildContext context) {
    if (_selectedLanguageOverride != null) {
      return _selectedLanguageOverride!;
    }
    final locale = Localizations.maybeLocaleOf(context);
    return LegalDocumentsRepository.resolveLanguageCode(locale);
  }

  String _screenTitle(String lang) {
    switch (lang) {
      case 'ru':
        return 'Правовая информация';
      case 'uk':
        return 'Правова інформація';
      default:
        return 'Legal & Privacy';
    }
  }

  String _placeholderBannerText(String lang) {
    switch (lang) {
      case 'ru':
        return 'Режим без чувствительных данных: реквизиты оператора/ИП и адрес вынесены в константы LegalConfig (legal_constants.dart) и заменены безопасными плейсхолдерами.';
      case 'uk':
        return 'Режим без чутливих даних: реквізити оператора/ФОП та адресу винесено в константи LegalConfig (legal_constants.dart) і замінено безпечними плейсхолдерами.';
      default:
        return 'Non-sensitive mode: legal entity/operator details and address are centralized in LegalConfig (legal_constants.dart) using safe placeholders.';
    }
  }

  String _copyTooltip(String lang) {
    switch (lang) {
      case 'ru':
        return 'Скопировать текст документа';
      case 'uk':
        return 'Скопіювати текст документа';
      default:
        return 'Copy document text';
    }
  }

  String _copiedSnackText(String lang) {
    switch (lang) {
      case 'ru':
        return 'Текст документа скопирован в буфер обмена';
      case 'uk':
        return 'Текст документа скопійовано до буфера обміну';
      default:
        return 'Document text copied to clipboard';
    }
  }

  String _plainTextForDocument(LegalDocumentData doc) {
    final buffer = StringBuffer();
    buffer.writeln('# ${doc.title}');
    buffer.writeln(doc.subtitle);
    buffer.writeln();
    buffer.writeln('## ${doc.tldrTitle}');
    for (final pt in doc.tldrPoints) {
      buffer.writeln('- $pt');
    }
    buffer.writeln();
    for (final s in doc.sections) {
      buffer.writeln('## ${s.number}. ${s.title}');
      for (final p in s.paragraphs) {
        buffer.writeln(p);
        buffer.writeln();
      }
      if (s.tableHeaders != null && s.tableRows != null) {
        buffer.writeln('| ${s.tableHeaders!.join(' | ')} |');
        buffer.writeln(
          '| ${List.filled(s.tableHeaders!.length, '---').join(' | ')} |',
        );
        for (final row in s.tableRows!) {
          final cells = [
            row.col1,
            row.col2,
            row.col3,
            if (row.col4 != null) row.col4!,
          ];
          buffer.writeln('| ${cells.join(' | ')} |');
        }
        buffer.writeln();
      }
      for (final b in s.bullets) {
        buffer.writeln('- $b');
      }
      if (s.bullets.isNotEmpty) {
        buffer.writeln();
      }
    }
    buffer.writeln('---');
    buffer.writeln(doc.footerNote);
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final lang = _activeLang(context);
    final docs = LegalDocumentsRepository.getAllDocuments(lang);
    final dims = UiDimensions.of(context);
    final theme = Theme.of(context);
    final instrument = InstrumentTheme.of(context);

    final tabIcons = const [
      Icons.shield_outlined,
      Icons.description_outlined,
      Icons.health_and_safety_outlined,
    ];

    return AmbientScaffoldShell(
      appBar: PrimaryAppBar.detail(
        title: _screenTitle(lang),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Language / Мова / Язык',
            initialValue: lang,
            onSelected: (value) {
              setState(() {
                _selectedLanguageOverride = value;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'ru', child: Text('Русский (RU)')),
              PopupMenuItem(value: 'uk', child: Text('Українська (UK)')),
              PopupMenuItem(value: 'en', child: Text('English (EN)')),
            ],
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Text(
                  lang.toUpperCase(),
                  style: InstrumentTheme.tabular(
                    (theme.textTheme.labelMedium ?? const TextStyle()).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: _copyTooltip(lang),
            icon: const Icon(Icons.copy_all_outlined),
            onPressed: () async {
              final currentDoc = docs[_tabController.index];
              await Clipboard.setData(
                ClipboardData(text: _plainTextForDocument(currentDoc)),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_copiedSnackText(lang))),
                );
              }
            },
          ),
        ],
      ),
      body: ResponsiveContainer(
        maxWidth: Breakpoints.maxContentWidthNarrow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AmbientScaffoldShell.topContentInset(context)),
            CanvasPillStrip(
              items: [
                for (int i = 0; i < docs.length; i++)
                  CanvasPillItem(
                    label: docs[i].shortTitle,
                    icon: tabIcons[i],
                    selected: _tabController.index == i,
                    accentColor: i == 2
                        ? instrument.stormAura
                        : instrument.workingAura,
                    onTap: () => _tabController.animateTo(i),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  for (final doc in docs)
                    _LegalDocumentBody(
                      document: doc,
                      languageCode: lang,
                      placeholderBannerText: _placeholderBannerText(lang),
                      dims: dims,
                      theme: theme,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalDocumentBody extends StatelessWidget {
  final LegalDocumentData document;
  final String languageCode;
  final String placeholderBannerText;
  final UiDimensions dims;
  final ThemeData theme;

  const _LegalDocumentBody({
    required this.document,
    required this.languageCode,
    required this.placeholderBannerText,
    required this.dims,
    required this.theme,
  });

  String _privacySettingsButtonLabel() {
    switch (languageCode) {
      case 'ru':
        return 'Управление профилем и удаление аккаунта (Настройки → Общие)';
      case 'uk':
        return 'Керування профілем і видалення акаунта (Налаштування → Загальні)';
      default:
        return 'Manage profile & account deletion (Settings → General)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hairline =
        (isDark ? instrument.hairlineBorder : colorScheme.outlineVariant)
            .withValues(alpha: isDark ? 0.85 : 0.55);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        dims.pagePadding,
        8,
        dims.pagePadding,
        MediaQuery.paddingOf(context).bottom + 28,
      ),
      children: [
        // Single-contour document title & TL;DR overview
        Container(
          decoration: InstrumentTheme.instrumentCardDecoration(
            context,
            accentColor: instrument.workingAura,
            radius: 22,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(dims.cardPadding + 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InstrumentStatusPill(
                      label:
                          'v${LegalConfig.policyVersion} · ${LegalConfig.lastUpdatedDate}',
                      color: instrument.workingAura,
                    ),
                    SizedBox(height: dims.rowGap),
                    Text(
                      document.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      document.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: hairline),
              Padding(
                padding: EdgeInsets.all(dims.cardPadding + 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bolt_outlined,
                          size: 18,
                          color: instrument.workingAura,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            document.tldrTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: instrument.workingAura,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: dims.rowGap),
                    for (final point in document.tldrPoints)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: instrument.workingAura,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SelectableText(
                                point,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (LegalConfig.hasPlaceholders) ...[
          SizedBox(height: dims.rowGap + 2),
          Container(
            padding: EdgeInsets.all(dims.cardPadding),
            decoration: InstrumentTheme.instrumentCardDecoration(
              context,
              accentColor: instrument.moderateEffortColor,
              radius: 18,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: instrument.moderateEffortColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    placeholderBannerText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        SizedBox(height: dims.sectionGap),

        for (final section in document.sections) ...[
          _LegalSectionModule(section: section, dims: dims, theme: theme),
          SizedBox(height: dims.rowGap + 2),
        ],

        if (document.type == LegalDocumentType.privacy) ...[
          SizedBox(height: dims.rowGap),
          InstrumentActionButton(
            icon: Icons.manage_accounts_outlined,
            label: _privacySettingsButtonLabel(),
            variant: InstrumentActionVariant.secondary,
            expanded: true,
            onPressed: () {
              Navigator.of(context).pushNamed(RouteNames.settingsGeneral);
            },
          ),
          SizedBox(height: dims.sectionGap),
        ],

        Padding(
          padding: EdgeInsets.symmetric(vertical: dims.rowGap),
          child: SelectableText(
            document.footerNote,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _LegalSectionModule extends StatelessWidget {
  final LegalSectionData section;
  final UiDimensions dims;
  final ThemeData theme;

  const _LegalSectionModule({
    required this.section,
    required this.dims,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final instrument = InstrumentTheme.of(context);
    final isWarning = section.isHighlightedWarning;
    final sectionAccent = isWarning
        ? instrument.peakEffortColor
        : instrument.workingAura;

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        accentColor: isWarning ? instrument.peakEffortColor : null,
        radius: 20,
      ),
      padding: EdgeInsets.all(dims.cardPadding + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InstrumentStatusPill(
                label: section.number,
                color: sectionAccent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (section.paragraphs.isNotEmpty) ...[
            SizedBox(height: dims.rowGap),
            for (int i = 0; i < section.paragraphs.length; i++) ...[
              SelectableText(
                section.paragraphs[i],
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
              if (i < section.paragraphs.length - 1) const SizedBox(height: 8),
            ],
          ],
          if (section.tableHeaders != null && section.tableRows != null) ...[
            SizedBox(height: dims.rowGap + 2),
            _LegalStructuredTable(
              headers: section.tableHeaders!,
              rows: section.tableRows!,
              theme: theme,
            ),
          ],
          if (section.bullets.isNotEmpty) ...[
            SizedBox(height: dims.rowGap),
            for (final bullet in section.bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: sectionAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SelectableText(
                        bullet,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _LegalStructuredTable extends StatelessWidget {
  final List<String> headers;
  final List<LegalTableRowData> rows;
  final ThemeData theme;

  const _LegalStructuredTable({
    required this.headers,
    required this.rows,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hairline =
        (isDark ? instrument.hairlineBorder : colorScheme.outlineVariant)
            .withValues(alpha: isDark ? 0.85 : 0.55);

    return Column(
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          Container(height: 1, color: hairline),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rows[i].col1,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: instrument.workingAura,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rows[i].col2,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${headers.length > 2 ? "${headers[2]}: " : ""}${rows[i].col3}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
