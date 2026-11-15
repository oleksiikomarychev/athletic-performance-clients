import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/services/api_client.dart';
import 'package:workout_app/services/macro_service.dart';

class MacroPreviewState {
  final bool loading;
  final Map<String, dynamic>? preview;
  final Map<String, dynamic>? applyResult;
  final String? error;
  const MacroPreviewState({
    this.loading = false,
    this.preview,
    this.applyResult,
    this.error,
  });
}

final macroPreviewServiceProvider = Provider<MacroService>(
  (ref) => MacroService(apiClient: ApiClient()),
);

class MacroPreviewNotifier extends StateNotifier<MacroPreviewState> {
  final MacroService service;
  MacroPreviewNotifier(this.service) : super(const MacroPreviewState());

  void show(Map<String, dynamic> preview) {
    state = MacroPreviewState(preview: preview);
  }

  Future<void> runPreview(
    int appliedPlanId, {
    int? observationWorkoutId,
    Map<String, dynamic>? legacyWeights,
  }) async {
    state = const MacroPreviewState(loading: true);
    try {
      final result = await service.runPreview(
        appliedPlanId: appliedPlanId,
        observationWorkoutId: observationWorkoutId,
        legacyWeights: legacyWeights,
      );
      if (mounted) show(result);
    } catch (e) {
      if (mounted) state = MacroPreviewState(error: e.toString());
    }
  }

  Future<void> apply(int appliedPlanId, {bool mesocyclesOnly = false}) async {
    final preview = state.preview;
    if (state.loading ||
        preview == null ||
        preview['applied_plan_id'] != appliedPlanId ||
        preview['contract_version'] != 2)
      return;
    final id = preview['preview_id'] as String?;
    if (!mesocyclesOnly && id == null) return;
    final previous = state.applyResult;
    state = MacroPreviewState(
      loading: true,
      preview: preview,
      applyResult: previous,
    );
    try {
      final result = await service.applyMacros(
        appliedPlanId: appliedPlanId,
        previewId: mesocyclesOnly ? null : id,
        mesocyclesOnly: mesocyclesOnly,
      );
      final combined = <String, dynamic>{...?previous};
      if (mesocyclesOnly) {
        combined['plan_changes'] = result['plan_changes'];
      } else {
        combined['apply_result'] = result['apply_result'];
      }
      if (mounted) {
        state = MacroPreviewState(preview: preview, applyResult: combined);
      }
    } catch (e) {
      if (mounted)
        state = MacroPreviewState(
          preview: preview,
          applyResult: previous,
          error: e.toString(),
        );
    }
  }
}

final macroPreviewNotifierProvider = StateNotifierProvider.autoDispose
    .family<MacroPreviewNotifier, MacroPreviewState, int>((ref, planId) {
      final svc = ref.watch(macroPreviewServiceProvider);
      return MacroPreviewNotifier(svc);
    });
