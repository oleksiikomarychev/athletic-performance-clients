import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';

class ConditionBuilder extends StatefulWidget {
  final Map<String, dynamic> initial;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final String? metric;
  const ConditionBuilder({
    super.key,
    required this.initial,
    required this.onChanged,
    this.metric,
  });

  @override
  State<ConditionBuilder> createState() => _ConditionBuilderState();
}

class _ConditionBuilderState extends State<ConditionBuilder> {
  String _op = '';
  String _value = '';
  String _rangeFrom = '';
  String _rangeTo = '';
  String _n = '';
  String _nSets = '';
  String _epsilonPercent = '';
  String _valuePercent = '';
  String _direction = '';
  String _relation = '';

  List<String> _allowedOpKeysForMetric(String? metric) {
    final m = (metric ?? '').trim();
    switch (m) {
      case 'Performance_Trend':
        return ['stagnates_for', 'deviates_from_avg'];
      case 'e1RM':
        return ['>', '<', '=', '!=', 'in_range', 'not_in_range'];
      case 'RPE_Delta_From_Plan':
      case 'Reps_Delta_From_Plan':
        return [
          '>',
          '<',
          '=',
          '!=',
          'in_range',
          'not_in_range',
          'holds_for',
          'holds_for_sets',
        ];
      case 'Total_Reps':
      case 'Readiness_Score':
      case 'RPE_Session':
        return ['>', '<', '=', '!=', 'in_range', 'not_in_range', 'holds_for'];
      default:
        return ['>', '<', '=', '!=', 'in_range', 'not_in_range'];
    }
  }

  String _opLabel(String op, AppLocalizations l10n) {
    switch (op) {
      case '>':
        return l10n.macroConditionGreater;
      case '<':
        return l10n.macroConditionLess;
      case '=':
        return l10n.macroConditionEqual;
      case '!=':
        return l10n.macroConditionNotEqual;
      case 'in_range':
        return l10n.macroConditionInRange;
      case 'not_in_range':
        return l10n.macroConditionNotInRange;
      case 'stagnates_for':
        return l10n.macroConditionStagnates;
      case 'deviates_from_avg':
        return l10n.macroConditionDeviates;
      case 'holds_for':
        return l10n.macroConditionHoldsForWorkouts;
      case 'holds_for_sets':
        return l10n.macroConditionHoldsForSets;
      default:
        return op;
    }
  }

  List<DropdownMenuItem<String>> _opItems(
    List<String> keys,
    AppLocalizations l10n,
  ) {
    return keys
        .map(
          (k) => DropdownMenuItem<String>(
            value: k,
            child: Text(_opLabel(k, l10n)),
          ),
        )
        .toList(growable: false);
  }

  String _opHelp(String op, AppLocalizations l10n) {
    switch (op) {
      case '>':
      case '<':
      case '=':
      case '!=':
        return l10n.macroCondHelpCompare;
      case 'in_range':
        return l10n.macroCondHelpInRange;
      case 'not_in_range':
        return l10n.macroCondHelpOutOfRange;
      case 'stagnates_for':
        return l10n.macroCondHelpStagnates;
      case 'deviates_from_avg':
        return l10n.macroCondHelpDeviates;
      case 'holds_for':
        return l10n.macroCondHelpHoldsWorkouts;
      case 'holds_for_sets':
        return l10n.macroCondHelpHoldsSets;
      default:
        return '';
    }
  }

