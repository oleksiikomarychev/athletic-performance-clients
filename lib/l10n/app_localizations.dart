import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout App'**
  String get appTitle;

  /// No description provided for @missingAthleteId.
  ///
  /// In en, this message translates to:
  /// **'Missing athleteId'**
  String get missingAthleteId;

  /// No description provided for @missingChatArguments.
  ///
  /// In en, this message translates to:
  /// **'Missing chat arguments'**
  String get missingChatArguments;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @exerciseName.
  ///
  /// In en, this message translates to:
  /// **'Exercise name'**
  String get exerciseName;

  /// No description provided for @exerciseListEmptyNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter an exercise name'**
  String get exerciseListEmptyNameError;

  /// No description provided for @activePlanLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load plan: {error}'**
  String activePlanLoadError(Object error);

  /// No description provided for @activePlanNoWorkoutsOnDay.
  ///
  /// In en, this message translates to:
  /// **'No workouts on this day'**
  String get activePlanNoWorkoutsOnDay;

  /// No description provided for @activePlanNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get activePlanNotesLabel;

  /// No description provided for @coachAthletePlanNoActivePlan.
  ///
  /// In en, this message translates to:
  /// **'No active plan'**
  String get coachAthletePlanNoActivePlan;

  /// No description provided for @coachAthletePlanSetsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get coachAthletePlanSetsLabel;

  /// No description provided for @coachAthletePlanMassEditExerciseHint.
  ///
  /// In en, this message translates to:
  /// **'Enter note for exercises'**
  String get coachAthletePlanMassEditExerciseHint;

  /// No description provided for @coachAthletePlanMassEditError.
  ///
  /// In en, this message translates to:
  /// **'Mass edit error: {error}'**
  String coachAthletePlanMassEditError(Object error);

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @noDate.
  ///
  /// In en, this message translates to:
  /// **'no date'**
  String get noDate;

  /// No description provided for @idPrefix.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String idPrefix(Object id);

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @changes.
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get changes;

  /// No description provided for @statuses.
  ///
  /// In en, this message translates to:
  /// **'Statuses: {statuses}'**
  String statuses(Object statuses);

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises: {exercises}'**
  String exercises(Object exercises);

  /// No description provided for @workoutsAffected.
  ///
  /// In en, this message translates to:
  /// **'Workouts affected: {count}'**
  String workoutsAffected(Object count);

  /// No description provided for @workoutsShifted.
  ///
  /// In en, this message translates to:
  /// **'Workouts shifted: {count}'**
  String workoutsShifted(Object count);

  /// No description provided for @setsModified.
  ///
  /// In en, this message translates to:
  /// **'Sets modified: {count}'**
  String setsModified(Object count);

  /// No description provided for @setsToBeModified.
  ///
  /// In en, this message translates to:
  /// **'Sets to be modified: {count}'**
  String setsToBeModified(Object count);

  /// No description provided for @shiftDays.
  ///
  /// In en, this message translates to:
  /// **'Shift: {sign}{days} d.'**
  String shiftDays(Object sign, Object days);

  /// No description provided for @startingFrom.
  ///
  /// In en, this message translates to:
  /// **'Starting from: {date}'**
  String startingFrom(Object date);

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date (inclusive): {date}'**
  String upToDate(Object date);

  /// No description provided for @onlyFutureWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Only future workouts'**
  String get onlyFutureWorkouts;

  /// No description provided for @dateNotEarlierThan.
  ///
  /// In en, this message translates to:
  /// **'Date not earlier than {date}'**
  String dateNotEarlierThan(Object date);

  /// No description provided for @dateNotLaterThan.
  ///
  /// In en, this message translates to:
  /// **'Date not later than {date}'**
  String dateNotLaterThan(Object date);

  /// No description provided for @clampNonNegative.
  ///
  /// In en, this message translates to:
  /// **'Do not allow negative values'**
  String get clampNonNegative;

  /// No description provided for @replaceExerciseTo.
  ///
  /// In en, this message translates to:
  /// **'Replace exercise to {name} (ID {id})'**
  String replaceExerciseTo(Object name, Object id);

  /// No description provided for @renameExerciseTo.
  ///
  /// In en, this message translates to:
  /// **'Rename exercise to \"{name}\"'**
  String renameExerciseTo(Object name);

  /// No description provided for @addNewExercises.
  ///
  /// In en, this message translates to:
  /// **'Add new exercises: {count}'**
  String addNewExercises(Object count);

  /// No description provided for @setIntensity.
  ///
  /// In en, this message translates to:
  /// **'Set intensity = {value}'**
  String setIntensity(Object value);

  /// No description provided for @increaseIntensityBy.
  ///
  /// In en, this message translates to:
  /// **'Increase intensity by {value}'**
  String increaseIntensityBy(Object value);

  /// No description provided for @decreaseIntensityBy.
  ///
  /// In en, this message translates to:
  /// **'Decrease intensity by {value}'**
  String decreaseIntensityBy(Object value);

  /// No description provided for @setVolume.
  ///
  /// In en, this message translates to:
  /// **'Set reps = {value}'**
  String setVolume(Object value);

  /// No description provided for @increaseVolumeBy.
  ///
  /// In en, this message translates to:
  /// **'Increase reps by {value}'**
  String increaseVolumeBy(Object value);

  /// No description provided for @decreaseVolumeBy.
  ///
  /// In en, this message translates to:
  /// **'Decrease reps by {value}'**
  String decreaseVolumeBy(Object value);

  /// No description provided for @setWeight.
  ///
  /// In en, this message translates to:
  /// **'Set weight = {value} kg'**
  String setWeight(Object value);

  /// No description provided for @increaseWeightBy.
  ///
  /// In en, this message translates to:
  /// **'Increase weight by {value} kg'**
  String increaseWeightBy(Object value);

  /// No description provided for @decreaseWeightBy.
  ///
  /// In en, this message translates to:
  /// **'Decrease weight by {value} kg'**
  String decreaseWeightBy(Object value);

  /// No description provided for @setEffort.
  ///
  /// In en, this message translates to:
  /// **'Set RPE = {value}'**
  String setEffort(Object value);

  /// No description provided for @increaseEffortBy.
  ///
  /// In en, this message translates to:
  /// **'Increase RPE by {value}'**
  String increaseEffortBy(Object value);

  /// No description provided for @decreaseEffortBy.
  ///
  /// In en, this message translates to:
  /// **'Decrease RPE by {value}'**
  String decreaseEffortBy(Object value);

  /// No description provided for @massEditPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Active plan mass edit preview'**
  String get massEditPreviewTitle;

  /// No description provided for @massEditAppliedTitle.
  ///
  /// In en, this message translates to:
  /// **'Active plan changes applied'**
  String get massEditAppliedTitle;

  /// No description provided for @scheduleShiftPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Active plan schedule shift preview'**
  String get scheduleShiftPreviewTitle;

  /// No description provided for @scheduleShiftTitle.
  ///
  /// In en, this message translates to:
  /// **'Active plan schedule shift applied'**
  String get scheduleShiftTitle;

  /// No description provided for @shiftParameters.
  ///
  /// In en, this message translates to:
  /// **'Shift parameters'**
  String get shiftParameters;

  /// No description provided for @modeChangeIntervals.
  ///
  /// In en, this message translates to:
  /// **'Mode: change intervals between workouts'**
  String get modeChangeIntervals;

  /// No description provided for @modeScheduleShift.
  ///
  /// In en, this message translates to:
  /// **'Mode: schedule shift'**
  String get modeScheduleShift;

  /// No description provided for @macroActionByPercent.
  ///
  /// In en, this message translates to:
  /// **'By Percent'**
  String get macroActionByPercent;

  /// No description provided for @macroActionToTarget.
  ///
  /// In en, this message translates to:
  /// **'To Target (RPE)'**
  String get macroActionToTarget;

  /// No description provided for @macroActionByValue.
  ///
  /// In en, this message translates to:
  /// **'By Value'**
  String get macroActionByValue;

  /// No description provided for @macroActionByTemplate.
  ///
  /// In en, this message translates to:
  /// **'By Template'**
  String get macroActionByTemplate;

  /// No description provided for @macroActionByExisting.
  ///
  /// In en, this message translates to:
  /// **'By Existing (ID)'**
  String get macroActionByExisting;

  /// No description provided for @macroActionCreateManual.
  ///
  /// In en, this message translates to:
  /// **'Create Manually'**
  String get macroActionCreateManual;

  /// No description provided for @macroActionHintPercent.
  ///
  /// In en, this message translates to:
  /// **'percent, e.g. -5 or 2.5'**
  String get macroActionHintPercent;

  /// No description provided for @macroActionHintReps.
  ///
  /// In en, this message translates to:
  /// **'reps delta, e.g. +1 or -1'**
  String get macroActionHintReps;

  /// No description provided for @macroActionHintTargetRpe.
  ///
  /// In en, this message translates to:
  /// **'target RPE, e.g. 8'**
  String get macroActionHintTargetRpe;

  /// No description provided for @macroActionHintSets.
  ///
  /// In en, this message translates to:
  /// **'±N sets, e.g. 1 or -2'**
  String get macroActionHintSets;

  /// No description provided for @macroActionHintGeneric.
  ///
  /// In en, this message translates to:
  /// **'value'**
  String get macroActionHintGeneric;

  /// No description provided for @macroActionAdjustLoad.
  ///
  /// In en, this message translates to:
  /// **'Adjust Load'**
  String get macroActionAdjustLoad;

  /// No description provided for @macroActionAdjustReps.
  ///
  /// In en, this message translates to:
  /// **'Adjust Reps'**
  String get macroActionAdjustReps;

  /// No description provided for @macroActionAdjustSets.
  ///
  /// In en, this message translates to:
  /// **'Adjust Sets'**
  String get macroActionAdjustSets;

  /// No description provided for @macroActionInjectMesocycle.
  ///
  /// In en, this message translates to:
  /// **'Inject Mesocycle'**
  String get macroActionInjectMesocycle;

  /// No description provided for @macroActionTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Action Type'**
  String get macroActionTypeLabel;

  /// No description provided for @macroActionModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get macroActionModeLabel;

  /// No description provided for @macroActionValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get macroActionValueLabel;

  /// No description provided for @macroActionNoTemplates.
  ///
  /// In en, this message translates to:
  /// **'No mesocycle templates'**
  String get macroActionNoTemplates;

  /// No description provided for @macroActionTemplateLabel.
  ///
  /// In en, this message translates to:
  /// **'Mesocycle Template'**
  String get macroActionTemplateLabel;

  /// No description provided for @macroActionLoadTemplatesError.
  ///
  /// In en, this message translates to:
  /// **'Error loading templates: {error}'**
  String macroActionLoadTemplatesError(Object error);

  /// No description provided for @macroActionMesoLabel.
  ///
  /// In en, this message translates to:
  /// **'Mesocycle {index}'**
  String macroActionMesoLabel(Object index);

  /// No description provided for @macroActionChooseMeso.
  ///
  /// In en, this message translates to:
  /// **'Choose Mesocycle'**
  String get macroActionChooseMeso;

  /// No description provided for @macroActionOtherId.
  ///
  /// In en, this message translates to:
  /// **'Other (enter ID)'**
  String get macroActionOtherId;

  /// No description provided for @macroActionExistingIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Existing mesocycle ID'**
  String get macroActionExistingIdLabel;

  /// No description provided for @macroActionEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get macroActionEnterNumber;

  /// No description provided for @macroActionDurationWeeks.
  ///
  /// In en, this message translates to:
  /// **'Duration (weeks)'**
  String get macroActionDurationWeeks;

  /// No description provided for @macroActionDaysInMicro.
  ///
  /// In en, this message translates to:
  /// **'Days in microcycle'**
  String get macroActionDaysInMicro;

  /// No description provided for @macroActionDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day {index}: {type}'**
  String macroActionDayLabel(Object index, Object type);

  /// No description provided for @macroActionRest.
  ///
  /// In en, this message translates to:
  /// **'rest'**
  String get macroActionRest;

  /// No description provided for @macroActionWork.
  ///
  /// In en, this message translates to:
  /// **'workout'**
  String get macroActionWork;

  /// No description provided for @macroActionFocusTags.
  ///
  /// In en, this message translates to:
  /// **'Focus Tags'**
  String get macroActionFocusTags;

  /// No description provided for @macroActionPlacement.
  ///
  /// In en, this message translates to:
  /// **'Placement'**
  String get macroActionPlacement;

  /// No description provided for @macroActionAppendEnd.
  ///
  /// In en, this message translates to:
  /// **'Append to end'**
  String get macroActionAppendEnd;

  /// No description provided for @macroActionInsertAfterWorkout.
  ///
  /// In en, this message translates to:
  /// **'After workout'**
  String get macroActionInsertAfterWorkout;

  /// No description provided for @macroActionInsertAfterMeso.
  ///
  /// In en, this message translates to:
  /// **'After mesocycle'**
  String get macroActionInsertAfterMeso;

  /// No description provided for @macroActionSelectAnchorWorkout.
  ///
  /// In en, this message translates to:
  /// **'Select anchor workout'**
  String get macroActionSelectAnchorWorkout;

  /// No description provided for @macroActionPickWorkout.
  ///
  /// In en, this message translates to:
  /// **'Pick workout'**
  String get macroActionPickWorkout;

  /// No description provided for @macroActionNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get macroActionNotSelected;

  /// No description provided for @macroActionAfterAnchor.
  ///
  /// In en, this message translates to:
  /// **'After: {name}'**
  String macroActionAfterAnchor(Object name);

  /// No description provided for @macroActionNoMesoInPlan.
  ///
  /// In en, this message translates to:
  /// **'No mesocycles in plan'**
  String get macroActionNoMesoInPlan;

  /// No description provided for @macroActionMesoIndexLabel.
  ///
  /// In en, this message translates to:
  /// **'Mesocycle: '**
  String get macroActionMesoIndexLabel;

  /// No description provided for @macroActionConflicts.
  ///
  /// In en, this message translates to:
  /// **'Conflicts'**
  String get macroActionConflicts;

  /// No description provided for @macroActionReplacePlanned.
  ///
  /// In en, this message translates to:
  /// **'Replace planned'**
  String get macroActionReplacePlanned;

  /// No description provided for @macroActionShiftForward.
  ///
  /// In en, this message translates to:
  /// **'Shift forward'**
  String get macroActionShiftForward;

  /// No description provided for @macroActionSkipConflict.
  ///
  /// In en, this message translates to:
  /// **'Skip on conflict'**
  String get macroActionSkipConflict;

  /// No description provided for @macroActionTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get macroActionTarget;

  /// No description provided for @macroActionTargetHelp.
  ///
  /// In en, this message translates to:
  /// **'If target is not specified — action applies to all exercises of selected workouts.'**
  String get macroActionTargetHelp;

  /// No description provided for @macroConditionGreater.
  ///
  /// In en, this message translates to:
  /// **'greater >'**
  String get macroConditionGreater;

  /// No description provided for @macroConditionLess.
  ///
  /// In en, this message translates to:
  /// **'less <'**
  String get macroConditionLess;

  /// No description provided for @macroConditionEqual.
  ///
  /// In en, this message translates to:
  /// **'equal ='**
  String get macroConditionEqual;

  /// No description provided for @macroConditionNotEqual.
  ///
  /// In en, this message translates to:
  /// **'not equal ≠'**
  String get macroConditionNotEqual;

  /// No description provided for @macroConditionInRange.
  ///
  /// In en, this message translates to:
  /// **'in range'**
  String get macroConditionInRange;

  /// No description provided for @macroConditionNotInRange.
  ///
  /// In en, this message translates to:
  /// **'not in range'**
  String get macroConditionNotInRange;

  /// No description provided for @macroConditionStagnates.
  ///
  /// In en, this message translates to:
  /// **'stagnation for N windows'**
  String get macroConditionStagnates;

  /// No description provided for @macroConditionDeviates.
  ///
  /// In en, this message translates to:
  /// **'deviation from average'**
  String get macroConditionDeviates;

  /// No description provided for @macroConditionHoldsForWorkouts.
  ///
  /// In en, this message translates to:
  /// **'holds for N workouts in a row'**
  String get macroConditionHoldsForWorkouts;

  /// No description provided for @macroConditionHoldsForSets.
  ///
  /// In en, this message translates to:
  /// **'holds for N sets in a row (within workout)'**
  String get macroConditionHoldsForSets;

  /// No description provided for @macroConditionOperatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get macroConditionOperatorLabel;

  /// No description provided for @macroConditionRangeFrom.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get macroConditionRangeFrom;

  /// No description provided for @macroConditionNumberHint.
  ///
  /// In en, this message translates to:
  /// **'number'**
  String get macroConditionNumberHint;

  /// No description provided for @macroConditionRangeTo.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get macroConditionRangeTo;

  /// No description provided for @macroConditionWindowCount.
  ///
  /// In en, this message translates to:
  /// **'n (windows)'**
  String get macroConditionWindowCount;

  /// No description provided for @macroConditionWindowCountHint.
  ///
  /// In en, this message translates to:
  /// **'integer, e.g. 5'**
  String get macroConditionWindowCountHint;

  /// No description provided for @macroConditionEpsilonPercent.
  ///
  /// In en, this message translates to:
  /// **'epsilon_percent (threshold, %)'**
  String get macroConditionEpsilonPercent;

  /// No description provided for @macroConditionValuePercent.
  ///
  /// In en, this message translates to:
  /// **'value_percent (deviation, %)'**
  String get macroConditionValuePercent;

  /// No description provided for @macroConditionPositive.
  ///
  /// In en, this message translates to:
  /// **'positive'**
  String get macroConditionPositive;

  /// No description provided for @macroConditionNegative.
  ///
  /// In en, this message translates to:
  /// **'negative'**
  String get macroConditionNegative;

  /// No description provided for @macroConditionDirection.
  ///
  /// In en, this message translates to:
  /// **'direction (optional)'**
  String get macroConditionDirection;

  /// No description provided for @macroConditionGreaterEqual.
  ///
  /// In en, this message translates to:
  /// **'greater or equal ≥'**
  String get macroConditionGreaterEqual;

  /// No description provided for @macroConditionLessEqual.
  ///
  /// In en, this message translates to:
  /// **'less or equal ≤'**
  String get macroConditionLessEqual;

  /// No description provided for @macroConditionRelationLabel.
  ///
  /// In en, this message translates to:
  /// **'relation'**
  String get macroConditionRelationLabel;

  /// No description provided for @macroConditionWorkoutCount.
  ///
  /// In en, this message translates to:
  /// **'n (workouts)'**
  String get macroConditionWorkoutCount;

  /// No description provided for @macroConditionWorkoutCountHint.
  ///
  /// In en, this message translates to:
  /// **'integer, e.g. 3'**
  String get macroConditionWorkoutCountHint;

  /// No description provided for @macroConditionDeltaHint.
  ///
  /// In en, this message translates to:
  /// **'delta, e.g. -2 for reps'**
  String get macroConditionDeltaHint;

  /// No description provided for @macroConditionSetCount.
  ///
  /// In en, this message translates to:
  /// **'n (sets in a row)'**
  String get macroConditionSetCount;

  /// No description provided for @macroConditionSetCountHint.
  ///
  /// In en, this message translates to:
  /// **'integer, e.g. 12'**
  String get macroConditionSetCountHint;

  /// No description provided for @macroConditionValueLabel.
  ///
  /// In en, this message translates to:
  /// **'value'**
  String get macroConditionValueLabel;

  /// No description provided for @macroDurationNextNWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Next N workouts'**
  String get macroDurationNextNWorkouts;

  /// No description provided for @macroDurationUntilLastWorkout.
  ///
  /// In en, this message translates to:
  /// **'Until last workout'**
  String get macroDurationUntilLastWorkout;

  /// No description provided for @macroDurationUntilEndOfMeso.
  ///
  /// In en, this message translates to:
  /// **'Until end of mesocycle'**
  String get macroDurationUntilEndOfMeso;

  /// No description provided for @macroDurationUntilEndOfMicro.
  ///
  /// In en, this message translates to:
  /// **'Until end of microcycle'**
  String get macroDurationUntilEndOfMicro;

  /// No description provided for @macroDurationUntilWorkoutX.
  ///
  /// In en, this message translates to:
  /// **'Until workout X'**
  String get macroDurationUntilWorkoutX;

  /// No description provided for @macroDurationScopeLabel.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get macroDurationScopeLabel;

  /// No description provided for @macroDurationCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get macroDurationCountLabel;

  /// No description provided for @macroTargetBy.
  ///
  /// In en, this message translates to:
  /// **'Target by:'**
  String get macroTargetBy;

  /// No description provided for @macroTargetTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get macroTargetTags;

  /// No description provided for @macroTargetIds.
  ///
  /// In en, this message translates to:
  /// **'IDs'**
  String get macroTargetIds;

  /// No description provided for @macroTargetIdsLabel.
  ///
  /// In en, this message translates to:
  /// **'exercise_ids (CSV)'**
  String get macroTargetIdsLabel;

  /// No description provided for @macroTriggerChooseExercises.
  ///
  /// In en, this message translates to:
  /// **'Choose exercises'**
  String get macroTriggerChooseExercises;

  /// No description provided for @macroTriggerMetricReadiness.
  ///
  /// In en, this message translates to:
  /// **'Readiness (workout)'**
  String get macroTriggerMetricReadiness;

  /// No description provided for @macroTriggerMetricRpeSession.
  ///
  /// In en, this message translates to:
  /// **'Session RPE'**
  String get macroTriggerMetricRpeSession;

  /// No description provided for @macroTriggerMetricTotalReps.
  ///
  /// In en, this message translates to:
  /// **'Total Reps'**
  String get macroTriggerMetricTotalReps;

  /// No description provided for @macroTriggerMetricE1rm.
  ///
  /// In en, this message translates to:
  /// **'e1RM estimate'**
  String get macroTriggerMetricE1rm;

  /// No description provided for @macroTriggerMetricPerformanceTrend.
  ///
  /// In en, this message translates to:
  /// **'Performance Trend'**
  String get macroTriggerMetricPerformanceTrend;

  /// No description provided for @macroTriggerMetricRpeDelta.
  ///
  /// In en, this message translates to:
  /// **'RPE Delta from Plan'**
  String get macroTriggerMetricRpeDelta;

  /// No description provided for @macroTriggerMetricRepsDelta.
  ///
  /// In en, this message translates to:
  /// **'Reps Delta from Plan'**
  String get macroTriggerMetricRepsDelta;

  /// No description provided for @macroTriggerMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'Trigger Metric'**
  String get macroTriggerMetricLabel;

  /// No description provided for @macroWorkoutPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose workout'**
  String get macroWorkoutPickerTitle;

  /// No description provided for @macroWorkoutPickerNoWorkouts.
  ///
  /// In en, this message translates to:
  /// **'No workouts in active plan'**
  String get macroWorkoutPickerNoWorkouts;

  /// No description provided for @macroWorkoutPickerNoWorkoutsOnDate.
  ///
  /// In en, this message translates to:
  /// **'No workouts on this date'**
  String get macroWorkoutPickerNoWorkoutsOnDate;

  /// No description provided for @macroWorkoutPickerOrChooseFromList.
  ///
  /// In en, this message translates to:
  /// **'Or choose from list'**
  String get macroWorkoutPickerOrChooseFromList;

  /// No description provided for @macroWorkoutPickerListButton.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get macroWorkoutPickerListButton;

  /// No description provided for @macroWorkoutPickerWorkoutsOnDate.
  ///
  /// In en, this message translates to:
  /// **'Workouts on this date'**
  String get macroWorkoutPickerWorkoutsOnDate;

  /// No description provided for @macroWorkoutPickerOrSelectFromList.
  ///
  /// In en, this message translates to:
  /// **'Or select from list'**
  String get macroWorkoutPickerOrSelectFromList;

  /// No description provided for @macroWorkoutPickerList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get macroWorkoutPickerList;

  /// No description provided for @analyticsPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan analytics {planName}'**
  String analyticsPlanTitle(Object planName);

  /// No description provided for @errorLoadingActivePlan.
  ///
  /// In en, this message translates to:
  /// **'Failed to load active plan'**
  String get errorLoadingActivePlan;

  /// No description provided for @selectTwoMetrics.
  ///
  /// In en, this message translates to:
  /// **'Select two metrics'**
  String get selectTwoMetrics;

  /// No description provided for @activePlanNotFound.
  ///
  /// In en, this message translates to:
  /// **'Active plan not found'**
  String get activePlanNotFound;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @axisX.
  ///
  /// In en, this message translates to:
  /// **'X axis'**
  String get axisX;

  /// No description provided for @axisY.
  ///
  /// In en, this message translates to:
  /// **'Y axis'**
  String get axisY;

  /// No description provided for @showChart.
  ///
  /// In en, this message translates to:
  /// **'Show chart'**
  String get showChart;

  /// No description provided for @selectRangeAndMetrics.
  ///
  /// In en, this message translates to:
  /// **'Select a range and metrics'**
  String get selectRangeAndMetrics;

  /// No description provided for @noDataForSelectedMetrics.
  ///
  /// In en, this message translates to:
  /// **'No data for selected metrics'**
  String get noDataForSelectedMetrics;

  /// No description provided for @metricVolumeKg.
  ///
  /// In en, this message translates to:
  /// **'Volume (kg)'**
  String get metricVolumeKg;

  /// No description provided for @metricEffortRpe.
  ///
  /// In en, this message translates to:
  /// **'Effort (RPE)'**
  String get metricEffortRpe;

  /// No description provided for @metricKpsh.
  ///
  /// In en, this message translates to:
  /// **'KPSH'**
  String get metricKpsh;

  /// No description provided for @metricReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get metricReps;

  /// No description provided for @metricOneRm.
  ///
  /// In en, this message translates to:
  /// **'1RM'**
  String get metricOneRm;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageUkrainian.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get languageUkrainian;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @bodyweightKg.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight (kg)'**
  String get bodyweightKg;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @trainingYears.
  ///
  /// In en, this message translates to:
  /// **'Training years'**
  String get trainingYears;

  /// No description provided for @publicProfile.
  ///
  /// In en, this message translates to:
  /// **'Public profile'**
  String get publicProfile;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @unitsMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get unitsMetric;

  /// No description provided for @unitsImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get unitsImperial;

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @editProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileButton;

  /// No description provided for @coachingSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Coaching settings'**
  String get coachingSettingsButton;

  /// No description provided for @coachingTitle.
  ///
  /// In en, this message translates to:
  /// **'Coaching'**
  String get coachingTitle;

  /// No description provided for @coachingAcceptingNewClients.
  ///
  /// In en, this message translates to:
  /// **'Accepting new clients'**
  String get coachingAcceptingNewClients;

  /// No description provided for @coachingNotAccepting.
  ///
  /// In en, this message translates to:
  /// **'Not accepting'**
  String get coachingNotAccepting;

  /// No description provided for @coachingDisabled.
  ///
  /// In en, this message translates to:
  /// **'Coaching disabled'**
  String get coachingDisabled;

  /// No description provided for @coachingDisabledDescription.
  ///
  /// In en, this message translates to:
  /// **'This user has not enabled coaching options.'**
  String get coachingDisabledDescription;

  /// No description provided for @coachingSpecializations.
  ///
  /// In en, this message translates to:
  /// **'Specializations'**
  String get coachingSpecializations;

  /// No description provided for @coachingLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get coachingLanguages;

  /// No description provided for @coachingExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get coachingExperience;

  /// No description provided for @coachingTimezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get coachingTimezone;

  /// No description provided for @coachingRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get coachingRate;

  /// No description provided for @coachingCustomRate.
  ///
  /// In en, this message translates to:
  /// **'Custom rate'**
  String get coachingCustomRate;

  /// No description provided for @requestCoaching.
  ///
  /// In en, this message translates to:
  /// **'Request coaching'**
  String get requestCoaching;

  /// No description provided for @statsTotalWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Total Workouts'**
  String get statsTotalWorkouts;

  /// No description provided for @statsVolumeKg.
  ///
  /// In en, this message translates to:
  /// **'Volume (kg)'**
  String get statsVolumeKg;

  /// No description provided for @statsActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Active Days'**
  String get statsActiveDays;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// No description provided for @lastWeeks.
  ///
  /// In en, this message translates to:
  /// **'Last {weeks} weeks'**
  String lastWeeks(Object weeks);

  /// No description provided for @maxKgPerDay.
  ///
  /// In en, this message translates to:
  /// **'Max: {value} kg/day'**
  String maxKgPerDay(Object value);

  /// No description provided for @sessionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} session(s)'**
  String sessionsCount(Object count);

  /// No description provided for @noActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity'**
  String get noActivity;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @completedWorkoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed Workouts'**
  String get completedWorkoutsTitle;

  /// No description provided for @noCompletedWorkoutsYet.
  ///
  /// In en, this message translates to:
  /// **'No completed workouts yet'**
  String get noCompletedWorkoutsYet;

  /// No description provided for @exerciseFormTitleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get exerciseFormTitleAdd;

  /// No description provided for @exerciseFormExerciseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise name'**
  String get exerciseFormExerciseNameLabel;

  /// No description provided for @exerciseFormPleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get exerciseFormPleaseEnterName;

  /// No description provided for @exerciseFormMuscleGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Muscle group'**
  String get exerciseFormMuscleGroupLabel;

  /// No description provided for @exerciseFormLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get exerciseFormLoading;

  /// No description provided for @exerciseFormSelectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select group'**
  String get exerciseFormSelectGroup;

  /// No description provided for @exerciseFormLoadingGroups.
  ///
  /// In en, this message translates to:
  /// **'Loading groups...'**
  String get exerciseFormLoadingGroups;

  /// No description provided for @exerciseFormPleaseSelectMuscleGroup.
  ///
  /// In en, this message translates to:
  /// **'Please select a muscle group'**
  String get exerciseFormPleaseSelectMuscleGroup;

  /// No description provided for @exerciseFormProgressionTemplateOptional.
  ///
  /// In en, this message translates to:
  /// **'Progression template (optional)'**
  String get exerciseFormProgressionTemplateOptional;

  /// No description provided for @exerciseFormSelectTemplate.
  ///
  /// In en, this message translates to:
  /// **'Select template'**
  String get exerciseFormSelectTemplate;

  /// No description provided for @exerciseFormNoTemplate.
  ///
  /// In en, this message translates to:
  /// **'No template'**
  String get exerciseFormNoTemplate;

  /// No description provided for @exerciseFormSetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get exerciseFormSetsTitle;

  /// No description provided for @exerciseFormAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get exerciseFormAddSet;

  /// No description provided for @exerciseFormSaveExercise.
  ///
  /// In en, this message translates to:
  /// **'Save exercise'**
  String get exerciseFormSaveExercise;

  /// No description provided for @exerciseFormWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get exerciseFormWeightKg;

  /// No description provided for @exerciseFormReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get exerciseFormReps;

  /// No description provided for @exerciseFormRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get exerciseFormRequired;

  /// No description provided for @exerciseFormFailedToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data: {error}'**
  String exerciseFormFailedToLoadData(Object error);

  /// No description provided for @exerciseFormErrorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String exerciseFormErrorSaving(Object error);

  /// No description provided for @exerciseDefinitionIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Exercise definition id is required'**
  String get exerciseDefinitionIdRequired;

  /// No description provided for @exerciseFormDefaultReps.
  ///
  /// In en, this message translates to:
  /// **'5'**
  String get exerciseFormDefaultReps;

  /// No description provided for @exerciseFormDefaultWeight.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get exerciseFormDefaultWeight;

  /// No description provided for @exerciseListTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exerciseListTitle;

  /// No description provided for @exerciseListAddExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get exerciseListAddExerciseTitle;

  /// No description provided for @exerciseListNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get exerciseListNameLabel;

  /// No description provided for @exerciseListMuscleGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Muscle group'**
  String get exerciseListMuscleGroupLabel;

  /// No description provided for @exerciseListEquipmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get exerciseListEquipmentLabel;

  /// No description provided for @exerciseListLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get exerciseListLoading;

  /// No description provided for @exerciseListSelectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select group'**
  String get exerciseListSelectGroup;

  /// No description provided for @exerciseListLoadingGroups.
  ///
  /// In en, this message translates to:
  /// **'Loading groups...'**
  String get exerciseListLoadingGroups;

  /// No description provided for @exerciseListSelectMuscleGroupValidator.
  ///
  /// In en, this message translates to:
  /// **'Select a muscle group'**
  String get exerciseListSelectMuscleGroupValidator;

  /// No description provided for @exerciseListEnterExerciseName.
  ///
  /// In en, this message translates to:
  /// **'Enter exercise name'**
  String get exerciseListEnterExerciseName;

  /// No description provided for @exerciseListSelectMuscleGroupSnack.
  ///
  /// In en, this message translates to:
  /// **'Select a muscle group'**
  String get exerciseListSelectMuscleGroupSnack;

  /// No description provided for @exerciseListErrorLoadingMuscleGroups.
  ///
  /// In en, this message translates to:
  /// **'Failed to load muscle groups: {error}'**
  String exerciseListErrorLoadingMuscleGroups(Object error);

  /// No description provided for @exerciseListErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String exerciseListErrorGeneric(Object error);

  /// No description provided for @exerciseListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No exercises. Add a new one!'**
  String get exerciseListEmpty;

  /// No description provided for @exerciseListMuscleGroupPrefix.
  ///
  /// In en, this message translates to:
  /// **'Muscle group: {value}'**
  String exerciseListMuscleGroupPrefix(Object value);

  /// No description provided for @exerciseListEquipmentPrefix.
  ///
  /// In en, this message translates to:
  /// **'Equipment: {value}'**
  String exerciseListEquipmentPrefix(Object value);

  /// No description provided for @exerciseListDeleteExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete exercise?'**
  String get exerciseListDeleteExerciseTitle;

  /// No description provided for @exerciseListDeleteExerciseBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get exerciseListDeleteExerciseBody;

  /// No description provided for @exerciseListDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get exerciseListDelete;

  /// No description provided for @exerciseListErrorDeleting.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {error}'**
  String exerciseListErrorDeleting(Object error);

  /// No description provided for @userMaxTitle.
  ///
  /// In en, this message translates to:
  /// **'Add max'**
  String get userMaxTitle;

  /// No description provided for @userMaxExerciseLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get userMaxExerciseLabel;

  /// No description provided for @userMaxSelectExerciseValidator.
  ///
  /// In en, this message translates to:
  /// **'Select an exercise'**
  String get userMaxSelectExerciseValidator;

  /// No description provided for @userMaxWeightKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get userMaxWeightKgLabel;

  /// No description provided for @userMaxWeightGtZeroValidator.
  ///
  /// In en, this message translates to:
  /// **'Enter weight > 0'**
  String get userMaxWeightGtZeroValidator;

  /// No description provided for @userMaxRepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get userMaxRepsLabel;

  /// No description provided for @userMaxRepsGtZeroValidator.
  ///
  /// In en, this message translates to:
  /// **'Enter reps > 0'**
  String get userMaxRepsGtZeroValidator;

  /// No description provided for @userMaxRepsMax12Validator.
  ///
  /// In en, this message translates to:
  /// **'Maximum 12 reps'**
  String get userMaxRepsMax12Validator;

  /// No description provided for @userMaxFillAllFieldsSnack.
  ///
  /// In en, this message translates to:
  /// **'Fill all fields and select an exercise'**
  String get userMaxFillAllFieldsSnack;

  /// No description provided for @userMaxSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get userMaxSaving;

  /// No description provided for @userMaxSave.
  ///
  /// In en, this message translates to:
  /// **'Save max'**
  String get userMaxSave;

  /// No description provided for @userMaxFailedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save max: {error}'**
  String userMaxFailedToSave(Object error);

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @planDraftMicrocycle.
  ///
  /// In en, this message translates to:
  /// **'Microcycle'**
  String get planDraftMicrocycle;

  /// No description provided for @planDraftMesocycle.
  ///
  /// In en, this message translates to:
  /// **'Mesocycle'**
  String get planDraftMesocycle;

  /// No description provided for @massEditToolWorkoutsMatched.
  ///
  /// In en, this message translates to:
  /// **'Workouts matched: {count}'**
  String massEditToolWorkoutsMatched(Object count);

  /// No description provided for @massEditToolSetsModified.
  ///
  /// In en, this message translates to:
  /// **'Sets modified: {count}'**
  String massEditToolSetsModified(Object count);

  /// No description provided for @massEditToolSetsToBeModified.
  ///
  /// In en, this message translates to:
  /// **'Sets to be modified: {count}'**
  String massEditToolSetsToBeModified(Object count);

  /// No description provided for @workoutDetailMacrosChangesFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Macro changes found'**
  String get workoutDetailMacrosChangesFoundTitle;

  /// No description provided for @workoutDetailMacrosChangesFoundBody.
  ///
  /// In en, this message translates to:
  /// **'Mesocycle injections: {injectCount}\nWorkout patches: {hasPatches}'**
  String workoutDetailMacrosChangesFoundBody(
    Object injectCount,
    Object hasPatches,
  );

  /// No description provided for @workoutDetailMacrosApplied.
  ///
  /// In en, this message translates to:
  /// **'Macros applied'**
  String get workoutDetailMacrosApplied;

  /// No description provided for @workoutDetailFailedToApplyMacros.
  ///
  /// In en, this message translates to:
  /// **'Failed to apply macros: {error}'**
  String workoutDetailFailedToApplyMacros(Object error);

  /// No description provided for @workoutDetailFailedToRefreshWorkoutBeforeApplyingReadiness.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh workout before applying readiness'**
  String get workoutDetailFailedToRefreshWorkoutBeforeApplyingReadiness;

  /// No description provided for @workoutDetailWorkoutNotReadyMissingIds.
  ///
  /// In en, this message translates to:
  /// **'Workout is not ready for set updates (missing ids)'**
  String get workoutDetailWorkoutNotReadyMissingIds;

  /// No description provided for @workoutDetailIncreaseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get workoutDetailIncreaseTooltip;

  /// No description provided for @workoutDetailSessionActive.
  ///
  /// In en, this message translates to:
  /// **'Active session'**
  String get workoutDetailSessionActive;

  /// No description provided for @workoutDetailSessionNone.
  ///
  /// In en, this message translates to:
  /// **'No active session'**
  String get workoutDetailSessionNone;

  /// No description provided for @workoutDetailSelectSetTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select set type'**
  String get workoutDetailSelectSetTypeTitle;

  /// No description provided for @workoutDetailSetTypeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal set'**
  String get workoutDetailSetTypeNormal;

  /// No description provided for @workoutDetailSetTypeDrop.
  ///
  /// In en, this message translates to:
  /// **'Drop set'**
  String get workoutDetailSetTypeDrop;

  /// No description provided for @workoutDetailSetTypeCluster.
  ///
  /// In en, this message translates to:
  /// **'Cluster set'**
  String get workoutDetailSetTypeCluster;

  /// No description provided for @workoutDetailSetTypeRestPause.
  ///
  /// In en, this message translates to:
  /// **'Rest-pause set'**
  String get workoutDetailSetTypeRestPause;

  /// No description provided for @workoutDetailFailedToUpdateSetType.
  ///
  /// In en, this message translates to:
  /// **'Failed to update set type: {error}'**
  String workoutDetailFailedToUpdateSetType(Object error);

  /// No description provided for @activePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Active plan'**
  String get activePlanTitle;

  /// No description provided for @activePlanFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load active plan: {error}'**
  String activePlanFailedToLoad(Object error);

  /// No description provided for @activePlanNone.
  ///
  /// In en, this message translates to:
  /// **'No active plan'**
  String get activePlanNone;

  /// No description provided for @activePlanAiMassEditTitle.
  ///
  /// In en, this message translates to:
  /// **'AI mass edit (chat)'**
  String get activePlanAiMassEditTitle;

  /// No description provided for @activePlanAiMassEditHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Increase RPE by 1 and add 1 set to all bench presses on Mondays'**
  String get activePlanAiMassEditHint;

  /// No description provided for @activePlanAiMassEditSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get activePlanAiMassEditSend;

  /// No description provided for @activePlanAiMassEditStarted.
  ///
  /// In en, this message translates to:
  /// **'AI mass edit started (task: {taskId})'**
  String activePlanAiMassEditStarted(Object taskId);

  /// No description provided for @activePlanAiMassEditFailedToSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to send AI mass edit command: {error}'**
  String activePlanAiMassEditFailedToSend(Object error);

  /// No description provided for @activePlanMassEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Mass edit (from {start} to {end})'**
  String activePlanMassEditTitle(Object end, Object start);

  /// No description provided for @activePlanRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Range:'**
  String get activePlanRangeLabel;

  /// No description provided for @activePlanRangeFutureFromWeek.
  ///
  /// In en, this message translates to:
  /// **'Future from week'**
  String get activePlanRangeFutureFromWeek;

  /// No description provided for @activePlanRangeByMesoMicro.
  ///
  /// In en, this message translates to:
  /// **'By meso/micro'**
  String get activePlanRangeByMesoMicro;

  /// No description provided for @activePlanIntensityLabel.
  ///
  /// In en, this message translates to:
  /// **'Intensity %'**
  String get activePlanIntensityLabel;

  /// No description provided for @activePlanRpeLabel.
  ///
  /// In en, this message translates to:
  /// **'RPE'**
  String get activePlanRpeLabel;

  /// No description provided for @activePlanRepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get activePlanRepsLabel;

  /// No description provided for @activePlanModeSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get activePlanModeSet;

  /// No description provided for @activePlanModeOffset.
  ///
  /// In en, this message translates to:
  /// **'Offset'**
  String get activePlanModeOffset;

  /// No description provided for @activePlanModeScale.
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get activePlanModeScale;

  /// No description provided for @activePlanHintEg75.
  ///
  /// In en, this message translates to:
  /// **'e.g. 75'**
  String get activePlanHintEg75;

  /// No description provided for @activePlanHintPercentOffset.
  ///
  /// In en, this message translates to:
  /// **'+/- % (e.g. -2)'**
  String get activePlanHintPercentOffset;

  /// No description provided for @activePlanHintFactor.
  ///
  /// In en, this message translates to:
  /// **'× factor (e.g. 1.05)'**
  String get activePlanHintFactor;

  /// No description provided for @activePlanHintEg8.
  ///
  /// In en, this message translates to:
  /// **'e.g. 8'**
  String get activePlanHintEg8;

  /// No description provided for @activePlanHintEg5.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5'**
  String get activePlanHintEg5;

  /// No description provided for @activePlanHintRepsOffset.
  ///
  /// In en, this message translates to:
  /// **'+/- reps (e.g. +1)'**
  String get activePlanHintRepsOffset;

  /// No description provided for @activePlanHintFactorReps.
  ///
  /// In en, this message translates to:
  /// **'× factor (e.g. 0.9)'**
  String get activePlanHintFactorReps;

  /// No description provided for @activePlanRecalcTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Recalc target:'**
  String get activePlanRecalcTargetLabel;

  /// No description provided for @activePlanRecalcTargetAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get activePlanRecalcTargetAuto;

  /// No description provided for @activePlanRecalcTargetReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get activePlanRecalcTargetReps;

  /// No description provided for @activePlanRecalcTargetRpe.
  ///
  /// In en, this message translates to:
  /// **'RPE'**
  String get activePlanRecalcTargetRpe;

  /// No description provided for @activePlanRecalcTargetIntensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get activePlanRecalcTargetIntensity;

  /// No description provided for @activePlanValidatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Validator:'**
  String get activePlanValidatorLabel;

  /// No description provided for @activePlanValidatorNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get activePlanValidatorNone;

  /// No description provided for @activePlanValidatorFixReps.
  ///
  /// In en, this message translates to:
  /// **'Fix reps'**
  String get activePlanValidatorFixReps;

  /// No description provided for @activePlanValidatorFixIntensity.
  ///
  /// In en, this message translates to:
  /// **'Fix intensity'**
  String get activePlanValidatorFixIntensity;

  /// No description provided for @activePlanSelectAtLeastOneExercise.
  ///
  /// In en, this message translates to:
  /// **'Select at least one exercise'**
  String get activePlanSelectAtLeastOneExercise;

  /// No description provided for @activePlanSelectAtLeastOneParameter.
  ///
  /// In en, this message translates to:
  /// **'Select at least one parameter'**
  String get activePlanSelectAtLeastOneParameter;

  /// No description provided for @activePlanPlanCancelled.
  ///
  /// In en, this message translates to:
  /// **'Plan cancelled'**
  String get activePlanPlanCancelled;

  /// No description provided for @activePlanFailedToCancelPlan.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel plan'**
  String get activePlanFailedToCancelPlan;

  /// No description provided for @activePlanExerciseIdFallback.
  ///
  /// In en, this message translates to:
  /// **'Exercise {id}'**
  String activePlanExerciseIdFallback(Object id);

  /// No description provided for @activePlanReplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace exercises (from {start} to {end})'**
  String activePlanReplaceTitle(Object end, Object start);

  /// No description provided for @activePlanSelectSourceExercises.
  ///
  /// In en, this message translates to:
  /// **'Select source exercises:'**
  String get activePlanSelectSourceExercises;

  /// No description provided for @activePlanSelectTargetExercise.
  ///
  /// In en, this message translates to:
  /// **'Select target exercise'**
  String get activePlanSelectTargetExercise;

  /// No description provided for @activePlanPreserveIntensity.
  ///
  /// In en, this message translates to:
  /// **'Preserve intensity via 1RM'**
  String get activePlanPreserveIntensity;

  /// No description provided for @activePlanSelectAtLeastOneSourceExercise.
  ///
  /// In en, this message translates to:
  /// **'Select at least one source exercise'**
  String get activePlanSelectAtLeastOneSourceExercise;

  /// No description provided for @activePlanSelectTargetExerciseSnack.
  ///
  /// In en, this message translates to:
  /// **'Select a target exercise'**
  String get activePlanSelectTargetExerciseSnack;

  /// No description provided for @activePlanPreviewReplacementTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview replacement'**
  String get activePlanPreviewReplacementTitle;

  /// No description provided for @activePlanPreviewTarget.
  ///
  /// In en, this message translates to:
  /// **'Target: {name}'**
  String activePlanPreviewTarget(Object name);

  /// No description provided for @activePlanPreviewExercisesToReplace.
  ///
  /// In en, this message translates to:
  /// **'Exercises to replace: {count}'**
  String activePlanPreviewExercisesToReplace(Object count);

  /// No description provided for @activePlanPreviewSetsAffected.
  ///
  /// In en, this message translates to:
  /// **'Sets affected: {count}'**
  String activePlanPreviewSetsAffected(Object count);

  /// No description provided for @activePlanDropoutReasonNotEnjoyable.
  ///
  /// In en, this message translates to:
  /// **'Not enjoyable'**
  String get activePlanDropoutReasonNotEnjoyable;

  /// No description provided for @activePlanDropoutReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other / prefer not to say'**
  String get activePlanDropoutReasonOther;

  /// No description provided for @activePlanDropoutSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get activePlanDropoutSkip;

  /// No description provided for @activePlanDropoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get activePlanDropoutConfirm;

  /// No description provided for @activePlanUpdatedSets.
  ///
  /// In en, this message translates to:
  /// **'Updated {count} sets'**
  String activePlanUpdatedSets(Object count);

  /// No description provided for @activePlanFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String activePlanFailed(Object error);

  /// No description provided for @activePlanReplacementCancelledOneRmRequired.
  ///
  /// In en, this message translates to:
  /// **'Replacement cancelled: 1RM required'**
  String get activePlanReplacementCancelledOneRmRequired;

  /// No description provided for @activePlanEnterOneRmTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter 1RM for {exerciseName}'**
  String activePlanEnterOneRmTitle(Object exerciseName);

  /// No description provided for @activePlanOneRmLabel.
  ///
  /// In en, this message translates to:
  /// **'1RM (kg)'**
  String get activePlanOneRmLabel;

  /// No description provided for @activePlanOneRmHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 120'**
  String get activePlanOneRmHint;

  /// No description provided for @activePlanOneRmHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter your current max for this exercise.'**
  String get activePlanOneRmHelp;

  /// No description provided for @activePlanEnterNumberGtZero.
  ///
  /// In en, this message translates to:
  /// **'Enter a number > 0'**
  String get activePlanEnterNumberGtZero;

  /// No description provided for @activePlanShiftedWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Shifted {count} workouts by +{days} day(s)'**
  String activePlanShiftedWorkouts(Object count, Object days);

  /// No description provided for @activePlanShiftFailed.
  ///
  /// In en, this message translates to:
  /// **'Shift failed: {error}'**
  String activePlanShiftFailed(Object error);

  /// No description provided for @activePlanKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get activePlanKeep;

  /// No description provided for @activePlanCancelPlan.
  ///
  /// In en, this message translates to:
  /// **'Cancel plan'**
  String get activePlanCancelPlan;

  /// No description provided for @activePlanWhyCancelling.
  ///
  /// In en, this message translates to:
  /// **'Why are you cancelling?'**
  String get activePlanWhyCancelling;

  /// No description provided for @activePlanDropoutReasonNotEnoughTime.
  ///
  /// In en, this message translates to:
  /// **'Not enough time'**
  String get activePlanDropoutReasonNotEnoughTime;

  /// No description provided for @activePlanDropoutReasonInjury.
  ///
  /// In en, this message translates to:
  /// **'Injury / pain'**
  String get activePlanDropoutReasonInjury;

  /// No description provided for @activePlanDropoutReasonTooHard.
  ///
  /// In en, this message translates to:
  /// **'Too hard'**
  String get activePlanDropoutReasonTooHard;

  /// No description provided for @activePlanReplaceSuccess.
  ///
  /// In en, this message translates to:
  /// **'Replaced {exercises} exercises, updated {sets} sets'**
  String activePlanReplaceSuccess(Object exercises, Object sets);

  /// No description provided for @activePlanReplaceFailed.
  ///
  /// In en, this message translates to:
  /// **'Replace failed: {error}'**
  String activePlanReplaceFailed(Object error);

  /// No description provided for @activePlanCancelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel active plan?'**
  String get activePlanCancelConfirmTitle;

  /// No description provided for @activePlanCancelConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will stop tracking this applied plan. Existing workouts will remain.'**
  String get activePlanCancelConfirmBody;

  /// No description provided for @activePlanDroppedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Dropped: {reason}{date}'**
  String activePlanDroppedPrefix(Object reason, Object date);

  /// No description provided for @activePlanAdherencePercent.
  ///
  /// In en, this message translates to:
  /// **'Adherence: {value}%'**
  String activePlanAdherencePercent(Object value);

  /// No description provided for @activePlanFailedToLoadAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Failed to load analytics: {error}'**
  String activePlanFailedToLoadAnalytics(Object error);

  /// No description provided for @activePlanStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activePlanStatusActive;

  /// No description provided for @coachRelationshipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Coach ↔ Athletes'**
  String get coachRelationshipsTitle;

  /// No description provided for @coachRelationshipsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get coachRelationshipsFilterAll;

  /// No description provided for @coachRelationshipsFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get coachRelationshipsFilterPending;

  /// No description provided for @coachRelationshipsFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get coachRelationshipsFilterActive;

  /// No description provided for @coachRelationshipsFilterPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get coachRelationshipsFilterPaused;

  /// No description provided for @coachRelationshipsFilterEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get coachRelationshipsFilterEnded;

  /// No description provided for @coachRelationshipsError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String coachRelationshipsError(Object error);

  /// No description provided for @coachRelationshipsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No relationships yet'**
  String get coachRelationshipsEmpty;

  /// No description provided for @coachRelationshipsAthletePrefix.
  ///
  /// In en, this message translates to:
  /// **'Athlete: {name}'**
  String coachRelationshipsAthletePrefix(Object name);

  /// No description provided for @coachRelationshipsStatusPrefix.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String coachRelationshipsStatusPrefix(Object status);

  /// No description provided for @coachRelationshipsNotePrefix.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String coachRelationshipsNotePrefix(Object note);

  /// No description provided for @coachRelationshipsChannelPrefix.
  ///
  /// In en, this message translates to:
  /// **'Channel: {channel}'**
  String coachRelationshipsChannelPrefix(Object channel);

  /// No description provided for @coachRelationshipsChannelNotCreated.
  ///
  /// In en, this message translates to:
  /// **'not created'**
  String get coachRelationshipsChannelNotCreated;

  /// No description provided for @coachRelationshipsSessions12w.
  ///
  /// In en, this message translates to:
  /// **'Sessions (12w): {count}'**
  String coachRelationshipsSessions12w(Object count);

  /// No description provided for @coachRelationshipsLastWorkout.
  ///
  /// In en, this message translates to:
  /// **'Last workout: {date}{suffix}'**
  String coachRelationshipsLastWorkout(Object date, Object suffix);

  /// No description provided for @coachRelationshipsLastWorkoutNA.
  ///
  /// In en, this message translates to:
  /// **'n/a'**
  String get coachRelationshipsLastWorkoutNA;

  /// No description provided for @coachRelationshipsDaysAgoSuffix.
  ///
  /// In en, this message translates to:
  /// **' · {days}d ago'**
  String coachRelationshipsDaysAgoSuffix(Object days);

  /// No description provided for @coachRelationshipsLoadingTrainingSummary.
  ///
  /// In en, this message translates to:
  /// **'Loading training summary...'**
  String get coachRelationshipsLoadingTrainingSummary;

  /// No description provided for @coachRelationshipsRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Request accepted'**
  String get coachRelationshipsRequestAccepted;

  /// No description provided for @coachRelationshipsFailedToAccept.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept: {error}'**
  String coachRelationshipsFailedToAccept(Object error);

  /// No description provided for @coachRelationshipsAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get coachRelationshipsAccept;

  /// No description provided for @coachRelationshipsDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get coachRelationshipsDecline;

  /// No description provided for @coachRelationshipsDeclineRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline request'**
  String get coachRelationshipsDeclineRequestTitle;

  /// No description provided for @coachRelationshipsDeclineReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get coachRelationshipsDeclineReasonHint;

  /// No description provided for @coachRelationshipsRequestDeclined.
  ///
  /// In en, this message translates to:
  /// **'Request declined'**
  String get coachRelationshipsRequestDeclined;

  /// No description provided for @coachRelationshipsFailedToDecline.
  ///
  /// In en, this message translates to:
  /// **'Failed to decline: {error}'**
  String coachRelationshipsFailedToDecline(Object error);

  /// No description provided for @coachRelationshipsCoachingPaused.
  ///
  /// In en, this message translates to:
  /// **'Coaching paused'**
  String get coachRelationshipsCoachingPaused;

  /// No description provided for @coachRelationshipsFailedToPause.
  ///
  /// In en, this message translates to:
  /// **'Failed to pause: {error}'**
  String coachRelationshipsFailedToPause(Object error);

  /// No description provided for @coachRelationshipsCoachingResumed.
  ///
  /// In en, this message translates to:
  /// **'Coaching resumed'**
  String get coachRelationshipsCoachingResumed;

  /// No description provided for @coachRelationshipsFailedToResume.
  ///
  /// In en, this message translates to:
  /// **'Failed to resume: {error}'**
  String coachRelationshipsFailedToResume(Object error);

  /// No description provided for @coachRelationshipsChatTooltip.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get coachRelationshipsChatTooltip;

  /// No description provided for @coachRelationshipsAnalyticsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get coachRelationshipsAnalyticsTooltip;

  /// No description provided for @coachRelationshipsNudgeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Nudge'**
  String get coachRelationshipsNudgeTooltip;

  /// No description provided for @coachRelationshipsPauseCoaching.
  ///
  /// In en, this message translates to:
  /// **'Pause coaching'**
  String get coachRelationshipsPauseCoaching;

  /// No description provided for @coachRelationshipsResumeCoaching.
  ///
  /// In en, this message translates to:
  /// **'Resume coaching'**
  String get coachRelationshipsResumeCoaching;

  /// No description provided for @coachRelationshipsEndCoaching.
  ///
  /// In en, this message translates to:
  /// **'End coaching'**
  String get coachRelationshipsEndCoaching;

  /// No description provided for @coachRelationshipsCoachingEnded.
  ///
  /// In en, this message translates to:
  /// **'Coaching ended'**
  String get coachRelationshipsCoachingEnded;

  /// No description provided for @coachRelationshipsFailedToEnd.
  ///
  /// In en, this message translates to:
  /// **'Failed to end: {error}'**
  String coachRelationshipsFailedToEnd(Object error);

  /// No description provided for @coachRelationshipsChatChannelNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Chat channel is not available'**
  String get coachRelationshipsChatChannelNotAvailable;

  /// No description provided for @coachRelationshipsNudgeSent.
  ///
  /// In en, this message translates to:
  /// **'Nudge sent'**
  String get coachRelationshipsNudgeSent;

  /// No description provided for @coachRelationshipsFailedToSendNudge.
  ///
  /// In en, this message translates to:
  /// **'Failed to send nudge: {error}'**
  String coachRelationshipsFailedToSendNudge(Object error);

  /// No description provided for @coachRelationshipsNudgeMessageWithDays.
  ///
  /// In en, this message translates to:
  /// **'Hey {athleteId}, it\'s been {days} day(s) since your last workout. Let\'s plan the next session!'**
  String coachRelationshipsNudgeMessageWithDays(Object athleteId, Object days);

  /// No description provided for @coachRelationshipsNudgeMessageNoDays.
  ///
  /// In en, this message translates to:
  /// **'Hey {athleteId}, let\'s schedule our next workout soon!'**
  String coachRelationshipsNudgeMessageNoDays(Object athleteId);

  /// No description provided for @coachRelationshipsVolumeAndPlan.
  ///
  /// In en, this message translates to:
  /// **'Volume: {volume} | Active plan: {plan}'**
  String coachRelationshipsVolumeAndPlan(Object volume, Object plan);

  /// No description provided for @coachRelationshipsVolumeDash.
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get coachRelationshipsVolumeDash;

  /// No description provided for @coachRelationshipsMenuAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get coachRelationshipsMenuAll;

  /// No description provided for @coachRelationshipsMenuPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get coachRelationshipsMenuPending;

  /// No description provided for @coachRelationshipsMenuActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get coachRelationshipsMenuActive;

  /// No description provided for @coachRelationshipsMenuPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get coachRelationshipsMenuPaused;

  /// No description provided for @coachRelationshipsMenuEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get coachRelationshipsMenuEnded;

  /// No description provided for @coachRelationshipsMenuPauseCoaching.
  ///
  /// In en, this message translates to:
  /// **'Pause coaching'**
  String get coachRelationshipsMenuPauseCoaching;

  /// No description provided for @coachRelationshipsMenuResumeCoaching.
  ///
  /// In en, this message translates to:
  /// **'Resume coaching'**
  String get coachRelationshipsMenuResumeCoaching;

  /// No description provided for @coachRelationshipsMenuEndCoaching.
  ///
  /// In en, this message translates to:
  /// **'End coaching'**
  String get coachRelationshipsMenuEndCoaching;

  /// No description provided for @planEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Editor: {name}'**
  String planEditorTitle(Object name);

  /// No description provided for @planEditorMacros.
  ///
  /// In en, this message translates to:
  /// **'Macros'**
  String get planEditorMacros;

  /// No description provided for @planEditorNoPlanId.
  ///
  /// In en, this message translates to:
  /// **'No plan ID'**
  String get planEditorNoPlanId;

  /// No description provided for @planEditorBulk.
  ///
  /// In en, this message translates to:
  /// **'Bulk ({count})'**
  String planEditorBulk(Object count);

  /// No description provided for @planEditorReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get planEditorReplace;

  /// No description provided for @planEditorSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search exercise by name...'**
  String get planEditorSearchHint;

  /// No description provided for @planEditorMesocycles.
  ///
  /// In en, this message translates to:
  /// **'Mesocycles'**
  String get planEditorMesocycles;

  /// No description provided for @planEditorDayFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter: day (number, optional)'**
  String get planEditorDayFilterLabel;

  /// No description provided for @planEditorSelectTargetError.
  ///
  /// In en, this message translates to:
  /// **'Choose target exercise'**
  String get planEditorSelectTargetError;

  /// No description provided for @planEditorSelectSourceError.
  ///
  /// In en, this message translates to:
  /// **'Select at least one exercise to replace'**
  String get planEditorSelectSourceError;

  /// No description provided for @planEditorDeleteMesocycleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete mesocycle'**
  String get planEditorDeleteMesocycleTitle;

  /// No description provided for @planEditorDeleteMesocycleBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete mesocycle \"{name}\" and all its microcycles?'**
  String planEditorDeleteMesocycleBody(Object name);

  /// No description provided for @planEditorDeleteMesocycle.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get planEditorDeleteMesocycle;

  /// No description provided for @planEditorMesocycleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Mesocycle deleted'**
  String get planEditorMesocycleDeleted;

  /// No description provided for @planEditorDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String planEditorDeleteFailed(Object error);

  /// No description provided for @planEditorDeleteMesocycleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete mesocycle'**
  String get planEditorDeleteMesocycleTooltip;

  /// No description provided for @planEditorMicroDays.
  ///
  /// In en, this message translates to:
  /// **'Days: {count}'**
  String planEditorMicroDays(Object count);

  /// No description provided for @planEditorExerciseIdFallback.
  ///
  /// In en, this message translates to:
  /// **'Exercise {id}'**
  String planEditorExerciseIdFallback(Object id);

  /// No description provided for @planEditorChangesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get planEditorChangesSaved;

  /// No description provided for @planEditorMicrocycleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Microcycle deleted'**
  String get planEditorMicrocycleDeleted;

  /// No description provided for @planEditorDeleteMicrocycleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete microcycle'**
  String get planEditorDeleteMicrocycleTitle;

  /// No description provided for @planEditorDeleteMicrocycleBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete microcycle \"{name}\"?'**
  String planEditorDeleteMicrocycleBody(Object name);

  /// No description provided for @planEditorDeleteMicrocycleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete microcycle'**
  String get planEditorDeleteMicrocycleTooltip;

  /// No description provided for @planEditorMassEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Mass edits: selected microcycles'**
  String get planEditorMassEditTitle;

  /// No description provided for @planEditorSkipNoRights.
  ///
  /// In en, this message translates to:
  /// **'Skipped {count} microcycles without access rights'**
  String planEditorSkipNoRights(Object count);

  /// No description provided for @planEditorRightsCheckUnavailableApplyAll.
  ///
  /// In en, this message translates to:
  /// **'Rights check unavailable, applying to all selected: {error}'**
  String planEditorRightsCheckUnavailableApplyAll(Object error);

  /// No description provided for @planEditorMassEditsResult.
  ///
  /// In en, this message translates to:
  /// **'Mass edits: success {success}, failed {failed}'**
  String planEditorMassEditsResult(Object success, Object failed);

  /// No description provided for @coachAthletePlanTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Athlete {id}'**
  String coachAthletePlanTitleFallback(Object id);

  /// No description provided for @coachAthletePlanLoadAnalyticsError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load plan analytics: {error}'**
  String coachAthletePlanLoadAnalyticsError(Object error);

  /// No description provided for @coachAthletePlanMetricSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get coachAthletePlanMetricSets;

  /// No description provided for @coachAthletePlanMetricReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get coachAthletePlanMetricReps;

  /// No description provided for @coachAthletePlanMetricIntensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity (avg)'**
  String get coachAthletePlanMetricIntensity;

  /// No description provided for @coachAthletePlanMetricEffort.
  ///
  /// In en, this message translates to:
  /// **'Effort (RPE avg)'**
  String get coachAthletePlanMetricEffort;

  /// No description provided for @coachAthletePlanAxisX.
  ///
  /// In en, this message translates to:
  /// **'Axis X'**
  String get coachAthletePlanAxisX;

  /// No description provided for @coachAthletePlanAxisY.
  ///
  /// In en, this message translates to:
  /// **'Axis Y'**
  String get coachAthletePlanAxisY;

  /// No description provided for @coachAthletePlanNoAnalytics.
  ///
  /// In en, this message translates to:
  /// **'No analytics for this plan'**
  String get coachAthletePlanNoAnalytics;

  /// No description provided for @coachAthletePlanSessionsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {planned} sessions'**
  String coachAthletePlanSessionsCompleted(Object completed, Object planned);

  /// No description provided for @coachAthletePlanPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period: {start} – {end}'**
  String coachAthletePlanPeriod(Object start, Object end);

  /// No description provided for @coachAthletePlanNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes: {notes}'**
  String coachAthletePlanNotes(Object notes);

  /// No description provided for @coachAthletePlanMassEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mass edit athlete plan'**
  String get coachAthletePlanMassEditTooltip;

  /// No description provided for @coachAthletePlanMassEditMenu.
  ///
  /// In en, this message translates to:
  /// **'Mass edit (notes/day)'**
  String get coachAthletePlanMassEditMenu;

  /// No description provided for @coachAthletePlanWorkoutNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter note for athlete'**
  String get coachAthletePlanWorkoutNotesHint;

  /// No description provided for @coachAthletePlanWorkoutRescheduled.
  ///
  /// In en, this message translates to:
  /// **'Workout rescheduled'**
  String get coachAthletePlanWorkoutRescheduled;

  /// No description provided for @coachAthletePlanWorkoutNotesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Note updated'**
  String get coachAthletePlanWorkoutNotesUpdated;

  /// No description provided for @coachAthletePlanNoExercises.
  ///
  /// In en, this message translates to:
  /// **'No exercise data in this workout'**
  String get coachAthletePlanNoExercises;

  /// No description provided for @coachAthletePlanEditExercise.
  ///
  /// In en, this message translates to:
  /// **'Edit exercise'**
  String get coachAthletePlanEditExercise;

  /// No description provided for @coachAthletePlanAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get coachAthletePlanAddExercise;

  /// No description provided for @coachAthletePlanDeleteExerciseConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete exercise?'**
  String get coachAthletePlanDeleteExerciseConfirmTitle;

  /// No description provided for @coachAthletePlanDeleteExerciseConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name} from workout?'**
  String coachAthletePlanDeleteExerciseConfirmBody(Object name);

  /// No description provided for @coachAthletePlanExerciseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Exercise deleted'**
  String get coachAthletePlanExerciseDeleted;

  /// No description provided for @coachAthletePlanDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error while deleting: {error}'**
  String coachAthletePlanDeleteError(Object error);

  /// No description provided for @coachAthletePlanOrder.
  ///
  /// In en, this message translates to:
  /// **'Order: {order}'**
  String coachAthletePlanOrder(Object order);

  /// No description provided for @coachAthletePlanSets.
  ///
  /// In en, this message translates to:
  /// **'Sets: {count}'**
  String coachAthletePlanSets(Object count);

  /// No description provided for @coachAthletePlanNoSets.
  ///
  /// In en, this message translates to:
  /// **'No sets'**
  String get coachAthletePlanNoSets;

  /// No description provided for @coachAthletePlanAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get coachAthletePlanAddSet;

  /// No description provided for @coachAthletePlanMassEditErrorNoWorkouts.
  ///
  /// In en, this message translates to:
  /// **'No workouts for mass edits'**
  String get coachAthletePlanMassEditErrorNoWorkouts;

  /// No description provided for @coachAthletePlanMassEditErrorNoWorkoutsOnDay.
  ///
  /// In en, this message translates to:
  /// **'No workouts on selected day'**
  String get coachAthletePlanMassEditErrorNoWorkoutsOnDay;

  /// No description provided for @coachAthletePlanMassEditUpdateWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Update workout notes'**
  String get coachAthletePlanMassEditUpdateWorkouts;

  /// No description provided for @coachAthletePlanMassEditUpdateExercises.
  ///
  /// In en, this message translates to:
  /// **'Update exercise notes'**
  String get coachAthletePlanMassEditUpdateExercises;

  /// No description provided for @coachAthletePlanMassEditNoChanges.
  ///
  /// In en, this message translates to:
  /// **'No changes to apply'**
  String get coachAthletePlanMassEditNoChanges;

  /// No description provided for @coachAthletePlanMassEditApplied.
  ///
  /// In en, this message translates to:
  /// **'Mass edit applied for selected day'**
  String get coachAthletePlanMassEditApplied;

  /// No description provided for @coachAthletePlanMassEditWorkoutHint.
  ///
  /// In en, this message translates to:
  /// **'New note for all workouts on this day'**
  String get coachAthletePlanMassEditWorkoutHint;

  /// No description provided for @planEditorMassReplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Mass exercise replacement'**
  String get planEditorMassReplaceTitle;

  /// No description provided for @planEditorChooseTarget.
  ///
  /// In en, this message translates to:
  /// **'Choose target exercise'**
  String get planEditorChooseTarget;

  /// No description provided for @planEditorTargetPrefix.
  ///
  /// In en, this message translates to:
  /// **'Target: {name}'**
  String planEditorTargetPrefix(Object name);

  /// No description provided for @planEditorSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get planEditorSelectAll;

  /// No description provided for @planEditorClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get planEditorClearAll;

  /// No description provided for @planEditorOccurrences.
  ///
  /// In en, this message translates to:
  /// **'Occurrences: {count}'**
  String planEditorOccurrences(Object count);

  /// No description provided for @planEditorPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get planEditorPreview;

  /// No description provided for @planEditorRightsCheckUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Rights check unavailable, continuing without it: {error}'**
  String planEditorRightsCheckUnavailable(Object error);

  /// No description provided for @planEditorNoAccessibleMicrocycles.
  ///
  /// In en, this message translates to:
  /// **'No accessible microcycles for replacement'**
  String get planEditorNoAccessibleMicrocycles;

  /// No description provided for @planEditorNoExercisesToReplace.
  ///
  /// In en, this message translates to:
  /// **'No exercises to replace'**
  String get planEditorNoExercisesToReplace;

  /// No description provided for @planEditorPreviewReplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Replacement preview'**
  String get planEditorPreviewReplaceTitle;

  /// No description provided for @planEditorPreviewTarget.
  ///
  /// In en, this message translates to:
  /// **'Target: {name}'**
  String planEditorPreviewTarget(Object name);

  /// No description provided for @planEditorPreviewTotals.
  ///
  /// In en, this message translates to:
  /// **'Exercises to replace: {exercises}, sets affected: {sets}'**
  String planEditorPreviewTotals(Object exercises, Object sets);

  /// No description provided for @planEditorPreviewMicroStats.
  ///
  /// In en, this message translates to:
  /// **'Exercises: {ex} · Sets: {sets}'**
  String planEditorPreviewMicroStats(Object ex, Object sets);

  /// No description provided for @planEditorApplyReplaceResult.
  ///
  /// In en, this message translates to:
  /// **'Replacement: success {success}, failed {failed}'**
  String planEditorApplyReplaceResult(Object success, Object failed);

  /// No description provided for @workoutListTitle.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workoutListTitle;

  /// No description provided for @workoutListAddWorkout.
  ///
  /// In en, this message translates to:
  /// **'Add Workout'**
  String get workoutListAddWorkout;

  /// No description provided for @workoutListWorkoutName.
  ///
  /// In en, this message translates to:
  /// **'Workout Name'**
  String get workoutListWorkoutName;

  /// No description provided for @workoutListEnterNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a workout name'**
  String get workoutListEnterNameError;

  /// No description provided for @workoutListCreateError.
  ///
  /// In en, this message translates to:
  /// **'Error creating workout: {error}'**
  String workoutListCreateError(Object error);

  /// No description provided for @workoutListNextWorkout.
  ///
  /// In en, this message translates to:
  /// **'Next Workout'**
  String get workoutListNextWorkout;

  /// No description provided for @workoutListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No workouts in this progression'**
  String get workoutListEmpty;

  /// No description provided for @exerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise} other{{count} exercises}}'**
  String exerciseCount(num count);

  /// No description provided for @nutritionSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Sessions'**
  String get nutritionSessionsTitle;

  /// No description provided for @nutritionSessionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No nutrition sessions yet'**
  String get nutritionSessionsEmpty;

  /// No description provided for @nutritionSessionsEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your nutrition by creating your first session'**
  String get nutritionSessionsEmptyDesc;

  /// No description provided for @nutritionSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session {id}'**
  String nutritionSessionTitle(Object id);

  /// No description provided for @userIdLabel.
  ///
  /// In en, this message translates to:
  /// **'User ID: {id}'**
  String userIdLabel(Object id);

  /// No description provided for @entriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry} other{{count} entries}}'**
  String entriesCount(num count);

  /// No description provided for @nutritionEntriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get nutritionEntriesLabel;

  /// No description provided for @nutritionNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries'**
  String get nutritionNoEntries;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @workoutIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Workout ID'**
  String get workoutIdLabel;

  /// No description provided for @appliedPlanWorkoutIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Applied Plan Workout ID'**
  String get appliedPlanWorkoutIdLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @dosageLabel.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosageLabel;

  /// No description provided for @nutritionEditSession.
  ///
  /// In en, this message translates to:
  /// **'Edit Nutrition Session'**
  String get nutritionEditSession;

  /// No description provided for @nutritionCreateSession.
  ///
  /// In en, this message translates to:
  /// **'Create Nutrition Session'**
  String get nutritionCreateSession;

  /// No description provided for @nutritionSessionConfig.
  ///
  /// In en, this message translates to:
  /// **'Session Configuration'**
  String get nutritionSessionConfig;

  /// No description provided for @nutritionSessionId.
  ///
  /// In en, this message translates to:
  /// **'Session ID'**
  String get nutritionSessionId;

  /// No description provided for @workoutIdOptional.
  ///
  /// In en, this message translates to:
  /// **'Workout ID (optional)'**
  String get workoutIdOptional;

  /// No description provided for @appliedPlanWorkoutIdOptional.
  ///
  /// In en, this message translates to:
  /// **'Applied Plan Workout ID (optional)'**
  String get appliedPlanWorkoutIdOptional;

  /// No description provided for @nutritionSelectedEntries.
  ///
  /// In en, this message translates to:
  /// **'Selected Entries'**
  String get nutritionSelectedEntries;

  /// No description provided for @nutritionNoEntriesSelected.
  ///
  /// In en, this message translates to:
  /// **'No entries selected'**
  String get nutritionNoEntriesSelected;

  /// No description provided for @nutritionAvailableItems.
  ///
  /// In en, this message translates to:
  /// **'Available Items'**
  String get nutritionAvailableItems;

  /// No description provided for @foodLabel.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get foodLabel;

  /// No description provided for @supplementsLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplements'**
  String get supplementsLabel;

  /// No description provided for @medicationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medicationsLabel;

  /// No description provided for @nutritionNoItemsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No items available'**
  String get nutritionNoItemsAvailable;

  /// No description provided for @updateSession.
  ///
  /// In en, this message translates to:
  /// **'Update Session'**
  String get updateSession;

  /// No description provided for @createSession.
  ///
  /// In en, this message translates to:
  /// **'Create Session'**
  String get createSession;

  /// No description provided for @exerciseListEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Try changing the filter or add a new exercise'**
  String get exerciseListEmptyDesc;

  /// No description provided for @envBadgeWorkZone.
  ///
  /// In en, this message translates to:
  /// **'WORK ZONE'**
  String get envBadgeWorkZone;

  /// No description provided for @envBadgeLive.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get envBadgeLive;

  /// No description provided for @envBadgeCnsStorm.
  ///
  /// In en, this message translates to:
  /// **'CNS STORM'**
  String get envBadgeCnsStorm;

  /// No description provided for @envBadgeDeload.
  ///
  /// In en, this message translates to:
  /// **'DELOAD'**
  String get envBadgeDeload;

  /// No description provided for @envIdleTactical.
  ///
  /// In en, this message translates to:
  /// **'System ready. Select a session or configure the grid.'**
  String get envIdleTactical;

  /// No description provided for @envIdleSnarky.
  ///
  /// In en, this message translates to:
  /// **'The barbell will not lift itself. Pick a target.'**
  String get envIdleSnarky;

  /// No description provided for @envLiveTacticalPeak.
  ///
  /// In en, this message translates to:
  /// **'Session in progress · Peak {peak}'**
  String envLiveTacticalPeak(Object peak);

  /// No description provided for @envLiveTactical.
  ///
  /// In en, this message translates to:
  /// **'Active session in progress · Focus mode'**
  String get envLiveTactical;

  /// No description provided for @envLiveSnarkyPeak.
  ///
  /// In en, this message translates to:
  /// **'Clock is ticking. Conquer {peak} and quit whining.'**
  String envLiveSnarkyPeak(Object peak);

  /// No description provided for @envLiveSnarky.
  ///
  /// In en, this message translates to:
  /// **'Stopwatch is running. Less talk, more reps.'**
  String get envLiveSnarky;

  /// No description provided for @envStormTacticalWithTonnage.
  ///
  /// In en, this message translates to:
  /// **'Peak {detail} · Volume {tonnage} · High CNS load'**
  String envStormTacticalWithTonnage(Object detail, Object tonnage);

  /// No description provided for @envStormTactical.
  ///
  /// In en, this message translates to:
  /// **'Peak {detail} · Peak CNS load'**
  String envStormTactical(Object detail);

  /// No description provided for @envStormSnarky.
  ///
  /// In en, this message translates to:
  /// **'Peak {detail}. CNS is begging for mercy — turn it up.'**
  String envStormSnarky(Object detail);

  /// No description provided for @envDeloadLightZone.
  ///
  /// In en, this message translates to:
  /// **'light zone'**
  String get envDeloadLightZone;

  /// No description provided for @envDeloadTacticalWithTonnage.
  ///
  /// In en, this message translates to:
  /// **'Recovery · {rpe} · Volume {tonnage}'**
  String envDeloadTacticalWithTonnage(Object rpe, Object tonnage);

  /// No description provided for @envDeloadTactical.
  ///
  /// In en, this message translates to:
  /// **'Deload phase · {rpe} · Adaptation'**
  String envDeloadTactical(Object rpe);

  /// No description provided for @envDeloadSnarky.
  ///
  /// In en, this message translates to:
  /// **'Resort mode ({rpe}). Do not even think about adding plates.'**
  String envDeloadSnarky(Object rpe);

  /// No description provided for @envWorkTacticalPeakTonnage.
  ///
  /// In en, this message translates to:
  /// **'Peak {peak} · Working volume {tonnage}'**
  String envWorkTacticalPeakTonnage(Object peak, Object tonnage);

  /// No description provided for @envWorkSnarkyPeak.
  ///
  /// In en, this message translates to:
  /// **'Working corridor: {peak}. Discipline beats ego.'**
  String envWorkSnarkyPeak(Object peak);

  /// No description provided for @envWorkTacticalSets.
  ///
  /// In en, this message translates to:
  /// **'Work zone · {sets} sets'**
  String envWorkTacticalSets(Object sets);

  /// No description provided for @envWorkTacticalSetsWithTonnage.
  ///
  /// In en, this message translates to:
  /// **'Work zone · {sets} sets · {tonnage}'**
  String envWorkTacticalSetsWithTonnage(Object sets, Object tonnage);

  /// No description provided for @envWorkSnarkySets.
  ///
  /// In en, this message translates to:
  /// **'{sets} working sets. Boring? That is called progress.'**
  String envWorkSnarkySets(Object sets);

  /// No description provided for @envWorkTacticalReady.
  ///
  /// In en, this message translates to:
  /// **'{prefix}Work zone · Ready to launch'**
  String envWorkTacticalReady(Object prefix);

  /// No description provided for @envWorkSnarkyReady.
  ///
  /// In en, this message translates to:
  /// **'{prefix}Clean slate. Load it properly.'**
  String envWorkSnarkyReady(Object prefix);

  /// No description provided for @unitKgValue.
  ///
  /// In en, this message translates to:
  /// **'{value} kg'**
  String unitKgValue(Object value);

  /// No description provided for @unitSetsShort.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String unitSetsShort(Object count);

  /// No description provided for @unitExercisesShort.
  ///
  /// In en, this message translates to:
  /// **'{count} ex.'**
  String unitExercisesShort(Object count);

  /// No description provided for @unitMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String unitMinutesShort(Object count);

  /// No description provided for @presetPowerlifter.
  ///
  /// In en, this message translates to:
  /// **'Strength 5/3/1'**
  String get presetPowerlifter;

  /// No description provided for @presetVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get presetVolume;

  /// No description provided for @presetMinimalist.
  ///
  /// In en, this message translates to:
  /// **'Minimalist'**
  String get presetMinimalist;

  /// No description provided for @presetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get presetCustom;

  /// No description provided for @slotShortPeakIntensity.
  ///
  /// In en, this message translates to:
  /// **'PEAK %'**
  String get slotShortPeakIntensity;

  /// No description provided for @slotShortE1rm.
  ///
  /// In en, this message translates to:
  /// **'E1RM'**
  String get slotShortE1rm;

  /// No description provided for @slotShortPeakRpe.
  ///
  /// In en, this message translates to:
  /// **'PEAK RPE'**
  String get slotShortPeakRpe;

  /// No description provided for @slotShortAvgRpe.
  ///
  /// In en, this message translates to:
  /// **'AVG RPE'**
  String get slotShortAvgRpe;

  /// No description provided for @slotShortTonnage.
  ///
  /// In en, this message translates to:
  /// **'TONNAGE'**
  String get slotShortTonnage;

  /// No description provided for @slotShortKpsh.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get slotShortKpsh;

  /// No description provided for @slotShortSetsCount.
  ///
  /// In en, this message translates to:
  /// **'SETS'**
  String get slotShortSetsCount;

  /// No description provided for @slotShortDensity.
  ///
  /// In en, this message translates to:
  /// **'DENSITY'**
  String get slotShortDensity;

  /// No description provided for @slotShortDurationWeeks.
  ///
  /// In en, this message translates to:
  /// **'WEEKS'**
  String get slotShortDurationWeeks;

  /// No description provided for @slotShortFrequencyPerWeek.
  ///
  /// In en, this message translates to:
  /// **'FREQ'**
  String get slotShortFrequencyPerWeek;

  /// No description provided for @slotNamePeakIntensity.
  ///
  /// In en, this message translates to:
  /// **'Peak % 1RM'**
  String get slotNamePeakIntensity;

  /// No description provided for @slotNameE1rm.
  ///
  /// In en, this message translates to:
  /// **'Estimated 1RM'**
  String get slotNameE1rm;

  /// No description provided for @slotNamePeakRpe.
  ///
  /// In en, this message translates to:
  /// **'Peak RPE'**
  String get slotNamePeakRpe;

  /// No description provided for @slotNameAvgRpe.
  ///
  /// In en, this message translates to:
  /// **'Average RPE'**
  String get slotNameAvgRpe;

  /// No description provided for @slotNameTonnage.
  ///
  /// In en, this message translates to:
  /// **'Tonnage'**
  String get slotNameTonnage;

  /// No description provided for @slotNameKpsh.
  ///
  /// In en, this message translates to:
  /// **'Total Reps'**
  String get slotNameKpsh;

  /// No description provided for @slotNameSetsCount.
  ///
  /// In en, this message translates to:
  /// **'Working Sets'**
  String get slotNameSetsCount;

  /// No description provided for @slotNameDensity.
  ///
  /// In en, this message translates to:
  /// **'Density'**
  String get slotNameDensity;

  /// No description provided for @slotNameDurationWeeks.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get slotNameDurationWeeks;

  /// No description provided for @slotNameFrequencyPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Workouts/week'**
  String get slotNameFrequencyPerWeek;

  /// No description provided for @moduleVariantOrHorizonStrip.
  ///
  /// In en, this message translates to:
  /// **'Presets / Variants strip'**
  String get moduleVariantOrHorizonStrip;

  /// No description provided for @moduleCommandBriefing.
  ///
  /// In en, this message translates to:
  /// **'Load Briefing'**
  String get moduleCommandBriefing;

  /// No description provided for @modulePrimaryTelemetry.
  ///
  /// In en, this message translates to:
  /// **'Telemetry & Chart'**
  String get modulePrimaryTelemetry;

  /// No description provided for @moduleScheduleOrLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library / Microcycles'**
  String get moduleScheduleOrLibrary;

  /// No description provided for @interfaceMakerTitle.
  ///
  /// In en, this message translates to:
  /// **'Screen Grid & Modules'**
  String get interfaceMakerTitle;

  /// No description provided for @interfaceMakerReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get interfaceMakerReset;

  /// No description provided for @interfaceMakerPresetsSection.
  ///
  /// In en, this message translates to:
  /// **'DISCIPLINE PRESETS'**
  String get interfaceMakerPresetsSection;

  /// No description provided for @interfaceMakerWaveChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Wave chart in cards'**
  String get interfaceMakerWaveChartTitle;

  /// No description provided for @interfaceMakerWaveChartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Disable for a compact view without charts'**
  String get interfaceMakerWaveChartSubtitle;

  /// No description provided for @interfaceMakerSnarkyTitle.
  ///
  /// In en, this message translates to:
  /// **'CARROT-style briefing'**
  String get interfaceMakerSnarkyTitle;

  /// No description provided for @interfaceMakerSnarkySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Snarky load summary instead of dry tactical'**
  String get interfaceMakerSnarkySubtitle;

  /// No description provided for @interfaceMakerSlotsSection.
  ///
  /// In en, this message translates to:
  /// **'4 TELEMETRY SLOTS (DATA POINT PICKER)'**
  String get interfaceMakerSlotsSection;

  /// No description provided for @interfaceMakerSlotNumber.
  ///
  /// In en, this message translates to:
  /// **'Slot {index}'**
  String interfaceMakerSlotNumber(Object index);

  /// No description provided for @interfaceMakerModulesSection.
  ///
  /// In en, this message translates to:
  /// **'MODULES & SCREEN ORDER'**
  String get interfaceMakerModulesSection;

  /// No description provided for @interfaceMakerMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get interfaceMakerMoveUp;

  /// No description provided for @interfaceMakerMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get interfaceMakerMoveDown;

  /// No description provided for @homeNoPlannedSessions.
  ///
  /// In en, this message translates to:
  /// **'All planned sessions completed or no plan selected'**
  String get homeNoPlannedSessions;

  /// No description provided for @homeOpenActivePlanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open active plan'**
  String get homeOpenActivePlanTooltip;

  /// No description provided for @homeOpenCalendarPlanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open calendar plan'**
  String get homeOpenCalendarPlanTooltip;

  /// No description provided for @actionStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get actionStart;

  /// No description provided for @actionFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get actionFinish;

  /// No description provided for @actionNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get actionNew;

  /// No description provided for @metricTimeShort.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get metricTimeShort;

  /// No description provided for @metricExercisesShort.
  ///
  /// In en, this message translates to:
  /// **'EX.'**
  String get metricExercisesShort;

  /// No description provided for @sessionLogHeader.
  ///
  /// In en, this message translates to:
  /// **'SESSION LOG'**
  String get sessionLogHeader;

  /// No description provided for @sessionLogLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get sessionLogLibrary;

  /// No description provided for @sessionLogLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load workouts'**
  String get sessionLogLoadError;

  /// No description provided for @sessionLogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No manual sessions'**
  String get sessionLogEmptyTitle;

  /// No description provided for @sessionLogEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap \"New\" to log a free workout'**
  String get sessionLogEmptySubtitle;

  /// No description provided for @sessionLogAllShown.
  ///
  /// In en, this message translates to:
  /// **'ALL SESSIONS SHOWN'**
  String get sessionLogAllShown;

  /// No description provided for @workoutDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete workout'**
  String get workoutDeleteTooltip;

  /// No description provided for @workoutManualSession.
  ///
  /// In en, this message translates to:
  /// **'Manual session'**
  String get workoutManualSession;

  /// No description provided for @workoutMarkAllCompletedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark all as completed'**
  String get workoutMarkAllCompletedTooltip;

  /// No description provided for @tooltipDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get tooltipDecrease;

  /// No description provided for @deleteExerciseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete exercise'**
  String get deleteExerciseTooltip;

  /// No description provided for @deleteSetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete set'**
  String get deleteSetTooltip;

  /// No description provided for @metricMicrocyclesShort.
  ///
  /// In en, this message translates to:
  /// **'MICROCYCLES'**
  String get metricMicrocyclesShort;

  /// No description provided for @metricAppliedShort.
  ///
  /// In en, this message translates to:
  /// **'APPLIED'**
  String get metricAppliedShort;

  /// No description provided for @planVariantOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get planVariantOriginal;

  /// No description provided for @planVariantAdd.
  ///
  /// In en, this message translates to:
  /// **'+ Variant'**
  String get planVariantAdd;

  /// No description provided for @planAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Analytics'**
  String get planAnalyticsTitle;

  /// No description provided for @tooltipCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get tooltipCollapse;

  /// No description provided for @tooltipExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get tooltipExpand;

  /// No description provided for @navWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get navWorkouts;

  /// No description provided for @navPlans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get navPlans;

  /// No description provided for @navFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get navFeed;

  /// No description provided for @navCrm.
  ///
  /// In en, this message translates to:
  /// **'CRM'**
  String get navCrm;

  /// No description provided for @navDebug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get navDebug;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @activePlanEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No active plan'**
  String get activePlanEmptyTitle;

  /// No description provided for @activePlanEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Select a calendar plan to start a cycle'**
  String get activePlanEmptyDescription;

  /// No description provided for @activePlanSelectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select plan'**
  String get activePlanSelectPlan;

  /// No description provided for @horizon1Week.
  ///
  /// In en, this message translates to:
  /// **'1 wk'**
  String get horizon1Week;

  /// No description provided for @horizon2Weeks.
  ///
  /// In en, this message translates to:
  /// **'2 wk'**
  String get horizon2Weeks;

  /// No description provided for @horizonMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get horizonMonth;

  /// No description provided for @horizonChipLabel.
  ///
  /// In en, this message translates to:
  /// **'Horizon · {horizon}'**
  String horizonChipLabel(Object horizon);

  /// No description provided for @gridPillLabel.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get gridPillLabel;

  /// No description provided for @planPillLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get planPillLabel;

  /// No description provided for @activePlanMicrocycleCalendarHeader.
  ///
  /// In en, this message translates to:
  /// **'MICROCYCLE CALENDAR'**
  String get activePlanMicrocycleCalendarHeader;

  /// No description provided for @activePlanDayLabel.
  ///
  /// In en, this message translates to:
  /// **'PLAN DAY'**
  String get activePlanDayLabel;

  /// No description provided for @actionView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get actionView;

  /// No description provided for @activePlanNoWorkoutsSelectedDay.
  ///
  /// In en, this message translates to:
  /// **'No workouts on the selected day'**
  String get activePlanNoWorkoutsSelectedDay;

  /// No description provided for @noWorkouts.
  ///
  /// In en, this message translates to:
  /// **'No workouts'**
  String get noWorkouts;

  /// No description provided for @metricAvgIntensityShort.
  ///
  /// In en, this message translates to:
  /// **'AVG INT.'**
  String get metricAvgIntensityShort;

  /// No description provided for @metricCompletedShort.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get metricCompletedShort;

  /// No description provided for @metricAvgRpeShort.
  ///
  /// In en, this message translates to:
  /// **'AVG RPE'**
  String get metricAvgRpeShort;

  /// No description provided for @metricRepsShort.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get metricRepsShort;

  /// No description provided for @metricSetsShort.
  ///
  /// In en, this message translates to:
  /// **'SETS'**
  String get metricSetsShort;

  /// No description provided for @metricSessionsShort.
  ///
  /// In en, this message translates to:
  /// **'SESSIONS'**
  String get metricSessionsShort;

  /// No description provided for @tooltipCollapseChart.
  ///
  /// In en, this message translates to:
  /// **'Collapse chart'**
  String get tooltipCollapseChart;

  /// No description provided for @tooltipExpandChart.
  ///
  /// In en, this message translates to:
  /// **'Expand chart'**
  String get tooltipExpandChart;

  /// No description provided for @activePlanNoData.
  ///
  /// In en, this message translates to:
  /// **'No data for plan'**
  String get activePlanNoData;

  /// No description provided for @workoutListAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Workout'**
  String get workoutListAddTitle;

  /// No description provided for @workoutListNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Workout name'**
  String get workoutListNameLabel;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @workoutListNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a workout name'**
  String get workoutListNameRequired;

  /// No description provided for @workoutListLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading workouts: {error}'**
  String workoutListLoadError(Object error);

  /// No description provided for @workoutListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No workouts'**
  String get workoutListEmptyTitle;

  /// No description provided for @workoutListEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'There are no workouts in this progression yet'**
  String get workoutListEmptyDescription;

  /// No description provided for @workoutListSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout List'**
  String get workoutListSectionTitle;

  /// No description provided for @workoutsCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Workout'**
  String get workoutsCreateTitle;

  /// No description provided for @actionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// No description provided for @workoutsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete workout?'**
  String get workoutsDeleteTitle;

  /// No description provided for @workoutsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this manual workout?'**
  String get workoutsDeleteConfirm;

  /// No description provided for @workoutsPlanLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading plan: {error}'**
  String workoutsPlanLoadError(Object error);

  /// No description provided for @workoutDetailOpenError.
  ///
  /// In en, this message translates to:
  /// **'Failed to open workout'**
  String get workoutDetailOpenError;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @workoutDetailAppStateNotReady.
  ///
  /// In en, this message translates to:
  /// **'Failed to update set: app state not ready'**
  String get workoutDetailAppStateNotReady;

  /// No description provided for @workoutDetailDeleteExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Exercise'**
  String get workoutDetailDeleteExerciseTitle;

  /// No description provided for @workoutDetailExerciseRemoved.
  ///
  /// In en, this message translates to:
  /// **'Exercise removed from workout'**
  String get workoutDetailExerciseRemoved;

  /// No description provided for @workoutDetailDeleteUnsavedExerciseError.
  ///
  /// In en, this message translates to:
  /// **'Error: Cannot delete unsaved exercise'**
  String get workoutDetailDeleteUnsavedExerciseError;

  /// No description provided for @workoutDetailAddSetUnsavedError.
  ///
  /// In en, this message translates to:
  /// **'Cannot add set: exercise is not saved yet'**
  String get workoutDetailAddSetUnsavedError;

  /// No description provided for @workoutDetailSetAdded.
  ///
  /// In en, this message translates to:
  /// **'Set added successfully'**
  String get workoutDetailSetAdded;

  /// No description provided for @workoutDetailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Workout updated'**
  String get workoutDetailUpdated;

  /// No description provided for @workoutDetailStarted.
  ///
  /// In en, this message translates to:
  /// **'Workout started'**
  String get workoutDetailStarted;

  /// No description provided for @workoutDetailSessionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Session cancelled'**
  String get workoutDetailSessionCancelled;

  /// No description provided for @workoutDetailFinished.
  ///
  /// In en, this message translates to:
  /// **'Workout finished'**
  String get workoutDetailFinished;

  /// No description provided for @workoutDetailAllSetsCompleted.
  ///
  /// In en, this message translates to:
  /// **'All sets are already completed'**
  String get workoutDetailAllSetsCompleted;

  /// No description provided for @workoutDetailDeleteSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Set'**
  String get workoutDetailDeleteSetTitle;

  /// No description provided for @workoutDetailSetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Set deleted successfully'**
  String get workoutDetailSetDeleted;

  /// No description provided for @workoutDetailExerciseAdded.
  ///
  /// In en, this message translates to:
  /// **'Exercise added successfully'**
  String get workoutDetailExerciseAdded;

  /// No description provided for @workoutDetailFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Details'**
  String get workoutDetailFallbackTitle;

  /// No description provided for @workoutDetailNoExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'No exercises yet'**
  String get workoutDetailNoExercisesTitle;

  /// No description provided for @workoutDetailNoExercisesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add exercise\" below to build a session'**
  String get workoutDetailNoExercisesSubtitle;

  /// No description provided for @metricTimerShort.
  ///
  /// In en, this message translates to:
  /// **'TIMER'**
  String get metricTimerShort;

  /// No description provided for @metricModeShort.
  ///
  /// In en, this message translates to:
  /// **'MODE'**
  String get metricModeShort;

  /// No description provided for @tooltipEditExercise.
  ///
  /// In en, this message translates to:
  /// **'Edit exercise'**
  String get tooltipEditExercise;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @planEditorSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'SELECTED: {count}'**
  String planEditorSelectedCount(Object count);

  /// No description provided for @planEditorBulkShort.
  ///
  /// In en, this message translates to:
  /// **'Bulk'**
  String get planEditorBulkShort;

  /// No description provided for @planEditorMesocyclesCount.
  ///
  /// In en, this message translates to:
  /// **'MESOCYCLES · {count}'**
  String planEditorMesocyclesCount(Object count);

  /// No description provided for @planEditorMicrocyclesCount.
  ///
  /// In en, this message translates to:
  /// **'MICROCYCLES: {count}'**
  String planEditorMicrocyclesCount(Object count);

  /// No description provided for @planEditorEditMicrocycleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit microcycle'**
  String get planEditorEditMicrocycleTooltip;

  /// No description provided for @planEditorIntensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get planEditorIntensity;

  /// No description provided for @planEditorReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get planEditorReps;

  /// No description provided for @planEditorModeSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get planEditorModeSet;

  /// No description provided for @planEditorModeOffset.
  ///
  /// In en, this message translates to:
  /// **'Offset'**
  String get planEditorModeOffset;

  /// No description provided for @planEditorModeScale.
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get planEditorModeScale;

  /// No description provided for @planEditorRecalcAuto.
  ///
  /// In en, this message translates to:
  /// **'Recalc: Auto'**
  String get planEditorRecalcAuto;

  /// No description provided for @planEditorRecalcReps.
  ///
  /// In en, this message translates to:
  /// **'Recalc: Reps'**
  String get planEditorRecalcReps;

  /// No description provided for @planEditorRecalcEffort.
  ///
  /// In en, this message translates to:
  /// **'Recalc: RPE'**
  String get planEditorRecalcEffort;

  /// No description provided for @planEditorRecalcIntensity.
  ///
  /// In en, this message translates to:
  /// **'Recalc: Intensity'**
  String get planEditorRecalcIntensity;

  /// No description provided for @planEditorAutoRecalcReps.
  ///
  /// In en, this message translates to:
  /// **'Auto-recalc: Reps (from Intensity & RPE)'**
  String get planEditorAutoRecalcReps;

  /// No description provided for @planEditorAutoRecalcIntensity.
  ///
  /// In en, this message translates to:
  /// **'Auto-recalc: Intensity (from Reps & RPE)'**
  String get planEditorAutoRecalcIntensity;

  /// No description provided for @planEditorAutoRecalcRpe.
  ///
  /// In en, this message translates to:
  /// **'Auto-recalc: RPE (from Intensity & Reps)'**
  String get planEditorAutoRecalcRpe;

  /// No description provided for @planEditorAutoRecalcNone.
  ///
  /// In en, this message translates to:
  /// **'Auto-recalc: disabled'**
  String get planEditorAutoRecalcNone;

  /// No description provided for @planEditorFilterExercisesOptional.
  ///
  /// In en, this message translates to:
  /// **'Filter: exercises (optional)'**
  String get planEditorFilterExercisesOptional;

  /// No description provided for @planEditorMassEditWarning.
  ///
  /// In en, this message translates to:
  /// **'ALL sets of all exercises in all selected microcycles will be modified.'**
  String get planEditorMassEditWarning;

  /// No description provided for @planEditorNoChanges.
  ///
  /// In en, this message translates to:
  /// **'No changes for selected parameters'**
  String get planEditorNoChanges;

  /// No description provided for @planEditorMassEditPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Mass edits preview'**
  String get planEditorMassEditPreviewTitle;

  /// No description provided for @planEditorMicrocyclesCountPlain.
  ///
  /// In en, this message translates to:
  /// **'Microcycles: {count}'**
  String planEditorMicrocyclesCountPlain(Object count);

  /// No description provided for @planEditorMismatchesCount.
  ///
  /// In en, this message translates to:
  /// **'Mismatches: {count}'**
  String planEditorMismatchesCount(Object count);

  /// No description provided for @planEditorChangedSets.
  ///
  /// In en, this message translates to:
  /// **'Changed sets: {changed} of {total}'**
  String planEditorChangedSets(Object changed, Object total);

  /// No description provided for @planEditorDeltaSummary.
  ///
  /// In en, this message translates to:
  /// **'Changes: Int {i} · RPE {e} · Reps {v}'**
  String planEditorDeltaSummary(Object e, Object i, Object v);

  /// No description provided for @planEditorFixNone.
  ///
  /// In en, this message translates to:
  /// **'Validator: No auto-fix'**
  String get planEditorFixNone;

  /// No description provided for @planEditorFixReps.
  ///
  /// In en, this message translates to:
  /// **'Validator: Fix Reps'**
  String get planEditorFixReps;

  /// No description provided for @planEditorFixIntensity.
  ///
  /// In en, this message translates to:
  /// **'Validator: Fix Intensity'**
  String get planEditorFixIntensity;

  /// No description provided for @planEditorPreviewMicroDiff.
  ///
  /// In en, this message translates to:
  /// **'Sets: {changed}/{total} · Δ Int {i} · Δ RPE {e} · Δ Reps {v}'**
  String planEditorPreviewMicroDiff(
    Object changed,
    Object e,
    Object i,
    Object total,
    Object v,
  );

  /// No description provided for @planDetailDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete plan: {error}'**
  String planDetailDeleteFailed(Object error);

  /// No description provided for @tooltipMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get tooltipMoreActions;

  /// No description provided for @planDetailEditPlan.
  ///
  /// In en, this message translates to:
  /// **'Edit plan'**
  String get planDetailEditPlan;

  /// No description provided for @planDetailRecalcSets.
  ///
  /// In en, this message translates to:
  /// **'Recalculate sets (RPE)'**
  String get planDetailRecalcSets;

  /// No description provided for @planDetailDeletePlan.
  ///
  /// In en, this message translates to:
  /// **'Delete plan'**
  String get planDetailDeletePlan;

  /// No description provided for @planDetailAdoptersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load adoption count: {error}'**
  String planDetailAdoptersLoadError(Object error);

  /// No description provided for @planDetailLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load plan: {error}'**
  String planDetailLoadError(Object error);

  /// No description provided for @planDetailRecalculated.
  ///
  /// In en, this message translates to:
  /// **'Plan recalculated'**
  String get planDetailRecalculated;

  /// No description provided for @planDetailRecalcError.
  ///
  /// In en, this message translates to:
  /// **'Failed to recalculate plan: {error}'**
  String planDetailRecalcError(Object error);

  /// No description provided for @planDetailVariantsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load variants: {error}'**
  String planDetailVariantsLoadError(Object error);

  /// No description provided for @planDetailNewVariantTitle.
  ///
  /// In en, this message translates to:
  /// **'New plan variant'**
  String get planDetailNewVariantTitle;

  /// No description provided for @planDetailVariantNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Variant name'**
  String get planDetailVariantNameLabel;

  /// No description provided for @errorEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get errorEnterName;

  /// No description provided for @planDetailVariantCreated.
  ///
  /// In en, this message translates to:
  /// **'Variant created'**
  String get planDetailVariantCreated;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetails(Object error);

  /// No description provided for @metricVolumeShort.
  ///
  /// In en, this message translates to:
  /// **'VOLUME'**
  String get metricVolumeShort;

  /// No description provided for @unitRepsShort.
  ///
  /// In en, this message translates to:
  /// **'{count} reps'**
  String unitRepsShort(Object count);

  /// No description provided for @unitSetsPerWorkout.
  ///
  /// In en, this message translates to:
  /// **'{value}/wo'**
  String unitSetsPerWorkout(Object value);

  /// No description provided for @planDetailAnalyticsFilters.
  ///
  /// In en, this message translates to:
  /// **'Analytics filters'**
  String get planDetailAnalyticsFilters;

  /// No description provided for @planDetailGranularity.
  ///
  /// In en, this message translates to:
  /// **'GRANULARITY'**
  String get planDetailGranularity;

  /// No description provided for @planDetailExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get planDetailExercisesTitle;

  /// No description provided for @loadingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loadingEllipsis;

  /// No description provided for @planDetailMuscleGroupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Muscle groups'**
  String get planDetailMuscleGroupsTitle;

  /// No description provided for @planDetailAxesTitle.
  ///
  /// In en, this message translates to:
  /// **'X Axis / Y Axis'**
  String get planDetailAxesTitle;

  /// No description provided for @planDetailFiltersPillCount.
  ///
  /// In en, this message translates to:
  /// **'Filters · {bucket} ({count})'**
  String planDetailFiltersPillCount(Object bucket, Object count);

  /// No description provided for @planDetailFiltersPill.
  ///
  /// In en, this message translates to:
  /// **'Filters · {bucket}'**
  String planDetailFiltersPill(Object bucket);

  /// No description provided for @planDetailExercisesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load exercise data'**
  String get planDetailExercisesLoadError;

  /// No description provided for @planDetailAllExercises.
  ///
  /// In en, this message translates to:
  /// **'All exercises'**
  String get planDetailAllExercises;

  /// No description provided for @planDetailFilterEmpty.
  ///
  /// In en, this message translates to:
  /// **'Filter contains no data'**
  String get planDetailFilterEmpty;

  /// No description provided for @planDetailAndMore.
  ///
  /// In en, this message translates to:
  /// **'{items} and {count} more'**
  String planDetailAndMore(Object count, Object items);

  /// No description provided for @planDetailAllMuscles.
  ///
  /// In en, this message translates to:
  /// **'All muscles'**
  String get planDetailAllMuscles;

  /// No description provided for @planDetailSelectExercises.
  ///
  /// In en, this message translates to:
  /// **'Select exercises'**
  String get planDetailSelectExercises;

  /// No description provided for @planDetailSelectMuscles.
  ///
  /// In en, this message translates to:
  /// **'Select muscles'**
  String get planDetailSelectMuscles;

  /// No description provided for @planDetailSelectMetricX.
  ///
  /// In en, this message translates to:
  /// **'Select metric for X axis'**
  String get planDetailSelectMetricX;

  /// No description provided for @planDetailSelectMetricY.
  ///
  /// In en, this message translates to:
  /// **'Select metric for Y axis'**
  String get planDetailSelectMetricY;

  /// No description provided for @metricYRepsVolume.
  ///
  /// In en, this message translates to:
  /// **'Reps (volume)'**
  String get metricYRepsVolume;

  /// No description provided for @metricYIntensityPct.
  ///
  /// In en, this message translates to:
  /// **'Intensity (%)'**
  String get metricYIntensityPct;

  /// No description provided for @metricYEffortRpe.
  ///
  /// In en, this message translates to:
  /// **'Effort (RPE)'**
  String get metricYEffortRpe;

  /// No description provided for @granularitySessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get granularitySessions;

  /// No description provided for @granularityMicrocycles.
  ///
  /// In en, this message translates to:
  /// **'Microcycles'**
  String get granularityMicrocycles;

  /// No description provided for @granularityWeeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get granularityWeeks;

  /// No description provided for @planDetailCurrentMax.
  ///
  /// In en, this message translates to:
  /// **'Current max: {weight} kg × {reps}'**
  String planDetailCurrentMax(Object reps, Object weight);

  /// No description provided for @planDetailMaxNotSet.
  ///
  /// In en, this message translates to:
  /// **'Max not set'**
  String get planDetailMaxNotSet;

  /// No description provided for @planDetailMadePublic.
  ///
  /// In en, this message translates to:
  /// **'Plan made public'**
  String get planDetailMadePublic;

  /// No description provided for @planDetailMadePrivate.
  ///
  /// In en, this message translates to:
  /// **'Plan hidden (private only)'**
  String get planDetailMadePrivate;

  /// No description provided for @planDetailVisibilityError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update plan visibility: {error}'**
  String planDetailVisibilityError(Object error);

  /// No description provided for @metricSetShort.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get metricSetShort;

  /// No description provided for @metricIntShort.
  ///
  /// In en, this message translates to:
  /// **'INT'**
  String get metricIntShort;

  /// No description provided for @metricRepsColShort.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get metricRepsColShort;

  /// No description provided for @normRulesCount.
  ///
  /// In en, this message translates to:
  /// **'Custom rules: {count}'**
  String normRulesCount(Object count);

  /// No description provided for @normNotSet.
  ///
  /// In en, this message translates to:
  /// **'Normalization not set'**
  String get normNotSet;

  /// No description provided for @normUnitPct1rm.
  ///
  /// In en, this message translates to:
  /// **'% of 1RM'**
  String get normUnitPct1rm;

  /// No description provided for @normUnitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get normUnitKg;

  /// No description provided for @normRulesSuffix.
  ///
  /// In en, this message translates to:
  /// **', rules: {count}'**
  String normRulesSuffix(Object count);

  /// No description provided for @normSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'POST-MICROCYCLE NORMALIZATION'**
  String get normSectionHeader;

  /// No description provided for @normDeltaLabel.
  ///
  /// In en, this message translates to:
  /// **'Change (e.g. -2.5)'**
  String get normDeltaLabel;

  /// No description provided for @normDeltaHint.
  ///
  /// In en, this message translates to:
  /// **'In kg or %'**
  String get normDeltaHint;

  /// No description provided for @normUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get normUnitLabel;

  /// No description provided for @normUnitPctMult.
  ///
  /// In en, this message translates to:
  /// **'% (multiplicative)'**
  String get normUnitPctMult;

  /// No description provided for @normUnitKgAbs.
  ///
  /// In en, this message translates to:
  /// **'kg (absolute)'**
  String get normUnitKgAbs;

  /// No description provided for @normDescription.
  ///
  /// In en, this message translates to:
  /// **'Specify one global change and/or rules for specific exercises, muscle groups, or target muscles.'**
  String get normDescription;

  /// No description provided for @normRulesHeader.
  ///
  /// In en, this message translates to:
  /// **'NORMALIZATION RULES'**
  String get normRulesHeader;

  /// No description provided for @normAddRule.
  ///
  /// In en, this message translates to:
  /// **'Add rule'**
  String get normAddRule;

  /// No description provided for @normNoRules.
  ///
  /// In en, this message translates to:
  /// **'No custom rules yet'**
  String get normNoRules;

  /// No description provided for @normRuleHeader.
  ///
  /// In en, this message translates to:
  /// **'RULE {index}'**
  String normRuleHeader(Object index);

  /// No description provided for @normDeleteRuleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete rule'**
  String get normDeleteRuleTooltip;

  /// No description provided for @normExerciseIdsLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise IDs (comma-separated)'**
  String get normExerciseIdsLabel;

  /// No description provided for @normExerciseIdsHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: 12, 45, 103'**
  String get normExerciseIdsHint;

  /// No description provided for @normMuscleGroupsLabel.
  ///
  /// In en, this message translates to:
  /// **'Muscle groups (comma-separated)'**
  String get normMuscleGroupsLabel;

  /// No description provided for @normMuscleGroupsHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: chest, quads'**
  String get normMuscleGroupsHint;

  /// No description provided for @normTargetMusclesLabel.
  ///
  /// In en, this message translates to:
  /// **'Target muscles (comma-separated)'**
  String get normTargetMusclesLabel;

  /// No description provided for @normTargetMusclesHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: biceps_long, lats'**
  String get normTargetMusclesHint;

  /// No description provided for @normDeltaValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Δ value'**
  String get normDeltaValueLabel;

  /// No description provided for @normUnitShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get normUnitShortLabel;

  /// No description provided for @microcycleNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Microcycle name'**
  String get microcycleNameLabel;

  /// No description provided for @planCreateEnterNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a plan name'**
  String get planCreateEnterNameError;

  /// No description provided for @planCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Plan created successfully'**
  String get planCreateSuccess;

  /// No description provided for @microEditorMassEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Mass edit sets'**
  String get microEditorMassEditTitle;

  /// No description provided for @microEditorIntensityOpt.
  ///
  /// In en, this message translates to:
  /// **'Intensity %1RM (optional)'**
  String get microEditorIntensityOpt;

  /// No description provided for @microEditorRpeOpt.
  ///
  /// In en, this message translates to:
  /// **'RPE (optional)'**
  String get microEditorRpeOpt;

  /// No description provided for @microEditorRepsOpt.
  ///
  /// In en, this message translates to:
  /// **'Reps (optional)'**
  String get microEditorRepsOpt;

  /// No description provided for @microEditorSaved.
  ///
  /// In en, this message translates to:
  /// **'Microcycle saved'**
  String get microEditorSaved;

  /// No description provided for @microEditorSaveError.
  ///
  /// In en, this message translates to:
  /// **'Save error: {error}'**
  String microEditorSaveError(Object error);

  /// No description provided for @microEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Microcycle: {name}'**
  String microEditorTitle(Object name);

  /// No description provided for @tooltipSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get tooltipSave;

  /// No description provided for @microEditorUnsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'There are unsaved changes'**
  String get microEditorUnsavedChanges;

  /// No description provided for @microEditorWorkoutMeta.
  ///
  /// In en, this message translates to:
  /// **'ORDER: {order} · EXERCISES: {count}'**
  String microEditorWorkoutMeta(Object count, Object order);

  /// No description provided for @microEditorSetLabel.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get microEditorSetLabel;

  /// No description provided for @plansOpenError.
  ///
  /// In en, this message translates to:
  /// **'Failed to open plan: {error}'**
  String plansOpenError(Object error);

  /// No description provided for @plansSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search plans'**
  String get plansSearchHint;

  /// No description provided for @plansClearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get plansClearSearchTooltip;

  /// No description provided for @plansFiltersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get plansFiltersTooltip;

  /// No description provided for @plansFoundCount.
  ///
  /// In en, this message translates to:
  /// **'Found: {count}'**
  String plansFoundCount(Object count);

  /// No description provided for @plansLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load plans: {error}'**
  String plansLoadError(Object error);

  /// No description provided for @plansEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No plans found'**
  String get plansEmptyTitle;

  /// No description provided for @plansEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Try changing the query or filters'**
  String get plansEmptyDescription;

  /// No description provided for @actionLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get actionLoadMore;

  /// No description provided for @actionLoadFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to load. Retry'**
  String get actionLoadFailedRetry;

  /// No description provided for @filterDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get filterDuration;

  /// No description provided for @filterGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get filterGoal;

  /// No description provided for @filterFrequency.
  ///
  /// In en, this message translates to:
  /// **'Workouts per week'**
  String get filterFrequency;

  /// No description provided for @filterLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get filterLevel;

  /// No description provided for @filterDurationValue.
  ///
  /// In en, this message translates to:
  /// **'{value} wk'**
  String filterDurationValue(Object value);

  /// No description provided for @filterFrequencyValue.
  ///
  /// In en, this message translates to:
  /// **'{value} / wk'**
  String filterFrequencyValue(Object value);

  /// No description provided for @planFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan filters'**
  String get planFiltersTitle;

  /// No description provided for @tooltipClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get tooltipClose;

  /// No description provided for @actionRetryLoad.
  ///
  /// In en, this message translates to:
  /// **'Retry loading'**
  String get actionRetryLoad;

  /// No description provided for @roundNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get roundNearest;

  /// No description provided for @roundUp.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get roundUp;

  /// No description provided for @roundDown.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get roundDown;

  /// No description provided for @applyPlanGenProgress.
  ///
  /// In en, this message translates to:
  /// **'Generating plan: {done} of {total} ({remaining} left)'**
  String applyPlanGenProgress(Object done, Object remaining, Object total);

  /// No description provided for @applyPlanGenStage.
  ///
  /// In en, this message translates to:
  /// **'Generating plan: {stage}'**
  String applyPlanGenStage(Object stage);

  /// No description provided for @applyPlanGenEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Generating plan…'**
  String get applyPlanGenEllipsis;

  /// No description provided for @weightKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKgLabel;

  /// No description provided for @repsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get repsLabel;

  /// No description provided for @errorValidWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid weight'**
  String get errorValidWeight;

  /// No description provided for @errorValidRepsRange.
  ///
  /// In en, this message translates to:
  /// **'Enter 1–12 reps'**
  String get errorValidRepsRange;

  /// No description provided for @saveMaxFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save max: {error}'**
  String saveMaxFailed(Object error);

  /// No description provided for @saveMaxButton.
  ///
  /// In en, this message translates to:
  /// **'Save max'**
  String get saveMaxButton;

  /// No description provided for @maxSavedForExercise.
  ///
  /// In en, this message translates to:
  /// **'Max saved for {name}'**
  String maxSavedForExercise(Object name);

  /// No description provided for @noSavedMaxesForPlan.
  ///
  /// In en, this message translates to:
  /// **'No saved maxes for this plan'**
  String get noSavedMaxesForPlan;

  /// No description provided for @selectAtLeastOneUserMax.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one User Max'**
  String get selectAtLeastOneUserMax;

  /// No description provided for @applyPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply plan'**
  String get applyPlanTitle;

  /// No description provided for @applyPlanBaseMaxesHeader.
  ///
  /// In en, this message translates to:
  /// **'BASE MAXES · USER MAX'**
  String get applyPlanBaseMaxesHeader;

  /// No description provided for @applyPlanSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'Selected: {count}'**
  String applyPlanSelectedCount(Object count);

  /// No description provided for @applyPlanRecentButton.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get applyPlanRecentButton;

  /// No description provided for @applyPlanNoMaxesHint.
  ///
  /// In en, this message translates to:
  /// **'No saved maxes for exercises in this plan. Add a 1RM above.'**
  String get applyPlanNoMaxesHint;

  /// No description provided for @applyPlanNoExactMatchHint.
  ///
  /// In en, this message translates to:
  /// **'No exact exercise match — showing all your User Maxes:'**
  String get applyPlanNoExactMatchHint;

  /// No description provided for @applyPlanWorkingWeightsHeader.
  ///
  /// In en, this message translates to:
  /// **'WORKING WEIGHTS CALCULATION'**
  String get applyPlanWorkingWeightsHeader;

  /// No description provided for @applyPlanComputeWeights.
  ///
  /// In en, this message translates to:
  /// **'Compute weights'**
  String get applyPlanComputeWeights;

  /// No description provided for @applyPlanComputeWeightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-calculate by % of selected max'**
  String get applyPlanComputeWeightsSubtitle;

  /// No description provided for @applyPlanStepKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Step (kg)'**
  String get applyPlanStepKgLabel;

  /// No description provided for @applyPlanRoundingHeader.
  ///
  /// In en, this message translates to:
  /// **'ROUNDING'**
  String get applyPlanRoundingHeader;

  /// No description provided for @userMaxDisplay.
  ///
  /// In en, this message translates to:
  /// **'{weight} kg × {reps}'**
  String userMaxDisplay(Object reps, Object weight);

  /// No description provided for @deletePlanWithVariantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete plan with variants?'**
  String get deletePlanWithVariantsTitle;

  /// No description provided for @deletePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete plan?'**
  String get deletePlanTitle;

  /// No description provided for @deletePlanCascadeBody.
  ///
  /// In en, this message translates to:
  /// **'The plan, all its variants, and linked plan applications will be permanently deleted.'**
  String get deletePlanCascadeBody;

  /// No description provided for @deletePlanSingleBody.
  ///
  /// In en, this message translates to:
  /// **'The plan and linked plan applications will be deleted. This action cannot be undone.'**
  String get deletePlanSingleBody;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// No description provided for @replaceActivePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace active plan?'**
  String get replaceActivePlanTitle;

  /// No description provided for @replaceActivePlanBody.
  ///
  /// In en, this message translates to:
  /// **'You already have an active plan. The new plan will replace it. Completed workout history will be preserved.'**
  String get replaceActivePlanBody;

  /// No description provided for @replacePlanAction.
  ///
  /// In en, this message translates to:
  /// **'Replace plan'**
  String get replacePlanAction;

  /// No description provided for @macroMetricReadiness.
  ///
  /// In en, this message translates to:
  /// **'readiness'**
  String get macroMetricReadiness;

  /// No description provided for @macroMetricSessionRpe.
  ///
  /// In en, this message translates to:
  /// **'session RPE'**
  String get macroMetricSessionRpe;

  /// No description provided for @macroMetricReps.
  ///
  /// In en, this message translates to:
  /// **'rep count'**
  String get macroMetricReps;

  /// No description provided for @macroMetricE1rm.
  ///
  /// In en, this message translates to:
  /// **'estimated 1RM'**
  String get macroMetricE1rm;

  /// No description provided for @macroMetricTrend.
  ///
  /// In en, this message translates to:
  /// **'progress trend'**
  String get macroMetricTrend;

  /// No description provided for @macroMetricRpeDelta.
  ///
  /// In en, this message translates to:
  /// **'RPE deviation from plan'**
  String get macroMetricRpeDelta;

  /// No description provided for @macroMetricRepsDelta.
  ///
  /// In en, this message translates to:
  /// **'rep deviation from plan'**
  String get macroMetricRepsDelta;

  /// No description provided for @macroMetricFallback.
  ///
  /// In en, this message translates to:
  /// **'metric'**
  String get macroMetricFallback;

  /// No description provided for @macroTriggerAllExercises.
  ///
  /// In en, this message translates to:
  /// **'across all exercises'**
  String get macroTriggerAllExercises;

  /// No description provided for @macroTriggerForExercises.
  ///
  /// In en, this message translates to:
  /// **'for exercises: {names}'**
  String macroTriggerForExercises(Object names);

  /// No description provided for @macroOpGte.
  ///
  /// In en, this message translates to:
  /// **'greater than or equal to'**
  String get macroOpGte;

  /// No description provided for @macroOpLte.
  ///
  /// In en, this message translates to:
  /// **'less than or equal to'**
  String get macroOpLte;

  /// No description provided for @macroOpEq.
  ///
  /// In en, this message translates to:
  /// **'equal to'**
  String get macroOpEq;

  /// No description provided for @macroOpNeq.
  ///
  /// In en, this message translates to:
  /// **'not equal to'**
  String get macroOpNeq;

  /// No description provided for @macroOpGt.
  ///
  /// In en, this message translates to:
  /// **'greater than'**
  String get macroOpGt;

  /// No description provided for @macroOpLt.
  ///
  /// In en, this message translates to:
  /// **'less than'**
  String get macroOpLt;

  /// No description provided for @macroOpInRange.
  ///
  /// In en, this message translates to:
  /// **'in range'**
  String get macroOpInRange;

  /// No description provided for @macroOpOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'out of range'**
  String get macroOpOutOfRange;

  /// No description provided for @macroCondNotSet.
  ///
  /// In en, this message translates to:
  /// **'condition not set'**
  String get macroCondNotSet;

  /// No description provided for @macroCondInRangeValues.
  ///
  /// In en, this message translates to:
  /// **'value in range {a} to {b}{unit}'**
  String macroCondInRangeValues(Object a, Object b, Object unit);

  /// No description provided for @macroCondOutOfRangeValues.
  ///
  /// In en, this message translates to:
  /// **'value out of range {a} to {b}{unit}'**
  String macroCondOutOfRangeValues(Object a, Object b, Object unit);

  /// No description provided for @macroCondInRange.
  ///
  /// In en, this message translates to:
  /// **'value in range'**
  String get macroCondInRange;

  /// No description provided for @macroCondOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'value out of range'**
  String get macroCondOutOfRange;

  /// No description provided for @macroCondStagnatesValues.
  ///
  /// In en, this message translates to:
  /// **'stagnation over {n} windows within {eps} percent'**
  String macroCondStagnatesValues(Object eps, Object n);

  /// No description provided for @macroCondStagnates.
  ///
  /// In en, this message translates to:
  /// **'stagnation over windows'**
  String get macroCondStagnates;

  /// No description provided for @macroCondDirPositive.
  ///
  /// In en, this message translates to:
  /// **'positive'**
  String get macroCondDirPositive;

  /// No description provided for @macroCondDirNegative.
  ///
  /// In en, this message translates to:
  /// **'negative'**
  String get macroCondDirNegative;

  /// No description provided for @macroCondDirSuffix.
  ///
  /// In en, this message translates to:
  /// **', direction: {dir}'**
  String macroCondDirSuffix(Object dir);

  /// No description provided for @macroCondDeviatesValues.
  ///
  /// In en, this message translates to:
  /// **'deviation from {n}-window average at least {val} percent{dir}'**
  String macroCondDeviatesValues(Object dir, Object n, Object val);

  /// No description provided for @macroCondDeviates.
  ///
  /// In en, this message translates to:
  /// **'deviation from average'**
  String get macroCondDeviates;

  /// No description provided for @macroCondHoldsWorkouts.
  ///
  /// In en, this message translates to:
  /// **'holds for {n} consecutive workouts: value {rel} {val}{unit}'**
  String macroCondHoldsWorkouts(Object n, Object rel, Object unit, Object val);

  /// No description provided for @macroCondHoldsWorkoutsGeneric.
  ///
  /// In en, this message translates to:
  /// **'holds for several consecutive workouts'**
  String get macroCondHoldsWorkoutsGeneric;

  /// No description provided for @macroCondHoldsSets.
  ///
  /// In en, this message translates to:
  /// **'holds for {n} consecutive sets in workout: value {rel} {val}{unit}'**
  String macroCondHoldsSets(Object n, Object rel, Object unit, Object val);

  /// No description provided for @macroCondHoldsSetsGeneric.
  ///
  /// In en, this message translates to:
  /// **'holds for several consecutive sets in workout'**
  String get macroCondHoldsSetsGeneric;

  /// No description provided for @macroCondSimpleGt.
  ///
  /// In en, this message translates to:
  /// **'value greater than {val}{unit}'**
  String macroCondSimpleGt(Object unit, Object val);

  /// No description provided for @macroCondSimpleLt.
  ///
  /// In en, this message translates to:
  /// **'value less than {val}{unit}'**
  String macroCondSimpleLt(Object unit, Object val);

  /// No description provided for @macroCondSimpleEq.
  ///
  /// In en, this message translates to:
  /// **'value equals {val}{unit}'**
  String macroCondSimpleEq(Object unit, Object val);

  /// No description provided for @macroCondSimpleNeq.
  ///
  /// In en, this message translates to:
  /// **'value not equal to {val}{unit}'**
  String macroCondSimpleNeq(Object unit, Object val);

  /// No description provided for @macroCondSet.
  ///
  /// In en, this message translates to:
  /// **'condition set'**
  String get macroCondSet;

  /// No description provided for @macroActionTargetAll.
  ///
  /// In en, this message translates to:
  /// **'for all exercises'**
  String get macroActionTargetAll;

  /// No description provided for @macroActionTargetExercises.
  ///
  /// In en, this message translates to:
  /// **'for exercises: {list}'**
  String macroActionTargetExercises(Object list);

  /// No description provided for @macroActionTargetTags.
  ///
  /// In en, this message translates to:
  /// **'by tags: {tags}'**
  String macroActionTargetTags(Object tags);

  /// No description provided for @macroActionTargetTagsExamples.
  ///
  /// In en, this message translates to:
  /// **'{base}, e.g.: {examples}'**
  String macroActionTargetTagsExamples(Object base, Object examples);

  /// No description provided for @macroInjectMesoBase.
  ///
  /// In en, this message translates to:
  /// **'inject mesocycle'**
  String get macroInjectMesoBase;

  /// No description provided for @macroInjectMesoTemplate.
  ///
  /// In en, this message translates to:
  /// **'{base} from template ID {id}'**
  String macroInjectMesoTemplate(Object base, Object id);

  /// No description provided for @macroInjectWeeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks'**
  String macroInjectWeeks(Object weeks);

  /// No description provided for @macroInjectMicroDays.
  ///
  /// In en, this message translates to:
  /// **'microcycle {days} days'**
  String macroInjectMicroDays(Object days);

  /// No description provided for @macroInjectRestDays.
  ///
  /// In en, this message translates to:
  /// **'rest days: {days}'**
  String macroInjectRestDays(Object days);

  /// No description provided for @macroInjectFocus.
  ///
  /// In en, this message translates to:
  /// **'focus: {tags}'**
  String macroInjectFocus(Object tags);

  /// No description provided for @macroInjectAppendEnd.
  ///
  /// In en, this message translates to:
  /// **'at the end of plan'**
  String get macroInjectAppendEnd;

  /// No description provided for @macroInjectAfterWorkoutId.
  ///
  /// In en, this message translates to:
  /// **'after workout #{id}'**
  String macroInjectAfterWorkoutId(Object id);

  /// No description provided for @macroInjectAfterSelectedWorkout.
  ///
  /// In en, this message translates to:
  /// **'after selected workout'**
  String get macroInjectAfterSelectedWorkout;

  /// No description provided for @macroInjectAfterMesoIdx.
  ///
  /// In en, this message translates to:
  /// **'after mesocycle {idx}'**
  String macroInjectAfterMesoIdx(Object idx);

  /// No description provided for @macroInjectAfterSelectedMeso.
  ///
  /// In en, this message translates to:
  /// **'after selected mesocycle'**
  String get macroInjectAfterSelectedMeso;

  /// No description provided for @macroConflictReplace.
  ///
  /// In en, this message translates to:
  /// **'replace scheduled'**
  String get macroConflictReplace;

  /// No description provided for @macroConflictShift.
  ///
  /// In en, this message translates to:
  /// **'shift forward'**
  String get macroConflictShift;

  /// No description provided for @macroConflictSkip.
  ///
  /// In en, this message translates to:
  /// **'skip conflicting'**
  String get macroConflictSkip;

  /// No description provided for @macroConflictPrefix.
  ///
  /// In en, this message translates to:
  /// **'on conflict: {text}'**
  String macroConflictPrefix(Object text);

  /// No description provided for @macroActDecreaseWeightPct.
  ///
  /// In en, this message translates to:
  /// **'decrease weight by {pct} percent {target}'**
  String macroActDecreaseWeightPct(Object pct, Object target);

  /// No description provided for @macroActIncreaseWeightPct.
  ///
  /// In en, this message translates to:
  /// **'increase weight by {pct} percent {target}'**
  String macroActIncreaseWeightPct(Object pct, Object target);

  /// No description provided for @macroActAdjustWeightRpe.
  ///
  /// In en, this message translates to:
  /// **'adjust weight to target RPE {rpe} {target}'**
  String macroActAdjustWeightRpe(Object rpe, Object target);

  /// No description provided for @macroActDecreaseReps.
  ///
  /// In en, this message translates to:
  /// **'decrease reps by {reps} {target}'**
  String macroActDecreaseReps(Object reps, Object target);

  /// No description provided for @macroActIncreaseReps.
  ///
  /// In en, this message translates to:
  /// **'increase reps by {reps} {target}'**
  String macroActIncreaseReps(Object reps, Object target);

  /// No description provided for @macroActAdjustRepsRpe.
  ///
  /// In en, this message translates to:
  /// **'adjust reps to target RPE {rpe} {target}'**
  String macroActAdjustRepsRpe(Object rpe, Object target);

  /// No description provided for @macroActRemoveSets.
  ///
  /// In en, this message translates to:
  /// **'remove {sets} sets {target}'**
  String macroActRemoveSets(Object sets, Object target);

  /// No description provided for @macroActAddSets.
  ///
  /// In en, this message translates to:
  /// **'add {sets} sets {target}'**
  String macroActAddSets(Object sets, Object target);

  /// No description provided for @macroActFallback.
  ///
  /// In en, this message translates to:
  /// **'perform action {target}'**
  String macroActFallback(Object target);

  /// No description provided for @macroDurNextWorkouts.
  ///
  /// In en, this message translates to:
  /// **'for the next {count} workouts'**
  String macroDurNextWorkouts(Object count);

  /// No description provided for @macroDurUntilLast.
  ///
  /// In en, this message translates to:
  /// **'until the last workout'**
  String get macroDurUntilLast;

  /// No description provided for @macroDurUntilEndMeso.
  ///
  /// In en, this message translates to:
  /// **'until the end of mesocycle'**
  String get macroDurUntilEndMeso;

  /// No description provided for @macroDurUntilEndMicro.
  ///
  /// In en, this message translates to:
  /// **'until the end of microcycle'**
  String get macroDurUntilEndMicro;

  /// No description provided for @macroDurUntilWorkoutId.
  ///
  /// In en, this message translates to:
  /// **'until workout #{id}'**
  String macroDurUntilWorkoutId(Object id);

  /// No description provided for @macroDurUntilSelectedWorkout.
  ///
  /// In en, this message translates to:
  /// **'until selected workout'**
  String get macroDurUntilSelectedWorkout;

  /// No description provided for @macroPreviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'Description will appear after selecting metric, condition, and action'**
  String get macroPreviewEmpty;

  /// No description provided for @macroPreviewSentence.
  ///
  /// In en, this message translates to:
  /// **'If {metric} {trigger}, and {condition}, then {action}'**
  String macroPreviewSentence(
    Object action,
    Object condition,
    Object metric,
    Object trigger,
  );

  /// No description provided for @macroLabelMetric.
  ///
  /// In en, this message translates to:
  /// **'METRIC'**
  String get macroLabelMetric;

  /// No description provided for @macroLabelTrigger.
  ///
  /// In en, this message translates to:
  /// **'TRIGGER'**
  String get macroLabelTrigger;

  /// No description provided for @macroLabelCondition.
  ///
  /// In en, this message translates to:
  /// **'CONDITION'**
  String get macroLabelCondition;

  /// No description provided for @macroLabelAction.
  ///
  /// In en, this message translates to:
  /// **'ACTION'**
  String get macroLabelAction;

  /// No description provided for @macroLabelDuration.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get macroLabelDuration;

  /// No description provided for @macroPreviewSetChangesCount.
  ///
  /// In en, this message translates to:
  /// **'Set changes: {count}'**
  String macroPreviewSetChangesCount(Object count);

  /// No description provided for @macroPreviewMesoInsertsCount.
  ///
  /// In en, this message translates to:
  /// **'Mesocycle inserts: {count}'**
  String macroPreviewMesoInsertsCount(Object count);

  /// No description provided for @macroPreviewMissingParamsHint.
  ///
  /// In en, this message translates to:
  /// **'Plan parameters are required to calculate weights.'**
  String get macroPreviewMissingParamsHint;

  /// No description provided for @macroPreviewDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed workout suggestions'**
  String get macroPreviewDialogTitle;

  /// No description provided for @macroPreviewViewChanges.
  ///
  /// In en, this message translates to:
  /// **'View changes'**
  String get macroPreviewViewChanges;

  /// No description provided for @macroPreviewLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load macro suggestions: {error}'**
  String macroPreviewLoadError(Object error);

  /// No description provided for @macroPreviewAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Macro changes'**
  String get macroPreviewAppBarTitle;

  /// No description provided for @macroPreviewConfirmNeedsNewServer.
  ///
  /// In en, this message translates to:
  /// **'Confirmation requires a newer server version.'**
  String get macroPreviewConfirmNeedsNewServer;

  /// No description provided for @macroPreviewObservationWorkout.
  ///
  /// In en, this message translates to:
  /// **'Observation: workout #{id}'**
  String macroPreviewObservationWorkout(Object id);

  /// No description provided for @macroPreviewSpecifyWeightParams.
  ///
  /// In en, this message translates to:
  /// **'Specify weight parameters to calculate this preview.'**
  String get macroPreviewSpecifyWeightParams;

  /// No description provided for @macroPreviewOneRmKgForExercise.
  ///
  /// In en, this message translates to:
  /// **'1RM, kg · {name}'**
  String macroPreviewOneRmKgForExercise(Object name);

  /// No description provided for @macroPreviewWeightStepKg.
  ///
  /// In en, this message translates to:
  /// **'Weight step, kg'**
  String get macroPreviewWeightStepKg;

  /// No description provided for @macroPreviewRoundNearest.
  ///
  /// In en, this message translates to:
  /// **'To nearest step'**
  String get macroPreviewRoundNearest;

  /// No description provided for @macroPreviewRoundDown.
  ///
  /// In en, this message translates to:
  /// **'Round down'**
  String get macroPreviewRoundDown;

  /// No description provided for @macroPreviewRoundUp.
  ///
  /// In en, this message translates to:
  /// **'Round up'**
  String get macroPreviewRoundUp;

  /// No description provided for @macroPreviewCalcButton.
  ///
  /// In en, this message translates to:
  /// **'Calculate preview'**
  String get macroPreviewCalcButton;

  /// No description provided for @macroPreviewNoSetChanges.
  ///
  /// In en, this message translates to:
  /// **'No set changes.'**
  String get macroPreviewNoSetChanges;

  /// No description provided for @macroPreviewExercisesModified.
  ///
  /// In en, this message translates to:
  /// **'Exercise instances modified: {count}'**
  String macroPreviewExercisesModified(Object count);

  /// No description provided for @macroPreviewMesoAdded.
  ///
  /// In en, this message translates to:
  /// **'Mesocycle added'**
  String get macroPreviewMesoAdded;

  /// No description provided for @macroPreviewMesoNotAdded.
  ///
  /// In en, this message translates to:
  /// **'Mesocycle not added: {reason}'**
  String macroPreviewMesoNotAdded(Object reason);

  /// No description provided for @macroPreviewConfirmSetsButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm set changes'**
  String get macroPreviewConfirmSetsButton;

  /// No description provided for @macroPreviewApplyMesoRulesButton.
  ///
  /// In en, this message translates to:
  /// **'Apply mesocycle insert rules separately'**
  String get macroPreviewApplyMesoRulesButton;

  /// No description provided for @macroPreviewAppliedToActivePlan.
  ///
  /// In en, this message translates to:
  /// **'Applied to active plan #{id}'**
  String macroPreviewAppliedToActivePlan(Object id);

  /// No description provided for @macroPreviewInstanceNewSet.
  ///
  /// In en, this message translates to:
  /// **'instance {id}, new set'**
  String macroPreviewInstanceNewSet(Object id);

  /// No description provided for @macroPreviewInstanceSet.
  ///
  /// In en, this message translates to:
  /// **'instance {id}, set {setId}'**
  String macroPreviewInstanceSet(Object id, Object setId);

  /// No description provided for @macroPreviewBefore.
  ///
  /// In en, this message translates to:
  /// **'Before: {values}'**
  String macroPreviewBefore(Object values);

  /// No description provided for @macroPreviewRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested: {values}'**
  String macroPreviewRequested(Object values);

  /// No description provided for @macroPreviewClosestOption.
  ///
  /// In en, this message translates to:
  /// **'Closest option: {values}'**
  String macroPreviewClosestOption(Object values);

  /// No description provided for @macroPreviewAfter.
  ///
  /// In en, this message translates to:
  /// **'Result: {values}'**
  String macroPreviewAfter(Object values);

  /// No description provided for @macroPreviewDeleteSet.
  ///
  /// In en, this message translates to:
  /// **'Delete set'**
  String get macroPreviewDeleteSet;

  /// No description provided for @macroPreviewMesoInsertParams.
  ///
  /// In en, this message translates to:
  /// **'Mesocycle insert: {params}'**
  String macroPreviewMesoInsertParams(Object params);

  /// No description provided for @macroEditorInvalidJsonRule.
  ///
  /// In en, this message translates to:
  /// **'Invalid rule JSON: {error}'**
  String macroEditorInvalidJsonRule(Object error);

  /// No description provided for @macroEditorCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create macro'**
  String get macroEditorCreateTitle;

  /// No description provided for @macroEditorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit macro'**
  String get macroEditorEditTitle;

  /// No description provided for @macroEditorRuleParamsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rule parameters'**
  String get macroEditorRuleParamsTitle;

  /// No description provided for @macroEditorNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get macroEditorNameLabel;

  /// No description provided for @macroEditorPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get macroEditorPriorityLabel;

  /// No description provided for @macroEditorInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get macroEditorInvalidNumber;

  /// No description provided for @macroEditorActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get macroEditorActiveLabel;

  /// No description provided for @macroEditorTriggerTitle.
  ///
  /// In en, this message translates to:
  /// **'Trigger'**
  String get macroEditorTriggerTitle;

  /// No description provided for @macroEditorConditionTitle.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get macroEditorConditionTitle;

  /// No description provided for @macroEditorActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get macroEditorActionTitle;

  /// No description provided for @macroEditorDurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get macroEditorDurationTitle;

  /// No description provided for @macroEditorNaturalDescTitle.
  ///
  /// In en, this message translates to:
  /// **'Natural description'**
  String get macroEditorNaturalDescTitle;

  /// No description provided for @macroEditorEditJson.
  ///
  /// In en, this message translates to:
  /// **'Edit JSON'**
  String get macroEditorEditJson;

  /// No description provided for @macroEditorRuleJsonLabel.
  ///
  /// In en, this message translates to:
  /// **'Rule (JSON preview)'**
  String get macroEditorRuleJsonLabel;

  /// No description provided for @macroEditorMustBeJsonObject.
  ///
  /// In en, this message translates to:
  /// **'Must be a JSON object'**
  String get macroEditorMustBeJsonObject;

  /// No description provided for @macroEditorInvalidJson.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON'**
  String get macroEditorInvalidJson;

  /// No description provided for @macroTriggerHelpReadiness.
  ///
  /// In en, this message translates to:
  /// **'Readiness score 1–10 (optional). Defaults to null; user can log it after workout to scale weights and trigger rules.'**
  String get macroTriggerHelpReadiness;

  /// No description provided for @macroTriggerHelpSessionRpe.
  ///
  /// In en, this message translates to:
  /// **'Session perceived exertion (Session RPE). Useful for auto-regulating load.'**
  String get macroTriggerHelpSessionRpe;

  /// No description provided for @macroTriggerHelpReps.
  ///
  /// In en, this message translates to:
  /// **'Total reps over the selected period. Use with exercise filter.'**
  String get macroTriggerHelpReps;

  /// No description provided for @macroTriggerHelpE1rm.
  ///
  /// In en, this message translates to:
  /// **'Estimated 1-rep max from performance (estimated 1RM). Useful for tracking progress.'**
  String get macroTriggerHelpE1rm;

  /// No description provided for @macroTriggerHelpTrend.
  ///
  /// In en, this message translates to:
  /// **'Performance trend (increase/decrease) over the last N windows.'**
  String get macroTriggerHelpTrend;

  /// No description provided for @macroTriggerHelpRpeDelta.
  ///
  /// In en, this message translates to:
  /// **'RPE deviation from plan per set (actual − planned). Used for autoregulation.'**
  String get macroTriggerHelpRpeDelta;

  /// No description provided for @macroTriggerHelpRepsDelta.
  ///
  /// In en, this message translates to:
  /// **'Reps deviation from plan per set (actual − planned). For under/over-performance rules.'**
  String get macroTriggerHelpRepsDelta;

  /// No description provided for @macroTriggerHintReadiness.
  ///
  /// In en, this message translates to:
  /// **'Numeric readiness score (1–10). Null by default; logged after workout. Case: < 6 for 5 consecutive workouts — deload mesocycle. Use holds_for for consecutive rules.'**
  String get macroTriggerHintReadiness;

  /// No description provided for @macroTriggerHintSessionRpe.
  ///
  /// In en, this message translates to:
  /// **'Session RPE: number 1–10. Use holds_for for consecutive rules.'**
  String get macroTriggerHintSessionRpe;

  /// No description provided for @macroTriggerHintReps.
  ///
  /// In en, this message translates to:
  /// **'Total reps (integer). Can be scoped to specific exercises below.'**
  String get macroTriggerHintReps;

  /// No description provided for @macroTriggerHintE1rm.
  ///
  /// In en, this message translates to:
  /// **'Estimated 1RM (kg). Compare with a number or use trend operators in conditions.'**
  String get macroTriggerHintE1rm;

  /// No description provided for @macroTriggerHintTrend.
  ///
  /// In en, this message translates to:
  /// **'For trends use operators: stagnates_for (n, epsilon_percent) or deviates_from_avg (n, value_percent, direction).'**
  String get macroTriggerHintTrend;

  /// No description provided for @macroTriggerHintRpeDelta.
  ///
  /// In en, this message translates to:
  /// **'ΔRPE = actual − planned (can be negative). Use holds_for for consecutive workouts, holds_for_sets for consecutive sets.'**
  String get macroTriggerHintRpeDelta;

  /// No description provided for @macroTriggerHintRepsDelta.
  ///
  /// In en, this message translates to:
  /// **'Δreps = actual − planned (integer, can be negative). Use holds_for_sets for intra-workout checks.'**
  String get macroTriggerHintRepsDelta;

  /// No description provided for @macroTriggerSelectExercisesHint.
  ///
  /// In en, this message translates to:
  /// **'This metric applies to selected exercises. Choose one or more.'**
  String get macroTriggerSelectExercisesHint;

  /// No description provided for @macroCondHelpCompare.
  ///
  /// In en, this message translates to:
  /// **'Numeric comparison. Enter a value (integer or decimal), e.g. 10 or -2.5.'**
  String get macroCondHelpCompare;

  /// No description provided for @macroCondHelpInRange.
  ///
  /// In en, this message translates to:
  /// **'Checks that value is INSIDE range (inclusive). Enter two numbers; order does not matter.'**
  String get macroCondHelpInRange;

  /// No description provided for @macroCondHelpOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Checks that value is OUTSIDE range (inclusive). Enter two numbers.'**
  String get macroCondHelpOutOfRange;

  /// No description provided for @macroCondHelpStagnates.
  ///
  /// In en, this message translates to:
  /// **'Stagnation: last n windows stay within epsilon_percent (%) corridor. Specify n and epsilon_percent.'**
  String get macroCondHelpStagnates;

  /// No description provided for @macroCondHelpDeviates.
  ///
  /// In en, this message translates to:
  /// **'Deviation from n-window average. value_percent is threshold in %, direction is optional.'**
  String get macroCondHelpDeviates;

  /// No description provided for @macroCondHelpHoldsWorkouts.
  ///
  /// In en, this message translates to:
  /// **'N consecutive workouts: relation (>, <, >=, <=, ==, !=, in range, out of range) holds N times in a row.'**
  String get macroCondHelpHoldsWorkouts;

  /// No description provided for @macroCondHelpHoldsSets.
  ///
  /// In en, this message translates to:
  /// **'N consecutive sets in workout: relation applies to per-set delta (e.g. Δreps).'**
  String get macroCondHelpHoldsSets;

  /// No description provided for @macroCondNoteStagnates.
  ///
  /// In en, this message translates to:
  /// **'Trend (stagnation): compares range width of last n values against epsilon_percent (%).\nFormat: n — integer (windows), epsilon_percent — percentage.\nExample: n=5, epsilon_percent=1.0 (change ≤ 1% over 5 windows).'**
  String get macroCondNoteStagnates;

  /// No description provided for @macroCondNoteDeviates.
  ///
  /// In en, this message translates to:
  /// **'Trend (deviation): compares latest value to n-window average.\nFormat: n — integer, value_percent — threshold %, direction — positive/negative (optional).\nExample: n=5, value_percent=3, direction=\"negative\" (drop ≥ 3%).'**
  String get macroCondNoteDeviates;

  /// No description provided for @macroActHelpAdjustWeight.
  ///
  /// In en, this message translates to:
  /// **'Changes weight and/or intensity by %: positive increases, negative decreases. Example: -2.5 lowers weight by 2.5%.'**
  String get macroActHelpAdjustWeight;

  /// No description provided for @macroActHelpAdjustReps.
  ///
  /// In en, this message translates to:
  /// **'Changes reps by ±N: positive adds rep(s), negative removes.'**
  String get macroActHelpAdjustReps;

  /// No description provided for @macroActHelpAdjustWeightRpe.
  ///
  /// In en, this message translates to:
  /// **'Adjusts intensity/weight to target RPE (1–10) keeping current reps. Uses RPE table.'**
  String get macroActHelpAdjustWeightRpe;

  /// No description provided for @macroActHelpAdjustRepsRpe.
  ///
  /// In en, this message translates to:
  /// **'Selects reps for target RPE (1–10) at fixed intensity (if set). Uses RPE table.'**
  String get macroActHelpAdjustRepsRpe;

  /// No description provided for @macroActHelpAdjustSets.
  ///
  /// In en, this message translates to:
  /// **'Adds or removes sets: positive adds (clones last set), negative removes from end.'**
  String get macroActHelpAdjustSets;

  /// No description provided for @macroActHelpInjectTemplate.
  ///
  /// In en, this message translates to:
  /// **'Injects a mesocycle from an existing template by ID. Placement and conflict strategy can be set.'**
  String get macroActHelpInjectTemplate;

  /// No description provided for @macroActHelpInjectExisting.
  ///
  /// In en, this message translates to:
  /// **'Injects an existing mesocycle by ID from database. Specify ID and placement.'**
  String get macroActHelpInjectExisting;

  /// No description provided for @macroActHelpInjectCustom.
  ///
  /// In en, this message translates to:
  /// **'Creates a custom mesocycle: duration in weeks, microcycle length in days, rest days, and focus tags.'**
  String get macroActHelpInjectCustom;

  /// No description provided for @macroActErrPct.
  ///
  /// In en, this message translates to:
  /// **'Change must be greater than -100%.'**
  String get macroActErrPct;

  /// No description provided for @macroActErrRpe.
  ///
  /// In en, this message translates to:
  /// **'Specify RPE from 1 to 10.'**
  String get macroActErrRpe;

  /// No description provided for @macroActErrInt.
  ///
  /// In en, this message translates to:
  /// **'Specify an integer.'**
  String get macroActErrInt;

  /// No description provided for @workoutPickerActivePlanNotFound.
  ///
  /// In en, this message translates to:
  /// **'Active plan not found'**
  String get workoutPickerActivePlanNotFound;

  /// No description provided for @userMaxWeakMusclesTitle.
  ///
  /// In en, this message translates to:
  /// **'Weak muscles analysis'**
  String get userMaxWeakMusclesTitle;

  /// No description provided for @userMaxLlmEnriched.
  ///
  /// In en, this message translates to:
  /// **'LLM enrichment enabled'**
  String get userMaxLlmEnriched;

  /// No description provided for @userMaxTopWeakMuscles.
  ///
  /// In en, this message translates to:
  /// **'Top weak muscles'**
  String get userMaxTopWeakMuscles;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @userMaxStrengthByMuscle.
  ///
  /// In en, this message translates to:
  /// **'Strength by muscle'**
  String get userMaxStrengthByMuscle;

  /// No description provided for @userMaxTrends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get userMaxTrends;

  /// No description provided for @userMaxAnomalies.
  ///
  /// In en, this message translates to:
  /// **'Anomalies'**
  String get userMaxAnomalies;

  /// No description provided for @userMaxNoneDetected.
  ///
  /// In en, this message translates to:
  /// **'None detected'**
  String get userMaxNoneDetected;

  /// No description provided for @userMaxAnalysisError.
  ///
  /// In en, this message translates to:
  /// **'Analysis error: {error}'**
  String userMaxAnalysisError(Object error);

  /// No description provided for @userMaxExerciseFallback.
  ///
  /// In en, this message translates to:
  /// **'Exercise {id}'**
  String userMaxExerciseFallback(Object id);

  /// No description provided for @userMaxDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete max?'**
  String get userMaxDeleteTitle;

  /// No description provided for @userMaxDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{exercise}\n{weight} kg × {reps} reps'**
  String userMaxDeleteBody(Object exercise, Object reps, Object weight);

  /// No description provided for @userMaxDeleted.
  ///
  /// In en, this message translates to:
  /// **'Max deleted'**
  String get userMaxDeleted;

  /// No description provided for @userMaxDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete max: {error}'**
  String userMaxDeleteError(Object error);

  /// No description provided for @userMaxDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete max'**
  String get userMaxDeleteTooltip;

  /// No description provided for @chatPlanGenTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan generation (FSM)'**
  String get chatPlanGenTitle;

  /// No description provided for @chatPlanGenDesc.
  ///
  /// In en, this message translates to:
  /// **'Starts a finite state machine dialog to build a training plan.'**
  String get chatPlanGenDesc;

  /// No description provided for @chatMassEditDesc.
  ///
  /// In en, this message translates to:
  /// **'Mass edit plan using AI.'**
  String get chatMassEditDesc;

  /// No description provided for @chatAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant chat'**
  String get chatAssistantTitle;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chatInputHint;

  /// No description provided for @chatSendTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSendTooltip;

  /// No description provided for @chatNoConnectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get chatNoConnectionTooltip;

  /// No description provided for @chatStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get chatStatusConnected;

  /// No description provided for @chatStatusConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get chatStatusConnecting;

  /// No description provided for @chatStatusReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting...'**
  String get chatStatusReconnecting;

  /// No description provided for @chatStatusError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get chatStatusError;

  /// No description provided for @chatStatusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get chatStatusDisconnected;

  /// No description provided for @chatWorkoutLinkDesc.
  ///
  /// In en, this message translates to:
  /// **'Link to workout in active plan'**
  String get chatWorkoutLinkDesc;

  /// No description provided for @chatExerciseLinkDesc.
  ///
  /// In en, this message translates to:
  /// **'Link to exercise'**
  String get chatExerciseLinkDesc;

  /// No description provided for @chatSessionLabel.
  ///
  /// In en, this message translates to:
  /// **'Session: {id}'**
  String chatSessionLabel(Object id);

  /// No description provided for @chatTypingStatus.
  ///
  /// In en, this message translates to:
  /// **'Assistant is typing...{session}'**
  String chatTypingStatus(Object session);

  /// No description provided for @chatTypingSessionSuffix.
  ///
  /// In en, this message translates to:
  /// **' (session {id})'**
  String chatTypingSessionSuffix(Object id);

  /// No description provided for @loadErrorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Load error: {error}'**
  String loadErrorWithDetails(Object error);

  /// No description provided for @listLoadErrorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load list: {error}'**
  String listLoadErrorWithDetails(Object error);

  /// No description provided for @chartMetricRepsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total reps'**
  String get chartMetricRepsTotal;

  /// No description provided for @chartMetricRepsPerSetAvg.
  ///
  /// In en, this message translates to:
  /// **'Reps per set (avg)'**
  String get chartMetricRepsPerSetAvg;

  /// No description provided for @chartMetricKgAvg.
  ///
  /// In en, this message translates to:
  /// **'Weight kg (avg)'**
  String get chartMetricKgAvg;

  /// No description provided for @chartMetricTonnage.
  ///
  /// In en, this message translates to:
  /// **'Tonnage'**
  String get chartMetricTonnage;

  /// No description provided for @chartMetricE1rm.
  ///
  /// In en, this message translates to:
  /// **'1RM (est.)'**
  String get chartMetricE1rm;

  /// No description provided for @noOptions.
  ///
  /// In en, this message translates to:
  /// **'No options'**
  String get noOptions;

  /// No description provided for @yAxisLabel.
  ///
  /// In en, this message translates to:
  /// **'Y Axis'**
  String get yAxisLabel;

  /// No description provided for @musclesTitle.
  ///
  /// In en, this message translates to:
  /// **'Muscles'**
  String get musclesTitle;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get statusPlanned;

  /// No description provided for @exerciseLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load exercises: {error}'**
  String exerciseLoadError(Object error);

  /// No description provided for @exerciseSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select exercise'**
  String get exerciseSelectTitle;

  /// No description provided for @exerciseSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search exercises'**
  String get exerciseSearchLabel;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @exerciseEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get exerciseEmptyTitle;

  /// No description provided for @exerciseEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Try changing the search query or muscle group.'**
  String get exerciseEmptyDescription;

  /// No description provided for @exerciseMuscleGroupMeta.
  ///
  /// In en, this message translates to:
  /// **'Muscle group: {group}'**
  String exerciseMuscleGroupMeta(Object group);

  /// No description provided for @exerciseEquipmentMeta.
  ///
  /// In en, this message translates to:
  /// **'Equipment: {equipment}'**
  String exerciseEquipmentMeta(Object equipment);

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInTitle;

  /// No description provided for @signInWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Sign in to your account.'**
  String get signInWelcomeBack;

  /// No description provided for @signInCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account to start training.'**
  String get signInCreateAccount;

  /// No description provided for @signInLegalConsent.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to the Terms of Service and acknowledge the Privacy Policy:'**
  String get signInLegalConsent;

  /// No description provided for @legalTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalTermsOfService;

  /// No description provided for @legalPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyPolicy;

  /// No description provided for @legalMedicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Medical Disclaimer'**
  String get legalMedicalDisclaimer;

  /// No description provided for @templateLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load template: {error}'**
  String templateLoadError(Object error);

  /// No description provided for @templateDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Template details'**
  String get templateDetailsTitle;

  /// No description provided for @descriptionSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get descriptionSectionHeader;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// No description provided for @signOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmBody;

  /// No description provided for @signOutAction.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutAction;

  /// No description provided for @signOutError.
  ///
  /// In en, this message translates to:
  /// **'Sign out error: {error}'**
  String signOutError(Object error);

  /// No description provided for @noDisplayDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No data to display'**
  String get noDisplayDataTitle;

  /// No description provided for @workoutHistoryEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed sessions for this workout will appear here.'**
  String get workoutHistoryEmptyDesc;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsImportWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Import workouts'**
  String get settingsImportWorkouts;

  /// No description provided for @settingsImportWorkoutsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import Hevy CSV training history'**
  String get settingsImportWorkoutsSubtitle;

  /// No description provided for @settingsAmplitudeTest.
  ///
  /// In en, this message translates to:
  /// **'Amplitude Test'**
  String get settingsAmplitudeTest;

  /// No description provided for @settingsAmplitudeTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics and funnel event telemetry'**
  String get settingsAmplitudeTestSubtitle;

  /// No description provided for @settingsGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'General settings'**
  String get settingsGeneralTitle;

  /// No description provided for @settingsThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get settingsThemeMode;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsInterfaceSize.
  ///
  /// In en, this message translates to:
  /// **'Interface size'**
  String get settingsInterfaceSize;

  /// No description provided for @settingsDensityCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get settingsDensityCompact;

  /// No description provided for @settingsDensityCompactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Less space between elements'**
  String get settingsDensityCompactSubtitle;

  /// No description provided for @settingsDensityComfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get settingsDensityComfortable;

  /// No description provided for @settingsDensityComfortableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'More space between elements'**
  String get settingsDensityComfortableSubtitle;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccountTitle;

  /// No description provided for @settingsInterfaceConfig.
  ///
  /// In en, this message translates to:
  /// **'Interface configuration'**
  String get settingsInterfaceConfig;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsShowActivityChart.
  ///
  /// In en, this message translates to:
  /// **'Show activity chart'**
  String get settingsShowActivityChart;

  /// No description provided for @settingsShowWorkoutHistory.
  ///
  /// In en, this message translates to:
  /// **'Show workout history'**
  String get settingsShowWorkoutHistory;

  /// No description provided for @settingsShowWorkoutAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Show workout analytics'**
  String get settingsShowWorkoutAnalytics;

  /// No description provided for @settingsShowAllTime.
  ///
  /// In en, this message translates to:
  /// **'Show all time'**
  String get settingsShowAllTime;

  /// No description provided for @settingsUseHorizontalScroll.
  ///
  /// In en, this message translates to:
  /// **'Use horizontal scroll'**
  String get settingsUseHorizontalScroll;

  /// No description provided for @settingsTrainerControls.
  ///
  /// In en, this message translates to:
  /// **'Trainer controls'**
  String get settingsTrainerControls;

  /// No description provided for @settingsEnableCoaching.
  ///
  /// In en, this message translates to:
  /// **'Enable coaching'**
  String get settingsEnableCoaching;

  /// No description provided for @settingsConnectStripe.
  ///
  /// In en, this message translates to:
  /// **'Connect Stripe payouts'**
  String get settingsConnectStripe;

  /// No description provided for @settingsConnectStripeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up payment processing for coaching'**
  String get settingsConnectStripeSubtitle;

  /// No description provided for @settingsStripeConnected.
  ///
  /// In en, this message translates to:
  /// **'Stripe connected'**
  String get settingsStripeConnected;

  /// No description provided for @settingsStripeConnectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Payment processing is set up'**
  String get settingsStripeConnectedSubtitle;

  /// No description provided for @settingsEnableCoachingFeatures.
  ///
  /// In en, this message translates to:
  /// **'Enable coaching features'**
  String get settingsEnableCoachingFeatures;

  /// No description provided for @settingsTaglineLabel.
  ///
  /// In en, this message translates to:
  /// **'Tagline'**
  String get settingsTaglineLabel;

  /// No description provided for @settingsDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get settingsDescriptionLabel;

  /// No description provided for @settingsSpecializationsHeader.
  ///
  /// In en, this message translates to:
  /// **'SPECIALIZATIONS'**
  String get settingsSpecializationsHeader;

  /// No description provided for @settingsLanguagesHeader.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGES'**
  String get settingsLanguagesHeader;

  /// No description provided for @settingsRatePerMonthUsd.
  ///
  /// In en, this message translates to:
  /// **'Rate per month (USD)'**
  String get settingsRatePerMonthUsd;

  /// No description provided for @settingsTimezoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Europe/Kyiv'**
  String get settingsTimezoneHint;

  /// No description provided for @importCreatedWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Created workouts'**
  String get importCreatedWorkouts;

  /// No description provided for @importTotalRows.
  ///
  /// In en, this message translates to:
  /// **'Total rows in file'**
  String get importTotalRows;

  /// No description provided for @importRowErrors.
  ///
  /// In en, this message translates to:
  /// **'Row errors'**
  String get importRowErrors;

  /// No description provided for @amplitudeSendTestEvent.
  ///
  /// In en, this message translates to:
  /// **'Send Test Event'**
  String get amplitudeSendTestEvent;

  /// No description provided for @amplitudeSendCustomEvent.
  ///
  /// In en, this message translates to:
  /// **'Send Custom Event'**
  String get amplitudeSendCustomEvent;

  /// No description provided for @amplitudeShowDebugInfo.
  ///
  /// In en, this message translates to:
  /// **'Show Debug Info'**
  String get amplitudeShowDebugInfo;

  /// No description provided for @amplitudeTestFunnel.
  ///
  /// In en, this message translates to:
  /// **'Test Time-to-First-Dollar Funnel'**
  String get amplitudeTestFunnel;

  /// No description provided for @debugScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Debug Screen'**
  String get debugScreenTitle;

  /// No description provided for @debugCoachChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Debug Coach Chat'**
  String get debugCoachChatTitle;

  /// No description provided for @debugChatEmbeddedTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat Screen (embedded)'**
  String get debugChatEmbeddedTitle;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusPlannedLabel.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get statusPlannedLabel;

  /// No description provided for @reviewRatingHeader.
  ///
  /// In en, this message translates to:
  /// **'RATING'**
  String get reviewRatingHeader;

  /// No description provided for @reviewCommentHeader.
  ///
  /// In en, this message translates to:
  /// **'COMMENT (OPTIONAL)'**
  String get reviewCommentHeader;

  /// No description provided for @reviewShareExperienceHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience...'**
  String get reviewShareExperienceHint;

  /// No description provided for @actionSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get actionSubmit;

  /// No description provided for @reviewSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully'**
  String get reviewSubmittedSuccess;

  /// No description provided for @sessionStartedHeader.
  ///
  /// In en, this message translates to:
  /// **'STARTED'**
  String get sessionStartedHeader;

  /// No description provided for @sessionFinishedHeader.
  ///
  /// In en, this message translates to:
  /// **'FINISHED'**
  String get sessionFinishedHeader;

  /// No description provided for @sessionDurationHeader.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get sessionDurationHeader;

  /// No description provided for @sessionCompletedSetsHeader.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED SETS'**
  String get sessionCompletedSetsHeader;

  /// No description provided for @planCardTargetSessionLength.
  ///
  /// In en, this message translates to:
  /// **'Target session length'**
  String get planCardTargetSessionLength;

  /// No description provided for @avatarTooltip.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatarTooltip;

  /// No description provided for @profileLoadErrorEyebrow.
  ///
  /// In en, this message translates to:
  /// **'PROFILE LOAD ERROR'**
  String get profileLoadErrorEyebrow;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile: {error}'**
  String failedToLoadProfile(Object error);

  /// No description provided for @appearanceEyebrow.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearanceEyebrow;

  /// No description provided for @layoutScaleEyebrow.
  ///
  /// In en, this message translates to:
  /// **'LAYOUT SCALE'**
  String get layoutScaleEyebrow;

  /// No description provided for @sessionAccessEyebrow.
  ///
  /// In en, this message translates to:
  /// **'SESSION ACCESS'**
  String get sessionAccessEyebrow;

  /// No description provided for @irreversibleActionEyebrow.
  ///
  /// In en, this message translates to:
  /// **'IRREVERSIBLE ACTION'**
  String get irreversibleActionEyebrow;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will schedule deletion of your account data. Continue?'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @appearanceAndLocaleEyebrow.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE & LOCALE'**
  String get appearanceAndLocaleEyebrow;

  /// No description provided for @profileTelemetryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'PROFILE TELEMETRY'**
  String get profileTelemetryEyebrow;

  /// No description provided for @visibilityAndCharts.
  ///
  /// In en, this message translates to:
  /// **'Visibility & charts'**
  String get visibilityAndCharts;

  /// No description provided for @coachingAndPayoutsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'COACHING & PAYOUTS'**
  String get coachingAndPayoutsEyebrow;

  /// No description provided for @notAvailableForAccount.
  ///
  /// In en, this message translates to:
  /// **'Not available for this account'**
  String get notAvailableForAccount;

  /// No description provided for @accountZoneEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT ZONE'**
  String get accountZoneEyebrow;

  /// No description provided for @sessionAndDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Session & data'**
  String get sessionAndDataTitle;

  /// No description provided for @notSetLabel.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSetLabel;

  /// No description provided for @ratePerMonthHelper.
  ///
  /// In en, this message translates to:
  /// **'Amount is entered in dollars (e.g. 120 = \$120.00).'**
  String get ratePerMonthHelper;

  /// No description provided for @addMuscleTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Add muscle tag'**
  String get addMuscleTagLabel;

  /// No description provided for @typeToSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Type to search...'**
  String get typeToSearchHint;

  /// No description provided for @failedToReadFileBytes.
  ///
  /// In en, this message translates to:
  /// **'Failed to read selected file bytes'**
  String get failedToReadFileBytes;

  /// No description provided for @gifUploaded.
  ///
  /// In en, this message translates to:
  /// **'GIF uploaded'**
  String get gifUploaded;

  /// No description provided for @imageUploaded.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded'**
  String get imageUploaded;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String uploadFailed(Object error);

  /// No description provided for @editExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Exercise'**
  String get editExerciseTitle;

  /// No description provided for @createExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Exercise'**
  String get createExerciseTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @muscleGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Muscle group'**
  String get muscleGroupLabel;

  /// No description provided for @selectGroupHint.
  ///
  /// In en, this message translates to:
  /// **'Select group'**
  String get selectGroupHint;

  /// No description provided for @movementTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Movement type'**
  String get movementTypeLabel;

  /// No description provided for @movementTypeCompound.
  ///
  /// In en, this message translates to:
  /// **'Compound'**
  String get movementTypeCompound;

  /// No description provided for @movementTypeIsolation.
  ///
  /// In en, this message translates to:
  /// **'Isolation'**
  String get movementTypeIsolation;

  /// No description provided for @regionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get regionLabel;

  /// No description provided for @regionUpper.
  ///
  /// In en, this message translates to:
  /// **'Upper'**
  String get regionUpper;

  /// No description provided for @regionLower.
  ///
  /// In en, this message translates to:
  /// **'Lower'**
  String get regionLower;

  /// No description provided for @failedToUpdateExercise.
  ///
  /// In en, this message translates to:
  /// **'Failed to update exercise: {error}'**
  String failedToUpdateExercise(Object error);

  /// No description provided for @failedToCreateExercise.
  ///
  /// In en, this message translates to:
  /// **'Failed to create exercise: {error}'**
  String failedToCreateExercise(Object error);

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @exercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercisesTitle;

  /// No description provided for @errorLoadingExercises.
  ///
  /// In en, this message translates to:
  /// **'Error loading exercises: {error}'**
  String errorLoadingExercises(Object error);

  /// No description provided for @noExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'No Exercises'**
  String get noExercisesTitle;

  /// No description provided for @noExercisesDescription.
  ///
  /// In en, this message translates to:
  /// **'No exercises found. Add your first exercise!'**
  String get noExercisesDescription;

  /// No description provided for @noMuscleGroup.
  ///
  /// In en, this message translates to:
  /// **'No muscle group'**
  String get noMuscleGroup;

  /// No description provided for @noEquipment.
  ///
  /// In en, this message translates to:
  /// **'No equipment'**
  String get noEquipment;

  /// No description provided for @uploadImageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImageTooltip;

  /// No description provided for @deleteExerciseQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete exercise?'**
  String get deleteExerciseQuestion;

  /// No description provided for @failedToDeleteExercise.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete exercise: {error}'**
  String failedToDeleteExercise(Object error);

  /// No description provided for @exerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exerciseTitle;

  /// No description provided for @failedToLoadExercise.
  ///
  /// In en, this message translates to:
  /// **'Failed to load exercise: {error}'**
  String failedToLoadExercise(Object error);

  /// No description provided for @exerciseNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise not found'**
  String get exerciseNotFoundTitle;

  /// No description provided for @muscleGroupHeader.
  ///
  /// In en, this message translates to:
  /// **'MUSCLE GROUP'**
  String get muscleGroupHeader;

  /// No description provided for @equipmentHeader.
  ///
  /// In en, this message translates to:
  /// **'EQUIPMENT'**
  String get equipmentHeader;

  /// No description provided for @movementTypeHeader.
  ///
  /// In en, this message translates to:
  /// **'MOVEMENT TYPE'**
  String get movementTypeHeader;

  /// No description provided for @regionHeader.
  ///
  /// In en, this message translates to:
  /// **'REGION'**
  String get regionHeader;

  /// No description provided for @targetMusclesHeader.
  ///
  /// In en, this message translates to:
  /// **'TARGET MUSCLES'**
  String get targetMusclesHeader;

  /// No description provided for @synergistMusclesHeader.
  ///
  /// In en, this message translates to:
  /// **'SYNERGIST MUSCLES'**
  String get synergistMusclesHeader;

  /// No description provided for @parentExerciseEyebrow.
  ///
  /// In en, this message translates to:
  /// **'PARENT EXERCISE'**
  String get parentExerciseEyebrow;

  /// No description provided for @baseMovementTitle.
  ///
  /// In en, this message translates to:
  /// **'Base Movement'**
  String get baseMovementTitle;

  /// No description provided for @directVariantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Direct Variants'**
  String get directVariantsTitle;

  /// No description provided for @relatedSiblingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Related Siblings'**
  String get relatedSiblingsTitle;

  /// No description provided for @failedToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data: {error}'**
  String failedToLoadData(Object error);

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String errorSaving(Object error);

  /// No description provided for @progressionTemplateOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Progression Template (optional)'**
  String get progressionTemplateOptionalLabel;

  /// No description provided for @selectTemplateHint.
  ///
  /// In en, this message translates to:
  /// **'Select template'**
  String get selectTemplateHint;

  /// No description provided for @noTemplateOption.
  ///
  /// In en, this message translates to:
  /// **'No template'**
  String get noTemplateOption;

  /// No description provided for @saveExercise.
  ///
  /// In en, this message translates to:
  /// **'Save Exercise'**
  String get saveExercise;

  /// No description provided for @exerciseDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Details'**
  String get exerciseDetailsTitle;

  /// No description provided for @exerciseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise Name'**
  String get exerciseNameLabel;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @addSet.
  ///
  /// In en, this message translates to:
  /// **'Add Set'**
  String get addSet;

  /// No description provided for @removeSetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove set'**
  String get removeSetTooltip;

  /// No description provided for @catalogEntryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'CATALOG ENTRY'**
  String get catalogEntryEyebrow;

  /// No description provided for @destructiveActionEyebrow.
  ///
  /// In en, this message translates to:
  /// **'DESTRUCTIVE ACTION'**
  String get destructiveActionEyebrow;

  /// No description provided for @allLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLabel;

  /// No description provided for @tryChangingFilterOrAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Try changing the filter or add a new exercise'**
  String get tryChangingFilterOrAddExercise;

  /// No description provided for @sexLabel.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sexLabel;

  /// No description provided for @sexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get sexMale;

  /// No description provided for @sexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get sexFemale;

  /// No description provided for @experienceLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Experience level'**
  String get experienceLevelLabel;

  /// No description provided for @experienceBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get experienceBeginner;

  /// No description provided for @experienceIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get experienceIntermediate;

  /// No description provided for @experienceAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get experienceAdvanced;

  /// No description provided for @primaryGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Primary goal'**
  String get primaryGoalLabel;

  /// No description provided for @goalStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get goalStrength;

  /// No description provided for @goalHypertrophy.
  ///
  /// In en, this message translates to:
  /// **'Hypertrophy'**
  String get goalHypertrophy;

  /// No description provided for @goalFatLoss.
  ///
  /// In en, this message translates to:
  /// **'Fat loss'**
  String get goalFatLoss;

  /// No description provided for @goalGeneralFitness.
  ///
  /// In en, this message translates to:
  /// **'General fitness'**
  String get goalGeneralFitness;

  /// No description provided for @trainingEnvironmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Training environment'**
  String get trainingEnvironmentLabel;

  /// No description provided for @envCommercialGym.
  ///
  /// In en, this message translates to:
  /// **'Commercial gym'**
  String get envCommercialGym;

  /// No description provided for @envHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get envHome;

  /// No description provided for @envGarage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get envGarage;

  /// No description provided for @failedToApply.
  ///
  /// In en, this message translates to:
  /// **'Failed to apply: {error}'**
  String failedToApply(Object error);

  /// No description provided for @useAsProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Use as profile picture'**
  String get useAsProfilePicture;

  /// No description provided for @describeYourAvatarHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your avatar'**
  String get describeYourAvatarHint;

  /// No description provided for @failedWithError.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String failedWithError(Object error);

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @failedToLoadAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Failed to load analytics: {error}'**
  String failedToLoadAnalytics(Object error);

  /// No description provided for @addSeriesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add series'**
  String get addSeriesTooltip;

  /// No description provided for @clearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearTooltip;

  /// No description provided for @failedToApplyReadiness.
  ///
  /// In en, this message translates to:
  /// **'Failed to apply readiness: {error}'**
  String failedToApplyReadiness(Object error);

  /// No description provided for @failedToUpdateSetNotReady.
  ///
  /// In en, this message translates to:
  /// **'Failed to update set: app state not ready'**
  String get failedToUpdateSetNotReady;

  /// No description provided for @failedToUpdateSet.
  ///
  /// In en, this message translates to:
  /// **'Failed to update set: {error}'**
  String failedToUpdateSet(Object error);

  /// No description provided for @deleteExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Exercise'**
  String get deleteExerciseTitle;

  /// No description provided for @exerciseRemovedFromWorkout.
  ///
  /// In en, this message translates to:
  /// **'Exercise removed from workout'**
  String get exerciseRemovedFromWorkout;

  /// No description provided for @errorCannotDeleteUnsavedExercise.
  ///
  /// In en, this message translates to:
  /// **'Error: Cannot delete unsaved exercise'**
  String get errorCannotDeleteUnsavedExercise;

  /// No description provided for @failedToRemoveExercise.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove exercise: {error}'**
  String failedToRemoveExercise(Object error);

  /// No description provided for @cannotAddSetUnsavedExercise.
  ///
  /// In en, this message translates to:
  /// **'Cannot add set: exercise is not saved yet'**
  String get cannotAddSetUnsavedExercise;

  /// No description provided for @setAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Set added successfully'**
  String get setAddedSuccessfully;

  /// No description provided for @failedToAddSet.
  ///
  /// In en, this message translates to:
  /// **'Failed to add set: {error}'**
  String failedToAddSet(Object error);

  /// No description provided for @failedToLoadExercises.
  ///
  /// In en, this message translates to:
  /// **'Failed to load exercises: {error}'**
  String failedToLoadExercises(Object error);

  /// No description provided for @workoutUpdated.
  ///
  /// In en, this message translates to:
  /// **'Workout updated'**
  String get workoutUpdated;

  /// No description provided for @failedToUpdateWorkout.
  ///
  /// In en, this message translates to:
  /// **'Failed to update workout: {error}'**
  String failedToUpdateWorkout(Object error);

  /// No description provided for @workoutStarted.
  ///
  /// In en, this message translates to:
  /// **'Workout started'**
  String get workoutStarted;

  /// No description provided for @failedToStartSession.
  ///
  /// In en, this message translates to:
  /// **'Failed to start session: {error}'**
  String failedToStartSession(Object error);

  /// No description provided for @sessionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Session cancelled'**
  String get sessionCancelled;

  /// No description provided for @workoutFinished.
  ///
  /// In en, this message translates to:
  /// **'Workout finished'**
  String get workoutFinished;

  /// No description provided for @failedToFinishSession.
  ///
  /// In en, this message translates to:
  /// **'Failed to finish session: {error}'**
  String failedToFinishSession(Object error);

  /// No description provided for @allSetsAlreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'All sets are already completed'**
  String get allSetsAlreadyCompleted;

  /// No description provided for @failedToCompleteAllSets.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete all sets: {error}'**
  String failedToCompleteAllSets(Object error);

  /// No description provided for @failedToUpdateSetCompletion.
  ///
  /// In en, this message translates to:
  /// **'Failed to update set completion: {error}'**
  String failedToUpdateSetCompletion(Object error);

  /// No description provided for @deleteSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Set'**
  String get deleteSetTitle;

  /// No description provided for @deleteSetConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this set? This action cannot be undone.'**
  String get deleteSetConfirmMessage;

  /// No description provided for @setDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Set deleted successfully'**
  String get setDeletedSuccessfully;

  /// No description provided for @failedToDeleteSet.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete set: {error}'**
  String failedToDeleteSet(Object error);

  /// No description provided for @exerciseAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Exercise added successfully'**
  String get exerciseAddedSuccessfully;

  /// No description provided for @failedToAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Failed to add exercise: {error}'**
  String failedToAddExercise(Object error);

  /// No description provided for @exerciseUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Exercise updated successfully'**
  String get exerciseUpdatedSuccessfully;

  /// No description provided for @errorUpdatingExercise.
  ///
  /// In en, this message translates to:
  /// **'Error updating exercise: {error}'**
  String errorUpdatingExercise(Object error);

  /// No description provided for @setCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 SET} other{{count} SETS}}'**
  String setCountLabel(num count);

  /// No description provided for @userMaxesTitle.
  ///
  /// In en, this message translates to:
  /// **'User Maxes'**
  String get userMaxesTitle;

  /// No description provided for @noMaxesSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'No maxes saved'**
  String get noMaxesSavedTitle;

  /// No description provided for @addFirstMaxWeightDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first max weight'**
  String get addFirstMaxWeightDescription;

  /// No description provided for @allSessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'All sessions'**
  String get allSessionsLabel;

  /// No description provided for @resetDatesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reset dates'**
  String get resetDatesTooltip;

  /// No description provided for @collapseCalendarTooltip.
  ///
  /// In en, this message translates to:
  /// **'Collapse calendar'**
  String get collapseCalendarTooltip;

  /// No description provided for @selectDateRangeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select date range'**
  String get selectDateRangeTooltip;

  /// No description provided for @calendarMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarMonthLabel;

  /// No description provided for @primaryMetricTrendHeader.
  ///
  /// In en, this message translates to:
  /// **'PRIMARY METRIC (TREND)'**
  String get primaryMetricTrendHeader;

  /// No description provided for @trendLabel.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trendLabel;

  /// No description provided for @exerciseDetailNotFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'The requested exercise definition could not be located.'**
  String get exerciseDetailNotFoundDescription;

  /// No description provided for @variantsCountEyebrow.
  ///
  /// In en, this message translates to:
  /// **'VARIANTS · {count}'**
  String variantsCountEyebrow(Object count);

  /// No description provided for @otherVariantsCountEyebrow.
  ///
  /// In en, this message translates to:
  /// **'OTHER VARIANTS · {count}'**
  String otherVariantsCountEyebrow(Object count);

  /// No description provided for @failedToLoadGroups.
  ///
  /// In en, this message translates to:
  /// **'Failed to load groups: {error}'**
  String failedToLoadGroups(Object error);

  /// No description provided for @deleteExerciseConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteExerciseConfirmBody(Object name);

  /// No description provided for @exerciseSpecEyebrow.
  ///
  /// In en, this message translates to:
  /// **'01 · EXERCISE SPEC'**
  String get exerciseSpecEyebrow;

  /// No description provided for @pleaseEnterNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterNameValidation;

  /// No description provided for @prescribedSetsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'02 · PRESCRIBED SETS ({count})'**
  String prescribedSetsEyebrow(Object count);

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @setNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'SET #{number}'**
  String setNumberLabel(Object number);

  /// No description provided for @removeExerciseConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this exercise from your workout?'**
  String get removeExerciseConfirmBody;

  /// No description provided for @allSetsMarkedCompleted.
  ///
  /// In en, this message translates to:
  /// **'All sets marked as completed ({count})'**
  String allSetsMarkedCompleted(Object count);

  /// No description provided for @markedSetsPartial.
  ///
  /// In en, this message translates to:
  /// **'Marked {success} sets, failed {failed}'**
  String markedSetsPartial(Object failed, Object success);

  /// No description provided for @myAthletesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Athletes'**
  String get myAthletesTitle;

  /// No description provided for @thresholdsAndFiltersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Thresholds & filters'**
  String get thresholdsAndFiltersTooltip;

  /// No description provided for @allSegmentsLabel.
  ///
  /// In en, this message translates to:
  /// **'All segments'**
  String get allSegmentsLabel;

  /// No description provided for @recentlyActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Recently active'**
  String get recentlyActiveLabel;

  /// No description provided for @sessionsPerWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Sessions / wk'**
  String get sessionsPerWeekLabel;

  /// No description provided for @adherenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Adherence'**
  String get adherenceLabel;

  /// No description provided for @visibleMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'VISIBLE'**
  String get visibleMetricLabel;

  /// No description provided for @linksMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'LINKS'**
  String get linksMetricLabel;

  /// No description provided for @avgSessionsPerWeekMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'AVG S / WK'**
  String get avgSessionsPerWeekMetricLabel;

  /// No description provided for @atRiskMetricLabel.
  ///
  /// In en, this message translates to:
  /// **'AT RISK'**
  String get atRiskMetricLabel;

  /// No description provided for @rosterFiltersEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ROSTER FILTERS'**
  String get rosterFiltersEyebrow;

  /// No description provided for @thresholdsFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Thresholds & filters'**
  String get thresholdsFilterTitle;

  /// No description provided for @resetLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetLabel;

  /// No description provided for @doneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneLabel;

  /// No description provided for @viewDetailedAnalyticsLabel.
  ///
  /// In en, this message translates to:
  /// **'View detailed analytics'**
  String get viewDetailedAnalyticsLabel;

  /// No description provided for @sessionsUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'SESSIONS'**
  String get sessionsUpperLabel;

  /// No description provided for @sessionsPerWeekUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'S / WK'**
  String get sessionsPerWeekUpperLabel;

  /// No description provided for @planPercentUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'PLAN %'**
  String get planPercentUpperLabel;

  /// No description provided for @rpeDistributionUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'RPE DISTRIBUTION'**
  String get rpeDistributionUpperLabel;

  /// No description provided for @allUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'All Users'**
  String get allUsersTitle;

  /// No description provided for @filterCoachesLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter coaches'**
  String get filterCoachesLabel;

  /// No description provided for @coachDirectoryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'COACH DIRECTORY'**
  String get coachDirectoryEyebrow;

  /// No description provided for @filterCoachesTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter Coaches'**
  String get filterCoachesTitle;

  /// No description provided for @allUsersPillLabel.
  ///
  /// In en, this message translates to:
  /// **'All users'**
  String get allUsersPillLabel;

  /// No description provided for @coachesOnlyPillLabel.
  ///
  /// In en, this message translates to:
  /// **'Coaches only'**
  String get coachesOnlyPillLabel;

  /// No description provided for @filtersActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Filters · Active'**
  String get filtersActiveLabel;

  /// No description provided for @showingUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'SHOWING'**
  String get showingUpperLabel;

  /// No description provided for @publicUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'PUBLIC'**
  String get publicUpperLabel;

  /// No description provided for @coachesUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'COACHES'**
  String get coachesUpperLabel;

  /// No description provided for @sortUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'SORT'**
  String get sortUpperLabel;

  /// No description provided for @minRateUsdLabel.
  ///
  /// In en, this message translates to:
  /// **'Min Rate (\$)'**
  String get minRateUsdLabel;

  /// No description provided for @maxRateUsdLabel.
  ///
  /// In en, this message translates to:
  /// **'Max Rate (\$)'**
  String get maxRateUsdLabel;

  /// No description provided for @sortByLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortByLabel;

  /// No description provided for @sortCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get sortCreatedAt;

  /// No description provided for @sortRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get sortRating;

  /// No description provided for @sortLastActive.
  ///
  /// In en, this message translates to:
  /// **'Last Active'**
  String get sortLastActive;

  /// No description provided for @applyFiltersLabel.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFiltersLabel;

  /// No description provided for @volumeUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'VOLUME'**
  String get volumeUpperLabel;

  /// No description provided for @sessPerWeekUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'SESS / WK'**
  String get sessPerWeekUpperLabel;

  /// No description provided for @intensityUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'INTENSITY'**
  String get intensityUpperLabel;

  /// No description provided for @avgRpeUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'AVG RPE'**
  String get avgRpeUpperLabel;

  /// No description provided for @lastDayUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'LAST DAY'**
  String get lastDayUpperLabel;

  /// No description provided for @daysGapUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'DAYS GAP'**
  String get daysGapUpperLabel;

  /// No description provided for @crmTitle.
  ///
  /// In en, this message translates to:
  /// **'CRM'**
  String get crmTitle;

  /// No description provided for @activeUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeUpperLabel;

  /// No description provided for @engagedUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'ENGAGED'**
  String get engagedUpperLabel;

  /// No description provided for @inactiveUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get inactiveUpperLabel;

  /// No description provided for @viewAthletesListLabel.
  ///
  /// In en, this message translates to:
  /// **'View athletes list'**
  String get viewAthletesListLabel;

  /// No description provided for @relationshipsAndChatLabel.
  ///
  /// In en, this message translates to:
  /// **'Relationships & chat'**
  String get relationshipsAndChatLabel;

  /// No description provided for @lastUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'LAST'**
  String get lastUpperLabel;

  /// No description provided for @planUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'PLAN'**
  String get planUpperLabel;

  /// No description provided for @relationshipEyebrow.
  ///
  /// In en, this message translates to:
  /// **'RELATIONSHIP'**
  String get relationshipEyebrow;

  /// No description provided for @failedToSendError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send: {error}'**
  String failedToSendError(Object error);

  /// No description provided for @typeMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessageHint;

  /// No description provided for @sendMessageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessageTooltip;

  /// No description provided for @adherenceUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'ADHERENCE'**
  String get adherenceUpperLabel;

  /// No description provided for @startUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get startUpperLabel;

  /// No description provided for @endUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'END'**
  String get endUpperLabel;

  /// No description provided for @workoutNotesEyebrow.
  ///
  /// In en, this message translates to:
  /// **'WORKOUT NOTES'**
  String get workoutNotesEyebrow;

  /// No description provided for @removeExerciseEyebrow.
  ///
  /// In en, this message translates to:
  /// **'REMOVE EXERCISE'**
  String get removeExerciseEyebrow;

  /// No description provided for @exerciseEditorEyebrow.
  ///
  /// In en, this message translates to:
  /// **'EXERCISE EDITOR'**
  String get exerciseEditorEyebrow;

  /// No description provided for @massEditLabel.
  ///
  /// In en, this message translates to:
  /// **'Mass edit'**
  String get massEditLabel;

  /// No description provided for @myCoachesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Coaches'**
  String get myCoachesTitle;

  /// No description provided for @analyticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsLabel;

  /// No description provided for @chatLabel.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatLabel;

  /// No description provided for @subscribeLabel.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribeLabel;

  /// No description provided for @invalidCheckoutUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid checkout URL'**
  String get invalidCheckoutUrl;

  /// No description provided for @cannotOpenCheckoutUrl.
  ///
  /// In en, this message translates to:
  /// **'Cannot open checkout URL'**
  String get cannotOpenCheckoutUrl;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @coachingRequestEyebrow.
  ///
  /// In en, this message translates to:
  /// **'COACHING REQUEST'**
  String get coachingRequestEyebrow;

  /// No description provided for @requestCoachingFromTitle.
  ///
  /// In en, this message translates to:
  /// **'Request coaching from {name}'**
  String requestCoachingFromTitle(Object name);

  /// No description provided for @messageOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Message (optional)'**
  String get messageOptionalLabel;

  /// No description provided for @sendLabel.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendLabel;

  /// No description provided for @requestSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get requestSentMessage;

  /// No description provided for @writeReviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReviewLabel;

  /// No description provided for @cannotReviewError.
  ///
  /// In en, this message translates to:
  /// **'Cannot review: {error}'**
  String cannotReviewError(Object error);

  /// No description provided for @workoutFeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Feed'**
  String get workoutFeedTitle;

  /// No description provided for @allPostsLabel.
  ///
  /// In en, this message translates to:
  /// **'All posts'**
  String get allPostsLabel;

  /// No description provided for @withStatsLabel.
  ///
  /// In en, this message translates to:
  /// **'With stats'**
  String get withStatsLabel;

  /// No description provided for @likedLabel.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get likedLabel;

  /// No description provided for @createPostLabel.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPostLabel;

  /// No description provided for @socialFeedEyebrow.
  ///
  /// In en, this message translates to:
  /// **'SOCIAL FEED'**
  String get socialFeedEyebrow;

  /// No description provided for @visibilityUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'VISIBILITY'**
  String get visibilityUpperLabel;

  /// No description provided for @visibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get visibilityPublic;

  /// No description provided for @visibilityFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get visibilityFollowers;

  /// No description provided for @visibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get visibilityPrivate;

  /// No description provided for @postLabel.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postLabel;

  /// No description provided for @likeLabel.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get likeLabel;

  /// No description provided for @errorLoadingItems.
  ///
  /// In en, this message translates to:
  /// **'Error loading items: {error}'**
  String errorLoadingItems(Object error);

  /// No description provided for @addItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Add {name}'**
  String addItemTitle(Object name);

  /// No description provided for @itemGenericName.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get itemGenericName;

  /// No description provided for @dosageWithUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Dosage ({unit})'**
  String dosageWithUnitLabel(Object unit);

  /// No description provided for @addLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addLabel;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String genericError(Object error);

  /// No description provided for @sessionConfigurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Configuration'**
  String get sessionConfigurationTitle;

  /// No description provided for @sessionIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Session ID'**
  String get sessionIdLabel;

  /// No description provided for @workoutIdOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Workout ID (optional)'**
  String get workoutIdOptionalLabel;

  /// No description provided for @appliedPlanWorkoutIdOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Applied Plan Workout ID (optional)'**
  String get appliedPlanWorkoutIdOptionalLabel;

  /// No description provided for @selectedEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Selected Entries'**
  String get selectedEntriesTitle;

  /// No description provided for @availableItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Items'**
  String get availableItemsTitle;

  /// No description provided for @removeEntryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove entry'**
  String get removeEntryTooltip;

  /// No description provided for @addEntryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get addEntryTooltip;

  /// No description provided for @deleteSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Session'**
  String get deleteSessionTitle;

  /// No description provided for @deleteSessionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this session?'**
  String get deleteSessionConfirm;

  /// No description provided for @sessionDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Session deleted successfully'**
  String get sessionDeletedSuccess;

  /// No description provided for @editSessionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit session'**
  String get editSessionTooltip;

  /// No description provided for @deleteSessionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get deleteSessionTooltip;

  /// No description provided for @kcalUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'KCAL'**
  String get kcalUpperLabel;

  /// No description provided for @proteinUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'PROTEIN'**
  String get proteinUpperLabel;

  /// No description provided for @fatUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'FAT'**
  String get fatUpperLabel;

  /// No description provided for @carbUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'CARB'**
  String get carbUpperLabel;

  /// No description provided for @activeNutritionPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Nutrition Plan'**
  String get activeNutritionPlanTitle;

  /// No description provided for @noActiveCalendarPlan.
  ///
  /// In en, this message translates to:
  /// **'No active calendar plan'**
  String get noActiveCalendarPlan;

  /// No description provided for @noNutritionPlanConfigured.
  ///
  /// In en, this message translates to:
  /// **'No nutrition plan configured'**
  String get noNutritionPlanConfigured;

  /// No description provided for @createSessionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create session'**
  String get createSessionTooltip;

  /// No description provided for @failedToLoadNutritionSessions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load nutrition sessions: {error}'**
  String failedToLoadNutritionSessions(Object error);

  /// No description provided for @createSessionButton.
  ///
  /// In en, this message translates to:
  /// **'Create Session'**
  String get createSessionButton;

  /// No description provided for @pleaseEnterPlanName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a plan name'**
  String get pleaseEnterPlanName;

  /// No description provided for @planCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Plan created successfully'**
  String get planCreatedSuccess;

  /// No description provided for @failedToCreatePlan.
  ///
  /// In en, this message translates to:
  /// **'Failed to create plan: {error}'**
  String failedToCreatePlan(Object error);

  /// No description provided for @createCalendarPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Calendar Plan'**
  String get createCalendarPlanTitle;

  /// No description provided for @planNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan Name'**
  String get planNameLabel;

  /// No description provided for @addMesocycleLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Mesocycle'**
  String get addMesocycleLabel;

  /// No description provided for @removeMesocycleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove Mesocycle'**
  String get removeMesocycleTooltip;

  /// No description provided for @mesocycleNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Mesocycle Name'**
  String get mesocycleNameLabel;

  /// No description provided for @microcyclesLabel.
  ///
  /// In en, this message translates to:
  /// **'Microcycles'**
  String get microcyclesLabel;

  /// No description provided for @microcycleLengthDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Microcycle Length (days)'**
  String get microcycleLengthDaysLabel;

  /// No description provided for @addExerciseLabel.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get addExerciseLabel;

  /// No description provided for @planAppliedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Plan applied successfully'**
  String get planAppliedSuccess;

  /// No description provided for @applyPlanButton.
  ///
  /// In en, this message translates to:
  /// **'Apply Plan'**
  String get applyPlanButton;

  /// No description provided for @noPlanWorkoutsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plan workouts available'**
  String get noPlanWorkoutsAvailable;

  /// No description provided for @removeRuleEyebrow.
  ///
  /// In en, this message translates to:
  /// **'REMOVE RULE'**
  String get removeRuleEyebrow;

  /// No description provided for @deleteMacroTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Macro'**
  String get deleteMacroTitle;

  /// No description provided for @planMacrosTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Macros'**
  String get planMacrosTitle;

  /// No description provided for @previewApplyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Preview/Apply'**
  String get previewApplyTooltip;

  /// No description provided for @addMacroLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Macro'**
  String get addMacroLabel;

  /// No description provided for @noMacrosYet.
  ///
  /// In en, this message translates to:
  /// **'No macros yet'**
  String get noMacrosYet;

  /// No description provided for @allCountLabel.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String allCountLabel(Object count);

  /// No description provided for @noMatchingMacros.
  ///
  /// In en, this message translates to:
  /// **'No matching macros'**
  String get noMatchingMacros;

  /// No description provided for @switchFilterToViewRules.
  ///
  /// In en, this message translates to:
  /// **'Switch filter above to view rules.'**
  String get switchFilterToViewRules;

  /// No description provided for @macroSuggestionsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'MACRO SUGGESTIONS'**
  String get macroSuggestionsEyebrow;

  /// No description provided for @sessionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Session History'**
  String get sessionHistoryTitle;

  /// No description provided for @loadSessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Load sessions'**
  String get loadSessionsLabel;

  /// No description provided for @clearFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear filter'**
  String get clearFilterLabel;

  /// No description provided for @errorLoadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Error loading history: {error}'**
  String errorLoadingHistory(Object error);

  /// No description provided for @noSessionsFound.
  ///
  /// In en, this message translates to:
  /// **'No sessions found'**
  String get noSessionsFound;

  /// No description provided for @tryChangingYourFilter.
  ///
  /// In en, this message translates to:
  /// **'Try changing your filter'**
  String get tryChangingYourFilter;

  /// No description provided for @sessionNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'Session #{id}'**
  String sessionNumberTitle(Object id);

  /// No description provided for @workoutIdUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'WORKOUT ID'**
  String get workoutIdUpperLabel;

  /// No description provided for @statusUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get statusUpperLabel;

  /// No description provided for @startedUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'STARTED'**
  String get startedUpperLabel;

  /// No description provided for @finishedUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'FINISHED'**
  String get finishedUpperLabel;

  /// No description provided for @durationUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get durationUpperLabel;

  /// No description provided for @noExerciseDataForWorkout.
  ///
  /// In en, this message translates to:
  /// **'No exercise data available for this workout'**
  String get noExerciseDataForWorkout;

  /// No description provided for @repsUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get repsUpperLabel;

  /// No description provided for @plannedUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'PLANNED'**
  String get plannedUpperLabel;

  /// No description provided for @actualUpperLabel.
  ///
  /// In en, this message translates to:
  /// **'ACTUAL'**
  String get actualUpperLabel;

  /// No description provided for @thresholdsLabel.
  ///
  /// In en, this message translates to:
  /// **'Thresholds'**
  String get thresholdsLabel;

  /// No description provided for @rosterTelemetryEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ROSTER TELEMETRY'**
  String get rosterTelemetryEyebrow;

  /// No description provided for @minSessionsPerWeekSliderLabel.
  ///
  /// In en, this message translates to:
  /// **'Min sessions / week: {value}'**
  String minSessionsPerWeekSliderLabel(Object value);

  /// No description provided for @minAdherenceSliderLabel.
  ///
  /// In en, this message translates to:
  /// **'Min adherence: {percent}%'**
  String minAdherenceSliderLabel(Object percent);

  /// No description provided for @workflowsChannelsEyebrow.
  ///
  /// In en, this message translates to:
  /// **'WORKFLOWS · CHANNELS'**
  String get workflowsChannelsEyebrow;

  /// No description provided for @userIdFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userIdFieldLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
