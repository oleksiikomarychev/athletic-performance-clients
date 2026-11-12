import 'package:flutter/material.dart';
import 'package:workout_app/services/base_api_service.dart';

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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Заменить активный план?'),
        content: const Text(
          'У вас уже есть активный план. Новый план заменит его. '
          'История завершённых тренировок сохранится.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Заменить план'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return null;
    return await submit(true);
  }
}