  String _metricOpHelp(String op, AppLocalizations l10n) {
    final m = (widget.metric ?? '').toString();
    if (m == 'Performance_Trend') {
      if (op == 'stagnates_for') {
        return l10n.macroCondNoteStagnates;
      }
      if (op == 'deviates_from_avg') {
        return l10n.macroCondNoteDeviates;
      }
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _op = (widget.initial['op'] ?? '').toString();
    if (widget.initial['value'] != null) {
      _value = widget.initial['value'].toString();
    }
    if (widget.initial['range'] is List &&
        (widget.initial['range'] as List).length >= 2) {
      _rangeFrom = (widget.initial['range'][0]).toString();
      _rangeTo = (widget.initial['range'][1]).toString();
    }
    if (widget.initial['values'] is List &&
        (widget.initial['values'] as List).length >= 2) {
      _rangeFrom = (widget.initial['values'][0]).toString();
      _rangeTo = (widget.initial['values'][1]).toString();
    }
    if (widget.initial['n'] != null) _n = widget.initial['n'].toString();
    if (widget.initial['n_sets'] != null) {
      _nSets = widget.initial['n_sets'].toString();
    }
    if (widget.initial['epsilon_percent'] != null) {
      _epsilonPercent = widget.initial['epsilon_percent'].toString();
    }
    if (widget.initial['value_percent'] != null) {
      _valuePercent = widget.initial['value_percent'].toString();
    }
    if (widget.initial['direction'] != null) {
      _direction = widget.initial['direction'].toString();
    }
    if (widget.initial['relation'] != null) {
      _relation = widget.initial['relation'].toString();
    }
  }

  @override
  void didUpdateWidget(covariant ConditionBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.metric != widget.metric) {
      final allowed = _allowedOpKeysForMetric(widget.metric);
      if (!allowed.contains(_op)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _op = '';
            _value = '';
            _rangeFrom = '';
            _rangeTo = '';
            _n = '';
            _nSets = '';
            _epsilonPercent = '';
            _valuePercent = '';
            _direction = '';
            _relation = '';
          });
          _emit();
        });
      }
    }
  }

  void _emit() {
    final map = <String, dynamic>{'op': _op};
    if (_op == 'in_range' || _op == 'not_in_range') {
      final a = double.tryParse(_rangeFrom);
      final b = double.tryParse(_rangeTo);
      if (a != null && b != null) map['range'] = [a, b];
    } else if (_op == 'holds_for') {
      if (_relation.isNotEmpty) map['relation'] = _relation;
      final isRangeRelation =
          _relation == 'in_range' || _relation == 'not_in_range';
      if (isRangeRelation) {
        final a = double.tryParse(_rangeFrom);
        final b = double.tryParse(_rangeTo);
        if (a != null && b != null) map['range'] = [a, b];
      } else if (_value.isNotEmpty) {
        final numVal = double.tryParse(_value);
        map['value'] = numVal ?? _value;
      }
      if (_n.isNotEmpty) map['n'] = int.tryParse(_n) ?? _n;
    } else if (_op == 'holds_for_sets') {
      if (_relation.isNotEmpty) map['relation'] = _relation;
      if (_value.isNotEmpty) {
        final numVal = double.tryParse(_value);
        map['value'] = numVal ?? _value;
      }
      if (_nSets.isNotEmpty) map['n_sets'] = int.tryParse(_nSets) ?? _nSets;
    } else {
      if (_value.isNotEmpty) {
        final numVal = double.tryParse(_value);
        map['value'] = numVal ?? _value;
      }
    }
    if (_op.startsWith('stagnates_for')) {
      if (_n.isNotEmpty) map['n'] = int.tryParse(_n) ?? _n;
      if (_epsilonPercent.isNotEmpty) {
        map['epsilon_percent'] =
            double.tryParse(_epsilonPercent) ?? _epsilonPercent;
      }
    }
    if (_op.startsWith('deviates_from_avg')) {
      if (_n.isNotEmpty) map['n'] = int.tryParse(_n) ?? _n;
      if (_valuePercent.isNotEmpty) {
        map['value_percent'] = double.tryParse(_valuePercent) ?? _valuePercent;
      }
      if (_direction.isNotEmpty) map['direction'] = _direction;
    }
    widget.onChanged(map);
  }

  Widget _buildRangeInputs(AppLocalizations l10n, TextStyle? tabularStyle) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fromField = TextFormField(
          initialValue: _rangeFrom,
          style: tabularStyle,
          decoration: InstrumentTheme.inputDecoration(
            context,
            labelText: l10n.macroConditionRangeFrom,
            hintText: l10n.macroConditionNumberHint,
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) {
            _rangeFrom = v;
            _emit();
          },
        );
        final toField = TextFormField(
          initialValue: _rangeTo,
          style: tabularStyle,
          decoration: InstrumentTheme.inputDecoration(
            context,
            labelText: l10n.macroConditionRangeTo,
            hintText: l10n.macroConditionNumberHint,
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) {
            _rangeTo = v;
            _emit();
          },
        );
        if (constraints.maxWidth < 260) {
          return Column(
            children: [
              fromField,
              const SizedBox(height: 10),
              toField,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: fromField),
            const SizedBox(width: 10),
            Expanded(child: toField),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tabularStyle = theme.textTheme.bodyLarge?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final allowedOps = _allowedOpKeysForMetric(widget.metric);
    final effectiveOp = allowedOps.contains(_op) ? _op : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: effectiveOp.isEmpty ? null : effectiveOp,
          isExpanded: true,
          items: _opItems(allowedOps, l10n),
          decoration: InstrumentTheme.inputDecoration(
            context,
            labelText: l10n.macroConditionOperatorLabel,
          ),
          onChanged: (v) {
            setState(() => _op = v ?? '');
            _emit();
          },
          validator: (v) => (v == null || v.isEmpty) ? l10n.fieldRequired : null,
        ),
        if (effectiveOp.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _opHelp(effectiveOp, l10n),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (_metricOpHelp(effectiveOp, l10n).isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _metricOpHelp(effectiveOp, l10n),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
        const SizedBox(height: 10),
        if (effectiveOp == 'in_range' || effectiveOp == 'not_in_range')
          _buildRangeInputs(l10n, tabularStyle)
        else if (effectiveOp == 'stagnates_for') ...[
          TextFormField(
            initialValue: _n,
            style: tabularStyle,
            decoration: InstrumentTheme.inputDecoration(
              context,
              labelText: l10n.macroConditionWindowCount,
              hintText: l10n.macroConditionWindowCountHint,
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              _n = v;
              _emit();
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _epsilonPercent,
            style: tabularStyle,
            decoration: InstrumentTheme.inputDecoration(
              context,
              labelText: l10n.macroConditionEpsilonPercent,
              hintText: '1.0',
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              _epsilonPercent = v;
              _emit();
            },
          ),
        ] else if (_op == 'deviates_from_avg') ...[
          TextFormField(
            initialValue: _n,
            style: tabularStyle,
            decoration: InstrumentTheme.inputDecoration(
              context,
              labelText: l10n.macroConditionWindowCount,
              hintText: l10n.macroConditionNumberHint,
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              _n = v;
              _emit();
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _valuePercent,
            style: tabularStyle,
            decoration: InstrumentTheme.inputDecoration(
              context,
              labelText: l10n.macroConditionValuePercent,
              hintText: '3.0',
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              _valuePercent = v;
              _emit();
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _direction.isEmpty ? null : _direction,
            isExpanded: true,
            items: [
              DropdownMenuItem(
                value: 'positive',
                child: Text(l10n.macroConditionPositive),
              ),
              DropdownMenuItem(
                value: 'negative',
                child: Text(l10n.macroConditionNegative),
              ),
            ],
            decoration: InstrumentTheme.inputDecoration(
              context,
              labelText: l10n.macroConditionDirection,
            ),
            onChanged: (v) {
              setState(() => _direction = v ?? '');
              _emit();
            },
          ),
        ] else if (_op == 'holds_for') ...[
          DropdownButtonFormField<String>(
            initialValue: _relation.isEmpty ? null : _relation,
            isExpanded: true,
            items: [
              DropdownMenuItem(
                value: '>=',
                child: Text(l10n.macroConditionGreaterEqual),
              ),
              DropdownMenuItem(
                value: '<=',
                child: Text(l10n.macroConditionLessEqual),
              ),
              DropdownMenuItem(
                value: '==',
                child: Text(l10n.macroConditionEqual),
              ),
              DropdownMenuItem(
                value: '!=',
                child: Text(l10n.macroConditionNotEqual),
              ),
              DropdownMenuItem(
                value: '>',
                child: Text(l10n.macroConditionGreater),
              ),
              DropdownMenuItem(
                value: '<',
                child: Text(l10n.macroConditionLess),
              ),
              DropdownMenuItem(
                value: 'in_range',
                child: Text(l10n.macroConditionInRange),
              ),
              DropdownMenuItem(
                value: 'not_in_range',
                child: Text(l10n.macroConditionNotInRange),
              ),
            ],
            decoration: InstrumentTheme.inputDecoration(
              context,
              labelText: l10n.macroConditionRelationLabel,
            ),
            onChanged: (v) {
              setState(() {
                _relation = v ?? '';
                if (_relation == 'in_range' || _relation == 'not_in_range') {
                  _value = '';
                }
              });
              _emit();
            },
          ),
          const SizedBox(height: 10),
          if (_relation == 'in_range' || _relation == 'not_in_range')
            _buildRangeInputs(l10n, tabularStyle)
          else
            TextFormField(
              initialValue: _value,
              style: tabularStyle,
              decoration: InstrumentTheme.inputDecoration(
                context,
                labelText: l10n.macroConditionValueLabel,
                hintText: '-2',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                _value = v;
                _emit();
              },
            ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _n,
            style: tabularStyle,
            decoration: InstrumentTheme.inputDecoration(
              context,
              labelText: l10n.macroConditionWorkoutCount,
              hintText: l10n.macroConditionWorkoutCountHint,
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              _n = v;
              _emit();
            },
          ),
        ] else if (_op == 'holds_for_sets') ...[
          DropdownButtonFormField<String>(
            initialValue: _relation.isEmpty ? null : _relation,
            isExpanded: true,
            items: [
              DropdownMenuItem(
                value: '>=',
                child: Text(l10n.macroConditionGreaterEqual),
              ),
              DropdownMenuItem(
                value: '<=',
                child: Text(l10n.macroConditionLessEqual),
              ),
              DropdownMenuItem(
                value: '==',
                child: Text(l10n.macroConditionEqual),
              ),
              DropdownMenuItem(
                value: '!=',
                child: Text(l10n.macroConditionNotEqual),
              ),
              DropdownMenuItem(
                value: '>',
                child: Text(l10n.macroConditionGreater),
              ),
              DropdownMenuItem(
                value: '<',
                child: Text(l10n.macroConditionLess),
              ),
            ],
            decoration: InstrumentTheme.inputDecoration(
              context,
              labelText: l10n.macroConditionRelationLabel,
            ),
            onChanged: (v) {
              setState(() => _relation = v ?? '');
              _emit();
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _value,
            style: tabularStyle,
            decoration: InstrumentTheme.inputDecoration(
              context,
              labelText: l10n.macroConditionValueLabel,
              hintText: l10n.macroConditionDeltaHint,
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              _value = v;
              _emit();
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _nSets,
            style: tabularStyle,
            decoration: InstrumentTheme.inputDecoration(
              context,
              labelText: l10n.macroConditionSetCount,
              hintText: l10n.macroConditionSetCountHint,
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              _nSets = v;
              _emit();
            },
          ),
        ] else ...[
          TextFormField(
            initialValue: _value,
            style: tabularStyle,
            decoration: InstrumentTheme.inputDecoration(
              context,
              labelText: l10n.macroConditionValueLabel,
              hintText: l10n.macroConditionNumberHint,
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              _value = v;
              _emit();
            },
          ),
        ],
      ],
    );
  }
}
