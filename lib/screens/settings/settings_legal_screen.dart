import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workout_app/config/constants/legal_constants.dart';
import 'package:workout_app/config/constants/route_names.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
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
    );
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitle(lang)),
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
              PopupMenuItem(
                value: 'ru',
                child: Text('Русский (RU)'),
              ),
              PopupMenuItem(
                value: 'uk',
                child: Text('Українська (UK)'),
              ),
              PopupMenuItem(
                value: 'en',
                child: Text('English (EN)'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.translate, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      lang.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: [
            Tab(
              icon: const Icon(Icons.shield_outlined, size: 18),
              text: docs[0].shortTitle,
            ),
            Tab(
              icon: const Icon(Icons.description_outlined, size: 18),
              text: docs[1].shortTitle,
            ),
            Tab(
              icon: const Icon(Icons.health_and_safety_outlined, size: 18),
              text: docs[2].shortTitle,
            ),
          ],
        ),
      ),
      body: ResponsiveContainer(
        maxWidth: Breakpoints.maxContentWidthNarrow,
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

    return ListView(
      padding: EdgeInsets.all(dims.pagePadding),
      children: [
        // Document title & metadata card
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          child: Padding(
            padding: EdgeInsets.all(dims.cardPadding + 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'v${LegalConfig.policyVersion} · ${LegalConfig.lastUpdatedDate}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: dims.rowGap),
                Text(
                  document.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
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
        ),

        if (LegalConfig.hasPlaceholders) ...[
          SizedBox(height: dims.rowGap),
          Container(
            padding: EdgeInsets.all(dims.cardPadding),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.tertiary.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    placeholderBannerText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        SizedBox(height: dims.sectionGap),

        // TL;DR Layered Summary Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          color: colorScheme.primaryContainer.withValues(alpha: 0.22),
          child: Padding(
            padding: EdgeInsets.all(dims.cardPadding + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bolt_outlined,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        document.tldrTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
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
                          color: colorScheme.primary,
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
        ),

        SizedBox(height: dims.sectionGap),

        // Numbered sections
        for (final section in document.sections) ...[
          _LegalSectionCard(
            section: section,
            dims: dims,
            theme: theme,
          ),
          SizedBox(height: dims.rowGap + 2),
        ],

        // Quick jump to Settings -> General for privacy/account deletion
        if (document.type == LegalDocumentType.privacy) ...[
          SizedBox(height: dims.rowGap),
          OutlinedButton.icon(
            icon: const Icon(Icons.manage_accounts_outlined, size: 18),
            label: Text(_privacySettingsButtonLabel()),
            onPressed: () {
              Navigator.of(context).pushNamed(RouteNames.settingsGeneral);
            },
          ),
          SizedBox(height: dims.sectionGap),
        ],

        // Footer metadata
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

class _LegalSectionCard extends StatelessWidget {
  final LegalSectionData section;
  final UiDimensions dims;
  final ThemeData theme;

  const _LegalSectionCard({
    required this.section,
    required this.dims,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final isWarning = section.isHighlightedWarning;

    return Card(
      elevation: 0,
      color: isWarning
          ? colorScheme.errorContainer.withValues(alpha: 0.25)
          : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isWarning
              ? colorScheme.error.withValues(alpha: 0.4)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(dims.cardPadding + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isWarning
                        ? colorScheme.error
                        : colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    section.number,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isWarning
                          ? colorScheme.onError
                          : colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
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
                if (i < section.paragraphs.length - 1)
                  const SizedBox(height: 8),
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
                            color: colorScheme.primary,
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

    return Column(
      children: [
        for (final row in rows)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.col1,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  row.col2,
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
                        '${headers.length > 2 ? "${headers[2]}: " : ""}${row.col3}',
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
    );
  }
}
