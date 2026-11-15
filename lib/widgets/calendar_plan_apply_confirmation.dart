import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/services/base_api_service.dart';
import 'package:workout_app/widgets/instrument_modal.dart';

/// A conflict prompts once; replacement is only submitted after confirmation.
/// Returning null means the user cancelled, or the screen was closed.
Future<T?> applyPlanWithConfirmation<T>(
  BuildContext context, {
  required Future<T> Function(bool replaceActive) submit,
}) async {
  try {
    return await submit(false);
  } on ApiException catch (error) {
    if (error.statusCode != 409) rethrow;
    if (!context.mounted) return null;

    final confirmed = await showInstrumentDialog<bool>(
      context: context,
      eyebrow: 'PLAN ACTIVATION',
      title: 'Заменить активный план?',
      message:
          'У вас уже есть активный план. Новый план заменит его. '
          'История завершённых тренировок сохранится.',
      accentColor: InstrumentTheme.of(context).stormAura,
      actionsBuilder: (dialogContext) => [
        InstrumentActionButton(
          label: 'Отмена',
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.of(dialogContext).pop(false),
        ),
        InstrumentActionButton(
          label: 'Заменить план',
          variant: InstrumentActionVariant.primary,
          accentColor: InstrumentTheme.of(dialogContext).stormAura,
          onPressed: () => Navigator.of(dialogContext).pop(true),
        ),
      ],
    );
    if (confirmed != true || !context.mounted) return null;
    return await submit(true);
  }
}
