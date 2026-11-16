// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Workout App';

  @override
  String get missingAthleteId => 'Missing athleteId';

  @override
  String get missingChatArguments => 'Missing chat arguments';

  @override
  String get fieldRequired => 'Required';

  @override
  String get exerciseName => 'Exercise name';

  @override
  String get exerciseListEmptyNameError => 'Please enter an exercise name';

  @override
  String activePlanLoadError(Object error) {
    return 'Failed to load plan: $error';
  }

  @override
  String get activePlanNoWorkoutsOnDay => 'No workouts on this day';

  @override
  String get activePlanNotesLabel => 'Notes';

  @override
  String get coachAthletePlanNoActivePlan => 'No active plan';

  @override
  String get coachAthletePlanSetsLabel => 'Sets';

  @override
  String get coachAthletePlanMassEditExerciseHint => 'Enter note for exercises';

  @override
  String coachAthletePlanMassEditError(Object error) {
    return 'Mass edit error: $error';
  }

  @override
  String get search => 'Search...';

  @override
  String get done => 'Done';

  @override
  String get refresh => 'Refresh';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get apply => 'Apply';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get hide => 'Hide';

  @override
  String get noDate => 'no date';

  @override
  String idPrefix(Object id) {
    return 'ID: $id';
  }

  @override
  String get filter => 'Filter';

  @override
  String get changes => 'Changes';

  @override
  String statuses(Object statuses) {
    return 'Statuses: $statuses';
  }

  @override
  String exercises(Object exercises) {
    return 'Exercises: $exercises';
  }

  @override
  String workoutsAffected(Object count) {
    return 'Workouts affected: $count';
  }

  @override
  String workoutsShifted(Object count) {
    return 'Workouts shifted: $count';
  }

  @override
  String setsModified(Object count) {
    return 'Sets modified: $count';
  }

  @override
  String setsToBeModified(Object count) {
    return 'Sets to be modified: $count';
  }

  @override
  String shiftDays(Object sign, Object days) {
    return 'Shift: $sign$days d.';
  }

  @override
  String startingFrom(Object date) {
    return 'Starting from: $date';
  }

  @override
  String upToDate(Object date) {
    return 'Up to date (inclusive): $date';
  }

  @override
  String get onlyFutureWorkouts => 'Only future workouts';

  @override
  String dateNotEarlierThan(Object date) {
    return 'Date not earlier than $date';
  }

  @override
  String dateNotLaterThan(Object date) {
    return 'Date not later than $date';
  }

  @override
  String get clampNonNegative => 'Do not allow negative values';

  @override
  String replaceExerciseTo(Object name, Object id) {
    return 'Replace exercise to $name (ID $id)';
  }

  @override
  String renameExerciseTo(Object name) {
    return 'Rename exercise to \"$name\"';
  }

  @override
  String addNewExercises(Object count) {
    return 'Add new exercises: $count';
  }

  @override
  String setIntensity(Object value) {
    return 'Set intensity = $value';
  }

  @override
  String increaseIntensityBy(Object value) {
    return 'Increase intensity by $value';
  }

  @override
  String decreaseIntensityBy(Object value) {
    return 'Decrease intensity by $value';
  }

  @override
  String setVolume(Object value) {
    return 'Set reps = $value';
  }

  @override
  String increaseVolumeBy(Object value) {
    return 'Increase reps by $value';
  }

  @override
  String decreaseVolumeBy(Object value) {
    return 'Decrease reps by $value';
  }

  @override
  String setWeight(Object value) {
    return 'Set weight = $value kg';
  }

  @override
  String increaseWeightBy(Object value) {
    return 'Increase weight by $value kg';
  }

  @override
  String decreaseWeightBy(Object value) {
    return 'Decrease weight by $value kg';
  }

  @override
  String setEffort(Object value) {
    return 'Set RPE = $value';
  }

  @override
  String increaseEffortBy(Object value) {
    return 'Increase RPE by $value';
  }

  @override
  String decreaseEffortBy(Object value) {
    return 'Decrease RPE by $value';
  }

  @override
  String get massEditPreviewTitle => 'Active plan mass edit preview';

  @override
  String get massEditAppliedTitle => 'Active plan changes applied';

  @override
  String get scheduleShiftPreviewTitle => 'Active plan schedule shift preview';

  @override
  String get scheduleShiftTitle => 'Active plan schedule shift applied';

  @override
  String get shiftParameters => 'Shift parameters';

  @override
  String get modeChangeIntervals => 'Mode: change intervals between workouts';

  @override
  String get modeScheduleShift => 'Mode: schedule shift';

  @override
  String get macroActionByPercent => 'By Percent';

  @override
  String get macroActionToTarget => 'To Target (RPE)';

  @override
  String get macroActionByValue => 'By Value';

  @override
  String get macroActionByTemplate => 'By Template';

  @override
  String get macroActionByExisting => 'By Existing (ID)';

  @override
  String get macroActionCreateManual => 'Create Manually';

  @override
  String get macroActionHintPercent => 'percent, e.g. -5 or 2.5';

  @override
  String get macroActionHintReps => 'reps delta, e.g. +1 or -1';

  @override
  String get macroActionHintTargetRpe => 'target RPE, e.g. 8';

  @override
  String get macroActionHintSets => '±N sets, e.g. 1 or -2';

  @override
  String get macroActionHintGeneric => 'value';

  @override
  String get macroActionAdjustLoad => 'Adjust Load';

  @override
  String get macroActionAdjustReps => 'Adjust Reps';

  @override
  String get macroActionAdjustSets => 'Adjust Sets';

  @override
  String get macroActionInjectMesocycle => 'Inject Mesocycle';

  @override
  String get macroActionTypeLabel => 'Action Type';

  @override
  String get macroActionModeLabel => 'Mode';

  @override
  String get macroActionValueLabel => 'Value';

  @override
  String get macroActionNoTemplates => 'No mesocycle templates';

  @override
  String get macroActionTemplateLabel => 'Mesocycle Template';

  @override
  String macroActionLoadTemplatesError(Object error) {
    return 'Error loading templates: $error';
  }

  @override
  String macroActionMesoLabel(Object index) {
    return 'Mesocycle $index';
  }

  @override
  String get macroActionChooseMeso => 'Choose Mesocycle';

  @override
  String get macroActionOtherId => 'Other (enter ID)';

  @override
  String get macroActionExistingIdLabel => 'Existing mesocycle ID';

  @override
  String get macroActionEnterNumber => 'Enter a number';

  @override
  String get macroActionDurationWeeks => 'Duration (weeks)';

  @override
  String get macroActionDaysInMicro => 'Days in microcycle';

  @override
  String macroActionDayLabel(Object index, Object type) {
    return 'Day $index: $type';
  }

  @override
  String get macroActionRest => 'rest';

  @override
  String get macroActionWork => 'workout';

  @override
  String get macroActionFocusTags => 'Focus Tags';

  @override
  String get macroActionPlacement => 'Placement';

  @override
  String get macroActionAppendEnd => 'Append to end';

  @override
  String get macroActionInsertAfterWorkout => 'After workout';

  @override
  String get macroActionInsertAfterMeso => 'After mesocycle';

  @override
  String get macroActionSelectAnchorWorkout => 'Select anchor workout';

  @override
  String get macroActionPickWorkout => 'Pick workout';

  @override
  String get macroActionNotSelected => 'Not selected';

  @override
  String macroActionAfterAnchor(Object name) {
    return 'After: $name';
  }

  @override
  String get macroActionNoMesoInPlan => 'No mesocycles in plan';

  @override
  String get macroActionMesoIndexLabel => 'Mesocycle: ';

  @override
  String get macroActionConflicts => 'Conflicts';

  @override
  String get macroActionReplacePlanned => 'Replace planned';

  @override
  String get macroActionShiftForward => 'Shift forward';

  @override
  String get macroActionSkipConflict => 'Skip on conflict';

  @override
  String get macroActionTarget => 'Target';

  @override
  String get macroActionTargetHelp =>
      'If target is not specified — action applies to all exercises of selected workouts.';

  @override
  String get macroConditionGreater => 'greater >';

  @override
  String get macroConditionLess => 'less <';

  @override
  String get macroConditionEqual => 'equal =';

  @override
  String get macroConditionNotEqual => 'not equal ≠';

  @override
  String get macroConditionInRange => 'in range';

  @override
  String get macroConditionNotInRange => 'not in range';

  @override
  String get macroConditionStagnates => 'stagnation for N windows';

  @override
  String get macroConditionDeviates => 'deviation from average';

  @override
  String get macroConditionHoldsForWorkouts => 'holds for N workouts in a row';

  @override
  String get macroConditionHoldsForSets =>
      'holds for N sets in a row (within workout)';

  @override
  String get macroConditionOperatorLabel => 'Operator';

  @override
  String get macroConditionRangeFrom => 'from';

  @override
  String get macroConditionNumberHint => 'number';

  @override
  String get macroConditionRangeTo => 'to';

  @override
  String get macroConditionWindowCount => 'n (windows)';

  @override
  String get macroConditionWindowCountHint => 'integer, e.g. 5';

  @override
  String get macroConditionEpsilonPercent => 'epsilon_percent (threshold, %)';

  @override
  String get macroConditionValuePercent => 'value_percent (deviation, %)';

  @override
  String get macroConditionPositive => 'positive';

  @override
  String get macroConditionNegative => 'negative';

  @override
  String get macroConditionDirection => 'direction (optional)';

  @override
  String get macroConditionGreaterEqual => 'greater or equal ≥';

  @override
  String get macroConditionLessEqual => 'less or equal ≤';

  @override
  String get macroConditionRelationLabel => 'relation';

  @override
  String get macroConditionWorkoutCount => 'n (workouts)';

  @override
  String get macroConditionWorkoutCountHint => 'integer, e.g. 3';

  @override
  String get macroConditionDeltaHint => 'delta, e.g. -2 for reps';

  @override
  String get macroConditionSetCount => 'n (sets in a row)';

  @override
  String get macroConditionSetCountHint => 'integer, e.g. 12';

  @override
  String get macroConditionValueLabel => 'value';

  @override
  String get macroDurationNextNWorkouts => 'Next N workouts';

  @override
  String get macroDurationUntilLastWorkout => 'Until last workout';

  @override
  String get macroDurationUntilEndOfMeso => 'Until end of mesocycle';

  @override
  String get macroDurationUntilEndOfMicro => 'Until end of microcycle';

  @override
  String get macroDurationUntilWorkoutX => 'Until workout X';

  @override
  String get macroDurationScopeLabel => 'Scope';

  @override
  String get macroDurationCountLabel => 'Count';

  @override
  String get macroTargetBy => 'Target by:';

  @override
  String get macroTargetTags => 'Tags';

  @override
  String get macroTargetIds => 'IDs';

  @override
  String get macroTargetIdsLabel => 'exercise_ids (CSV)';

  @override
  String get macroTriggerChooseExercises => 'Choose exercises';

  @override
  String get macroTriggerMetricReadiness => 'Readiness (workout)';

  @override
  String get macroTriggerMetricRpeSession => 'Session RPE';

  @override
  String get macroTriggerMetricTotalReps => 'Total Reps';

  @override
  String get macroTriggerMetricE1rm => 'e1RM estimate';

  @override
  String get macroTriggerMetricPerformanceTrend => 'Performance Trend';

  @override
  String get macroTriggerMetricRpeDelta => 'RPE Delta from Plan';

  @override
  String get macroTriggerMetricRepsDelta => 'Reps Delta from Plan';

  @override
  String get macroTriggerMetricLabel => 'Trigger Metric';

  @override
  String get macroWorkoutPickerTitle => 'Choose workout';

  @override
  String get macroWorkoutPickerNoWorkouts => 'No workouts in active plan';

  @override
  String get macroWorkoutPickerNoWorkoutsOnDate => 'No workouts on this date';

  @override
  String get macroWorkoutPickerOrChooseFromList => 'Or choose from list';

  @override
  String get macroWorkoutPickerListButton => 'List';

  @override
  String get macroWorkoutPickerWorkoutsOnDate => 'Workouts on this date';

  @override
  String get macroWorkoutPickerOrSelectFromList => 'Or select from list';

  @override
  String get macroWorkoutPickerList => 'List';

  @override
  String analyticsPlanTitle(Object planName) {
    return 'Plan analytics $planName';
  }

  @override
  String get errorLoadingActivePlan => 'Failed to load active plan';

  @override
  String get selectTwoMetrics => 'Select two metrics';

  @override
  String get activePlanNotFound => 'Active plan not found';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get axisX => 'X axis';

  @override
  String get axisY => 'Y axis';

  @override
  String get showChart => 'Show chart';

  @override
  String get selectRangeAndMetrics => 'Select a range and metrics';

  @override
  String get noDataForSelectedMetrics => 'No data for selected metrics';

  @override
  String get metricVolumeKg => 'Volume (kg)';

  @override
  String get metricEffortRpe => 'Effort (RPE)';

  @override
  String get metricKpsh => 'KPSH';

  @override
  String get metricReps => 'Reps';

  @override
  String get metricOneRm => '1RM';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUkrainian => 'Ukrainian';

  @override
  String get accountTitle => 'Account';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get displayName => 'Display name';

  @override
  String get bio => 'Bio';

  @override
  String get bodyweightKg => 'Bodyweight (kg)';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get age => 'Age';

  @override
  String get trainingYears => 'Training years';

  @override
  String get publicProfile => 'Public profile';

  @override
  String get units => 'Units';

  @override
  String get unitsMetric => 'Metric';

  @override
  String get unitsImperial => 'Imperial';

  @override
  String get timezone => 'Timezone';

  @override
  String get notifications => 'Notifications';

  @override
  String get save => 'Save';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get failedToUpdateProfile => 'Failed to update profile';

  @override
  String get editProfileButton => 'Edit profile';

  @override
  String get coachingSettingsButton => 'Coaching settings';

  @override
  String get coachingTitle => 'Coaching';

  @override
  String get coachingAcceptingNewClients => 'Accepting new clients';

  @override
  String get coachingNotAccepting => 'Not accepting';

  @override
  String get coachingDisabled => 'Coaching disabled';

  @override
  String get coachingDisabledDescription =>
      'This user has not enabled coaching options.';

  @override
  String get coachingSpecializations => 'Specializations';

  @override
  String get coachingLanguages => 'Languages';

  @override
  String get coachingExperience => 'Experience';

  @override
  String get coachingTimezone => 'Timezone';

  @override
  String get coachingRate => 'Rate';

  @override
  String get coachingCustomRate => 'Custom rate';

  @override
  String get requestCoaching => 'Request coaching';

  @override
  String get statsTotalWorkouts => 'Total Workouts';

  @override
  String get statsVolumeKg => 'Volume (kg)';

  @override
  String get statsActiveDays => 'Active Days';

  @override
  String get activityTitle => 'Activity';

  @override
  String lastWeeks(Object weeks) {
    return 'Last $weeks weeks';
  }

  @override
  String maxKgPerDay(Object value) {
    return 'Max: $value kg/day';
  }

  @override
  String sessionsCount(Object count) {
    return '$count session(s)';
  }

  @override
  String get noActivity => 'No activity';

  @override
  String get less => 'Less';

  @override
  String get more => 'More';

  @override
  String get completedWorkoutsTitle => 'Completed Workouts';

  @override
  String get noCompletedWorkoutsYet => 'No completed workouts yet';

  @override
  String get exerciseFormTitleAdd => 'Add exercise';

  @override
  String get exerciseFormExerciseNameLabel => 'Exercise name';

  @override
  String get exerciseFormPleaseEnterName => 'Please enter a name';

  @override
  String get exerciseFormMuscleGroupLabel => 'Muscle group';

  @override
  String get exerciseFormLoading => 'Loading...';

  @override
  String get exerciseFormSelectGroup => 'Select group';

  @override
  String get exerciseFormLoadingGroups => 'Loading groups...';

  @override
  String get exerciseFormPleaseSelectMuscleGroup =>
      'Please select a muscle group';

  @override
  String get exerciseFormProgressionTemplateOptional =>
      'Progression template (optional)';

  @override
  String get exerciseFormSelectTemplate => 'Select template';

  @override
  String get exerciseFormNoTemplate => 'No template';

  @override
  String get exerciseFormSetsTitle => 'Sets';

  @override
  String get exerciseFormAddSet => 'Add set';

  @override
  String get exerciseFormSaveExercise => 'Save exercise';

  @override
  String get exerciseFormWeightKg => 'Weight (kg)';

  @override
  String get exerciseFormReps => 'Reps';

  @override
  String get exerciseFormRequired => 'Required';

  @override
  String exerciseFormFailedToLoadData(Object error) {
    return 'Failed to load data: $error';
  }

  @override
  String exerciseFormErrorSaving(Object error) {
    return 'Error saving: $error';
  }

  @override
  String get exerciseDefinitionIdRequired =>
      'Exercise definition id is required';

  @override
  String get exerciseFormDefaultReps => '5';

  @override
  String get exerciseFormDefaultWeight => '0';

  @override
  String get exerciseListTitle => 'Exercises';

  @override
  String get exerciseListAddExerciseTitle => 'Add exercise';

  @override
  String get exerciseListNameLabel => 'Name';

  @override
  String get exerciseListMuscleGroupLabel => 'Muscle group';

  @override
  String get exerciseListEquipmentLabel => 'Equipment';

  @override
  String get exerciseListLoading => 'Loading...';

  @override
  String get exerciseListSelectGroup => 'Select group';

  @override
  String get exerciseListLoadingGroups => 'Loading groups...';

  @override
  String get exerciseListSelectMuscleGroupValidator => 'Select a muscle group';

  @override
  String get exerciseListEnterExerciseName => 'Enter exercise name';

  @override
  String get exerciseListSelectMuscleGroupSnack => 'Select a muscle group';

  @override
  String exerciseListErrorLoadingMuscleGroups(Object error) {
    return 'Failed to load muscle groups: $error';
  }

  @override
  String exerciseListErrorGeneric(Object error) {
    return 'Error: $error';
  }

  @override
  String get exerciseListEmpty => 'No exercises. Add a new one!';

  @override
  String exerciseListMuscleGroupPrefix(Object value) {
    return 'Muscle group: $value';
  }

  @override
  String exerciseListEquipmentPrefix(Object value) {
    return 'Equipment: $value';
  }

  @override
  String get exerciseListDeleteExerciseTitle => 'Delete exercise?';

  @override
  String get exerciseListDeleteExerciseBody => 'This action cannot be undone.';

  @override
  String get exerciseListDelete => 'Delete';

  @override
  String exerciseListErrorDeleting(Object error) {
    return 'Failed to delete: $error';
  }

  @override
  String get userMaxTitle => 'Add max';

  @override
  String get userMaxExerciseLabel => 'Exercise';

  @override
  String get userMaxSelectExerciseValidator => 'Select an exercise';

  @override
  String get userMaxWeightKgLabel => 'Weight (kg)';

  @override
  String get userMaxWeightGtZeroValidator => 'Enter weight > 0';

  @override
  String get userMaxRepsLabel => 'Reps';

  @override
  String get userMaxRepsGtZeroValidator => 'Enter reps > 0';

  @override
  String get userMaxRepsMax12Validator => 'Maximum 12 reps';

  @override
  String get userMaxFillAllFieldsSnack =>
      'Fill all fields and select an exercise';

  @override
  String get userMaxSaving => 'Saving...';

  @override
  String get userMaxSave => 'Save max';

  @override
  String userMaxFailedToSave(Object error) {
    return 'Failed to save max: $error';
  }

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get planDraftMicrocycle => 'Microcycle';

  @override
  String get planDraftMesocycle => 'Mesocycle';

  @override
  String massEditToolWorkoutsMatched(Object count) {
    return 'Workouts matched: $count';
  }

  @override
  String massEditToolSetsModified(Object count) {
    return 'Sets modified: $count';
  }

  @override
  String massEditToolSetsToBeModified(Object count) {
    return 'Sets to be modified: $count';
  }

  @override
  String get workoutDetailMacrosChangesFoundTitle => 'Macro changes found';

  @override
  String workoutDetailMacrosChangesFoundBody(
    Object injectCount,
    Object hasPatches,
  ) {
    return 'Mesocycle injections: $injectCount\nWorkout patches: $hasPatches';
  }

  @override
  String get workoutDetailMacrosApplied => 'Macros applied';

  @override
  String workoutDetailFailedToApplyMacros(Object error) {
    return 'Failed to apply macros: $error';
  }

  @override
  String get workoutDetailFailedToRefreshWorkoutBeforeApplyingReadiness =>
      'Failed to refresh workout before applying readiness';

  @override
  String get workoutDetailWorkoutNotReadyMissingIds =>
      'Workout is not ready for set updates (missing ids)';

  @override
  String get workoutDetailIncreaseTooltip => 'Increase';

  @override
  String get workoutDetailSessionActive => 'Active session';

  @override
  String get workoutDetailSessionNone => 'No active session';

  @override
  String get workoutDetailSelectSetTypeTitle => 'Select set type';

  @override
  String get workoutDetailSetTypeNormal => 'Normal set';

  @override
  String get workoutDetailSetTypeDrop => 'Drop set';

  @override
  String get workoutDetailSetTypeCluster => 'Cluster set';

  @override
  String get workoutDetailSetTypeRestPause => 'Rest-pause set';

  @override
  String workoutDetailFailedToUpdateSetType(Object error) {
    return 'Failed to update set type: $error';
  }

  @override
  String get activePlanTitle => 'Active plan';

  @override
  String activePlanFailedToLoad(Object error) {
    return 'Failed to load active plan: $error';
  }

  @override
  String get activePlanNone => 'No active plan';

  @override
  String get activePlanAiMassEditTitle => 'AI mass edit (chat)';

  @override
  String get activePlanAiMassEditHint =>
      'For example: Increase RPE by 1 and add 1 set to all bench presses on Mondays';

  @override
  String get activePlanAiMassEditSend => 'Send';

  @override
  String activePlanAiMassEditStarted(Object taskId) {
    return 'AI mass edit started (task: $taskId)';
  }

  @override
  String activePlanAiMassEditFailedToSend(Object error) {
    return 'Failed to send AI mass edit command: $error';
  }

  @override
  String activePlanMassEditTitle(Object end, Object start) {
    return 'Mass edit (from $start to $end)';
  }

  @override
  String get activePlanRangeLabel => 'Range:';

  @override
  String get activePlanRangeFutureFromWeek => 'Future from week';

  @override
  String get activePlanRangeByMesoMicro => 'By meso/micro';

  @override
  String get activePlanIntensityLabel => 'Intensity %';

  @override
  String get activePlanRpeLabel => 'RPE';

  @override
  String get activePlanRepsLabel => 'Reps';

  @override
  String get activePlanModeSet => 'Set';

  @override
  String get activePlanModeOffset => 'Offset';

  @override
  String get activePlanModeScale => 'Scale';

  @override
  String get activePlanHintEg75 => 'e.g. 75';

  @override
  String get activePlanHintPercentOffset => '+/- % (e.g. -2)';

  @override
  String get activePlanHintFactor => '× factor (e.g. 1.05)';

  @override
  String get activePlanHintEg8 => 'e.g. 8';

  @override
  String get activePlanHintEg5 => 'e.g. 5';

  @override
  String get activePlanHintRepsOffset => '+/- reps (e.g. +1)';

  @override
  String get activePlanHintFactorReps => '× factor (e.g. 0.9)';

  @override
  String get activePlanRecalcTargetLabel => 'Recalc target:';

  @override
  String get activePlanRecalcTargetAuto => 'Auto';

  @override
  String get activePlanRecalcTargetReps => 'Reps';

  @override
  String get activePlanRecalcTargetRpe => 'RPE';

  @override
  String get activePlanRecalcTargetIntensity => 'Intensity';

  @override
  String get activePlanValidatorLabel => 'Validator:';

  @override
  String get activePlanValidatorNone => 'None';

  @override
  String get activePlanValidatorFixReps => 'Fix reps';

  @override
  String get activePlanValidatorFixIntensity => 'Fix intensity';

  @override
  String get activePlanSelectAtLeastOneExercise =>
      'Select at least one exercise';

  @override
  String get activePlanSelectAtLeastOneParameter =>
      'Select at least one parameter';

  @override
  String get activePlanPlanCancelled => 'Plan cancelled';

  @override
  String get activePlanFailedToCancelPlan => 'Failed to cancel plan';

  @override
  String activePlanExerciseIdFallback(Object id) {
    return 'Exercise $id';
  }

  @override
  String activePlanReplaceTitle(Object end, Object start) {
    return 'Replace exercises (from $start to $end)';
  }

  @override
  String get activePlanSelectSourceExercises => 'Select source exercises:';

  @override
  String get activePlanSelectTargetExercise => 'Select target exercise';

  @override
  String get activePlanPreserveIntensity => 'Preserve intensity via 1RM';

  @override
  String get activePlanSelectAtLeastOneSourceExercise =>
      'Select at least one source exercise';

  @override
  String get activePlanSelectTargetExerciseSnack => 'Select a target exercise';

  @override
  String get activePlanPreviewReplacementTitle => 'Preview replacement';

  @override
  String activePlanPreviewTarget(Object name) {
    return 'Target: $name';
  }

  @override
  String activePlanPreviewExercisesToReplace(Object count) {
    return 'Exercises to replace: $count';
  }

  @override
  String activePlanPreviewSetsAffected(Object count) {
    return 'Sets affected: $count';
  }

  @override
  String get activePlanDropoutReasonNotEnjoyable => 'Not enjoyable';

  @override
  String get activePlanDropoutReasonOther => 'Other / prefer not to say';

  @override
  String get activePlanDropoutSkip => 'Skip';

  @override
  String get activePlanDropoutConfirm => 'Confirm';

  @override
  String activePlanUpdatedSets(Object count) {
    return 'Updated $count sets';
  }

  @override
  String activePlanFailed(Object error) {
    return 'Failed: $error';
  }

  @override
  String get activePlanReplacementCancelledOneRmRequired =>
      'Replacement cancelled: 1RM required';

  @override
  String activePlanEnterOneRmTitle(Object exerciseName) {
    return 'Enter 1RM for $exerciseName';
  }

  @override
  String get activePlanOneRmLabel => '1RM (kg)';

  @override
  String get activePlanOneRmHint => 'e.g. 120';

  @override
  String get activePlanOneRmHelp => 'Enter your current max for this exercise.';

  @override
  String get activePlanEnterNumberGtZero => 'Enter a number > 0';

  @override
  String activePlanShiftedWorkouts(Object count, Object days) {
    return 'Shifted $count workouts by +$days day(s)';
  }

  @override
  String activePlanShiftFailed(Object error) {
    return 'Shift failed: $error';
  }

  @override
  String get activePlanKeep => 'Keep';

  @override
  String get activePlanCancelPlan => 'Cancel plan';

  @override
  String get activePlanWhyCancelling => 'Why are you cancelling?';

  @override
  String get activePlanDropoutReasonNotEnoughTime => 'Not enough time';

  @override
  String get activePlanDropoutReasonInjury => 'Injury / pain';

  @override
  String get activePlanDropoutReasonTooHard => 'Too hard';

  @override
  String activePlanReplaceSuccess(Object exercises, Object sets) {
    return 'Replaced $exercises exercises, updated $sets sets';
  }

  @override
  String activePlanReplaceFailed(Object error) {
    return 'Replace failed: $error';
  }

  @override
  String get activePlanCancelConfirmTitle => 'Cancel active plan?';

  @override
  String get activePlanCancelConfirmBody =>
      'This will stop tracking this applied plan. Existing workouts will remain.';

  @override
  String activePlanDroppedPrefix(Object reason, Object date) {
    return 'Dropped: $reason$date';
  }

  @override
  String activePlanAdherencePercent(Object value) {
    return 'Adherence: $value%';
  }

  @override
  String activePlanFailedToLoadAnalytics(Object error) {
    return 'Failed to load analytics: $error';
  }

  @override
  String get activePlanStatusActive => 'Active';

  @override
  String get coachRelationshipsTitle => 'Coach ↔ Athletes';

  @override
  String get coachRelationshipsFilterAll => 'All';

  @override
  String get coachRelationshipsFilterPending => 'Pending';

  @override
  String get coachRelationshipsFilterActive => 'Active';

  @override
  String get coachRelationshipsFilterPaused => 'Paused';

  @override
  String get coachRelationshipsFilterEnded => 'Ended';

  @override
  String coachRelationshipsError(Object error) {
    return 'Error: $error';
  }

  @override
  String get coachRelationshipsEmpty => 'No relationships yet';

  @override
  String coachRelationshipsAthletePrefix(Object name) {
    return 'Athlete: $name';
  }

  @override
  String coachRelationshipsStatusPrefix(Object status) {
    return 'Status: $status';
  }

  @override
  String coachRelationshipsNotePrefix(Object note) {
    return 'Note: $note';
  }

  @override
  String coachRelationshipsChannelPrefix(Object channel) {
    return 'Channel: $channel';
  }

  @override
  String get coachRelationshipsChannelNotCreated => 'not created';

  @override
  String coachRelationshipsSessions12w(Object count) {
    return 'Sessions (12w): $count';
  }

  @override
  String coachRelationshipsLastWorkout(Object date, Object suffix) {
    return 'Last workout: $date$suffix';
  }

  @override
  String get coachRelationshipsLastWorkoutNA => 'n/a';

  @override
  String coachRelationshipsDaysAgoSuffix(Object days) {
    return ' · ${days}d ago';
  }

  @override
  String get coachRelationshipsLoadingTrainingSummary =>
      'Loading training summary...';

  @override
  String get coachRelationshipsRequestAccepted => 'Request accepted';

  @override
  String coachRelationshipsFailedToAccept(Object error) {
    return 'Failed to accept: $error';
  }

  @override
  String get coachRelationshipsAccept => 'Accept';

  @override
  String get coachRelationshipsDecline => 'Decline';

  @override
  String get coachRelationshipsDeclineRequestTitle => 'Decline request';

  @override
  String get coachRelationshipsDeclineReasonHint => 'Reason (optional)';

  @override
  String get coachRelationshipsRequestDeclined => 'Request declined';

  @override
  String coachRelationshipsFailedToDecline(Object error) {
    return 'Failed to decline: $error';
  }

  @override
  String get coachRelationshipsCoachingPaused => 'Coaching paused';

  @override
  String coachRelationshipsFailedToPause(Object error) {
    return 'Failed to pause: $error';
  }

  @override
  String get coachRelationshipsCoachingResumed => 'Coaching resumed';

  @override
  String coachRelationshipsFailedToResume(Object error) {
    return 'Failed to resume: $error';
  }

  @override
  String get coachRelationshipsChatTooltip => 'Chat';

  @override
  String get coachRelationshipsAnalyticsTooltip => 'Analytics';

  @override
  String get coachRelationshipsNudgeTooltip => 'Nudge';

  @override
  String get coachRelationshipsPauseCoaching => 'Pause coaching';

  @override
  String get coachRelationshipsResumeCoaching => 'Resume coaching';

  @override
  String get coachRelationshipsEndCoaching => 'End coaching';

  @override
  String get coachRelationshipsCoachingEnded => 'Coaching ended';

  @override
  String coachRelationshipsFailedToEnd(Object error) {
    return 'Failed to end: $error';
  }

  @override
  String get coachRelationshipsChatChannelNotAvailable =>
      'Chat channel is not available';

  @override
  String get coachRelationshipsNudgeSent => 'Nudge sent';

  @override
  String coachRelationshipsFailedToSendNudge(Object error) {
    return 'Failed to send nudge: $error';
  }

  @override
  String coachRelationshipsNudgeMessageWithDays(Object athleteId, Object days) {
    return 'Hey $athleteId, it\'s been $days day(s) since your last workout. Let\'s plan the next session!';
  }

  @override
  String coachRelationshipsNudgeMessageNoDays(Object athleteId) {
    return 'Hey $athleteId, let\'s schedule our next workout soon!';
  }

  @override
  String coachRelationshipsVolumeAndPlan(Object volume, Object plan) {
    return 'Volume: $volume | Active plan: $plan';
  }

  @override
  String get coachRelationshipsVolumeDash => '-';

  @override
  String get coachRelationshipsMenuAll => 'All';

  @override
  String get coachRelationshipsMenuPending => 'Pending';

  @override
  String get coachRelationshipsMenuActive => 'Active';

  @override
  String get coachRelationshipsMenuPaused => 'Paused';

  @override
  String get coachRelationshipsMenuEnded => 'Ended';

  @override
  String get coachRelationshipsMenuPauseCoaching => 'Pause coaching';

  @override
  String get coachRelationshipsMenuResumeCoaching => 'Resume coaching';

  @override
  String get coachRelationshipsMenuEndCoaching => 'End coaching';

  @override
  String planEditorTitle(Object name) {
    return 'Editor: $name';
  }

  @override
  String get planEditorMacros => 'Macros';

  @override
  String get planEditorNoPlanId => 'No plan ID';

  @override
  String planEditorBulk(Object count) {
    return 'Bulk ($count)';
  }

  @override
  String get planEditorReplace => 'Replace';

  @override
  String get planEditorSearchHint => 'Search exercise by name...';

  @override
  String get planEditorMesocycles => 'Mesocycles';

  @override
  String get planEditorDayFilterLabel => 'Filter: day (number, optional)';

  @override
  String get planEditorSelectTargetError => 'Choose target exercise';

  @override
  String get planEditorSelectSourceError =>
      'Select at least one exercise to replace';

  @override
  String get planEditorDeleteMesocycleTitle => 'Delete mesocycle';

  @override
  String planEditorDeleteMesocycleBody(Object name) {
    return 'Are you sure you want to delete mesocycle \"$name\" and all its microcycles?';
  }

  @override
  String get planEditorDeleteMesocycle => 'Delete';

  @override
  String get planEditorMesocycleDeleted => 'Mesocycle deleted';

  @override
  String planEditorDeleteFailed(Object error) {
    return 'Delete failed: $error';
  }

  @override
  String get planEditorDeleteMesocycleTooltip => 'Delete mesocycle';

  @override
  String planEditorMicroDays(Object count) {
    return 'Days: $count';
  }

  @override
  String planEditorExerciseIdFallback(Object id) {
    return 'Exercise $id';
  }

  @override
  String get planEditorChangesSaved => 'Changes saved';

  @override
  String get planEditorMicrocycleDeleted => 'Microcycle deleted';

  @override
  String get planEditorDeleteMicrocycleTitle => 'Delete microcycle';

  @override
  String planEditorDeleteMicrocycleBody(Object name) {
    return 'Are you sure you want to delete microcycle \"$name\"?';
  }

  @override
  String get planEditorDeleteMicrocycleTooltip => 'Delete microcycle';

  @override
  String get planEditorMassEditTitle => 'Mass edits: selected microcycles';

  @override
  String planEditorSkipNoRights(Object count) {
    return 'Skipped $count microcycles without access rights';
  }

  @override
  String planEditorRightsCheckUnavailableApplyAll(Object error) {
    return 'Rights check unavailable, applying to all selected: $error';
  }

  @override
  String planEditorMassEditsResult(Object success, Object failed) {
    return 'Mass edits: success $success, failed $failed';
  }

  @override
  String coachAthletePlanTitleFallback(Object id) {
    return 'Athlete $id';
  }

  @override
  String coachAthletePlanLoadAnalyticsError(Object error) {
    return 'Failed to load plan analytics: $error';
  }

  @override
  String get coachAthletePlanMetricSets => 'Sets';

  @override
  String get coachAthletePlanMetricReps => 'Reps';

  @override
  String get coachAthletePlanMetricIntensity => 'Intensity (avg)';

  @override
  String get coachAthletePlanMetricEffort => 'Effort (RPE avg)';

  @override
  String get coachAthletePlanAxisX => 'Axis X';

  @override
  String get coachAthletePlanAxisY => 'Axis Y';

  @override
  String get coachAthletePlanNoAnalytics => 'No analytics for this plan';

  @override
  String coachAthletePlanSessionsCompleted(Object completed, Object planned) {
    return '$completed / $planned sessions';
  }

  @override
  String coachAthletePlanPeriod(Object start, Object end) {
    return 'Period: $start – $end';
  }

  @override
  String coachAthletePlanNotes(Object notes) {
    return 'Notes: $notes';
  }

  @override
  String get coachAthletePlanMassEditTooltip => 'Mass edit athlete plan';

  @override
  String get coachAthletePlanMassEditMenu => 'Mass edit (notes/day)';

  @override
  String get coachAthletePlanWorkoutNotesHint => 'Enter note for athlete';

  @override
  String get coachAthletePlanWorkoutRescheduled => 'Workout rescheduled';

  @override
  String get coachAthletePlanWorkoutNotesUpdated => 'Note updated';

  @override
  String get coachAthletePlanNoExercises => 'No exercise data in this workout';

  @override
  String get coachAthletePlanEditExercise => 'Edit exercise';

  @override
  String get coachAthletePlanAddExercise => 'Add exercise';

  @override
  String get coachAthletePlanDeleteExerciseConfirmTitle => 'Delete exercise?';

  @override
  String coachAthletePlanDeleteExerciseConfirmBody(Object name) {
    return 'Are you sure you want to delete $name from workout?';
  }

  @override
  String get coachAthletePlanExerciseDeleted => 'Exercise deleted';

  @override
  String coachAthletePlanDeleteError(Object error) {
    return 'Error while deleting: $error';
  }

  @override
  String coachAthletePlanOrder(Object order) {
    return 'Order: $order';
  }

  @override
  String coachAthletePlanSets(Object count) {
    return 'Sets: $count';
  }

  @override
  String get coachAthletePlanNoSets => 'No sets';

  @override
  String get coachAthletePlanAddSet => 'Add set';

  @override
  String get coachAthletePlanMassEditErrorNoWorkouts =>
      'No workouts for mass edits';

  @override
  String get coachAthletePlanMassEditErrorNoWorkoutsOnDay =>
      'No workouts on selected day';

  @override
  String get coachAthletePlanMassEditUpdateWorkouts => 'Update workout notes';

  @override
  String get coachAthletePlanMassEditUpdateExercises => 'Update exercise notes';

  @override
  String get coachAthletePlanMassEditNoChanges => 'No changes to apply';

  @override
  String get coachAthletePlanMassEditApplied =>
      'Mass edit applied for selected day';

  @override
  String get coachAthletePlanMassEditWorkoutHint =>
      'New note for all workouts on this day';

  @override
  String get planEditorMassReplaceTitle => 'Mass exercise replacement';

  @override
  String get planEditorChooseTarget => 'Choose target exercise';

  @override
  String planEditorTargetPrefix(Object name) {
    return 'Target: $name';
  }

  @override
  String get planEditorSelectAll => 'Select all';

  @override
  String get planEditorClearAll => 'Clear all';

  @override
  String planEditorOccurrences(Object count) {
    return 'Occurrences: $count';
  }

  @override
  String get planEditorPreview => 'Preview';

  @override
  String planEditorRightsCheckUnavailable(Object error) {
    return 'Rights check unavailable, continuing without it: $error';
  }

  @override
  String get planEditorNoAccessibleMicrocycles =>
      'No accessible microcycles for replacement';

  @override
  String get planEditorNoExercisesToReplace => 'No exercises to replace';

  @override
  String get planEditorPreviewReplaceTitle => 'Replacement preview';

  @override
  String planEditorPreviewTarget(Object name) {
    return 'Target: $name';
  }

  @override
  String planEditorPreviewTotals(Object exercises, Object sets) {
    return 'Exercises to replace: $exercises, sets affected: $sets';
  }

  @override
  String planEditorPreviewMicroStats(Object ex, Object sets) {
    return 'Exercises: $ex · Sets: $sets';
  }

  @override
  String planEditorApplyReplaceResult(Object success, Object failed) {
    return 'Replacement: success $success, failed $failed';
  }

  @override
  String get workoutListTitle => 'Workouts';

  @override
  String get workoutListAddWorkout => 'Add Workout';

  @override
  String get workoutListWorkoutName => 'Workout Name';

  @override
  String get workoutListEnterNameError => 'Please enter a workout name';

  @override
  String workoutListCreateError(Object error) {
    return 'Error creating workout: $error';
  }

  @override
  String get workoutListNextWorkout => 'Next Workout';

  @override
  String get workoutListEmpty => 'No workouts in this progression';

  @override
  String exerciseCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString exercises',
      one: '1 exercise',
    );
    return '$_temp0';
  }

  @override
  String get nutritionSessionsTitle => 'Nutrition Sessions';

  @override
  String get nutritionSessionsEmpty => 'No nutrition sessions yet';

  @override
  String get nutritionSessionsEmptyDesc =>
      'Start tracking your nutrition by creating your first session';

  @override
  String nutritionSessionTitle(Object id) {
    return 'Session $id';
  }

  @override
  String userIdLabel(Object id) {
    return 'User ID: $id';
  }

  @override
  String entriesCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String get nutritionEntriesLabel => 'Entries';

  @override
  String get nutritionNoEntries => 'No entries';

  @override
  String get dateLabel => 'Date';

  @override
  String get workoutIdLabel => 'Workout ID';

  @override
  String get appliedPlanWorkoutIdLabel => 'Applied Plan Workout ID';

  @override
  String get typeLabel => 'Type';

  @override
  String get dosageLabel => 'Dosage';

  @override
  String get nutritionEditSession => 'Edit Nutrition Session';

  @override
  String get nutritionCreateSession => 'Create Nutrition Session';

  @override
  String get nutritionSessionConfig => 'Session Configuration';

  @override
  String get nutritionSessionId => 'Session ID';

  @override
  String get workoutIdOptional => 'Workout ID (optional)';

  @override
  String get appliedPlanWorkoutIdOptional =>
      'Applied Plan Workout ID (optional)';

  @override
  String get nutritionSelectedEntries => 'Selected Entries';

  @override
  String get nutritionNoEntriesSelected => 'No entries selected';

  @override
  String get nutritionAvailableItems => 'Available Items';

  @override
  String get foodLabel => 'Food';

  @override
  String get supplementsLabel => 'Supplements';

  @override
  String get medicationsLabel => 'Medications';

  @override
  String get nutritionNoItemsAvailable => 'No items available';

  @override
  String get updateSession => 'Update Session';

  @override
  String get createSession => 'Create Session';

  @override
  String get exerciseListEmptyDesc =>
      'Try changing the filter or add a new exercise';

  @override
  String get envBadgeWorkZone => 'WORK ZONE';

  @override
  String get envBadgeLive => 'LIVE';

  @override
  String get envBadgeCnsStorm => 'CNS STORM';

  @override
  String get envBadgeDeload => 'DELOAD';

  @override
  String get envIdleTactical =>
      'System ready. Select a session or configure the grid.';

  @override
  String get envIdleSnarky =>
      'The barbell will not lift itself. Pick a target.';

  @override
  String envLiveTacticalPeak(Object peak) {
    return 'Session in progress · Peak $peak';
  }

  @override
  String get envLiveTactical => 'Active session in progress · Focus mode';

  @override
  String envLiveSnarkyPeak(Object peak) {
    return 'Clock is ticking. Conquer $peak and quit whining.';
  }

  @override
  String get envLiveSnarky => 'Stopwatch is running. Less talk, more reps.';

  @override
  String envStormTacticalWithTonnage(Object detail, Object tonnage) {
    return 'Peak $detail · Volume $tonnage · High CNS load';
  }

  @override
  String envStormTactical(Object detail) {
    return 'Peak $detail · Peak CNS load';
  }

  @override
  String envStormSnarky(Object detail) {
    return 'Peak $detail. CNS is begging for mercy — turn it up.';
  }

  @override
  String get envDeloadLightZone => 'light zone';

  @override
  String envDeloadTacticalWithTonnage(Object rpe, Object tonnage) {
    return 'Recovery · $rpe · Volume $tonnage';
  }

  @override
  String envDeloadTactical(Object rpe) {
    return 'Deload phase · $rpe · Adaptation';
  }

  @override
  String envDeloadSnarky(Object rpe) {
    return 'Resort mode ($rpe). Do not even think about adding plates.';
  }

  @override
  String envWorkTacticalPeakTonnage(Object peak, Object tonnage) {
    return 'Peak $peak · Working volume $tonnage';
  }

  @override
  String envWorkSnarkyPeak(Object peak) {
    return 'Working corridor: $peak. Discipline beats ego.';
  }

  @override
  String envWorkTacticalSets(Object sets) {
    return 'Work zone · $sets sets';
  }

  @override
  String envWorkTacticalSetsWithTonnage(Object sets, Object tonnage) {
    return 'Work zone · $sets sets · $tonnage';
  }

  @override
  String envWorkSnarkySets(Object sets) {
    return '$sets working sets. Boring? That is called progress.';
  }

  @override
  String envWorkTacticalReady(Object prefix) {
    return '${prefix}Work zone · Ready to launch';
  }

  @override
  String envWorkSnarkyReady(Object prefix) {
    return '${prefix}Clean slate. Load it properly.';
  }

  @override
  String unitKgValue(Object value) {
    return '$value kg';
  }

  @override
  String unitSetsShort(Object count) {
    return '$count sets';
  }

  @override
  String unitExercisesShort(Object count) {
    return '$count ex.';
  }

  @override
  String unitMinutesShort(Object count) {
    return '$count min';
  }

  @override
  String get presetPowerlifter => 'Strength 5/3/1';

  @override
  String get presetVolume => 'Volume';

  @override
  String get presetMinimalist => 'Minimalist';

  @override
  String get presetCustom => 'Custom';

  @override
  String get slotShortPeakIntensity => 'PEAK %';

  @override
  String get slotShortE1rm => 'E1RM';

  @override
  String get slotShortPeakRpe => 'PEAK RPE';

  @override
  String get slotShortAvgRpe => 'AVG RPE';

  @override
  String get slotShortTonnage => 'TONNAGE';

  @override
  String get slotShortKpsh => 'REPS';

  @override
  String get slotShortSetsCount => 'SETS';

  @override
  String get slotShortDensity => 'DENSITY';

  @override
  String get slotShortDurationWeeks => 'WEEKS';

  @override
  String get slotShortFrequencyPerWeek => 'FREQ';

  @override
  String get slotNamePeakIntensity => 'Peak % 1RM';

  @override
  String get slotNameE1rm => 'Estimated 1RM';

  @override
  String get slotNamePeakRpe => 'Peak RPE';

  @override
  String get slotNameAvgRpe => 'Average RPE';

  @override
  String get slotNameTonnage => 'Tonnage';

  @override
  String get slotNameKpsh => 'Total Reps';

  @override
  String get slotNameSetsCount => 'Working Sets';

  @override
  String get slotNameDensity => 'Density';

  @override
  String get slotNameDurationWeeks => 'Duration';

  @override
  String get slotNameFrequencyPerWeek => 'Workouts/week';

  @override
  String get moduleVariantOrHorizonStrip => 'Presets / Variants strip';

  @override
  String get moduleCommandBriefing => 'Load Briefing';

  @override
  String get modulePrimaryTelemetry => 'Telemetry & Chart';

  @override
  String get moduleScheduleOrLibrary => 'Library / Microcycles';

  @override
  String get interfaceMakerTitle => 'Screen Grid & Modules';

  @override
  String get interfaceMakerReset => 'Reset';

  @override
  String get interfaceMakerPresetsSection => 'DISCIPLINE PRESETS';

  @override
  String get interfaceMakerWaveChartTitle => 'Wave chart in cards';

  @override
  String get interfaceMakerWaveChartSubtitle =>
      'Disable for a compact view without charts';

  @override
  String get interfaceMakerSnarkyTitle => 'CARROT-style briefing';

  @override
  String get interfaceMakerSnarkySubtitle =>
      'Snarky load summary instead of dry tactical';

  @override
  String get interfaceMakerSlotsSection =>
      '4 TELEMETRY SLOTS (DATA POINT PICKER)';

  @override
  String interfaceMakerSlotNumber(Object index) {
    return 'Slot $index';
  }

  @override
  String get interfaceMakerModulesSection => 'MODULES & SCREEN ORDER';

  @override
  String get interfaceMakerMoveUp => 'Move up';

  @override
  String get interfaceMakerMoveDown => 'Move down';

  @override
  String get homeNoPlannedSessions =>
      'All planned sessions completed or no plan selected';

  @override
  String get homeOpenActivePlanTooltip => 'Open active plan';

  @override
  String get homeOpenCalendarPlanTooltip => 'Open calendar plan';

  @override
  String get actionStart => 'Start';

  @override
  String get actionFinish => 'Finish';

  @override
  String get actionNew => 'New';

  @override
  String get metricTimeShort => 'TIME';

  @override
  String get metricExercisesShort => 'EX.';

  @override
  String get sessionLogHeader => 'SESSION LOG';

  @override
  String get sessionLogLibrary => 'Library';

  @override
  String get sessionLogLoadError => 'Failed to load workouts';

  @override
  String get sessionLogEmptyTitle => 'No manual sessions';

  @override
  String get sessionLogEmptySubtitle => 'Tap \"New\" to log a free workout';

  @override
  String get sessionLogAllShown => 'ALL SESSIONS SHOWN';

  @override
  String get workoutDeleteTooltip => 'Delete workout';

  @override
  String get workoutManualSession => 'Manual session';

  @override
  String get workoutMarkAllCompletedTooltip => 'Mark all as completed';

  @override
  String get tooltipDecrease => 'Decrease';

  @override
  String get deleteExerciseTooltip => 'Delete exercise';

  @override
  String get deleteSetTooltip => 'Delete set';

  @override
  String get metricMicrocyclesShort => 'MICROCYCLES';

  @override
  String get metricAppliedShort => 'APPLIED';

  @override
  String get planVariantOriginal => 'Original';

  @override
  String get planVariantAdd => '+ Variant';

  @override
  String get planAnalyticsTitle => 'Plan Analytics';

  @override
  String get tooltipCollapse => 'Collapse';

  @override
  String get tooltipExpand => 'Expand';

  @override
  String get navWorkouts => 'Workouts';

  @override
  String get navPlans => 'Plans';

  @override
  String get navFeed => 'Feed';

  @override
  String get navCrm => 'CRM';

  @override
  String get navDebug => 'Debug';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get activePlanEmptyTitle => 'No active plan';

  @override
  String get activePlanEmptyDescription =>
      'Select a calendar plan to start a cycle';

  @override
  String get activePlanSelectPlan => 'Select plan';

  @override
  String get horizon1Week => '1 wk';

  @override
  String get horizon2Weeks => '2 wk';

  @override
  String get horizonMonth => 'Month';

  @override
  String horizonChipLabel(Object horizon) {
    return 'Horizon · $horizon';
  }

  @override
  String get gridPillLabel => 'Grid';

  @override
  String get planPillLabel => 'Plan';

  @override
  String get activePlanMicrocycleCalendarHeader => 'MICROCYCLE CALENDAR';

  @override
  String get activePlanDayLabel => 'PLAN DAY';

  @override
  String get actionView => 'View';

  @override
  String get activePlanNoWorkoutsSelectedDay =>
      'No workouts on the selected day';

  @override
  String get noWorkouts => 'No workouts';

  @override
  String get metricAvgIntensityShort => 'AVG INT.';

  @override
  String get metricCompletedShort => 'DONE';

  @override
  String get metricAvgRpeShort => 'AVG RPE';

  @override
  String get metricRepsShort => 'REPS';

  @override
  String get metricSetsShort => 'SETS';

  @override
  String get metricSessionsShort => 'SESSIONS';

  @override
  String get tooltipCollapseChart => 'Collapse chart';

  @override
  String get tooltipExpandChart => 'Expand chart';

  @override
  String get activePlanNoData => 'No data for plan';

  @override
  String get workoutListAddTitle => 'Add Workout';

  @override
  String get workoutListNameLabel => 'Workout name';

  @override
  String get actionAdd => 'Add';

  @override
  String get workoutListNameRequired => 'Please enter a workout name';

  @override
  String workoutListLoadError(Object error) {
    return 'Error loading workouts: $error';
  }

  @override
  String get workoutListEmptyTitle => 'No workouts';

  @override
  String get workoutListEmptyDescription =>
      'There are no workouts in this progression yet';

  @override
  String get workoutListSectionTitle => 'Workout List';

  @override
  String get workoutsCreateTitle => 'Create Workout';

  @override
  String get actionCreate => 'Create';

  @override
  String get workoutsDeleteTitle => 'Delete workout?';

  @override
  String get workoutsDeleteConfirm =>
      'Are you sure you want to delete this manual workout?';

  @override
  String workoutsPlanLoadError(Object error) {
    return 'Error loading plan: $error';
  }

  @override
  String get workoutDetailOpenError => 'Failed to open workout';

  @override
  String get actionBack => 'Back';

  @override
  String get workoutDetailAppStateNotReady =>
      'Failed to update set: app state not ready';

  @override
  String get workoutDetailDeleteExerciseTitle => 'Delete Exercise';

  @override
  String get workoutDetailExerciseRemoved => 'Exercise removed from workout';

  @override
  String get workoutDetailDeleteUnsavedExerciseError =>
      'Error: Cannot delete unsaved exercise';

  @override
  String get workoutDetailAddSetUnsavedError =>
      'Cannot add set: exercise is not saved yet';

  @override
  String get workoutDetailSetAdded => 'Set added successfully';

  @override
  String get workoutDetailUpdated => 'Workout updated';

  @override
  String get workoutDetailStarted => 'Workout started';

  @override
  String get workoutDetailSessionCancelled => 'Session cancelled';

  @override
  String get workoutDetailFinished => 'Workout finished';

  @override
  String get workoutDetailAllSetsCompleted => 'All sets are already completed';

  @override
  String get workoutDetailDeleteSetTitle => 'Delete Set';

  @override
  String get workoutDetailSetDeleted => 'Set deleted successfully';

  @override
  String get workoutDetailExerciseAdded => 'Exercise added successfully';

  @override
  String get workoutDetailFallbackTitle => 'Workout Details';

  @override
  String get workoutDetailNoExercisesTitle => 'No exercises yet';

  @override
  String get workoutDetailNoExercisesSubtitle =>
      'Tap \"Add exercise\" below to build a session';

  @override
  String get metricTimerShort => 'TIMER';

  @override
  String get metricModeShort => 'MODE';

  @override
  String get tooltipEditExercise => 'Edit exercise';

  @override
  String get actionClear => 'Clear';

  @override
  String planEditorSelectedCount(Object count) {
    return 'SELECTED: $count';
  }

  @override
  String get planEditorBulkShort => 'Bulk';

  @override
  String planEditorMesocyclesCount(Object count) {
    return 'MESOCYCLES · $count';
  }

  @override
  String planEditorMicrocyclesCount(Object count) {
    return 'MICROCYCLES: $count';
  }

  @override
  String get planEditorEditMicrocycleTooltip => 'Edit microcycle';

  @override
  String get planEditorIntensity => 'Intensity';

  @override
  String get planEditorReps => 'Reps';

  @override
  String get planEditorModeSet => 'Set';

  @override
  String get planEditorModeOffset => 'Offset';

  @override
  String get planEditorModeScale => 'Scale';

  @override
  String get planEditorRecalcAuto => 'Recalc: Auto';

  @override
  String get planEditorRecalcReps => 'Recalc: Reps';

  @override
  String get planEditorRecalcEffort => 'Recalc: RPE';

  @override
  String get planEditorRecalcIntensity => 'Recalc: Intensity';

  @override
  String get planEditorAutoRecalcReps =>
      'Auto-recalc: Reps (from Intensity & RPE)';

  @override
  String get planEditorAutoRecalcIntensity =>
      'Auto-recalc: Intensity (from Reps & RPE)';

  @override
  String get planEditorAutoRecalcRpe =>
      'Auto-recalc: RPE (from Intensity & Reps)';

  @override
  String get planEditorAutoRecalcNone => 'Auto-recalc: disabled';

  @override
  String get planEditorFilterExercisesOptional =>
      'Filter: exercises (optional)';

  @override
  String get planEditorMassEditWarning =>
      'ALL sets of all exercises in all selected microcycles will be modified.';

  @override
  String get planEditorNoChanges => 'No changes for selected parameters';

  @override
  String get planEditorMassEditPreviewTitle => 'Mass edits preview';

  @override
  String planEditorMicrocyclesCountPlain(Object count) {
    return 'Microcycles: $count';
  }

  @override
  String planEditorMismatchesCount(Object count) {
    return 'Mismatches: $count';
  }

  @override
  String planEditorChangedSets(Object changed, Object total) {
    return 'Changed sets: $changed of $total';
  }

  @override
  String planEditorDeltaSummary(Object e, Object i, Object v) {
    return 'Changes: Int $i · RPE $e · Reps $v';
  }

  @override
  String get planEditorFixNone => 'Validator: No auto-fix';

  @override
  String get planEditorFixReps => 'Validator: Fix Reps';

  @override
  String get planEditorFixIntensity => 'Validator: Fix Intensity';

  @override
  String planEditorPreviewMicroDiff(
    Object changed,
    Object e,
    Object i,
    Object total,
    Object v,
  ) {
    return 'Sets: $changed/$total · Δ Int $i · Δ RPE $e · Δ Reps $v';
  }

  @override
  String planDetailDeleteFailed(Object error) {
    return 'Failed to delete plan: $error';
  }

  @override
  String get tooltipMoreActions => 'More actions';

  @override
  String get planDetailEditPlan => 'Edit plan';

  @override
  String get planDetailRecalcSets => 'Recalculate sets (RPE)';

  @override
  String get planDetailDeletePlan => 'Delete plan';

  @override
  String planDetailAdoptersLoadError(Object error) {
    return 'Failed to load adoption count: $error';
  }

  @override
  String planDetailLoadError(Object error) {
    return 'Failed to load plan: $error';
  }

  @override
  String get planDetailRecalculated => 'Plan recalculated';

  @override
  String planDetailRecalcError(Object error) {
    return 'Failed to recalculate plan: $error';
  }

  @override
  String planDetailVariantsLoadError(Object error) {
    return 'Failed to load variants: $error';
  }

  @override
  String get planDetailNewVariantTitle => 'New plan variant';

  @override
  String get planDetailVariantNameLabel => 'Variant name';

  @override
  String get errorEnterName => 'Enter a name';

  @override
  String get planDetailVariantCreated => 'Variant created';

  @override
  String errorWithDetails(Object error) {
    return 'Error: $error';
  }

  @override
  String get metricVolumeShort => 'VOLUME';

  @override
  String unitRepsShort(Object count) {
    return '$count reps';
  }

  @override
  String unitSetsPerWorkout(Object value) {
    return '$value/wo';
  }

  @override
  String get planDetailAnalyticsFilters => 'Analytics filters';

  @override
  String get planDetailGranularity => 'GRANULARITY';

  @override
  String get planDetailExercisesTitle => 'Exercises';

  @override
  String get loadingEllipsis => 'Loading…';

  @override
  String get planDetailMuscleGroupsTitle => 'Muscle groups';

  @override
  String get planDetailAxesTitle => 'X Axis / Y Axis';

  @override
  String planDetailFiltersPillCount(Object bucket, Object count) {
    return 'Filters · $bucket ($count)';
  }

  @override
  String planDetailFiltersPill(Object bucket) {
    return 'Filters · $bucket';
  }

  @override
  String get planDetailExercisesLoadError => 'Failed to load exercise data';

  @override
  String get planDetailAllExercises => 'All exercises';

  @override
  String get planDetailFilterEmpty => 'Filter contains no data';

  @override
  String planDetailAndMore(Object count, Object items) {
    return '$items and $count more';
  }

  @override
  String get planDetailAllMuscles => 'All muscles';

  @override
  String get planDetailSelectExercises => 'Select exercises';

  @override
  String get planDetailSelectMuscles => 'Select muscles';

  @override
  String get planDetailSelectMetricX => 'Select metric for X axis';

  @override
  String get planDetailSelectMetricY => 'Select metric for Y axis';

  @override
  String get metricYRepsVolume => 'Reps (volume)';

  @override
  String get metricYIntensityPct => 'Intensity (%)';

  @override
  String get metricYEffortRpe => 'Effort (RPE)';

  @override
  String get granularitySessions => 'Sessions';

  @override
  String get granularityMicrocycles => 'Microcycles';

  @override
  String get granularityWeeks => 'Weeks';

  @override
  String planDetailCurrentMax(Object reps, Object weight) {
    return 'Current max: $weight kg × $reps';
  }

  @override
  String get planDetailMaxNotSet => 'Max not set';

  @override
  String get planDetailMadePublic => 'Plan made public';

  @override
  String get planDetailMadePrivate => 'Plan hidden (private only)';

  @override
  String planDetailVisibilityError(Object error) {
    return 'Failed to update plan visibility: $error';
  }

  @override
  String get metricSetShort => 'SET';

  @override
  String get metricIntShort => 'INT';

  @override
  String get metricRepsColShort => 'REPS';

  @override
  String normRulesCount(Object count) {
    return 'Custom rules: $count';
  }

  @override
  String get normNotSet => 'Normalization not set';

  @override
  String get normUnitPct1rm => '% of 1RM';

  @override
  String get normUnitKg => 'kg';

  @override
  String normRulesSuffix(Object count) {
    return ', rules: $count';
  }

  @override
  String get normSectionHeader => 'POST-MICROCYCLE NORMALIZATION';

  @override
  String get normDeltaLabel => 'Change (e.g. -2.5)';

  @override
  String get normDeltaHint => 'In kg or %';

  @override
  String get normUnitLabel => 'Unit';

  @override
  String get normUnitPctMult => '% (multiplicative)';

  @override
  String get normUnitKgAbs => 'kg (absolute)';

  @override
  String get normDescription =>
      'Specify one global change and/or rules for specific exercises, muscle groups, or target muscles.';

  @override
  String get normRulesHeader => 'NORMALIZATION RULES';

  @override
  String get normAddRule => 'Add rule';

  @override
  String get normNoRules => 'No custom rules yet';

  @override
  String normRuleHeader(Object index) {
    return 'RULE $index';
  }

  @override
  String get normDeleteRuleTooltip => 'Delete rule';

  @override
  String get normExerciseIdsLabel => 'Exercise IDs (comma-separated)';

  @override
  String get normExerciseIdsHint => 'E.g.: 12, 45, 103';

  @override
  String get normMuscleGroupsLabel => 'Muscle groups (comma-separated)';

  @override
  String get normMuscleGroupsHint => 'E.g.: chest, quads';

  @override
  String get normTargetMusclesLabel => 'Target muscles (comma-separated)';

  @override
  String get normTargetMusclesHint => 'E.g.: biceps_long, lats';

  @override
  String get normDeltaValueLabel => 'Δ value';

  @override
  String get normUnitShortLabel => 'Unit';

  @override
  String get microcycleNameLabel => 'Microcycle name';

  @override
  String get planCreateEnterNameError => 'Please enter a plan name';

  @override
  String get planCreateSuccess => 'Plan created successfully';

  @override
  String get microEditorMassEditTitle => 'Mass edit sets';

  @override
  String get microEditorIntensityOpt => 'Intensity %1RM (optional)';

  @override
  String get microEditorRpeOpt => 'RPE (optional)';

  @override
  String get microEditorRepsOpt => 'Reps (optional)';

  @override
  String get microEditorSaved => 'Microcycle saved';

  @override
  String microEditorSaveError(Object error) {
    return 'Save error: $error';
  }

  @override
  String microEditorTitle(Object name) {
    return 'Microcycle: $name';
  }

  @override
  String get tooltipSave => 'Save';

  @override
  String get microEditorUnsavedChanges => 'There are unsaved changes';

  @override
  String microEditorWorkoutMeta(Object count, Object order) {
    return 'ORDER: $order · EXERCISES: $count';
  }

  @override
  String get microEditorSetLabel => 'Set';

  @override
  String plansOpenError(Object error) {
    return 'Failed to open plan: $error';
  }

  @override
  String get plansSearchHint => 'Search plans';

  @override
  String get plansClearSearchTooltip => 'Clear search';

  @override
  String get plansFiltersTooltip => 'Filters';

  @override
  String plansFoundCount(Object count) {
    return 'Found: $count';
  }

  @override
  String plansLoadError(Object error) {
    return 'Failed to load plans: $error';
  }

  @override
  String get plansEmptyTitle => 'No plans found';

  @override
  String get plansEmptyDescription => 'Try changing the query or filters';

  @override
  String get actionLoadMore => 'Show more';

  @override
  String get actionLoadFailedRetry => 'Failed to load. Retry';

  @override
  String get filterDuration => 'Duration';

  @override
  String get filterGoal => 'Goal';

  @override
  String get filterFrequency => 'Workouts per week';

  @override
  String get filterLevel => 'Level';

  @override
  String filterDurationValue(Object value) {
    return '$value wk';
  }

  @override
  String filterFrequencyValue(Object value) {
    return '$value / wk';
  }

  @override
  String get planFiltersTitle => 'Plan filters';

  @override
  String get tooltipClose => 'Close';

  @override
  String get actionRetryLoad => 'Retry loading';

  @override
  String get roundNearest => 'Nearest';

  @override
  String get roundUp => 'Up';

  @override
  String get roundDown => 'Down';

  @override
  String applyPlanGenProgress(Object done, Object remaining, Object total) {
    return 'Generating plan: $done of $total ($remaining left)';
  }

  @override
  String applyPlanGenStage(Object stage) {
    return 'Generating plan: $stage';
  }

  @override
  String get applyPlanGenEllipsis => 'Generating plan…';

  @override
  String get weightKgLabel => 'Weight (kg)';

  @override
  String get repsLabel => 'Reps';

  @override
  String get errorValidWeight => 'Enter a valid weight';

  @override
  String get errorValidRepsRange => 'Enter 1–12 reps';

  @override
  String saveMaxFailed(Object error) {
    return 'Failed to save max: $error';
  }

  @override
  String get saveMaxButton => 'Save max';

  @override
  String maxSavedForExercise(Object name) {
    return 'Max saved for $name';
  }

  @override
  String get noSavedMaxesForPlan => 'No saved maxes for this plan';

  @override
  String get selectAtLeastOneUserMax => 'Please select at least one User Max';

  @override
  String get applyPlanTitle => 'Apply plan';

  @override
  String get applyPlanBaseMaxesHeader => 'BASE MAXES · USER MAX';

  @override
  String applyPlanSelectedCount(Object count) {
    return 'Selected: $count';
  }

  @override
  String get applyPlanRecentButton => 'Recent';

  @override
  String get applyPlanNoMaxesHint =>
      'No saved maxes for exercises in this plan. Add a 1RM above.';

  @override
  String get applyPlanNoExactMatchHint =>
      'No exact exercise match — showing all your User Maxes:';

  @override
  String get applyPlanWorkingWeightsHeader => 'WORKING WEIGHTS CALCULATION';

  @override
  String get applyPlanComputeWeights => 'Compute weights';

  @override
  String get applyPlanComputeWeightsSubtitle =>
      'Auto-calculate by % of selected max';

  @override
  String get applyPlanStepKgLabel => 'Step (kg)';

  @override
  String get applyPlanRoundingHeader => 'ROUNDING';

  @override
  String userMaxDisplay(Object reps, Object weight) {
    return '$weight kg × $reps';
  }

  @override
  String get deletePlanWithVariantsTitle => 'Delete plan with variants?';

  @override
  String get deletePlanTitle => 'Delete plan?';

  @override
  String get deletePlanCascadeBody =>
      'The plan, all its variants, and linked plan applications will be permanently deleted.';

  @override
  String get deletePlanSingleBody =>
      'The plan and linked plan applications will be deleted. This action cannot be undone.';

  @override
  String get untitled => 'Untitled';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get replaceActivePlanTitle => 'Replace active plan?';

  @override
  String get replaceActivePlanBody =>
      'You already have an active plan. The new plan will replace it. Completed workout history will be preserved.';

  @override
  String get replacePlanAction => 'Replace plan';

  @override
  String get macroMetricReadiness => 'readiness';

  @override
  String get macroMetricSessionRpe => 'session RPE';

  @override
  String get macroMetricReps => 'rep count';

  @override
  String get macroMetricE1rm => 'estimated 1RM';

  @override
  String get macroMetricTrend => 'progress trend';

  @override
  String get macroMetricRpeDelta => 'RPE deviation from plan';

  @override
  String get macroMetricRepsDelta => 'rep deviation from plan';

  @override
  String get macroMetricFallback => 'metric';

  @override
  String get macroTriggerAllExercises => 'across all exercises';

  @override
  String macroTriggerForExercises(Object names) {
    return 'for exercises: $names';
  }

  @override
  String get macroOpGte => 'greater than or equal to';

  @override
  String get macroOpLte => 'less than or equal to';

  @override
  String get macroOpEq => 'equal to';

  @override
  String get macroOpNeq => 'not equal to';

  @override
  String get macroOpGt => 'greater than';

  @override
  String get macroOpLt => 'less than';

  @override
  String get macroOpInRange => 'in range';

  @override
  String get macroOpOutOfRange => 'out of range';

  @override
  String get macroCondNotSet => 'condition not set';

  @override
  String macroCondInRangeValues(Object a, Object b, Object unit) {
    return 'value in range $a to $b$unit';
  }

  @override
  String macroCondOutOfRangeValues(Object a, Object b, Object unit) {
    return 'value out of range $a to $b$unit';
  }

  @override
  String get macroCondInRange => 'value in range';

  @override
  String get macroCondOutOfRange => 'value out of range';

  @override
  String macroCondStagnatesValues(Object eps, Object n) {
    return 'stagnation over $n windows within $eps percent';
  }

  @override
  String get macroCondStagnates => 'stagnation over windows';

  @override
  String get macroCondDirPositive => 'positive';

  @override
  String get macroCondDirNegative => 'negative';

  @override
  String macroCondDirSuffix(Object dir) {
    return ', direction: $dir';
  }

  @override
  String macroCondDeviatesValues(Object dir, Object n, Object val) {
    return 'deviation from $n-window average at least $val percent$dir';
  }

  @override
  String get macroCondDeviates => 'deviation from average';

  @override
  String macroCondHoldsWorkouts(Object n, Object rel, Object unit, Object val) {
    return 'holds for $n consecutive workouts: value $rel $val$unit';
  }

  @override
  String get macroCondHoldsWorkoutsGeneric =>
      'holds for several consecutive workouts';

  @override
  String macroCondHoldsSets(Object n, Object rel, Object unit, Object val) {
    return 'holds for $n consecutive sets in workout: value $rel $val$unit';
  }

  @override
  String get macroCondHoldsSetsGeneric =>
      'holds for several consecutive sets in workout';

  @override
  String macroCondSimpleGt(Object unit, Object val) {
    return 'value greater than $val$unit';
  }

  @override
  String macroCondSimpleLt(Object unit, Object val) {
    return 'value less than $val$unit';
  }

  @override
  String macroCondSimpleEq(Object unit, Object val) {
    return 'value equals $val$unit';
  }

  @override
  String macroCondSimpleNeq(Object unit, Object val) {
    return 'value not equal to $val$unit';
  }

  @override
  String get macroCondSet => 'condition set';

  @override
  String get macroActionTargetAll => 'for all exercises';

  @override
  String macroActionTargetExercises(Object list) {
    return 'for exercises: $list';
  }

  @override
  String macroActionTargetTags(Object tags) {
    return 'by tags: $tags';
  }

  @override
  String macroActionTargetTagsExamples(Object base, Object examples) {
    return '$base, e.g.: $examples';
  }

  @override
  String get macroInjectMesoBase => 'inject mesocycle';

  @override
  String macroInjectMesoTemplate(Object base, Object id) {
    return '$base from template ID $id';
  }

  @override
  String macroInjectWeeks(Object weeks) {
    return '$weeks weeks';
  }

  @override
  String macroInjectMicroDays(Object days) {
    return 'microcycle $days days';
  }

  @override
  String macroInjectRestDays(Object days) {
    return 'rest days: $days';
  }

  @override
  String macroInjectFocus(Object tags) {
    return 'focus: $tags';
  }

  @override
  String get macroInjectAppendEnd => 'at the end of plan';

  @override
  String macroInjectAfterWorkoutId(Object id) {
    return 'after workout #$id';
  }

  @override
  String get macroInjectAfterSelectedWorkout => 'after selected workout';

  @override
  String macroInjectAfterMesoIdx(Object idx) {
    return 'after mesocycle $idx';
  }

  @override
  String get macroInjectAfterSelectedMeso => 'after selected mesocycle';

  @override
  String get macroConflictReplace => 'replace scheduled';

  @override
  String get macroConflictShift => 'shift forward';

  @override
  String get macroConflictSkip => 'skip conflicting';

  @override
  String macroConflictPrefix(Object text) {
    return 'on conflict: $text';
  }

  @override
  String macroActDecreaseWeightPct(Object pct, Object target) {
    return 'decrease weight by $pct percent $target';
  }

  @override
  String macroActIncreaseWeightPct(Object pct, Object target) {
    return 'increase weight by $pct percent $target';
  }

  @override
  String macroActAdjustWeightRpe(Object rpe, Object target) {
    return 'adjust weight to target RPE $rpe $target';
  }

  @override
  String macroActDecreaseReps(Object reps, Object target) {
    return 'decrease reps by $reps $target';
  }

  @override
  String macroActIncreaseReps(Object reps, Object target) {
    return 'increase reps by $reps $target';
  }

  @override
  String macroActAdjustRepsRpe(Object rpe, Object target) {
    return 'adjust reps to target RPE $rpe $target';
  }

  @override
  String macroActRemoveSets(Object sets, Object target) {
    return 'remove $sets sets $target';
  }

  @override
  String macroActAddSets(Object sets, Object target) {
    return 'add $sets sets $target';
  }

  @override
  String macroActFallback(Object target) {
    return 'perform action $target';
  }

  @override
  String macroDurNextWorkouts(Object count) {
    return 'for the next $count workouts';
  }

  @override
  String get macroDurUntilLast => 'until the last workout';

  @override
  String get macroDurUntilEndMeso => 'until the end of mesocycle';

  @override
  String get macroDurUntilEndMicro => 'until the end of microcycle';

  @override
  String macroDurUntilWorkoutId(Object id) {
    return 'until workout #$id';
  }

  @override
  String get macroDurUntilSelectedWorkout => 'until selected workout';

  @override
  String get macroPreviewEmpty =>
      'Description will appear after selecting metric, condition, and action';

  @override
  String macroPreviewSentence(
    Object action,
    Object condition,
    Object metric,
    Object trigger,
  ) {
    return 'If $metric $trigger, and $condition, then $action';
  }

  @override
  String get macroLabelMetric => 'METRIC';

  @override
  String get macroLabelTrigger => 'TRIGGER';

  @override
  String get macroLabelCondition => 'CONDITION';

  @override
  String get macroLabelAction => 'ACTION';

  @override
  String get macroLabelDuration => 'DURATION';

  @override
  String macroPreviewSetChangesCount(Object count) {
    return 'Set changes: $count';
  }

  @override
  String macroPreviewMesoInsertsCount(Object count) {
    return 'Mesocycle inserts: $count';
  }

  @override
  String get macroPreviewMissingParamsHint =>
      'Plan parameters are required to calculate weights.';

  @override
  String get macroPreviewDialogTitle => 'Completed workout suggestions';

  @override
  String get macroPreviewViewChanges => 'View changes';

  @override
  String macroPreviewLoadError(Object error) {
    return 'Failed to load macro suggestions: $error';
  }

  @override
  String get macroPreviewAppBarTitle => 'Macro changes';

  @override
  String get macroPreviewConfirmNeedsNewServer =>
      'Confirmation requires a newer server version.';

  @override
  String macroPreviewObservationWorkout(Object id) {
    return 'Observation: workout #$id';
  }

  @override
  String get macroPreviewSpecifyWeightParams =>
      'Specify weight parameters to calculate this preview.';

  @override
  String macroPreviewOneRmKgForExercise(Object name) {
    return '1RM, kg · $name';
  }

  @override
  String get macroPreviewWeightStepKg => 'Weight step, kg';

  @override
  String get macroPreviewRoundNearest => 'To nearest step';

  @override
  String get macroPreviewRoundDown => 'Round down';

  @override
  String get macroPreviewRoundUp => 'Round up';

  @override
  String get macroPreviewCalcButton => 'Calculate preview';

  @override
  String get macroPreviewNoSetChanges => 'No set changes.';

  @override
  String macroPreviewExercisesModified(Object count) {
    return 'Exercise instances modified: $count';
  }

  @override
  String get macroPreviewMesoAdded => 'Mesocycle added';

  @override
  String macroPreviewMesoNotAdded(Object reason) {
    return 'Mesocycle not added: $reason';
  }

  @override
  String get macroPreviewConfirmSetsButton => 'Confirm set changes';

  @override
  String get macroPreviewApplyMesoRulesButton =>
      'Apply mesocycle insert rules separately';

  @override
  String macroPreviewAppliedToActivePlan(Object id) {
    return 'Applied to active plan #$id';
  }

  @override
  String macroPreviewInstanceNewSet(Object id) {
    return 'instance $id, new set';
  }

  @override
  String macroPreviewInstanceSet(Object id, Object setId) {
    return 'instance $id, set $setId';
  }

  @override
  String macroPreviewBefore(Object values) {
    return 'Before: $values';
  }

  @override
  String macroPreviewRequested(Object values) {
    return 'Requested: $values';
  }

  @override
  String macroPreviewClosestOption(Object values) {
    return 'Closest option: $values';
  }

  @override
  String macroPreviewAfter(Object values) {
    return 'Result: $values';
  }

  @override
  String get macroPreviewDeleteSet => 'Delete set';

  @override
  String macroPreviewMesoInsertParams(Object params) {
    return 'Mesocycle insert: $params';
  }

  @override
  String macroEditorInvalidJsonRule(Object error) {
    return 'Invalid rule JSON: $error';
  }

  @override
  String get macroEditorCreateTitle => 'Create macro';

  @override
  String get macroEditorEditTitle => 'Edit macro';

  @override
  String get macroEditorRuleParamsTitle => 'Rule parameters';

  @override
  String get macroEditorNameLabel => 'Name';

  @override
  String get macroEditorPriorityLabel => 'Priority';

  @override
  String get macroEditorInvalidNumber => 'Invalid number';

  @override
  String get macroEditorActiveLabel => 'Active';

  @override
  String get macroEditorTriggerTitle => 'Trigger';

  @override
  String get macroEditorConditionTitle => 'Condition';

  @override
  String get macroEditorActionTitle => 'Action';

  @override
  String get macroEditorDurationTitle => 'Duration';

  @override
  String get macroEditorNaturalDescTitle => 'Natural description';

  @override
  String get macroEditorEditJson => 'Edit JSON';

  @override
  String get macroEditorRuleJsonLabel => 'Rule (JSON preview)';

  @override
  String get macroEditorMustBeJsonObject => 'Must be a JSON object';

  @override
  String get macroEditorInvalidJson => 'Invalid JSON';

  @override
  String get macroTriggerHelpReadiness =>
      'Readiness score 1–10 (optional). Defaults to null; user can log it after workout to scale weights and trigger rules.';

  @override
  String get macroTriggerHelpSessionRpe =>
      'Session perceived exertion (Session RPE). Useful for auto-regulating load.';

  @override
  String get macroTriggerHelpReps =>
      'Total reps over the selected period. Use with exercise filter.';

  @override
  String get macroTriggerHelpE1rm =>
      'Estimated 1-rep max from performance (estimated 1RM). Useful for tracking progress.';

  @override
  String get macroTriggerHelpTrend =>
      'Performance trend (increase/decrease) over the last N windows.';

  @override
  String get macroTriggerHelpRpeDelta =>
      'RPE deviation from plan per set (actual − planned). Used for autoregulation.';

  @override
  String get macroTriggerHelpRepsDelta =>
      'Reps deviation from plan per set (actual − planned). For under/over-performance rules.';

  @override
  String get macroTriggerHintReadiness =>
      'Numeric readiness score (1–10). Null by default; logged after workout. Case: < 6 for 5 consecutive workouts — deload mesocycle. Use holds_for for consecutive rules.';

  @override
  String get macroTriggerHintSessionRpe =>
      'Session RPE: number 1–10. Use holds_for for consecutive rules.';

  @override
  String get macroTriggerHintReps =>
      'Total reps (integer). Can be scoped to specific exercises below.';

  @override
  String get macroTriggerHintE1rm =>
      'Estimated 1RM (kg). Compare with a number or use trend operators in conditions.';

  @override
  String get macroTriggerHintTrend =>
      'For trends use operators: stagnates_for (n, epsilon_percent) or deviates_from_avg (n, value_percent, direction).';

  @override
  String get macroTriggerHintRpeDelta =>
      'ΔRPE = actual − planned (can be negative). Use holds_for for consecutive workouts, holds_for_sets for consecutive sets.';

  @override
  String get macroTriggerHintRepsDelta =>
      'Δreps = actual − planned (integer, can be negative). Use holds_for_sets for intra-workout checks.';

  @override
  String get macroTriggerSelectExercisesHint =>
      'This metric applies to selected exercises. Choose one or more.';

  @override
  String get macroCondHelpCompare =>
      'Numeric comparison. Enter a value (integer or decimal), e.g. 10 or -2.5.';

  @override
  String get macroCondHelpInRange =>
      'Checks that value is INSIDE range (inclusive). Enter two numbers; order does not matter.';

  @override
  String get macroCondHelpOutOfRange =>
      'Checks that value is OUTSIDE range (inclusive). Enter two numbers.';

  @override
  String get macroCondHelpStagnates =>
      'Stagnation: last n windows stay within epsilon_percent (%) corridor. Specify n and epsilon_percent.';

  @override
  String get macroCondHelpDeviates =>
      'Deviation from n-window average. value_percent is threshold in %, direction is optional.';

  @override
  String get macroCondHelpHoldsWorkouts =>
      'N consecutive workouts: relation (>, <, >=, <=, ==, !=, in range, out of range) holds N times in a row.';

  @override
  String get macroCondHelpHoldsSets =>
      'N consecutive sets in workout: relation applies to per-set delta (e.g. Δreps).';

  @override
  String get macroCondNoteStagnates =>
      'Trend (stagnation): compares range width of last n values against epsilon_percent (%).\nFormat: n — integer (windows), epsilon_percent — percentage.\nExample: n=5, epsilon_percent=1.0 (change ≤ 1% over 5 windows).';

  @override
  String get macroCondNoteDeviates =>
      'Trend (deviation): compares latest value to n-window average.\nFormat: n — integer, value_percent — threshold %, direction — positive/negative (optional).\nExample: n=5, value_percent=3, direction=\"negative\" (drop ≥ 3%).';

  @override
  String get macroActHelpAdjustWeight =>
      'Changes weight and/or intensity by %: positive increases, negative decreases. Example: -2.5 lowers weight by 2.5%.';

  @override
  String get macroActHelpAdjustReps =>
      'Changes reps by ±N: positive adds rep(s), negative removes.';

  @override
  String get macroActHelpAdjustWeightRpe =>
      'Adjusts intensity/weight to target RPE (1–10) keeping current reps. Uses RPE table.';

  @override
  String get macroActHelpAdjustRepsRpe =>
      'Selects reps for target RPE (1–10) at fixed intensity (if set). Uses RPE table.';

  @override
  String get macroActHelpAdjustSets =>
      'Adds or removes sets: positive adds (clones last set), negative removes from end.';

  @override
  String get macroActHelpInjectTemplate =>
      'Injects a mesocycle from an existing template by ID. Placement and conflict strategy can be set.';

  @override
  String get macroActHelpInjectExisting =>
      'Injects an existing mesocycle by ID from database. Specify ID and placement.';

  @override
  String get macroActHelpInjectCustom =>
      'Creates a custom mesocycle: duration in weeks, microcycle length in days, rest days, and focus tags.';

  @override
  String get macroActErrPct => 'Change must be greater than -100%.';

  @override
  String get macroActErrRpe => 'Specify RPE from 1 to 10.';

  @override
  String get macroActErrInt => 'Specify an integer.';

  @override
  String get workoutPickerActivePlanNotFound => 'Active plan not found';

  @override
  String get userMaxWeakMusclesTitle => 'Weak muscles analysis';

  @override
  String get userMaxLlmEnriched => 'LLM enrichment enabled';

  @override
  String get userMaxTopWeakMuscles => 'Top weak muscles';

  @override
  String get noData => 'No data';

  @override
  String get userMaxStrengthByMuscle => 'Strength by muscle';

  @override
  String get userMaxTrends => 'Trends';

  @override
  String get userMaxAnomalies => 'Anomalies';

  @override
  String get userMaxNoneDetected => 'None detected';

  @override
  String userMaxAnalysisError(Object error) {
    return 'Analysis error: $error';
  }

  @override
  String userMaxExerciseFallback(Object id) {
    return 'Exercise $id';
  }

  @override
  String get userMaxDeleteTitle => 'Delete max?';

  @override
  String userMaxDeleteBody(Object exercise, Object reps, Object weight) {
    return '$exercise\n$weight kg × $reps reps';
  }

  @override
  String get userMaxDeleted => 'Max deleted';

  @override
  String userMaxDeleteError(Object error) {
    return 'Failed to delete max: $error';
  }

  @override
  String get userMaxDeleteTooltip => 'Delete max';

  @override
  String get chatPlanGenTitle => 'Plan generation (FSM)';

  @override
  String get chatPlanGenDesc =>
      'Starts a finite state machine dialog to build a training plan.';

  @override
  String get chatMassEditDesc => 'Mass edit plan using AI.';

  @override
  String get chatAssistantTitle => 'Assistant chat';

  @override
  String get chatInputHint => 'Type a message...';

  @override
  String get chatSendTooltip => 'Send';

  @override
  String get chatNoConnectionTooltip => 'No connection';

  @override
  String get chatStatusConnected => 'Connected';

  @override
  String get chatStatusConnecting => 'Connecting...';

  @override
  String get chatStatusReconnecting => 'Reconnecting...';

  @override
  String get chatStatusError => 'Connection error';

  @override
  String get chatStatusDisconnected => 'Disconnected';

  @override
  String get chatWorkoutLinkDesc => 'Link to workout in active plan';

  @override
  String get chatExerciseLinkDesc => 'Link to exercise';

  @override
  String chatSessionLabel(Object id) {
    return 'Session: $id';
  }

  @override
  String chatTypingStatus(Object session) {
    return 'Assistant is typing...$session';
  }

  @override
  String chatTypingSessionSuffix(Object id) {
    return ' (session $id)';
  }

  @override
  String loadErrorWithDetails(Object error) {
    return 'Load error: $error';
  }

  @override
  String listLoadErrorWithDetails(Object error) {
    return 'Failed to load list: $error';
  }

  @override
  String get chartMetricRepsTotal => 'Total reps';

  @override
  String get chartMetricRepsPerSetAvg => 'Reps per set (avg)';

  @override
  String get chartMetricKgAvg => 'Weight kg (avg)';

  @override
  String get chartMetricTonnage => 'Tonnage';

  @override
  String get chartMetricE1rm => '1RM (est.)';

  @override
  String get noOptions => 'No options';

  @override
  String get yAxisLabel => 'Y Axis';

  @override
  String get musclesTitle => 'Muscles';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusPlanned => 'Planned';

  @override
  String exerciseLoadError(Object error) {
    return 'Failed to load exercises: $error';
  }

  @override
  String get exerciseSelectTitle => 'Select exercise';

  @override
  String get exerciseSearchLabel => 'Search exercises';

  @override
  String get filterAll => 'All';

  @override
  String get exerciseEmptyTitle => 'No exercises found';

  @override
  String get exerciseEmptyDescription =>
      'Try changing the search query or muscle group.';

  @override
  String exerciseMuscleGroupMeta(Object group) {
    return 'Muscle group: $group';
  }

  @override
  String exerciseEquipmentMeta(Object equipment) {
    return 'Equipment: $equipment';
  }

  @override
  String get signInTitle => 'Sign in to continue';

  @override
  String get signInWelcomeBack => 'Welcome back! Sign in to your account.';

  @override
  String get signInCreateAccount => 'Create an account to start training.';

  @override
  String get signInLegalConsent =>
      'By continuing, you agree to the Terms of Service and acknowledge the Privacy Policy:';

  @override
  String get legalTermsOfService => 'Terms of Service';

  @override
  String get legalPrivacyPolicy => 'Privacy Policy';

  @override
  String get legalMedicalDisclaimer => 'Medical Disclaimer';

  @override
  String templateLoadError(Object error) {
    return 'Failed to load template: $error';
  }

  @override
  String get templateDetailsTitle => 'Template details';

  @override
  String get descriptionSectionHeader => 'DESCRIPTION';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutConfirmBody => 'Are you sure you want to sign out?';

  @override
  String get signOutAction => 'Sign out';

  @override
  String signOutError(Object error) {
    return 'Sign out error: $error';
  }

  @override
  String get noDisplayDataTitle => 'No data to display';

  @override
  String get workoutHistoryEmptyDesc =>
      'Completed sessions for this workout will appear here.';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsImportWorkouts => 'Import workouts';

  @override
  String get settingsImportWorkoutsSubtitle =>
      'Import Hevy CSV training history';

  @override
  String get settingsAmplitudeTest => 'Amplitude Test';

  @override
  String get settingsAmplitudeTestSubtitle =>
      'Diagnostics and funnel event telemetry';

  @override
  String get settingsGeneralTitle => 'General settings';

  @override
  String get settingsThemeMode => 'Theme mode';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsInterfaceSize => 'Interface size';

  @override
  String get settingsDensityCompact => 'Compact';

  @override
  String get settingsDensityCompactSubtitle => 'Less space between elements';

  @override
  String get settingsDensityComfortable => 'Comfortable';

  @override
  String get settingsDensityComfortableSubtitle =>
      'More space between elements';

  @override
  String get settingsDeleteAccountTitle => 'Delete account';

  @override
  String get settingsInterfaceConfig => 'Interface configuration';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsShowActivityChart => 'Show activity chart';

  @override
  String get settingsShowWorkoutHistory => 'Show workout history';

  @override
  String get settingsShowWorkoutAnalytics => 'Show workout analytics';

  @override
  String get settingsShowAllTime => 'Show all time';

  @override
  String get settingsUseHorizontalScroll => 'Use horizontal scroll';

  @override
  String get settingsTrainerControls => 'Trainer controls';

  @override
  String get settingsEnableCoaching => 'Enable coaching';

  @override
  String get settingsConnectStripe => 'Connect Stripe payouts';

  @override
  String get settingsConnectStripeSubtitle =>
      'Set up payment processing for coaching';

  @override
  String get settingsStripeConnected => 'Stripe connected';

  @override
  String get settingsStripeConnectedSubtitle => 'Payment processing is set up';

  @override
  String get settingsEnableCoachingFeatures => 'Enable coaching features';

  @override
  String get settingsTaglineLabel => 'Tagline';

  @override
  String get settingsDescriptionLabel => 'Description';

  @override
  String get settingsSpecializationsHeader => 'SPECIALIZATIONS';

  @override
  String get settingsLanguagesHeader => 'LANGUAGES';

  @override
  String get settingsRatePerMonthUsd => 'Rate per month (USD)';

  @override
  String get settingsTimezoneHint => 'e.g. Europe/Kyiv';

  @override
  String get importCreatedWorkouts => 'Created workouts';

  @override
  String get importTotalRows => 'Total rows in file';

  @override
  String get importRowErrors => 'Row errors';

  @override
  String get amplitudeSendTestEvent => 'Send Test Event';

  @override
  String get amplitudeSendCustomEvent => 'Send Custom Event';

  @override
  String get amplitudeShowDebugInfo => 'Show Debug Info';

  @override
  String get amplitudeTestFunnel => 'Test Time-to-First-Dollar Funnel';

  @override
  String get debugScreenTitle => 'Debug Screen';

  @override
  String get debugCoachChatTitle => 'Debug Coach Chat';

  @override
  String get debugChatEmbeddedTitle => 'Chat Screen (embedded)';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusPlannedLabel => 'Planned';

  @override
  String get reviewRatingHeader => 'RATING';

  @override
  String get reviewCommentHeader => 'COMMENT (OPTIONAL)';

  @override
  String get reviewShareExperienceHint => 'Share your experience...';

  @override
  String get actionSubmit => 'Submit';

  @override
  String get reviewSubmittedSuccess => 'Review submitted successfully';

  @override
  String get sessionStartedHeader => 'STARTED';

  @override
  String get sessionFinishedHeader => 'FINISHED';

  @override
  String get sessionDurationHeader => 'DURATION';

  @override
  String get sessionCompletedSetsHeader => 'COMPLETED SETS';

  @override
  String get planCardTargetSessionLength => 'Target session length';

  @override
  String get avatarTooltip => 'Avatar';

  @override
  String get profileLoadErrorEyebrow => 'PROFILE LOAD ERROR';

  @override
  String failedToLoadProfile(Object error) {
    return 'Failed to load profile: $error';
  }

  @override
  String get appearanceEyebrow => 'APPEARANCE';

  @override
  String get layoutScaleEyebrow => 'LAYOUT SCALE';

  @override
  String get sessionAccessEyebrow => 'SESSION ACCESS';

  @override
  String get irreversibleActionEyebrow => 'IRREVERSIBLE ACTION';

  @override
  String get deleteAccountConfirmMessage =>
      'This will schedule deletion of your account data. Continue?';

  @override
  String get appearanceAndLocaleEyebrow => 'APPEARANCE & LOCALE';

  @override
  String get profileTelemetryEyebrow => 'PROFILE TELEMETRY';

  @override
  String get visibilityAndCharts => 'Visibility & charts';

  @override
  String get coachingAndPayoutsEyebrow => 'COACHING & PAYOUTS';

  @override
  String get notAvailableForAccount => 'Not available for this account';

  @override
  String get accountZoneEyebrow => 'ACCOUNT ZONE';

  @override
  String get sessionAndDataTitle => 'Session & data';

  @override
  String get notSetLabel => 'Not set';

  @override
  String get ratePerMonthHelper =>
      'Amount is entered in dollars (e.g. 120 = \$120.00).';

  @override
  String get addMuscleTagLabel => 'Add muscle tag';

  @override
  String get typeToSearchHint => 'Type to search...';

  @override
  String get failedToReadFileBytes => 'Failed to read selected file bytes';

  @override
  String get gifUploaded => 'GIF uploaded';

  @override
  String get imageUploaded => 'Image uploaded';

  @override
  String uploadFailed(Object error) {
    return 'Upload failed: $error';
  }

  @override
  String get editExerciseTitle => 'Edit Exercise';

  @override
  String get createExerciseTitle => 'Create Exercise';

  @override
  String get nameLabel => 'Name';

  @override
  String get muscleGroupLabel => 'Muscle group';

  @override
  String get selectGroupHint => 'Select group';

  @override
  String get movementTypeLabel => 'Movement type';

  @override
  String get movementTypeCompound => 'Compound';

  @override
  String get movementTypeIsolation => 'Isolation';

  @override
  String get regionLabel => 'Region';

  @override
  String get regionUpper => 'Upper';

  @override
  String get regionLower => 'Lower';

  @override
  String failedToUpdateExercise(Object error) {
    return 'Failed to update exercise: $error';
  }

  @override
  String failedToCreateExercise(Object error) {
    return 'Failed to create exercise: $error';
  }

  @override
  String get create => 'Create';

  @override
  String get exercisesTitle => 'Exercises';

  @override
  String errorLoadingExercises(Object error) {
    return 'Error loading exercises: $error';
  }

  @override
  String get noExercisesTitle => 'No Exercises';

  @override
  String get noExercisesDescription =>
      'No exercises found. Add your first exercise!';

  @override
  String get noMuscleGroup => 'No muscle group';

  @override
  String get noEquipment => 'No equipment';

  @override
  String get uploadImageTooltip => 'Upload Image';

  @override
  String get deleteExerciseQuestion => 'Delete exercise?';

  @override
  String failedToDeleteExercise(Object error) {
    return 'Failed to delete exercise: $error';
  }

  @override
  String get exerciseTitle => 'Exercise';

  @override
  String failedToLoadExercise(Object error) {
    return 'Failed to load exercise: $error';
  }

  @override
  String get exerciseNotFoundTitle => 'Exercise not found';

  @override
  String get muscleGroupHeader => 'MUSCLE GROUP';

  @override
  String get equipmentHeader => 'EQUIPMENT';

  @override
  String get movementTypeHeader => 'MOVEMENT TYPE';

  @override
  String get regionHeader => 'REGION';

  @override
  String get targetMusclesHeader => 'TARGET MUSCLES';

  @override
  String get synergistMusclesHeader => 'SYNERGIST MUSCLES';

  @override
  String get parentExerciseEyebrow => 'PARENT EXERCISE';

  @override
  String get baseMovementTitle => 'Base Movement';

  @override
  String get directVariantsTitle => 'Direct Variants';

  @override
  String get relatedSiblingsTitle => 'Related Siblings';

  @override
  String failedToLoadData(Object error) {
    return 'Failed to load data: $error';
  }

  @override
  String errorSaving(Object error) {
    return 'Error saving: $error';
  }

  @override
  String get progressionTemplateOptionalLabel =>
      'Progression Template (optional)';

  @override
  String get selectTemplateHint => 'Select template';

  @override
  String get noTemplateOption => 'No template';

  @override
  String get saveExercise => 'Save Exercise';

  @override
  String get exerciseDetailsTitle => 'Exercise Details';

  @override
  String get exerciseNameLabel => 'Exercise Name';

  @override
  String get sets => 'Sets';

  @override
  String get addSet => 'Add Set';

  @override
  String get removeSetTooltip => 'Remove set';

  @override
  String get catalogEntryEyebrow => 'CATALOG ENTRY';

  @override
  String get destructiveActionEyebrow => 'DESTRUCTIVE ACTION';

  @override
  String get allLabel => 'All';

  @override
  String get tryChangingFilterOrAddExercise =>
      'Try changing the filter or add a new exercise';

  @override
  String get sexLabel => 'Sex';

  @override
  String get sexMale => 'Male';

  @override
  String get sexFemale => 'Female';

  @override
  String get experienceLevelLabel => 'Experience level';

  @override
  String get experienceBeginner => 'Beginner';

  @override
  String get experienceIntermediate => 'Intermediate';

  @override
  String get experienceAdvanced => 'Advanced';

  @override
  String get primaryGoalLabel => 'Primary goal';

  @override
  String get goalStrength => 'Strength';

  @override
  String get goalHypertrophy => 'Hypertrophy';

  @override
  String get goalFatLoss => 'Fat loss';

  @override
  String get goalGeneralFitness => 'General fitness';

  @override
  String get trainingEnvironmentLabel => 'Training environment';

  @override
  String get envCommercialGym => 'Commercial gym';

  @override
  String get envHome => 'Home';

  @override
  String get envGarage => 'Garage';

  @override
  String failedToApply(Object error) {
    return 'Failed to apply: $error';
  }

  @override
  String get useAsProfilePicture => 'Use as profile picture';

  @override
  String get describeYourAvatarHint => 'Describe your avatar';

  @override
  String failedWithError(Object error) {
    return 'Failed: $error';
  }

  @override
  String get generate => 'Generate';

  @override
  String failedToLoadAnalytics(Object error) {
    return 'Failed to load analytics: $error';
  }

  @override
  String get addSeriesTooltip => 'Add series';

  @override
  String get clearTooltip => 'Clear';

  @override
  String failedToApplyReadiness(Object error) {
    return 'Failed to apply readiness: $error';
  }

  @override
  String get failedToUpdateSetNotReady =>
      'Failed to update set: app state not ready';

  @override
  String failedToUpdateSet(Object error) {
    return 'Failed to update set: $error';
  }

  @override
  String get deleteExerciseTitle => 'Delete Exercise';

  @override
  String get exerciseRemovedFromWorkout => 'Exercise removed from workout';

  @override
  String get errorCannotDeleteUnsavedExercise =>
      'Error: Cannot delete unsaved exercise';

  @override
  String failedToRemoveExercise(Object error) {
    return 'Failed to remove exercise: $error';
  }

  @override
  String get cannotAddSetUnsavedExercise =>
      'Cannot add set: exercise is not saved yet';

  @override
  String get setAddedSuccessfully => 'Set added successfully';

  @override
  String failedToAddSet(Object error) {
    return 'Failed to add set: $error';
  }

  @override
  String failedToLoadExercises(Object error) {
    return 'Failed to load exercises: $error';
  }

  @override
  String get workoutUpdated => 'Workout updated';

  @override
  String failedToUpdateWorkout(Object error) {
    return 'Failed to update workout: $error';
  }

  @override
  String get workoutStarted => 'Workout started';

  @override
  String failedToStartSession(Object error) {
    return 'Failed to start session: $error';
  }

  @override
  String get sessionCancelled => 'Session cancelled';

  @override
  String get workoutFinished => 'Workout finished';

  @override
  String failedToFinishSession(Object error) {
    return 'Failed to finish session: $error';
  }

  @override
  String get allSetsAlreadyCompleted => 'All sets are already completed';

  @override
  String failedToCompleteAllSets(Object error) {
    return 'Failed to complete all sets: $error';
  }

  @override
  String failedToUpdateSetCompletion(Object error) {
    return 'Failed to update set completion: $error';
  }

  @override
  String get deleteSetTitle => 'Delete Set';

  @override
  String get deleteSetConfirmMessage =>
      'Are you sure you want to delete this set? This action cannot be undone.';

  @override
  String get setDeletedSuccessfully => 'Set deleted successfully';

  @override
  String failedToDeleteSet(Object error) {
    return 'Failed to delete set: $error';
  }

  @override
  String get exerciseAddedSuccessfully => 'Exercise added successfully';

  @override
  String failedToAddExercise(Object error) {
    return 'Failed to add exercise: $error';
  }

  @override
  String get exerciseUpdatedSuccessfully => 'Exercise updated successfully';

  @override
  String errorUpdatingExercise(Object error) {
    return 'Error updating exercise: $error';
  }

  @override
  String setCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count SETS',
      one: '1 SET',
    );
    return '$_temp0';
  }

  @override
  String get userMaxesTitle => 'User Maxes';

  @override
  String get noMaxesSavedTitle => 'No maxes saved';

  @override
  String get addFirstMaxWeightDescription => 'Add your first max weight';

  @override
  String get allSessionsLabel => 'All sessions';

  @override
  String get resetDatesTooltip => 'Reset dates';

  @override
  String get collapseCalendarTooltip => 'Collapse calendar';

  @override
  String get selectDateRangeTooltip => 'Select date range';

  @override
  String get calendarMonthLabel => 'Month';

  @override
  String get primaryMetricTrendHeader => 'PRIMARY METRIC (TREND)';

  @override
  String get trendLabel => 'Trend';

  @override
  String get exerciseDetailNotFoundDescription =>
      'The requested exercise definition could not be located.';

  @override
  String variantsCountEyebrow(Object count) {
    return 'VARIANTS · $count';
  }

  @override
  String otherVariantsCountEyebrow(Object count) {
    return 'OTHER VARIANTS · $count';
  }

  @override
  String failedToLoadGroups(Object error) {
    return 'Failed to load groups: $error';
  }

  @override
  String deleteExerciseConfirmBody(Object name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get exerciseSpecEyebrow => '01 · EXERCISE SPEC';

  @override
  String get pleaseEnterNameValidation => 'Please enter a name';

  @override
  String prescribedSetsEyebrow(Object count) {
    return '02 · PRESCRIBED SETS ($count)';
  }

  @override
  String get requiredField => 'Required';

  @override
  String setNumberLabel(Object number) {
    return 'SET #$number';
  }

  @override
  String get removeExerciseConfirmBody =>
      'Are you sure you want to remove this exercise from your workout?';

  @override
  String allSetsMarkedCompleted(Object count) {
    return 'All sets marked as completed ($count)';
  }

  @override
  String markedSetsPartial(Object failed, Object success) {
    return 'Marked $success sets, failed $failed';
  }

  @override
  String get myAthletesTitle => 'My Athletes';

  @override
  String get thresholdsAndFiltersTooltip => 'Thresholds & filters';

  @override
  String get allSegmentsLabel => 'All segments';

  @override
  String get recentlyActiveLabel => 'Recently active';

  @override
  String get sessionsPerWeekLabel => 'Sessions / wk';

  @override
  String get adherenceLabel => 'Adherence';

  @override
  String get visibleMetricLabel => 'VISIBLE';

  @override
  String get linksMetricLabel => 'LINKS';

  @override
  String get avgSessionsPerWeekMetricLabel => 'AVG S / WK';

  @override
  String get atRiskMetricLabel => 'AT RISK';

  @override
  String get rosterFiltersEyebrow => 'ROSTER FILTERS';

  @override
  String get thresholdsFilterTitle => 'Thresholds & filters';

  @override
  String get resetLabel => 'Reset';

  @override
  String get doneLabel => 'Done';

  @override
  String get viewDetailedAnalyticsLabel => 'View detailed analytics';

  @override
  String get sessionsUpperLabel => 'SESSIONS';

  @override
  String get sessionsPerWeekUpperLabel => 'S / WK';

  @override
  String get planPercentUpperLabel => 'PLAN %';

  @override
  String get rpeDistributionUpperLabel => 'RPE DISTRIBUTION';

  @override
  String get allUsersTitle => 'All Users';

  @override
  String get filterCoachesLabel => 'Filter coaches';

  @override
  String get coachDirectoryEyebrow => 'COACH DIRECTORY';

  @override
  String get filterCoachesTitle => 'Filter Coaches';

  @override
  String get allUsersPillLabel => 'All users';

  @override
  String get coachesOnlyPillLabel => 'Coaches only';

  @override
  String get filtersActiveLabel => 'Filters · Active';

  @override
  String get showingUpperLabel => 'SHOWING';

  @override
  String get publicUpperLabel => 'PUBLIC';

  @override
  String get coachesUpperLabel => 'COACHES';

  @override
  String get sortUpperLabel => 'SORT';

  @override
  String get minRateUsdLabel => 'Min Rate (\$)';

  @override
  String get maxRateUsdLabel => 'Max Rate (\$)';

  @override
  String get sortByLabel => 'Sort By';

  @override
  String get sortCreatedAt => 'Created At';

  @override
  String get sortRating => 'Rating';

  @override
  String get sortLastActive => 'Last Active';

  @override
  String get applyFiltersLabel => 'Apply Filters';

  @override
  String get volumeUpperLabel => 'VOLUME';

  @override
  String get sessPerWeekUpperLabel => 'SESS / WK';

  @override
  String get intensityUpperLabel => 'INTENSITY';

  @override
  String get avgRpeUpperLabel => 'AVG RPE';

  @override
  String get lastDayUpperLabel => 'LAST DAY';

  @override
  String get daysGapUpperLabel => 'DAYS GAP';

  @override
  String get crmTitle => 'CRM';

  @override
  String get activeUpperLabel => 'ACTIVE';

  @override
  String get engagedUpperLabel => 'ENGAGED';

  @override
  String get inactiveUpperLabel => 'INACTIVE';

  @override
  String get viewAthletesListLabel => 'View athletes list';

  @override
  String get relationshipsAndChatLabel => 'Relationships & chat';

  @override
  String get lastUpperLabel => 'LAST';

  @override
  String get planUpperLabel => 'PLAN';

  @override
  String get relationshipEyebrow => 'RELATIONSHIP';

  @override
  String failedToSendError(Object error) {
    return 'Failed to send: $error';
  }

  @override
  String get typeMessageHint => 'Type a message...';

  @override
  String get sendMessageTooltip => 'Send message';

  @override
  String get adherenceUpperLabel => 'ADHERENCE';

  @override
  String get startUpperLabel => 'START';

  @override
  String get endUpperLabel => 'END';

  @override
  String get workoutNotesEyebrow => 'WORKOUT NOTES';

  @override
  String get removeExerciseEyebrow => 'REMOVE EXERCISE';

  @override
  String get exerciseEditorEyebrow => 'EXERCISE EDITOR';

  @override
  String get massEditLabel => 'Mass edit';

  @override
  String get myCoachesTitle => 'My Coaches';

  @override
  String get analyticsLabel => 'Analytics';

  @override
  String get chatLabel => 'Chat';

  @override
  String get subscribeLabel => 'Subscribe';

  @override
  String get invalidCheckoutUrl => 'Invalid checkout URL';

  @override
  String get cannotOpenCheckoutUrl => 'Cannot open checkout URL';

  @override
  String get profileTitle => 'Profile';

  @override
  String get coachingRequestEyebrow => 'COACHING REQUEST';

  @override
  String requestCoachingFromTitle(Object name) {
    return 'Request coaching from $name';
  }

  @override
  String get messageOptionalLabel => 'Message (optional)';

  @override
  String get sendLabel => 'Send';

  @override
  String get requestSentMessage => 'Request sent';

  @override
  String get writeReviewLabel => 'Write a Review';

  @override
  String cannotReviewError(Object error) {
    return 'Cannot review: $error';
  }

  @override
  String get workoutFeedTitle => 'Workout Feed';

  @override
  String get allPostsLabel => 'All posts';

  @override
  String get withStatsLabel => 'With stats';

  @override
  String get likedLabel => 'Liked';

  @override
  String get createPostLabel => 'Create Post';

  @override
  String get socialFeedEyebrow => 'SOCIAL FEED';

  @override
  String get visibilityUpperLabel => 'VISIBILITY';

  @override
  String get visibilityPublic => 'Public';

  @override
  String get visibilityFollowers => 'Followers';

  @override
  String get visibilityPrivate => 'Private';

  @override
  String get postLabel => 'Post';

  @override
  String get likeLabel => 'Like';

  @override
  String errorLoadingItems(Object error) {
    return 'Error loading items: $error';
  }

  @override
  String addItemTitle(Object name) {
    return 'Add $name';
  }

  @override
  String get itemGenericName => 'Item';

  @override
  String dosageWithUnitLabel(Object unit) {
    return 'Dosage ($unit)';
  }

  @override
  String get addLabel => 'Add';

  @override
  String genericError(Object error) {
    return 'Error: $error';
  }

  @override
  String get sessionConfigurationTitle => 'Session Configuration';

  @override
  String get sessionIdLabel => 'Session ID';

  @override
  String get workoutIdOptionalLabel => 'Workout ID (optional)';

  @override
  String get appliedPlanWorkoutIdOptionalLabel =>
      'Applied Plan Workout ID (optional)';

  @override
  String get selectedEntriesTitle => 'Selected Entries';

  @override
  String get availableItemsTitle => 'Available Items';

  @override
  String get removeEntryTooltip => 'Remove entry';

  @override
  String get addEntryTooltip => 'Add entry';

  @override
  String get deleteSessionTitle => 'Delete Session';

  @override
  String get deleteSessionConfirm =>
      'Are you sure you want to delete this session?';

  @override
  String get sessionDeletedSuccess => 'Session deleted successfully';

  @override
  String get editSessionTooltip => 'Edit session';

  @override
  String get deleteSessionTooltip => 'Delete session';

  @override
  String get kcalUpperLabel => 'KCAL';

  @override
  String get proteinUpperLabel => 'PROTEIN';

  @override
  String get fatUpperLabel => 'FAT';

  @override
  String get carbUpperLabel => 'CARB';

  @override
  String get activeNutritionPlanTitle => 'Active Nutrition Plan';

  @override
  String get noActiveCalendarPlan => 'No active calendar plan';

  @override
  String get noNutritionPlanConfigured => 'No nutrition plan configured';

  @override
  String get createSessionTooltip => 'Create session';

  @override
  String failedToLoadNutritionSessions(Object error) {
    return 'Failed to load nutrition sessions: $error';
  }

  @override
  String get createSessionButton => 'Create Session';

  @override
  String get pleaseEnterPlanName => 'Please enter a plan name';

  @override
  String get planCreatedSuccess => 'Plan created successfully';

  @override
  String failedToCreatePlan(Object error) {
    return 'Failed to create plan: $error';
  }

  @override
  String get createCalendarPlanTitle => 'Create Calendar Plan';

  @override
  String get planNameLabel => 'Plan Name';

  @override
  String get addMesocycleLabel => 'Add Mesocycle';

  @override
  String get removeMesocycleTooltip => 'Remove Mesocycle';

  @override
  String get mesocycleNameLabel => 'Mesocycle Name';

  @override
  String get microcyclesLabel => 'Microcycles';

  @override
  String get microcycleLengthDaysLabel => 'Microcycle Length (days)';

  @override
  String get addExerciseLabel => 'Add exercise';

  @override
  String get planAppliedSuccess => 'Plan applied successfully';

  @override
  String get applyPlanButton => 'Apply Plan';

  @override
  String get noPlanWorkoutsAvailable => 'No plan workouts available';

  @override
  String get removeRuleEyebrow => 'REMOVE RULE';

  @override
  String get deleteMacroTitle => 'Delete Macro';

  @override
  String get planMacrosTitle => 'Plan Macros';

  @override
  String get previewApplyTooltip => 'Preview/Apply';

  @override
  String get addMacroLabel => 'Add Macro';

  @override
  String get noMacrosYet => 'No macros yet';

  @override
  String allCountLabel(Object count) {
    return 'All ($count)';
  }

  @override
  String get noMatchingMacros => 'No matching macros';

  @override
  String get switchFilterToViewRules => 'Switch filter above to view rules.';

  @override
  String get macroSuggestionsEyebrow => 'MACRO SUGGESTIONS';

  @override
  String get sessionHistoryTitle => 'Session History';

  @override
  String get loadSessionsLabel => 'Load sessions';

  @override
  String get clearFilterLabel => 'Clear filter';

  @override
  String errorLoadingHistory(Object error) {
    return 'Error loading history: $error';
  }

  @override
  String get noSessionsFound => 'No sessions found';

  @override
  String get tryChangingYourFilter => 'Try changing your filter';

  @override
  String sessionNumberTitle(Object id) {
    return 'Session #$id';
  }

  @override
  String get workoutIdUpperLabel => 'WORKOUT ID';

  @override
  String get statusUpperLabel => 'STATUS';

  @override
  String get startedUpperLabel => 'STARTED';

  @override
  String get finishedUpperLabel => 'FINISHED';

  @override
  String get durationUpperLabel => 'DURATION';

  @override
  String get noExerciseDataForWorkout =>
      'No exercise data available for this workout';

  @override
  String get repsUpperLabel => 'REPS';

  @override
  String get plannedUpperLabel => 'PLANNED';

  @override
  String get actualUpperLabel => 'ACTUAL';

  @override
  String get thresholdsLabel => 'Thresholds';

  @override
  String get rosterTelemetryEyebrow => 'ROSTER TELEMETRY';

  @override
  String minSessionsPerWeekSliderLabel(Object value) {
    return 'Min sessions / week: $value';
  }

  @override
  String minAdherenceSliderLabel(Object percent) {
    return 'Min adherence: $percent%';
  }

  @override
  String get workflowsChannelsEyebrow => 'WORKFLOWS · CHANNELS';

  @override
  String get userIdFieldLabel => 'User ID';
}
