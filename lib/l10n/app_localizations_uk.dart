// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Workout App';

  @override
  String get missingAthleteId => 'Відсутній athleteId';

  @override
  String get missingChatArguments => 'Відсутні аргументи чату';

  @override
  String get fieldRequired => 'Обовʼязково';

  @override
  String get exerciseName => 'Назва вправи';

  @override
  String get exerciseListEmptyNameError => 'Будь ласка, введіть назву вправи';

  @override
  String activePlanLoadError(Object error) {
    return 'Не вдалося завантажити план: $error';
  }

  @override
  String get activePlanNoWorkoutsOnDay => 'Немає тренувань на цей день';

  @override
  String get activePlanNotesLabel => 'Примітки';

  @override
  String get coachAthletePlanNoActivePlan => 'Немає активного плану';

  @override
  String get coachAthletePlanSetsLabel => 'Підходи';

  @override
  String get coachAthletePlanMassEditExerciseHint =>
      'Введіть примітку для вправ';

  @override
  String coachAthletePlanMassEditError(Object error) {
    return 'Помилка масового редагування: $error';
  }

  @override
  String get search => 'Пошук...';

  @override
  String get done => 'Готово';

  @override
  String get refresh => 'Оновити';

  @override
  String get edit => 'Редагувати';

  @override
  String get delete => 'Видалити';

  @override
  String get apply => 'Застосувати';

  @override
  String get cancel => 'Скасувати';

  @override
  String get retry => 'Повторити';

  @override
  String get hide => 'Приховати';

  @override
  String get noDate => 'без дати';

  @override
  String idPrefix(Object id) {
    return 'ID: $id';
  }

  @override
  String get filter => 'Фільтр';

  @override
  String get changes => 'Зміни';

  @override
  String statuses(Object statuses) {
    return 'Статуси: $statuses';
  }

  @override
  String exercises(Object exercises) {
    return 'Вправи: $exercises';
  }

  @override
  String workoutsAffected(Object count) {
    return 'Тренувань затронуто: $count';
  }

  @override
  String workoutsShifted(Object count) {
    return 'Тренувань зсунуто: $count';
  }

  @override
  String setsModified(Object count) {
    return 'Сетів змінено: $count';
  }

  @override
  String setsToBeModified(Object count) {
    return 'Сетів буде змінено: $count';
  }

  @override
  String shiftDays(Object sign, Object days) {
    return 'Зсув: $sign$days дн.';
  }

  @override
  String startingFrom(Object date) {
    return 'Починаючи з: $date';
  }

  @override
  String upToDate(Object date) {
    return 'До дати (включно): $date';
  }

  @override
  String get onlyFutureWorkouts => 'Тільки майбутні тренування';

  @override
  String dateNotEarlierThan(Object date) {
    return 'Дата не раніше $date';
  }

  @override
  String dateNotLaterThan(Object date) {
    return 'Дата не пізніше $date';
  }

  @override
  String get clampNonNegative => 'Не допускати від\'ємних значень';

  @override
  String replaceExerciseTo(Object name, Object id) {
    return 'Замінити вправу на $name (ID $id)';
  }

  @override
  String renameExerciseTo(Object name) {
    return 'Перейменувати вправу на \"$name\"';
  }

  @override
  String addNewExercises(Object count) {
    return 'Додати нових вправ: $count';
  }

  @override
  String setIntensity(Object value) {
    return 'Встановити інтенсивність = $value';
  }

  @override
  String increaseIntensityBy(Object value) {
    return 'Збільшити інтенсивність на $value';
  }

  @override
  String decreaseIntensityBy(Object value) {
    return 'Зменшити інтенсивність на $value';
  }

  @override
  String setVolume(Object value) {
    return 'Встановити повторення = $value';
  }

  @override
  String increaseVolumeBy(Object value) {
    return 'Збільшити повторення на $value';
  }

  @override
  String decreaseVolumeBy(Object value) {
    return 'Зменшити повторення на $value';
  }

  @override
  String setWeight(Object value) {
    return 'Встановити вагу = $value кг';
  }

  @override
  String increaseWeightBy(Object value) {
    return 'Збільшити вагу на $value кг';
  }

  @override
  String decreaseWeightBy(Object value) {
    return 'Зменшити вагу на $value кг';
  }

  @override
  String setEffort(Object value) {
    return 'Встановити RPE = $value';
  }

  @override
  String increaseEffortBy(Object value) {
    return 'Збільшити RPE на $value';
  }

  @override
  String decreaseEffortBy(Object value) {
    return 'Зменшити RPE на $value';
  }

  @override
  String get massEditPreviewTitle =>
      'Попередній перегляд масових змін активного плану';

  @override
  String get massEditAppliedTitle => 'Зміни активного плану застосовані';

  @override
  String get scheduleShiftPreviewTitle =>
      'Попередній перегляд зсуву розкладу активного плану';

  @override
  String get scheduleShiftTitle => 'Зсув розкладу активного плану виконано';

  @override
  String get shiftParameters => 'Параметри зсуву';

  @override
  String get modeChangeIntervals => 'Режим: змінити інтервали між тренуваннями';

  @override
  String get modeScheduleShift => 'Режим: зсув розкладу';

  @override
  String get macroActionByPercent => 'За відсотком';

  @override
  String get macroActionToTarget => 'До цільового (RPE)';

  @override
  String get macroActionByValue => 'За значенням';

  @override
  String get macroActionByTemplate => 'За шаблоном';

  @override
  String get macroActionByExisting => 'З існуючого (ID)';

  @override
  String get macroActionCreateManual => 'Створити вручну';

  @override
  String get macroActionHintPercent => 'відсоток, напр. -5 або 2.5';

  @override
  String get macroActionHintReps => 'дельта повторень, напр. +1 або -1';

  @override
  String get macroActionHintTargetRpe => 'цільовий RPE, напр. 8';

  @override
  String get macroActionHintSets => '±N підходів, напр. 1 або -2';

  @override
  String get macroActionHintGeneric => 'значення';

  @override
  String get macroActionAdjustLoad => 'Коригувати вагу';

  @override
  String get macroActionAdjustReps => 'Коригувати повторення';

  @override
  String get macroActionAdjustSets => 'Коригувати підходи';

  @override
  String get macroActionInjectMesocycle => 'Впровадити мезоцикл';

  @override
  String get macroActionTypeLabel => 'Тип дії';

  @override
  String get macroActionModeLabel => 'Режим';

  @override
  String get macroActionValueLabel => 'Значення';

  @override
  String get macroActionNoTemplates => 'Немає шаблонів мезоциклів';

  @override
  String get macroActionTemplateLabel => 'Шаблон мезоциклу';

  @override
  String macroActionLoadTemplatesError(Object error) {
    return 'Помилка завантаження шаблонів: $error';
  }

  @override
  String macroActionMesoLabel(Object index) {
    return 'Мезоцикл $index';
  }

  @override
  String get macroActionChooseMeso => 'Вибрати мезоцикл';

  @override
  String get macroActionOtherId => 'Інший (ввести ID)';

  @override
  String get macroActionExistingIdLabel => 'ID існуючого мезоцикла';

  @override
  String get macroActionEnterNumber => 'Введіть число';

  @override
  String get macroActionDurationWeeks => 'Тривалість (тижнів)';

  @override
  String get macroActionDaysInMicro => 'Днів у мікроциклі';

  @override
  String macroActionDayLabel(Object index, Object type) {
    return 'День $index: $type';
  }

  @override
  String get macroActionRest => 'вихідний';

  @override
  String get macroActionWork => 'тренування';

  @override
  String get macroActionFocusTags => 'Теги фокусу';

  @override
  String get macroActionPlacement => 'Розміщення';

  @override
  String get macroActionAppendEnd => 'В кінець плану';

  @override
  String get macroActionInsertAfterWorkout => 'Після тренування';

  @override
  String get macroActionInsertAfterMeso => 'Після мезоциклу';

  @override
  String get macroActionSelectAnchorWorkout => 'Вибрати тренування-якір';

  @override
  String get macroActionPickWorkout => 'Вибрати тренування';

  @override
  String get macroActionNotSelected => 'Не вибрано';

  @override
  String macroActionAfterAnchor(Object name) {
    return 'Після: $name';
  }

  @override
  String get macroActionNoMesoInPlan => 'В плані немає мезоциклів';

  @override
  String get macroActionMesoIndexLabel => 'Мезоцикл: ';

  @override
  String get macroActionConflicts => 'Конфлікти';

  @override
  String get macroActionReplacePlanned => 'Замінити заплановане';

  @override
  String get macroActionShiftForward => 'Зсунути вперед';

  @override
  String get macroActionSkipConflict => 'Пропустити конфлікт';

  @override
  String get macroActionTarget => 'Ціль';

  @override
  String get macroActionTargetHelp =>
      'Якщо ціль не вказана — дія застосовується до всіх вправ вибраних тренувань.';

  @override
  String get macroConditionGreater => 'більше >';

  @override
  String get macroConditionLess => 'менше <';

  @override
  String get macroConditionEqual => 'рівно =';

  @override
  String get macroConditionNotEqual => 'не рівно ≠';

  @override
  String get macroConditionInRange => 'в діапазоні';

  @override
  String get macroConditionNotInRange => 'поза діапазоном';

  @override
  String get macroConditionStagnates => 'стагнація за N вікон';

  @override
  String get macroConditionDeviates => 'відхилення від середнього';

  @override
  String get macroConditionHoldsForWorkouts =>
      'виконується N тренувань поспіль';

  @override
  String get macroConditionHoldsForSets =>
      'виконується N підходів поспіль (всередині тренування)';

  @override
  String get macroConditionOperatorLabel => 'Оператор';

  @override
  String get macroConditionRangeFrom => 'від';

  @override
  String get macroConditionNumberHint => 'число';

  @override
  String get macroConditionRangeTo => 'до';

  @override
  String get macroConditionWindowCount => 'n (вікон)';

  @override
  String get macroConditionWindowCountHint => 'ціле число, наприклад 5';

  @override
  String get macroConditionEpsilonPercent => 'epsilon_percent (поріг, %)';

  @override
  String get macroConditionValuePercent => 'value_percent (відхил., %)';

  @override
  String get macroConditionPositive => 'позитивне';

  @override
  String get macroConditionNegative => 'негативне';

  @override
  String get macroConditionDirection => 'напрямок (необов\'язково)';

  @override
  String get macroConditionGreaterEqual => 'більше або рівно ≥';

  @override
  String get macroConditionLessEqual => 'менше або рівно ≤';

  @override
  String get macroConditionRelationLabel => 'порівняння';

  @override
  String get macroConditionWorkoutCount => 'n (тренувань)';

  @override
  String get macroConditionWorkoutCountHint => 'ціле, наприклад 3';

  @override
  String get macroConditionDeltaHint => 'дельта, наприклад -2 для повторів';

  @override
  String get macroConditionSetCount => 'n (підряд підходів)';

  @override
  String get macroConditionSetCountHint => 'ціле, наприклад 12';

  @override
  String get macroConditionValueLabel => 'значення';

  @override
  String get macroDurationNextNWorkouts => 'Наступні N тренувань';

  @override
  String get macroDurationUntilLastWorkout => 'До останнього тренування';

  @override
  String get macroDurationUntilEndOfMeso => 'До кінця мезоциклу';

  @override
  String get macroDurationUntilEndOfMicro => 'До кінця мікроциклу';

  @override
  String get macroDurationUntilWorkoutX => 'До тренування X';

  @override
  String get macroDurationScopeLabel => 'Область';

  @override
  String get macroDurationCountLabel => 'Кількість';

  @override
  String get macroTargetBy => 'Ціль за:';

  @override
  String get macroTargetTags => 'Теги';

  @override
  String get macroTargetIds => 'ID';

  @override
  String get macroTargetIdsLabel => 'exercise_ids (CSV)';

  @override
  String get macroTriggerChooseExercises => 'Вибір вправ';

  @override
  String get macroTriggerMetricReadiness => 'Готовність (тренування)';

  @override
  String get macroTriggerMetricRpeSession => 'RPE сесії';

  @override
  String get macroTriggerMetricTotalReps => 'Кількість повторень';

  @override
  String get macroTriggerMetricE1rm => 'Оцінка 1ПМ (e1RM)';

  @override
  String get macroTriggerMetricPerformanceTrend => 'Тренд продуктивності';

  @override
  String get macroTriggerMetricRpeDelta => 'Дельта RPE від плану';

  @override
  String get macroTriggerMetricRepsDelta => 'Дельта повторень від плану';

  @override
  String get macroTriggerMetricLabel => 'Метрика тригера';

  @override
  String get macroWorkoutPickerTitle => 'Виберіть тренування';

  @override
  String get macroWorkoutPickerNoWorkouts =>
      'Немає тренувань в активному плані';

  @override
  String get macroWorkoutPickerNoWorkoutsOnDate => 'На цю дату немає тренувань';

  @override
  String get macroWorkoutPickerOrChooseFromList => 'Або вибрати зі списку';

  @override
  String get macroWorkoutPickerListButton => 'Список';

  @override
  String get macroWorkoutPickerWorkoutsOnDate => 'Тренування на цю дату';

  @override
  String get macroWorkoutPickerOrSelectFromList => 'Або вибрати зі списку';

  @override
  String get macroWorkoutPickerList => 'Список';

  @override
  String analyticsPlanTitle(Object planName) {
    return 'Аналітика плану $planName';
  }

  @override
  String get errorLoadingActivePlan => 'Не вдалося отримати активний план';

  @override
  String get selectTwoMetrics => 'Оберіть дві метрики';

  @override
  String get activePlanNotFound => 'Активний план не знайдено';

  @override
  String get errorLoadingData => 'Помилка завантаження даних';

  @override
  String get axisX => 'Вісь X';

  @override
  String get axisY => 'Вісь Y';

  @override
  String get showChart => 'Показати графік';

  @override
  String get selectRangeAndMetrics => 'Оберіть діапазон і метрики';

  @override
  String get noDataForSelectedMetrics => 'Немає даних для вибраних метрик';

  @override
  String get metricVolumeKg => 'Обсяг (кг)';

  @override
  String get metricEffortRpe => 'Зусилля (RPE)';

  @override
  String get metricKpsh => 'КПШ';

  @override
  String get metricReps => 'Повтори';

  @override
  String get metricOneRm => '1RM';

  @override
  String get language => 'Мова';

  @override
  String get languageSystem => 'Системна';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUkrainian => 'Українська';

  @override
  String get accountTitle => 'Профіль';

  @override
  String get editProfileTitle => 'Редагувати профіль';

  @override
  String get displayName => 'Імʼя';

  @override
  String get bio => 'Про себе';

  @override
  String get bodyweightKg => 'Вага (кг)';

  @override
  String get heightCm => 'Зріст (см)';

  @override
  String get age => 'Вік';

  @override
  String get trainingYears => 'Стаж тренувань';

  @override
  String get publicProfile => 'Публічний профіль';

  @override
  String get units => 'Одиниці';

  @override
  String get unitsMetric => 'Метрична';

  @override
  String get unitsImperial => 'Імперська';

  @override
  String get timezone => 'Часовий пояс';

  @override
  String get notifications => 'Сповіщення';

  @override
  String get save => 'Зберегти';

  @override
  String get profileUpdated => 'Профіль оновлено';

  @override
  String get failedToUpdateProfile => 'Не вдалося оновити профіль';

  @override
  String get editProfileButton => 'Редагувати профіль';

  @override
  String get coachingSettingsButton => 'Налаштування коучингу';

  @override
  String get coachingTitle => 'Коучинг';

  @override
  String get coachingAcceptingNewClients => 'Приймає нових клієнтів';

  @override
  String get coachingNotAccepting => 'Не приймає';

  @override
  String get coachingDisabled => 'Коучинг вимкнено';

  @override
  String get coachingDisabledDescription =>
      'Користувач не ввімкнув опції коучингу.';

  @override
  String get coachingSpecializations => 'Спеціалізації';

  @override
  String get coachingLanguages => 'Мови';

  @override
  String get coachingExperience => 'Досвід';

  @override
  String get coachingTimezone => 'Часовий пояс';

  @override
  String get coachingRate => 'Тариф';

  @override
  String get coachingCustomRate => 'Індивідуальний тариф';

  @override
  String get requestCoaching => 'Запит на коучинг';

  @override
  String get statsTotalWorkouts => 'Всього тренувань';

  @override
  String get statsVolumeKg => 'Обсяг (кг)';

  @override
  String get statsActiveDays => 'Активні дні';

  @override
  String get activityTitle => 'Активність';

  @override
  String lastWeeks(Object weeks) {
    return 'Останні $weeks тижнів';
  }

  @override
  String maxKgPerDay(Object value) {
    return 'Макс: $value кг/день';
  }

  @override
  String sessionsCount(Object count) {
    return '$count сесій';
  }

  @override
  String get noActivity => 'Немає активності';

  @override
  String get less => 'Менше';

  @override
  String get more => 'Більше';

  @override
  String get completedWorkoutsTitle => 'Завершені тренування';

  @override
  String get noCompletedWorkoutsYet => 'Ще немає завершених тренувань';

  @override
  String get exerciseFormTitleAdd => 'Додати вправу';

  @override
  String get exerciseFormExerciseNameLabel => 'Назва вправи';

  @override
  String get exerciseFormPleaseEnterName => 'Будь ласка, введіть назву';

  @override
  String get exerciseFormMuscleGroupLabel => 'Група мʼязів';

  @override
  String get exerciseFormLoading => 'Завантаження...';

  @override
  String get exerciseFormSelectGroup => 'Оберіть групу';

  @override
  String get exerciseFormLoadingGroups => 'Завантаження груп...';

  @override
  String get exerciseFormPleaseSelectMuscleGroup =>
      'Будь ласка, оберіть групу мʼязів';

  @override
  String get exerciseFormProgressionTemplateOptional =>
      'Шаблон прогресії (необовʼязково)';

  @override
  String get exerciseFormSelectTemplate => 'Оберіть шаблон';

  @override
  String get exerciseFormNoTemplate => 'Без шаблону';

  @override
  String get exerciseFormSetsTitle => 'Сети';

  @override
  String get exerciseFormAddSet => 'Додати сет';

  @override
  String get exerciseFormSaveExercise => 'Зберегти вправу';

  @override
  String get exerciseFormWeightKg => 'Вага (кг)';

  @override
  String get exerciseFormReps => 'Повтори';

  @override
  String get exerciseFormRequired => 'Обовʼязково';

  @override
  String exerciseFormFailedToLoadData(Object error) {
    return 'Не вдалося завантажити дані: $error';
  }

  @override
  String exerciseFormErrorSaving(Object error) {
    return 'Помилка збереження: $error';
  }

  @override
  String get exerciseDefinitionIdRequired => 'Потрібен id визначення вправи';

  @override
  String get exerciseFormDefaultReps => '5';

  @override
  String get exerciseFormDefaultWeight => '0';

  @override
  String get exerciseListTitle => 'Вправи';

  @override
  String get exerciseListAddExerciseTitle => 'Додати вправу';

  @override
  String get exerciseListNameLabel => 'Назва';

  @override
  String get exerciseListMuscleGroupLabel => 'Група мʼязів';

  @override
  String get exerciseListEquipmentLabel => 'Обладнання';

  @override
  String get exerciseListLoading => 'Завантаження...';

  @override
  String get exerciseListSelectGroup => 'Оберіть групу';

  @override
  String get exerciseListLoadingGroups => 'Завантаження груп...';

  @override
  String get exerciseListSelectMuscleGroupValidator => 'Оберіть групу мʼязів';

  @override
  String get exerciseListEnterExerciseName => 'Введіть назву вправи';

  @override
  String get exerciseListSelectMuscleGroupSnack => 'Оберіть групу мʼязів';

  @override
  String exerciseListErrorLoadingMuscleGroups(Object error) {
    return 'Не вдалося завантажити групи мʼязів: $error';
  }

  @override
  String exerciseListErrorGeneric(Object error) {
    return 'Помилка: $error';
  }

  @override
  String get exerciseListEmpty => 'Немає вправ. Додайте нову!';

  @override
  String exerciseListMuscleGroupPrefix(Object value) {
    return 'Група мʼязів: $value';
  }

  @override
  String exerciseListEquipmentPrefix(Object value) {
    return 'Обладнання: $value';
  }

  @override
  String get exerciseListDeleteExerciseTitle => 'Видалити вправу?';

  @override
  String get exerciseListDeleteExerciseBody => 'Цю дію не можна скасувати.';

  @override
  String get exerciseListDelete => 'Видалити';

  @override
  String exerciseListErrorDeleting(Object error) {
    return 'Не вдалося видалити: $error';
  }

  @override
  String get userMaxTitle => 'Додати максимум';

  @override
  String get userMaxExerciseLabel => 'Вправа';

  @override
  String get userMaxSelectExerciseValidator => 'Оберіть вправу';

  @override
  String get userMaxWeightKgLabel => 'Вага (кг)';

  @override
  String get userMaxWeightGtZeroValidator => 'Введіть вагу > 0';

  @override
  String get userMaxRepsLabel => 'Повтори';

  @override
  String get userMaxRepsGtZeroValidator => 'Введіть повтори > 0';

  @override
  String get userMaxRepsMax12Validator => 'Максимум 12 повторів';

  @override
  String get userMaxFillAllFieldsSnack =>
      'Заповніть усі поля та оберіть вправу';

  @override
  String get userMaxSaving => 'Збереження...';

  @override
  String get userMaxSave => 'Зберегти максимум';

  @override
  String userMaxFailedToSave(Object error) {
    return 'Не вдалося зберегти максимум: $error';
  }

  @override
  String get yes => 'Так';

  @override
  String get no => 'Ні';

  @override
  String get planDraftMicrocycle => 'Мікроцикл';

  @override
  String get planDraftMesocycle => 'Мезоцикл';

  @override
  String massEditToolWorkoutsMatched(Object count) {
    return 'Тренувань затронуто: $count';
  }

  @override
  String massEditToolSetsModified(Object count) {
    return 'Сетів змінено: $count';
  }

  @override
  String massEditToolSetsToBeModified(Object count) {
    return 'Сетів буде змінено: $count';
  }

  @override
  String get workoutDetailMacrosChangesFoundTitle =>
      'Знайдено зміни по макросах';

  @override
  String workoutDetailMacrosChangesFoundBody(
    Object injectCount,
    Object hasPatches,
  ) {
    return 'Вставок мезоциклів: $injectCount\nПатчі на тренування: $hasPatches';
  }

  @override
  String get workoutDetailMacrosApplied => 'Макроси застосовано';

  @override
  String workoutDetailFailedToApplyMacros(Object error) {
    return 'Не вдалося застосувати макроси: $error';
  }

  @override
  String get workoutDetailFailedToRefreshWorkoutBeforeApplyingReadiness =>
      'Не вдалося оновити тренування перед застосуванням готовності';

  @override
  String get workoutDetailWorkoutNotReadyMissingIds =>
      'Тренування не готове до оновлення сетів (відсутні id)';

  @override
  String get workoutDetailIncreaseTooltip => 'Збільшити';

  @override
  String get workoutDetailSessionActive => 'Активна сесія';

  @override
  String get workoutDetailSessionNone => 'Немає активної сесії';

  @override
  String get workoutDetailSelectSetTypeTitle => 'Оберіть тип сета';

  @override
  String get workoutDetailSetTypeNormal => 'Звичайний сет';

  @override
  String get workoutDetailSetTypeDrop => 'Дроп-сет';

  @override
  String get workoutDetailSetTypeCluster => 'Кластерний сет';

  @override
  String get workoutDetailSetTypeRestPause => 'Rest-pause сет';

  @override
  String workoutDetailFailedToUpdateSetType(Object error) {
    return 'Не вдалося оновити тип сета: $error';
  }

  @override
  String get activePlanTitle => 'Активний план';

  @override
  String activePlanFailedToLoad(Object error) {
    return 'Не вдалося завантажити активний план: $error';
  }

  @override
  String get activePlanNone => 'Немає активного плану';

  @override
  String get activePlanAiMassEditTitle => 'AI mass edit (chat)';

  @override
  String get activePlanAiMassEditHint =>
      'Наприклад: Збільш RPE на 1 і додай по 1 підходу у всіх жимах по понеділках';

  @override
  String get activePlanAiMassEditSend => 'Надіслати';

  @override
  String activePlanAiMassEditStarted(Object taskId) {
    return 'AI mass edit запущено (task: $taskId)';
  }

  @override
  String activePlanAiMassEditFailedToSend(Object error) {
    return 'Не вдалося надіслати команду AI mass edit: $error';
  }

  @override
  String activePlanMassEditTitle(Object end, Object start) {
    return 'Масове редагування (з $start по $end)';
  }

  @override
  String get activePlanRangeLabel => 'Діапазон:';

  @override
  String get activePlanRangeFutureFromWeek => 'Майбутнє від тижня';

  @override
  String get activePlanRangeByMesoMicro => 'За мезо/мікро';

  @override
  String get activePlanIntensityLabel => 'Інтенсивність %';

  @override
  String get activePlanRpeLabel => 'RPE';

  @override
  String get activePlanRepsLabel => 'Повтори';

  @override
  String get activePlanModeSet => 'Задати';

  @override
  String get activePlanModeOffset => 'Зсув';

  @override
  String get activePlanModeScale => 'Масштаб';

  @override
  String get activePlanHintEg75 => 'напр. 75';

  @override
  String get activePlanHintPercentOffset => '+/- % (напр. -2)';

  @override
  String get activePlanHintFactor => '× коефіцієнт (напр. 1.05)';

  @override
  String get activePlanHintEg8 => 'напр. 8';

  @override
  String get activePlanHintEg5 => 'напр. 5';

  @override
  String get activePlanHintRepsOffset => '+/- повтори (напр. +1)';

  @override
  String get activePlanHintFactorReps => '× коефіцієнт (напр. 0.9)';

  @override
  String get activePlanRecalcTargetLabel => 'Перерахувати:';

  @override
  String get activePlanRecalcTargetAuto => 'Авто';

  @override
  String get activePlanRecalcTargetReps => 'Повтори';

  @override
  String get activePlanRecalcTargetRpe => 'RPE';

  @override
  String get activePlanRecalcTargetIntensity => 'Інтенсивність';

  @override
  String get activePlanValidatorLabel => 'Валідатор:';

  @override
  String get activePlanValidatorNone => 'Немає';

  @override
  String get activePlanValidatorFixReps => 'Фіксувати повтори';

  @override
  String get activePlanValidatorFixIntensity => 'Фіксувати інтенсивність';

  @override
  String get activePlanSelectAtLeastOneExercise => 'Оберіть хоча б одну вправу';

  @override
  String get activePlanSelectAtLeastOneParameter =>
      'Оберіть хоча б один параметр';

  @override
  String get activePlanPlanCancelled => 'План скасовано';

  @override
  String get activePlanFailedToCancelPlan => 'Не вдалося скасувати план';

  @override
  String activePlanExerciseIdFallback(Object id) {
    return 'Вправа $id';
  }

  @override
  String activePlanReplaceTitle(Object end, Object start) {
    return 'Заміна вправ (з $start по $end)';
  }

  @override
  String get activePlanSelectSourceExercises => 'Оберіть вправи для заміни:';

  @override
  String get activePlanSelectTargetExercise => 'Оберіть цільову вправу';

  @override
  String get activePlanPreserveIntensity => 'Зберегти інтенсивність через 1RM';

  @override
  String get activePlanSelectAtLeastOneSourceExercise =>
      'Оберіть хоча б одну вправу для заміни';

  @override
  String get activePlanSelectTargetExerciseSnack => 'Оберіть цільову вправу';

  @override
  String get activePlanPreviewReplacementTitle => 'Попередній перегляд заміни';

  @override
  String activePlanPreviewTarget(Object name) {
    return 'Ціль: $name';
  }

  @override
  String activePlanPreviewExercisesToReplace(Object count) {
    return 'Вправ до заміни: $count';
  }

  @override
  String activePlanPreviewSetsAffected(Object count) {
    return 'Зачеплено сетів: $count';
  }

  @override
  String get activePlanDropoutReasonNotEnjoyable => 'Не сподобалось';

  @override
  String get activePlanDropoutReasonOther => 'Інше / не хочу відповідати';

  @override
  String get activePlanDropoutSkip => 'Пропустити';

  @override
  String get activePlanDropoutConfirm => 'Підтвердити';

  @override
  String activePlanUpdatedSets(Object count) {
    return 'Оновлено $count сетів';
  }

  @override
  String activePlanFailed(Object error) {
    return 'Помилка: $error';
  }

  @override
  String get activePlanReplacementCancelledOneRmRequired =>
      'Заміна скасована: потрібен 1RM';

  @override
  String activePlanEnterOneRmTitle(Object exerciseName) {
    return 'Введіть 1RM для $exerciseName';
  }

  @override
  String get activePlanOneRmLabel => '1RM (кг)';

  @override
  String get activePlanOneRmHint => 'напр. 120';

  @override
  String get activePlanOneRmHelp =>
      'Введіть ваш поточний максимум для цієї вправи.';

  @override
  String get activePlanEnterNumberGtZero => 'Введіть число > 0';

  @override
  String activePlanShiftedWorkouts(Object count, Object days) {
    return 'Зміщено $count тренувань на +$days дн.';
  }

  @override
  String activePlanShiftFailed(Object error) {
    return 'Не вдалося змістити: $error';
  }

  @override
  String get activePlanKeep => 'Залишити';

  @override
  String get activePlanCancelPlan => 'Скасувати план';

  @override
  String get activePlanWhyCancelling => 'Чому ви скасовуєте?';

  @override
  String get activePlanDropoutReasonNotEnoughTime => 'Немає часу';

  @override
  String get activePlanDropoutReasonInjury => 'Травма / біль';

  @override
  String get activePlanDropoutReasonTooHard => 'Занадто складно';

  @override
  String activePlanReplaceSuccess(Object exercises, Object sets) {
    return 'Замінено $exercises вправ, оновлено $sets сетів';
  }

  @override
  String activePlanReplaceFailed(Object error) {
    return 'Помилка заміни: $error';
  }

  @override
  String get activePlanCancelConfirmTitle => 'Скасувати активний план?';

  @override
  String get activePlanCancelConfirmBody =>
      'Це припинить відстеження цього застосованого плану. Існуючі тренування залишаться.';

  @override
  String activePlanDroppedPrefix(Object reason, Object date) {
    return 'Припинено: $reason$date';
  }

  @override
  String activePlanAdherencePercent(Object value) {
    return 'Дотримання: $value%';
  }

  @override
  String activePlanFailedToLoadAnalytics(Object error) {
    return 'Не вдалося завантажити аналітику: $error';
  }

  @override
  String get activePlanStatusActive => 'Активний';

  @override
  String get coachRelationshipsTitle => 'Коуч ↔ Атлети';

  @override
  String get coachRelationshipsFilterAll => 'Усі';

  @override
  String get coachRelationshipsFilterPending => 'Очікує';

  @override
  String get coachRelationshipsFilterActive => 'Активні';

  @override
  String get coachRelationshipsFilterPaused => 'Пауза';

  @override
  String get coachRelationshipsFilterEnded => 'Завершено';

  @override
  String coachRelationshipsError(Object error) {
    return 'Помилка: $error';
  }

  @override
  String get coachRelationshipsEmpty => 'Поки що немає звʼязків';

  @override
  String coachRelationshipsAthletePrefix(Object name) {
    return 'Атлет: $name';
  }

  @override
  String coachRelationshipsStatusPrefix(Object status) {
    return 'Статус: $status';
  }

  @override
  String coachRelationshipsNotePrefix(Object note) {
    return 'Нотатка: $note';
  }

  @override
  String coachRelationshipsChannelPrefix(Object channel) {
    return 'Канал: $channel';
  }

  @override
  String get coachRelationshipsChannelNotCreated => 'не створено';

  @override
  String coachRelationshipsSessions12w(Object count) {
    return 'Сесії (12 тиж): $count';
  }

  @override
  String coachRelationshipsLastWorkout(Object date, Object suffix) {
    return 'Останнє тренування: $date$suffix';
  }

  @override
  String get coachRelationshipsLastWorkoutNA => 'н/д';

  @override
  String coachRelationshipsDaysAgoSuffix(Object days) {
    return ' · $daysд тому';
  }

  @override
  String get coachRelationshipsLoadingTrainingSummary =>
      'Завантаження підсумку...';

  @override
  String get coachRelationshipsRequestAccepted => 'Запит прийнято';

  @override
  String coachRelationshipsFailedToAccept(Object error) {
    return 'Не вдалося прийняти: $error';
  }

  @override
  String get coachRelationshipsAccept => 'Прийняти';

  @override
  String get coachRelationshipsDecline => 'Відхилити';

  @override
  String get coachRelationshipsDeclineRequestTitle => 'Відхилити запит';

  @override
  String get coachRelationshipsDeclineReasonHint => 'Причина (необовʼязково)';

  @override
  String get coachRelationshipsRequestDeclined => 'Запит відхилено';

  @override
  String coachRelationshipsFailedToDecline(Object error) {
    return 'Не вдалося відхилити: $error';
  }

  @override
  String get coachRelationshipsCoachingPaused => 'Коучинг призупинено';

  @override
  String coachRelationshipsFailedToPause(Object error) {
    return 'Не вдалося призупинити: $error';
  }

  @override
  String get coachRelationshipsCoachingResumed => 'Коучинг відновлено';

  @override
  String coachRelationshipsFailedToResume(Object error) {
    return 'Не вдалося відновити: $error';
  }

  @override
  String get coachRelationshipsChatTooltip => 'Чат';

  @override
  String get coachRelationshipsAnalyticsTooltip => 'Аналітика';

  @override
  String get coachRelationshipsNudgeTooltip => 'Нагадати';

  @override
  String get coachRelationshipsPauseCoaching => 'Призупинити коучинг';

  @override
  String get coachRelationshipsResumeCoaching => 'Відновити коучинг';

  @override
  String get coachRelationshipsEndCoaching => 'Завершити коучинг';

  @override
  String get coachRelationshipsCoachingEnded => 'Коучинг завершено';

  @override
  String coachRelationshipsFailedToEnd(Object error) {
    return 'Не вдалося завершити: $error';
  }

  @override
  String get coachRelationshipsChatChannelNotAvailable =>
      'Канал чату недоступний';

  @override
  String get coachRelationshipsNudgeSent => 'Нагадування надіслано';

  @override
  String coachRelationshipsFailedToSendNudge(Object error) {
    return 'Не вдалося надіслати нагадування: $error';
  }

  @override
  String coachRelationshipsNudgeMessageWithDays(Object athleteId, Object days) {
    return 'Привіт $athleteId, минуло $days дн. з твого останнього тренування. Давай заплануємо наступну сесію!';
  }

  @override
  String coachRelationshipsNudgeMessageNoDays(Object athleteId) {
    return 'Привіт $athleteId, давай скоро заплануємо наступне тренування!';
  }

  @override
  String coachRelationshipsVolumeAndPlan(Object volume, Object plan) {
    return 'Обсяг: $volume | Активний план: $plan';
  }

  @override
  String get coachRelationshipsVolumeDash => '-';

  @override
  String get coachRelationshipsMenuAll => 'Усі';

  @override
  String get coachRelationshipsMenuPending => 'Очікує';

  @override
  String get coachRelationshipsMenuActive => 'Активні';

  @override
  String get coachRelationshipsMenuPaused => 'Пауза';

  @override
  String get coachRelationshipsMenuEnded => 'Завершено';

  @override
  String get coachRelationshipsMenuPauseCoaching => 'Призупинити коучинг';

  @override
  String get coachRelationshipsMenuResumeCoaching => 'Відновити коучинг';

  @override
  String get coachRelationshipsMenuEndCoaching => 'Завершити коучинг';

  @override
  String planEditorTitle(Object name) {
    return 'Редактор: $name';
  }

  @override
  String get planEditorMacros => 'Макроси';

  @override
  String get planEditorNoPlanId => 'Немає ID плану';

  @override
  String planEditorBulk(Object count) {
    return 'Масово ($count)';
  }

  @override
  String get planEditorReplace => 'Заміна';

  @override
  String get planEditorSearchHint => 'Пошук вправи за назвою...';

  @override
  String get planEditorMesocycles => 'Мезоцикли';

  @override
  String get planEditorDayFilterLabel => 'Фільтр: день (число, необовʼязково)';

  @override
  String get planEditorSelectTargetError => 'Обрати цільову вправу';

  @override
  String get planEditorSelectSourceError =>
      'Оберіть хоча б одну вправу для заміни';

  @override
  String get planEditorDeleteMesocycleTitle => 'Видалити мезоцикл';

  @override
  String planEditorDeleteMesocycleBody(Object name) {
    return 'Ви впевнені, що хочете видалити мезоцикл \"$name\" та всі його мікроцикли?';
  }

  @override
  String get planEditorDeleteMesocycle => 'Видалити';

  @override
  String get planEditorMesocycleDeleted => 'Мезоцикл видалено';

  @override
  String planEditorDeleteFailed(Object error) {
    return 'Помилка видалення: $error';
  }

  @override
  String get planEditorDeleteMesocycleTooltip => 'Видалити мезоцикл';

  @override
  String planEditorMicroDays(Object count) {
    return 'Днів: $count';
  }

  @override
  String planEditorExerciseIdFallback(Object id) {
    return 'Вправа $id';
  }

  @override
  String get planEditorChangesSaved => 'Зміни збережено';

  @override
  String get planEditorMicrocycleDeleted => 'Мікроцикл видалено';

  @override
  String get planEditorDeleteMicrocycleTitle => 'Видалити мікроцикл';

  @override
  String planEditorDeleteMicrocycleBody(Object name) {
    return 'Ви впевнені, що хочете видалити мікроцикл \"$name\"?';
  }

  @override
  String get planEditorDeleteMicrocycleTooltip => 'Видалити мікроцикл';

  @override
  String get planEditorMassEditTitle => 'Масові правки: вибрані мікроцикли';

  @override
  String planEditorSkipNoRights(Object count) {
    return 'Пропущено $count мікроциклів без прав доступу';
  }

  @override
  String planEditorRightsCheckUnavailableApplyAll(Object error) {
    return 'Перевірка прав недоступна, застосовую до всіх вибраних: $error';
  }

  @override
  String planEditorMassEditsResult(Object success, Object failed) {
    return 'Масові правки: успішно $success, помилок $failed';
  }

  @override
  String coachAthletePlanTitleFallback(Object id) {
    return 'Атлет $id';
  }

  @override
  String coachAthletePlanLoadAnalyticsError(Object error) {
    return 'Не вдалося завантажити аналітику плану: $error';
  }

  @override
  String get coachAthletePlanMetricSets => 'Сети';

  @override
  String get coachAthletePlanMetricReps => 'Повторення';

  @override
  String get coachAthletePlanMetricIntensity => 'Інтенсивність (сер.)';

  @override
  String get coachAthletePlanMetricEffort => 'Зусилля (RPE сер.)';

  @override
  String get coachAthletePlanAxisX => 'Вісь X';

  @override
  String get coachAthletePlanAxisY => 'Вісь Y';

  @override
  String get coachAthletePlanNoAnalytics => 'Немає аналітики по плану';

  @override
  String coachAthletePlanSessionsCompleted(Object completed, Object planned) {
    return '$completed / $planned тренувань';
  }

  @override
  String coachAthletePlanPeriod(Object start, Object end) {
    return 'Період: $start – $end';
  }

  @override
  String coachAthletePlanNotes(Object notes) {
    return 'Примітки: $notes';
  }

  @override
  String get coachAthletePlanMassEditTooltip => 'Масові правки плану атлета';

  @override
  String get coachAthletePlanMassEditMenu =>
      'Масове редагування (нотатки/день)';

  @override
  String get coachAthletePlanWorkoutNotesHint => 'Введіть примітку для атлета';

  @override
  String get coachAthletePlanWorkoutRescheduled => 'Тренування переплановано';

  @override
  String get coachAthletePlanWorkoutNotesUpdated => 'Примітку оновлено';

  @override
  String get coachAthletePlanNoExercises =>
      'Немає даних по вправах у цьому тренуванні';

  @override
  String get coachAthletePlanEditExercise => 'Редагувати вправу';

  @override
  String get coachAthletePlanAddExercise => 'Додати вправу';

  @override
  String get coachAthletePlanDeleteExerciseConfirmTitle => 'Видалити вправу?';

  @override
  String coachAthletePlanDeleteExerciseConfirmBody(Object name) {
    return 'Ви впевнені, що хочете видалити $name з тренування?';
  }

  @override
  String get coachAthletePlanExerciseDeleted => 'Вправу видалено';

  @override
  String coachAthletePlanDeleteError(Object error) {
    return 'Помилка при видаленні: $error';
  }

  @override
  String coachAthletePlanOrder(Object order) {
    return 'Порядок: $order';
  }

  @override
  String coachAthletePlanSets(Object count) {
    return 'Сетів: $count';
  }

  @override
  String get coachAthletePlanNoSets => 'Немає сетів';

  @override
  String get coachAthletePlanAddSet => 'Додати сет';

  @override
  String get coachAthletePlanMassEditErrorNoWorkouts =>
      'Немає тренувань для масових правок';

  @override
  String get coachAthletePlanMassEditErrorNoWorkoutsOnDay =>
      'У вибраний день немає тренувань';

  @override
  String get coachAthletePlanMassEditUpdateWorkouts =>
      'Оновити нотатки тренувань (workouts)';

  @override
  String get coachAthletePlanMassEditUpdateExercises =>
      'Оновити нотатки вправ (exercise instances)';

  @override
  String get coachAthletePlanMassEditNoChanges => 'Немає змін для застосування';

  @override
  String get coachAthletePlanMassEditApplied =>
      'Mass edit застосовано для вибраного дня';

  @override
  String get coachAthletePlanMassEditWorkoutHint =>
      'Нова нотатка для всіх тренувань цього дня';

  @override
  String get planEditorMassReplaceTitle => 'Масова заміна вправ';

  @override
  String get planEditorChooseTarget => 'Обрати цільову вправу';

  @override
  String planEditorTargetPrefix(Object name) {
    return 'Ціль: $name';
  }

  @override
  String get planEditorSelectAll => 'Обрати все';

  @override
  String get planEditorClearAll => 'Зняти все';

  @override
  String planEditorOccurrences(Object count) {
    return 'Входжень: $count';
  }

  @override
  String get planEditorPreview => 'Передперегляд';

  @override
  String planEditorRightsCheckUnavailable(Object error) {
    return 'Перевірка прав недоступна, продовжую без неї: $error';
  }

  @override
  String get planEditorNoAccessibleMicrocycles =>
      'Немає доступних мікроциклів для заміни';

  @override
  String get planEditorNoExercisesToReplace => 'Немає вправ для заміни';

  @override
  String get planEditorPreviewReplaceTitle => 'Передперегляд заміни';

  @override
  String planEditorPreviewTarget(Object name) {
    return 'Ціль: $name';
  }

  @override
  String planEditorPreviewTotals(Object exercises, Object sets) {
    return 'Буде замінено вправ: $exercises, сетів зачеплено: $sets';
  }

  @override
  String planEditorPreviewMicroStats(Object ex, Object sets) {
    return 'Вправ: $ex · Сетів: $sets';
  }

  @override
  String planEditorApplyReplaceResult(Object success, Object failed) {
    return 'Заміна: успішно $success, помилок $failed';
  }

  @override
  String get workoutListTitle => 'Тренування';

  @override
  String get workoutListAddWorkout => 'Додати тренування';

  @override
  String get workoutListWorkoutName => 'Назва тренування';

  @override
  String get workoutListEnterNameError =>
      'Будь ласка, введіть назву тренування';

  @override
  String workoutListCreateError(Object error) {
    return 'Помилка створення тренування: $error';
  }

  @override
  String get workoutListNextWorkout => 'Наступне тренування';

  @override
  String get workoutListEmpty => 'У цій прогресії немає тренувань';

  @override
  String exerciseCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString вправ',
      many: '$countString вправ',
      few: '$countString вправи',
      one: '$countString вправа',
    );
    return '$_temp0';
  }

  @override
  String get nutritionSessionsTitle => 'Сесії харчування';

  @override
  String get nutritionSessionsEmpty => 'Сесій харчування ще немає';

  @override
  String get nutritionSessionsEmptyDesc =>
      'Почніть відстежувати харчування, створивши першу сесію';

  @override
  String nutritionSessionTitle(Object id) {
    return 'Сесія $id';
  }

  @override
  String userIdLabel(Object id) {
    return 'ID користувача: $id';
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
      other: '$countString записів',
      many: '$countString записів',
      few: '$countString записи',
      one: '$countString запис',
    );
    return '$_temp0';
  }

  @override
  String get nutritionEntriesLabel => 'Записи';

  @override
  String get nutritionNoEntries => 'Немає записів';

  @override
  String get dateLabel => 'Дата';

  @override
  String get workoutIdLabel => 'ID тренування';

  @override
  String get appliedPlanWorkoutIdLabel => 'ID тренування в плані';

  @override
  String get typeLabel => 'Тип';

  @override
  String get dosageLabel => 'Дозування';

  @override
  String get nutritionEditSession => 'Редагувати сесію';

  @override
  String get nutritionCreateSession => 'Створити сесію';

  @override
  String get nutritionSessionConfig => 'Конфігурація сесії';

  @override
  String get nutritionSessionId => 'ID сесії';

  @override
  String get workoutIdOptional => 'ID тренування (опціонально)';

  @override
  String get appliedPlanWorkoutIdOptional =>
      'ID тренування в плані (опціонально)';

  @override
  String get nutritionSelectedEntries => 'Вибрані записи';

  @override
  String get nutritionNoEntriesSelected => 'Записи не вибрані';

  @override
  String get nutritionAvailableItems => 'Доступні елементи';

  @override
  String get foodLabel => 'Їжа';

  @override
  String get supplementsLabel => 'Добавки';

  @override
  String get medicationsLabel => 'Ліки';

  @override
  String get nutritionNoItemsAvailable => 'Немає доступних елементів';

  @override
  String get updateSession => 'Оновити сесію';

  @override
  String get createSession => 'Створити сесію';

  @override
  String get exerciseListEmptyDesc =>
      'Спробуйте змінити фільтр або додайте нову вправу';

  @override
  String get envBadgeWorkZone => 'РОБОЧА ЗОНА';

  @override
  String get envBadgeLive => 'НАЖИВО';

  @override
  String get envBadgeCnsStorm => 'ШТОРМ ЦНС';

  @override
  String get envBadgeDeload => 'РОЗВАНТАЖЕННЯ';

  @override
  String get envIdleTactical =>
      'Система готова. Оберіть сесію або налаштуйте сітку.';

  @override
  String get envIdleSnarky => 'Штанга сама себе не підніме. Обирай ціль.';

  @override
  String envLiveTacticalPeak(Object peak) {
    return 'Триває сесія · Пік $peak';
  }

  @override
  String get envLiveTactical => 'Триває активна сесія · Режим фокусу';

  @override
  String envLiveSnarkyPeak(Object peak) {
    return 'Таймер тікає. Підкори $peak і не скигли.';
  }

  @override
  String get envLiveSnarky =>
      'Секундомір пішов. Менше розмов, більше повторів.';

  @override
  String envStormTacticalWithTonnage(Object detail, Object tonnage) {
    return 'Пік $detail · Обʼєм $tonnage · Високе навантаження ЦНС';
  }

  @override
  String envStormTactical(Object detail) {
    return 'Пік $detail · Граничне навантаження ЦНС';
  }

  @override
  String envStormSnarky(Object detail) {
    return 'Пік $detail. ЦНС просить пощади — зроби її гучніше.';
  }

  @override
  String get envDeloadLightZone => 'легка зона';

  @override
  String envDeloadTacticalWithTonnage(Object rpe, Object tonnage) {
    return 'Відновлення · $rpe · Обʼєм $tonnage';
  }

  @override
  String envDeloadTactical(Object rpe) {
    return 'Розвантажувальна фаза · $rpe · Адаптація';
  }

  @override
  String envDeloadSnarky(Object rpe) {
    return 'Режим курорту ($rpe). Навіть не думай додавати млинці.';
  }

  @override
  String envWorkTacticalPeakTonnage(Object peak, Object tonnage) {
    return 'Пік $peak · Робочий обʼєм $tonnage';
  }

  @override
  String envWorkSnarkyPeak(Object peak) {
    return 'Робочий коридор: $peak. Дисципліна важливіша за его.';
  }

  @override
  String envWorkTacticalSets(Object sets) {
    return 'Робоча зона · $sets підх.';
  }

  @override
  String envWorkTacticalSetsWithTonnage(Object sets, Object tonnage) {
    return 'Робоча зона · $sets підх. · $tonnage';
  }

  @override
  String envWorkSnarkySets(Object sets) {
    return '$sets робочих підходів. Нудно? Це називається прогрес.';
  }

  @override
  String envWorkTacticalReady(Object prefix) {
    return '$prefixРобоча зона · Готово до запуску';
  }

  @override
  String envWorkSnarkyReady(Object prefix) {
    return '$prefixЧистий аркуш. Навантаж його нормально.';
  }

  @override
  String unitKgValue(Object value) {
    return '$value кг';
  }

  @override
  String unitSetsShort(Object count) {
    return '$count підх.';
  }

  @override
  String unitExercisesShort(Object count) {
    return '$count впр.';
  }

  @override
  String unitMinutesShort(Object count) {
    return '$count хв';
  }

  @override
  String get presetPowerlifter => 'Сила 5/3/1';

  @override
  String get presetVolume => 'Обʼєм';

  @override
  String get presetMinimalist => 'Мінімалізм';

  @override
  String get presetCustom => 'Свій';

  @override
  String get slotShortPeakIntensity => 'ПІК %';

  @override
  String get slotShortE1rm => 'E1RM';

  @override
  String get slotShortPeakRpe => 'ПІК RPE';

  @override
  String get slotShortAvgRpe => 'СЕР RPE';

  @override
  String get slotShortTonnage => 'ТОННАЖ';

  @override
  String get slotShortKpsh => 'КПШ';

  @override
  String get slotShortSetsCount => 'ПІДХОДИ';

  @override
  String get slotShortDensity => 'ЩІЛЬН.';

  @override
  String get slotShortDurationWeeks => 'ТИЖНІ';

  @override
  String get slotShortFrequencyPerWeek => 'ЧАСТОТА';

  @override
  String get slotNamePeakIntensity => 'Пік % 1RM';

  @override
  String get slotNameE1rm => 'Розрахунковий 1RM';

  @override
  String get slotNamePeakRpe => 'Пік RPE';

  @override
  String get slotNameAvgRpe => 'Середній RPE';

  @override
  String get slotNameTonnage => 'Тоннаж';

  @override
  String get slotNameKpsh => 'КПШ (Повтори)';

  @override
  String get slotNameSetsCount => 'Робочі підходи';

  @override
  String get slotNameDensity => 'Щільність';

  @override
  String get slotNameDurationWeeks => 'Тривалість';

  @override
  String get slotNameFrequencyPerWeek => 'Тренувань/тижд';

  @override
  String get moduleVariantOrHorizonStrip => 'Стрічка пресетів / варіантів';

  @override
  String get moduleCommandBriefing => 'Зведення навантаження';

  @override
  String get modulePrimaryTelemetry => 'Телеметрія та графік';

  @override
  String get moduleScheduleOrLibrary => 'Бібліотека / Мікроцикли';

  @override
  String get interfaceMakerTitle => 'Сітка та модулі екрана';

  @override
  String get interfaceMakerReset => 'Скинути';

  @override
  String get interfaceMakerPresetsSection => 'ПРЕСЕТИ ДИСЦИПЛІНИ';

  @override
  String get interfaceMakerWaveChartTitle => 'Графік-хвиля в картках';

  @override
  String get interfaceMakerWaveChartSubtitle =>
      'Вимкніть для компактного режиму без графіків';

  @override
  String get interfaceMakerSnarkyTitle => 'Характерний CARROT-брифінг';

  @override
  String get interfaceMakerSnarkySubtitle =>
      'Саркастичне зведення замість сухої тактики';

  @override
  String get interfaceMakerSlotsSection =>
      '4 СЛОТИ ТЕЛЕМЕТРІЇ (DATA POINT PICKER)';

  @override
  String interfaceMakerSlotNumber(Object index) {
    return 'Слот $index';
  }

  @override
  String get interfaceMakerModulesSection => 'МОДУЛІ ТА ПОРЯДОК ЕКРАНА';

  @override
  String get interfaceMakerMoveUp => 'Вище';

  @override
  String get interfaceMakerMoveDown => 'Нижче';

  @override
  String get homeNoPlannedSessions =>
      'Усі заплановані сесії виконано або план не обрано';

  @override
  String get homeOpenActivePlanTooltip => 'Відкрити активний план';

  @override
  String get homeOpenCalendarPlanTooltip => 'Відкрити календарний план';

  @override
  String get actionStart => 'Почати';

  @override
  String get actionFinish => 'Завершити';

  @override
  String get actionNew => 'Нова';

  @override
  String get metricTimeShort => 'ЧАС';

  @override
  String get metricExercisesShort => 'ВПРАВИ';

  @override
  String get sessionLogHeader => 'ЖУРНАЛ СЕСІЙ';

  @override
  String get sessionLogLibrary => 'Бібліотека';

  @override
  String get sessionLogLoadError => 'Не вдалося завантажити тренування';

  @override
  String get sessionLogEmptyTitle => 'Немає ручних сесій';

  @override
  String get sessionLogEmptySubtitle =>
      'Натисніть «Нова», щоб записати вільне тренування';

  @override
  String get sessionLogAllShown => 'УСІ СЕСІЇ ПОКАЗАНО';

  @override
  String get workoutDeleteTooltip => 'Видалити тренування';

  @override
  String get workoutManualSession => 'Ручна сесія';

  @override
  String get workoutMarkAllCompletedTooltip => 'Позначити всі як виконані';

  @override
  String get tooltipDecrease => 'Зменшити';

  @override
  String get deleteExerciseTooltip => 'Видалити вправу';

  @override
  String get deleteSetTooltip => 'Видалити підхід';

  @override
  String get metricMicrocyclesShort => 'МІКРОЦИКЛИ';

  @override
  String get metricAppliedShort => 'ЗАСТОСОВАНО';

  @override
  String get planVariantOriginal => 'Оригінал';

  @override
  String get planVariantAdd => '+ Варіант';

  @override
  String get planAnalyticsTitle => 'Аналітика плану';

  @override
  String get tooltipCollapse => 'Згорнути';

  @override
  String get tooltipExpand => 'Розгорнути';

  @override
  String get navWorkouts => 'Тренування';

  @override
  String get navPlans => 'Плани';

  @override
  String get navFeed => 'Стрічка';

  @override
  String get navCrm => 'CRM';

  @override
  String get navDebug => 'Дебаг';

  @override
  String get aiAssistant => 'AI Асистент';

  @override
  String get profile => 'Профіль';

  @override
  String get settings => 'Налаштування';

  @override
  String get activePlanEmptyTitle => 'Немає активного плану';

  @override
  String get activePlanEmptyDescription =>
      'Оберіть календарний план для старту циклу';

  @override
  String get activePlanSelectPlan => 'Обрати план';

  @override
  String get horizon1Week => '1 тижд';

  @override
  String get horizon2Weeks => '2 тижд';

  @override
  String get horizonMonth => 'Місяць';

  @override
  String horizonChipLabel(Object horizon) {
    return 'Горизонт · $horizon';
  }

  @override
  String get gridPillLabel => 'Сітка';

  @override
  String get planPillLabel => 'План';

  @override
  String get activePlanMicrocycleCalendarHeader => 'КАЛЕНДАР МІКРОЦИКЛІВ';

  @override
  String get activePlanDayLabel => 'ДЕНЬ ПЛАНУ';

  @override
  String get actionView => 'Дивитись';

  @override
  String get activePlanNoWorkoutsSelectedDay =>
      'На обраний день тренувань немає';

  @override
  String get noWorkouts => 'Немає тренувань';

  @override
  String get metricAvgIntensityShort => 'ІНТЕНС. СР';

  @override
  String get metricCompletedShort => 'ВИКОНАНО';

  @override
  String get metricAvgRpeShort => 'RPE СР';

  @override
  String get metricRepsShort => 'ПОВТОРИ';

  @override
  String get metricSetsShort => 'ПІДХОДИ';

  @override
  String get metricSessionsShort => 'СЕСІЇ';

  @override
  String get tooltipCollapseChart => 'Згорнути графік';

  @override
  String get tooltipExpandChart => 'Розгорнути графік';

  @override
  String get activePlanNoData => 'Немає даних для плану';

  @override
  String get workoutListAddTitle => 'Додати тренування';

  @override
  String get workoutListNameLabel => 'Назва тренування';

  @override
  String get actionAdd => 'Додати';

  @override
  String get workoutListNameRequired => 'Введіть назву тренування';

  @override
  String workoutListLoadError(Object error) {
    return 'Помилка завантаження тренувань: $error';
  }

  @override
  String get workoutListEmptyTitle => 'Немає тренувань';

  @override
  String get workoutListEmptyDescription =>
      'У цій прогресії поки немає тренувань';

  @override
  String get workoutListSectionTitle => 'Список тренувань';

  @override
  String get workoutsCreateTitle => 'Створити тренування';

  @override
  String get actionCreate => 'Створити';

  @override
  String get workoutsDeleteTitle => 'Видалити тренування?';

  @override
  String get workoutsDeleteConfirm =>
      'Ви впевнені, що хочете видалити це ручне тренування?';

  @override
  String workoutsPlanLoadError(Object error) {
    return 'Помилка завантаження плану: $error';
  }

  @override
  String get workoutDetailOpenError => 'Не вдалося відкрити тренування';

  @override
  String get actionBack => 'Назад';

  @override
  String get workoutDetailAppStateNotReady =>
      'Не вдалося оновити підхід: стан додатку не готовий';

  @override
  String get workoutDetailDeleteExerciseTitle => 'Видалити вправу';

  @override
  String get workoutDetailExerciseRemoved => 'Вправу видалено з тренування';

  @override
  String get workoutDetailDeleteUnsavedExerciseError =>
      'Помилка: неможливо видалити незбережену вправу';

  @override
  String get workoutDetailAddSetUnsavedError =>
      'Неможливо додати підхід: вправу ще не збережено';

  @override
  String get workoutDetailSetAdded => 'Підхід додано';

  @override
  String get workoutDetailUpdated => 'Тренування оновлено';

  @override
  String get workoutDetailStarted => 'Тренування розпочато';

  @override
  String get workoutDetailSessionCancelled => 'Сесію скасовано';

  @override
  String get workoutDetailFinished => 'Тренування завершено';

  @override
  String get workoutDetailAllSetsCompleted => 'Усі підходи вже виконано';

  @override
  String get workoutDetailDeleteSetTitle => 'Видалити підхід';

  @override
  String get workoutDetailSetDeleted => 'Підхід видалено';

  @override
  String get workoutDetailExerciseAdded => 'Вправу додано';

  @override
  String get workoutDetailFallbackTitle => 'Деталі тренування';

  @override
  String get workoutDetailNoExercisesTitle => 'Вправ поки немає';

  @override
  String get workoutDetailNoExercisesSubtitle =>
      'Натисніть «Додати вправу» нижче, щоб зібрати сесію';

  @override
  String get metricTimerShort => 'ТАЙМЕР';

  @override
  String get metricModeShort => 'РЕЖИМ';

  @override
  String get tooltipEditExercise => 'Редагувати вправу';

  @override
  String get actionClear => 'Очистити';

  @override
  String planEditorSelectedCount(Object count) {
    return 'ОБРАНО: $count';
  }

  @override
  String get planEditorBulkShort => 'Масово';

  @override
  String planEditorMesocyclesCount(Object count) {
    return 'МЕЗОЦИКЛИ · $count';
  }

  @override
  String planEditorMicrocyclesCount(Object count) {
    return 'МІКРОЦИКЛІВ: $count';
  }

  @override
  String get planEditorEditMicrocycleTooltip => 'Редагувати мікроцикл';

  @override
  String get planEditorIntensity => 'Інтенсивність';

  @override
  String get planEditorReps => 'Повтори';

  @override
  String get planEditorModeSet => 'Задати';

  @override
  String get planEditorModeOffset => 'Зсув';

  @override
  String get planEditorModeScale => 'Множник';

  @override
  String get planEditorRecalcAuto => 'Перерахувати: Авто';

  @override
  String get planEditorRecalcReps => 'Перерахувати: Повтори';

  @override
  String get planEditorRecalcEffort => 'Перерахувати: RPE';

  @override
  String get planEditorRecalcIntensity => 'Перерахувати: Інтенсивність';

  @override
  String get planEditorAutoRecalcReps =>
      'Авто-перерахунок: Повтори (за Інтенсивністю та RPE)';

  @override
  String get planEditorAutoRecalcIntensity =>
      'Авто-перерахунок: Інтенсивність (за Повторами та RPE)';

  @override
  String get planEditorAutoRecalcRpe =>
      'Авто-перерахунок: RPE (за Інтенсивністю та Повторами)';

  @override
  String get planEditorAutoRecalcNone => 'Авто-перерахунок: не застосовується';

  @override
  String get planEditorFilterExercisesOptional =>
      'Фільтр: вправи (опціонально)';

  @override
  String get planEditorMassEditWarning =>
      'Будуть змінені УСІ підходи усіх вправ у всіх обраних мікроциклах.';

  @override
  String get planEditorNoChanges => 'Немає змін за обраними параметрами';

  @override
  String get planEditorMassEditPreviewTitle =>
      'Попередній перегляд масових правок';

  @override
  String planEditorMicrocyclesCountPlain(Object count) {
    return 'Мікроциклів: $count';
  }

  @override
  String planEditorMismatchesCount(Object count) {
    return 'Невідповідностей: $count';
  }

  @override
  String planEditorChangedSets(Object changed, Object total) {
    return 'Змінено підходів: $changed з $total';
  }

  @override
  String planEditorDeltaSummary(Object e, Object i, Object v) {
    return 'Зміни: Int $i · RPE $e · Повт $v';
  }

  @override
  String get planEditorFixNone => 'Валідатор: Без авто-виправлень';

  @override
  String get planEditorFixReps => 'Валідатор: Виправити Повтори';

  @override
  String get planEditorFixIntensity => 'Валідатор: Виправити Інтенсивність';

  @override
  String planEditorPreviewMicroDiff(
    Object changed,
    Object e,
    Object i,
    Object total,
    Object v,
  ) {
    return 'Підходи: $changed/$total · Δ Int $i · Δ RPE $e · Δ Повт $v';
  }

  @override
  String planDetailDeleteFailed(Object error) {
    return 'Не вдалося видалити план: $error';
  }

  @override
  String get tooltipMoreActions => 'Додаткові дії';

  @override
  String get planDetailEditPlan => 'Редагувати план';

  @override
  String get planDetailRecalcSets => 'Перерахувати підходи (RPE)';

  @override
  String get planDetailDeletePlan => 'Видалити план';

  @override
  String planDetailAdoptersLoadError(Object error) {
    return 'Не вдалося завантажити лічильник застосувань: $error';
  }

  @override
  String planDetailLoadError(Object error) {
    return 'Не вдалося завантажити план: $error';
  }

  @override
  String get planDetailRecalculated => 'План перераховано';

  @override
  String planDetailRecalcError(Object error) {
    return 'Не вдалося перерахувати план: $error';
  }

  @override
  String planDetailVariantsLoadError(Object error) {
    return 'Не вдалося завантажити варіанти: $error';
  }

  @override
  String get planDetailNewVariantTitle => 'Новий варіант плану';

  @override
  String get planDetailVariantNameLabel => 'Назва варіанту';

  @override
  String get errorEnterName => 'Введіть назву';

  @override
  String get planDetailVariantCreated => 'Варіант створено';

  @override
  String errorWithDetails(Object error) {
    return 'Помилка: $error';
  }

  @override
  String get metricVolumeShort => 'ОБʼЄМ';

  @override
  String unitRepsShort(Object count) {
    return '$count повт.';
  }

  @override
  String unitSetsPerWorkout(Object value) {
    return '$value/тр';
  }

  @override
  String get planDetailAnalyticsFilters => 'Фільтри аналітики';

  @override
  String get planDetailGranularity => 'ГРАНУЛЯРНІСТЬ';

  @override
  String get planDetailExercisesTitle => 'Вправи';

  @override
  String get loadingEllipsis => 'Завантаження…';

  @override
  String get planDetailMuscleGroupsTitle => 'Мʼязові групи';

  @override
  String get planDetailAxesTitle => 'Вісь X / Вісь Y';

  @override
  String planDetailFiltersPillCount(Object bucket, Object count) {
    return 'Фільтри · $bucket ($count)';
  }

  @override
  String planDetailFiltersPill(Object bucket) {
    return 'Фільтри · $bucket';
  }

  @override
  String get planDetailExercisesLoadError =>
      'Не вдалося завантажити дані вправ';

  @override
  String get planDetailAllExercises => 'Усі вправи';

  @override
  String get planDetailFilterEmpty => 'Фільтр не містить даних';

  @override
  String planDetailAndMore(Object count, Object items) {
    return '$items та ще $count';
  }

  @override
  String get planDetailAllMuscles => 'Усі мʼязи';

  @override
  String get planDetailSelectExercises => 'Оберіть вправи';

  @override
  String get planDetailSelectMuscles => 'Оберіть мʼязи';

  @override
  String get planDetailSelectMetricX => 'Оберіть метрику для осі X';

  @override
  String get planDetailSelectMetricY => 'Оберіть метрику для осі Y';

  @override
  String get metricYRepsVolume => 'Повторення (volume)';

  @override
  String get metricYIntensityPct => 'Інтенсивність (%)';

  @override
  String get metricYEffortRpe => 'Зусилля (RPE)';

  @override
  String get granularitySessions => 'Сесії';

  @override
  String get granularityMicrocycles => 'Мікроцикли';

  @override
  String get granularityWeeks => 'Тижні';

  @override
  String planDetailCurrentMax(Object reps, Object weight) {
    return 'Поточний максимум: $weight кг × $reps';
  }

  @override
  String get planDetailMaxNotSet => 'Максимум не задано';

  @override
  String get planDetailMadePublic => 'План зроблено публічним';

  @override
  String get planDetailMadePrivate => 'План приховано (тільки для вас)';

  @override
  String planDetailVisibilityError(Object error) {
    return 'Не вдалося оновити видимість плану: $error';
  }

  @override
  String get metricSetShort => 'ПІДХ.';

  @override
  String get metricIntShort => 'ІНТ';

  @override
  String get metricRepsColShort => 'ПОВТ';

  @override
  String normRulesCount(Object count) {
    return 'Індивід. правил: $count';
  }

  @override
  String get normNotSet => 'Нормалізацію не задано';

  @override
  String get normUnitPct1rm => '% від 1RM';

  @override
  String get normUnitKg => 'кг';

  @override
  String normRulesSuffix(Object count) {
    return ', правил: $count';
  }

  @override
  String get normSectionHeader => 'НОРМАЛІЗАЦІЯ ПІСЛЯ МІКРОЦИКЛУ';

  @override
  String get normDeltaLabel => 'Зміна (напр. -2.5)';

  @override
  String get normDeltaHint => 'У кг або %';

  @override
  String get normUnitLabel => 'Од. виміру';

  @override
  String get normUnitPctMult => '% (мультиплікативно)';

  @override
  String get normUnitKgAbs => 'кг (абсолютно)';

  @override
  String get normDescription =>
      'Можна вказати одну загальну зміну та/або список правил для конкретних вправ, груп мʼязів або target-мʼязів.';

  @override
  String get normRulesHeader => 'ПРАВИЛА НОРМАЛІЗАЦІЇ';

  @override
  String get normAddRule => 'Додати правило';

  @override
  String get normNoRules => 'Поки немає індивідуальних правил';

  @override
  String normRuleHeader(Object index) {
    return 'ПРАВИЛО $index';
  }

  @override
  String get normDeleteRuleTooltip => 'Видалити правило';

  @override
  String get normExerciseIdsLabel => 'ID вправ (через кому)';

  @override
  String get normExerciseIdsHint => 'Напр.: 12, 45, 103';

  @override
  String get normMuscleGroupsLabel => 'Групи мʼязів (через кому)';

  @override
  String get normMuscleGroupsHint => 'Напр.: chest, quads';

  @override
  String get normTargetMusclesLabel => 'Цільові мʼязи (через кому)';

  @override
  String get normTargetMusclesHint => 'Напр.: biceps_long, lats';

  @override
  String get normDeltaValueLabel => 'Δ значення';

  @override
  String get normUnitShortLabel => 'Од. вим.';

  @override
  String get microcycleNameLabel => 'Назва мікроцикла';

  @override
  String get planCreateEnterNameError => 'Будь ласка, введіть назву плану';

  @override
  String get planCreateSuccess => 'План успішно створено';

  @override
  String get microEditorMassEditTitle => 'Масова зміна підходів';

  @override
  String get microEditorIntensityOpt => 'Інтенсивність %1RM (опціонально)';

  @override
  String get microEditorRpeOpt => 'RPE (опціонально)';

  @override
  String get microEditorRepsOpt => 'Повтори (опціонально)';

  @override
  String get microEditorSaved => 'Мікроцикл збережено';

  @override
  String microEditorSaveError(Object error) {
    return 'Помилка збереження: $error';
  }

  @override
  String microEditorTitle(Object name) {
    return 'Мікроцикл: $name';
  }

  @override
  String get tooltipSave => 'Зберегти';

  @override
  String get microEditorUnsavedChanges => 'Є незбережені зміни';

  @override
  String microEditorWorkoutMeta(Object count, Object order) {
    return 'ПОРЯДОК: $order · ВПРАВ: $count';
  }

  @override
  String get microEditorSetLabel => 'Підхід';

  @override
  String plansOpenError(Object error) {
    return 'Не вдалося відкрити план: $error';
  }

  @override
  String get plansSearchHint => 'Пошук планів';

  @override
  String get plansClearSearchTooltip => 'Очистити пошук';

  @override
  String get plansFiltersTooltip => 'Фільтри';

  @override
  String plansFoundCount(Object count) {
    return 'Знайдено: $count';
  }

  @override
  String plansLoadError(Object error) {
    return 'Не вдалося завантажити плани: $error';
  }

  @override
  String get plansEmptyTitle => 'Плани не знайдено';

  @override
  String get plansEmptyDescription => 'Змініть запит або фільтри';

  @override
  String get actionLoadMore => 'Показати ще';

  @override
  String get actionLoadFailedRetry => 'Не вдалося завантажити. Повторити';

  @override
  String get filterDuration => 'Тривалість';

  @override
  String get filterGoal => 'Мета';

  @override
  String get filterFrequency => 'Тренувань на тиждень';

  @override
  String get filterLevel => 'Рівень';

  @override
  String filterDurationValue(Object value) {
    return '$value тижд.';
  }

  @override
  String filterFrequencyValue(Object value) {
    return '$value / тижд.';
  }

  @override
  String get planFiltersTitle => 'Фільтри планів';

  @override
  String get tooltipClose => 'Закрити';

  @override
  String get actionRetryLoad => 'Повторити завантаження';

  @override
  String get roundNearest => 'Найбл.';

  @override
  String get roundUp => 'Вгору';

  @override
  String get roundDown => 'Вниз';

  @override
  String applyPlanGenProgress(Object done, Object remaining, Object total) {
    return 'Генерація плану: $done з $total (залишилось $remaining)';
  }

  @override
  String applyPlanGenStage(Object stage) {
    return 'Генерація плану: $stage';
  }

  @override
  String get applyPlanGenEllipsis => 'Генерація плану…';

  @override
  String get weightKgLabel => 'Вага (кг)';

  @override
  String get repsLabel => 'Повторення';

  @override
  String get errorValidWeight => 'Введіть коректну вагу';

  @override
  String get errorValidRepsRange => 'Введіть 1–12 повторень';

  @override
  String saveMaxFailed(Object error) {
    return 'Не вдалося зберегти максимум: $error';
  }

  @override
  String get saveMaxButton => 'Зберегти максимум';

  @override
  String maxSavedForExercise(Object name) {
    return 'Максимум для $name збережено';
  }

  @override
  String get noSavedMaxesForPlan =>
      'Немає збережених максимумів для цього плану';

  @override
  String get selectAtLeastOneUserMax =>
      'Будь ласка, оберіть хоча б один User Max';

  @override
  String get applyPlanTitle => 'Застосувати план';

  @override
  String get applyPlanBaseMaxesHeader => 'БАЗОВІ МАКСИМУМИ · USER MAX';

  @override
  String applyPlanSelectedCount(Object count) {
    return 'Обрано: $count';
  }

  @override
  String get applyPlanRecentButton => 'Останні';

  @override
  String get applyPlanNoMaxesHint =>
      'Немає збережених максимумів для вправ у плані. Додайте 1RM вище.';

  @override
  String get applyPlanNoExactMatchHint =>
      'Точного збігу вправ немає — показано всі ваші User Max:';

  @override
  String get applyPlanWorkingWeightsHeader => 'РОЗРАХУНОК РОБОЧИХ ВАГ';

  @override
  String get applyPlanComputeWeights => 'Обчислювати ваги';

  @override
  String get applyPlanComputeWeightsSubtitle =>
      'Автопідбір за % від обраного максимуму';

  @override
  String get applyPlanStepKgLabel => 'Крок (кг)';

  @override
  String get applyPlanRoundingHeader => 'ОКРУГЛЕННЯ';

  @override
  String userMaxDisplay(Object reps, Object weight) {
    return '$weight кг × $reps';
  }

  @override
  String get deletePlanWithVariantsTitle => 'Видалити план з варіантами?';

  @override
  String get deletePlanTitle => 'Видалити план?';

  @override
  String get deletePlanCascadeBody =>
      'Будуть безповоротно видалені план, усі його варіанти та повʼязані застосування плану.';

  @override
  String get deletePlanSingleBody =>
      'План та повʼязані застосування плану будуть видалені. Цю дію неможливо скасувати.';

  @override
  String get untitled => 'Без назви';

  @override
  String get deleteAll => 'Видалити все';

  @override
  String get replaceActivePlanTitle => 'Замінити активний план?';

  @override
  String get replaceActivePlanBody =>
      'У вас вже є активний план. Новий план замінить його. Історія завершених тренувань збережеться.';

  @override
  String get replacePlanAction => 'Замінити план';

  @override
  String get macroMetricReadiness => 'готовність';

  @override
  String get macroMetricSessionRpe => 'RPE сесії';

  @override
  String get macroMetricReps => 'кількість повторень';

  @override
  String get macroMetricE1rm => 'оцінка 1ПМ';

  @override
  String get macroMetricTrend => 'тренд прогресу';

  @override
  String get macroMetricRpeDelta => 'відхилення RPE від плану';

  @override
  String get macroMetricRepsDelta => 'відхилення повторів від плану';

  @override
  String get macroMetricFallback => 'метрика';

  @override
  String get macroTriggerAllExercises => 'по всіх вправах';

  @override
  String macroTriggerForExercises(Object names) {
    return 'для вправ: $names';
  }

  @override
  String get macroOpGte => 'більше або дорівнює';

  @override
  String get macroOpLte => 'менше або дорівнює';

  @override
  String get macroOpEq => 'дорівнює';

  @override
  String get macroOpNeq => 'не дорівнює';

  @override
  String get macroOpGt => 'більше';

  @override
  String get macroOpLt => 'менше';

  @override
  String get macroOpInRange => 'у діапазоні';

  @override
  String get macroOpOutOfRange => 'поза діапазоном';

  @override
  String get macroCondNotSet => 'умову не задано';

  @override
  String macroCondInRangeValues(Object a, Object b, Object unit) {
    return 'значення в діапазоні $a до $b$unit';
  }

  @override
  String macroCondOutOfRangeValues(Object a, Object b, Object unit) {
    return 'значення поза діапазоном $a до $b$unit';
  }

  @override
  String get macroCondInRange => 'значення в діапазоні';

  @override
  String get macroCondOutOfRange => 'значення поза діапазоном';

  @override
  String macroCondStagnatesValues(Object eps, Object n) {
    return 'стагнація за $n вікон у межах $eps відсотків';
  }

  @override
  String get macroCondStagnates => 'стагнація за вікна';

  @override
  String get macroCondDirPositive => 'позитивний';

  @override
  String get macroCondDirNegative => 'негативний';

  @override
  String macroCondDirSuffix(Object dir) {
    return ', напрямок: $dir';
  }

  @override
  String macroCondDeviatesValues(Object dir, Object n, Object val) {
    return 'відхилення від середнього за $n вікон не менше $val відсотків$dir';
  }

  @override
  String get macroCondDeviates => 'відхилення від середнього';

  @override
  String macroCondHoldsWorkouts(Object n, Object rel, Object unit, Object val) {
    return 'виконується $n тренувань поспіль: значення $rel $val$unit';
  }

  @override
  String get macroCondHoldsWorkoutsGeneric =>
      'виконується кілька тренувань поспіль';

  @override
  String macroCondHoldsSets(Object n, Object rel, Object unit, Object val) {
    return 'виконується $n підходів поспіль усередині тренування: значення $rel $val$unit';
  }

  @override
  String get macroCondHoldsSetsGeneric =>
      'виконується кілька підходів поспіль усередині тренування';

  @override
  String macroCondSimpleGt(Object unit, Object val) {
    return 'значення більше $val$unit';
  }

  @override
  String macroCondSimpleLt(Object unit, Object val) {
    return 'значення менше $val$unit';
  }

  @override
  String macroCondSimpleEq(Object unit, Object val) {
    return 'значення дорівнює $val$unit';
  }

  @override
  String macroCondSimpleNeq(Object unit, Object val) {
    return 'значення не дорівнює $val$unit';
  }

  @override
  String get macroCondSet => 'умову задано';

  @override
  String get macroActionTargetAll => 'для всіх вправ';

  @override
  String macroActionTargetExercises(Object list) {
    return 'для вправ: $list';
  }

  @override
  String macroActionTargetTags(Object tags) {
    return 'за тегами: $tags';
  }

  @override
  String macroActionTargetTagsExamples(Object base, Object examples) {
    return '$base, напр.: $examples';
  }

  @override
  String get macroInjectMesoBase => 'впровадити мезоцикл';

  @override
  String macroInjectMesoTemplate(Object base, Object id) {
    return '$base за шаблоном ID $id';
  }

  @override
  String macroInjectWeeks(Object weeks) {
    return '$weeks тижнів';
  }

  @override
  String macroInjectMicroDays(Object days) {
    return 'мікроцикл $days днів';
  }

  @override
  String macroInjectRestDays(Object days) {
    return 'вихідні дні: $days';
  }

  @override
  String macroInjectFocus(Object tags) {
    return 'фокус: $tags';
  }

  @override
  String get macroInjectAppendEnd => 'у кінець плану';

  @override
  String macroInjectAfterWorkoutId(Object id) {
    return 'після тренування #$id';
  }

  @override
  String get macroInjectAfterSelectedWorkout => 'після обраного тренування';

  @override
  String macroInjectAfterMesoIdx(Object idx) {
    return 'після мезоцикла $idx';
  }

  @override
  String get macroInjectAfterSelectedMeso => 'після обраного мезоцикла';

  @override
  String get macroConflictReplace => 'замінювати заплановане';

  @override
  String get macroConflictShift => 'зсувати вперед';

  @override
  String get macroConflictSkip => 'пропускати конфліктні';

  @override
  String macroConflictPrefix(Object text) {
    return 'при конфлікті: $text';
  }

  @override
  String macroActDecreaseWeightPct(Object pct, Object target) {
    return 'зменшити вагу на $pct відсотків $target';
  }

  @override
  String macroActIncreaseWeightPct(Object pct, Object target) {
    return 'збільшити вагу на $pct відсотків $target';
  }

  @override
  String macroActAdjustWeightRpe(Object rpe, Object target) {
    return 'підігнати вагу до цільового RPE $rpe $target';
  }

  @override
  String macroActDecreaseReps(Object reps, Object target) {
    return 'зменшити повтори на $reps $target';
  }

  @override
  String macroActIncreaseReps(Object reps, Object target) {
    return 'збільшити повтори на $reps $target';
  }

  @override
  String macroActAdjustRepsRpe(Object rpe, Object target) {
    return 'підібрати повтори до цільового RPE $rpe $target';
  }

  @override
  String macroActRemoveSets(Object sets, Object target) {
    return 'прибрати $sets підходів $target';
  }

  @override
  String macroActAddSets(Object sets, Object target) {
    return 'додати $sets підходів $target';
  }

  @override
  String macroActFallback(Object target) {
    return 'виконати дію $target';
  }

  @override
  String macroDurNextWorkouts(Object count) {
    return 'у наступні $count тренувань';
  }

  @override
  String get macroDurUntilLast => 'до останнього тренування';

  @override
  String get macroDurUntilEndMeso => 'до кінця мезоцикла';

  @override
  String get macroDurUntilEndMicro => 'до кінця мікроцикла';

  @override
  String macroDurUntilWorkoutId(Object id) {
    return 'до тренування #$id';
  }

  @override
  String get macroDurUntilSelectedWorkout => 'до обраного тренування';

  @override
  String get macroPreviewEmpty =>
      'Опис зʼявиться після вибору метрики, умови та дії';

  @override
  String macroPreviewSentence(
    Object action,
    Object condition,
    Object metric,
    Object trigger,
  ) {
    return 'Якщо $metric $trigger, і $condition, то $action';
  }

  @override
  String get macroLabelMetric => 'МЕТРИКА';

  @override
  String get macroLabelTrigger => 'ТРИГЕР';

  @override
  String get macroLabelCondition => 'УМОВА';

  @override
  String get macroLabelAction => 'ДІЯ';

  @override
  String get macroLabelDuration => 'ТРИВАЛІСТЬ';

  @override
  String macroPreviewSetChangesCount(Object count) {
    return 'Змін підходів: $count';
  }

  @override
  String macroPreviewMesoInsertsCount(Object count) {
    return 'Вставок мезоциклів: $count';
  }

  @override
  String get macroPreviewMissingParamsHint =>
      'Для розрахунку ваги потрібні параметри плану.';

  @override
  String get macroPreviewDialogTitle => 'Пропозиції за завершеним тренуванням';

  @override
  String get macroPreviewViewChanges => 'Переглянути зміни';

  @override
  String macroPreviewLoadError(Object error) {
    return 'Не вдалося завантажити пропозиції макросів: $error';
  }

  @override
  String get macroPreviewAppBarTitle => 'Зміни за макросами';

  @override
  String get macroPreviewConfirmNeedsNewServer =>
      'Для підтвердження потрібна нова версія сервера.';

  @override
  String macroPreviewObservationWorkout(Object id) {
    return 'Спостереження: тренування #$id';
  }

  @override
  String get macroPreviewSpecifyWeightParams =>
      'Вкажіть параметри ваги для розрахунку цього перегляду.';

  @override
  String macroPreviewOneRmKgForExercise(Object name) {
    return '1ПМ, кг · $name';
  }

  @override
  String get macroPreviewWeightStepKg => 'Крок ваги, кг';

  @override
  String get macroPreviewRoundNearest => 'До найближчого кроку';

  @override
  String get macroPreviewRoundDown => 'Округлити вниз';

  @override
  String get macroPreviewRoundUp => 'Округлити вгору';

  @override
  String get macroPreviewCalcButton => 'Розрахувати перегляд';

  @override
  String get macroPreviewNoSetChanges => 'Змін підходів немає.';

  @override
  String macroPreviewExercisesModified(Object count) {
    return 'Змінено екземплярів вправ: $count';
  }

  @override
  String get macroPreviewMesoAdded => 'Мезоцикл додано';

  @override
  String macroPreviewMesoNotAdded(Object reason) {
    return 'Мезоцикл не додано: $reason';
  }

  @override
  String get macroPreviewConfirmSetsButton => 'Підтвердити зміни підходів';

  @override
  String get macroPreviewApplyMesoRulesButton =>
      'Застосувати правила вставки мезоциклів окремо';

  @override
  String macroPreviewAppliedToActivePlan(Object id) {
    return 'Застосовано до активного плану #$id';
  }

  @override
  String macroPreviewInstanceNewSet(Object id) {
    return 'екземпляр $id, новий підхід';
  }

  @override
  String macroPreviewInstanceSet(Object id, Object setId) {
    return 'екземпляр $id, підхід $setId';
  }

  @override
  String macroPreviewBefore(Object values) {
    return 'Було: $values';
  }

  @override
  String macroPreviewRequested(Object values) {
    return 'Запрошено: $values';
  }

  @override
  String macroPreviewClosestOption(Object values) {
    return 'Найближчий варіант: $values';
  }

  @override
  String macroPreviewAfter(Object values) {
    return 'Результат: $values';
  }

  @override
  String get macroPreviewDeleteSet => 'Видалення підходу';

  @override
  String macroPreviewMesoInsertParams(Object params) {
    return 'Вставка мезоцикла: $params';
  }

  @override
  String macroEditorInvalidJsonRule(Object error) {
    return 'Некоректний JSON правила: $error';
  }

  @override
  String get macroEditorCreateTitle => 'Створити макрос';

  @override
  String get macroEditorEditTitle => 'Редагувати макрос';

  @override
  String get macroEditorRuleParamsTitle => 'Параметри правила';

  @override
  String get macroEditorNameLabel => 'Назва';

  @override
  String get macroEditorPriorityLabel => 'Пріоритет';

  @override
  String get macroEditorInvalidNumber => 'Некоректне число';

  @override
  String get macroEditorActiveLabel => 'Активний';

  @override
  String get macroEditorTriggerTitle => 'Тригер';

  @override
  String get macroEditorConditionTitle => 'Умова';

  @override
  String get macroEditorActionTitle => 'Дія';

  @override
  String get macroEditorDurationTitle => 'Тривалість';

  @override
  String get macroEditorNaturalDescTitle => 'Природний опис';

  @override
  String get macroEditorEditJson => 'Редагувати JSON';

  @override
  String get macroEditorRuleJsonLabel => 'Правило (перегляд JSON)';

  @override
  String get macroEditorMustBeJsonObject => 'Має бути JSON-обʼєкт';

  @override
  String get macroEditorInvalidJson => 'Некоректний JSON';

  @override
  String get macroTriggerHelpReadiness =>
      'Оцінка готовності 1–10 (опціонально). За замовчуванням null; користувач може вказувати її після тренування для коефіцієнтів до ваги та правил.';

  @override
  String get macroTriggerHelpSessionRpe =>
      'Оцінка сприйнятого навантаження всієї сесії (Session RPE). Корисно для автокорекції навантаження.';

  @override
  String get macroTriggerHelpReps =>
      'Сумарна кількість повторень за обраний період. Використовуйте з фільтром вправ.';

  @override
  String get macroTriggerHelpE1rm =>
      'Оцінка одноповторного максимуму за продуктивністю (estimated 1RM). Корисно для прогресу.';

  @override
  String get macroTriggerHelpTrend =>
      'Тренд зміни показників (зростання/падіння) за останні N вікон.';

  @override
  String get macroTriggerHelpRpeDelta =>
      'Відхилення RPE від планового за підходами (факт − план). Використовується для авторегулювання.';

  @override
  String get macroTriggerHelpRepsDelta =>
      'Відхилення повторів від планових за підходами (факт − план). Для правил щодо недовиконання/перевиконання.';

  @override
  String get macroTriggerHintReadiness =>
      'Числова оцінка готовності (1–10). За замовчуванням null; заповнюється після тренування. Кейс: < 6 тримається 5 тренувань поспіль — делоад мезоцикл. Для правил поспіль використовуйте holds_for.';

  @override
  String get macroTriggerHintSessionRpe =>
      'RPE сесії: число 1–10. Для правил поспіль використовуйте оператор holds_for.';

  @override
  String get macroTriggerHintReps =>
      'Загальне число повторень (ціле). Можна обмежити конкретними вправами нижче.';

  @override
  String get macroTriggerHintE1rm =>
      'Оцінка 1ПМ (кг). Порівнюйте числом або використовуйте тренд-оператори в умовах.';

  @override
  String get macroTriggerHintTrend =>
      'Для трендів використовуйте оператори: stagnates_for (n, epsilon_percent) або deviates_from_avg (n, value_percent, direction).';

  @override
  String get macroTriggerHintRpeDelta =>
      'ΔRPE = факт − план (може бути відʼємним). Для тренувань поспіль — holds_for, для підходів поспіль — holds_for_sets.';

  @override
  String get macroTriggerHintRepsDelta =>
      'Δповторів = факт − план (ціле, може бути відʼємним). Для перевірки всередині тренування використовуйте holds_for_sets.';

  @override
  String get macroTriggerSelectExercisesHint =>
      'Ця метрика застосовується до обраних вправ. Оберіть одну або кілька.';

  @override
  String get macroCondHelpCompare =>
      'Порівняння з числом. Введіть значення (ціле або дробове), напр. 10 або -2.5.';

  @override
  String get macroCondHelpInRange =>
      'Перевіряє, що значення УСЕРЕДИНІ діапазону (включно). Введіть два числа; порядок не важливий.';

  @override
  String get macroCondHelpOutOfRange =>
      'Перевіряє, що значення ПОЗА діапазоном (включно з межами). Введіть два числа.';

  @override
  String get macroCondHelpStagnates =>
      'Стагнація: останні n вікон вкладаються в коридор шириною epsilon_percent (%). Вкажіть n та epsilon_percent.';

  @override
  String get macroCondHelpDeviates =>
      'Відхилення від середнього за n вікон. value_percent — поріг у %, direction — напрямок (опціонально).';

  @override
  String get macroCondHelpHoldsWorkouts =>
      'Поспіль N тренувань: relation (>, <, >=, <=, ==, !=, у діапазоні, поза діапазоном) застосовується N разів поспіль.';

  @override
  String get macroCondHelpHoldsSets =>
      'Поспіль N підходів усередині тренування: для кожної пари план/факт за підходом застосовується relation до дельти.';

  @override
  String get macroCondNoteStagnates =>
      'Тренд (стагнація): беруться останні n значень метрики та порівнюється ширина діапазону з epsilon_percent (%).\nФормат: n — ціле (вікна), epsilon_percent — число у відсотках.\nПриклад: n=5, epsilon_percent=1.0 (зміна ≤ 1% за 5 вікон).';

  @override
  String get macroCondNoteDeviates =>
      'Тренд (відхилення): порівнюється останнє значення із середнім за n вікон.\nФормат: n — ціле, value_percent — поріг у %, direction — positive/negative (опціонально).\nПриклад: n=5, value_percent=3, direction=\"negative\" (падіння ≥ 3%).';

  @override
  String get macroActHelpAdjustWeight =>
      'Змінює вагу та/або інтенсивність на заданий %: позитивне — збільшити, негативне — зменшити. Приклад: -2.5 знизить вагу на 2.5%.';

  @override
  String get macroActHelpAdjustReps =>
      'Змінює кількість повторень на ±N: позитивне — додати повтор(и), негативне — прибрати.';

  @override
  String get macroActHelpAdjustWeightRpe =>
      'Підганяє інтенсивність/вагу до цільового RPE (1–10), зберігаючи поточні повтори. Використовує RPE-таблицю.';

  @override
  String get macroActHelpAdjustRepsRpe =>
      'Підбирає повтори під цільовий RPE (1–10) при фіксованій інтенсивності (якщо задано). Використовує RPE-таблицю.';

  @override
  String get macroActHelpAdjustSets =>
      'Додає або видаляє підходи: позитивне — додати (клонується останній сет), негативне — видалити з кінця.';

  @override
  String get macroActHelpInjectTemplate =>
      'Впроваджує мезоцикл з наявного шаблону за його ID. Можна вказати розміщення та стратегію конфліктів.';

  @override
  String get macroActHelpInjectExisting =>
      'Впроваджує вже наявний мезоцикл за його ID з бази. Вкажіть ідентифікатор та розміщення.';

  @override
  String get macroActHelpInjectCustom =>
      'Створює мезоцикл вручну: тривалість у тижнях, довжина мікроцикла в днях, вихідні дні та теги фокусу.';

  @override
  String get macroActErrPct => 'Зміна має бути більшою за -100%.';

  @override
  String get macroActErrRpe => 'Вкажіть RPE від 1 до 10.';

  @override
  String get macroActErrInt => 'Вкажіть ціле число.';

  @override
  String get workoutPickerActivePlanNotFound => 'Активний план не знайдено';

  @override
  String get userMaxWeakMusclesTitle => 'Аналіз слабких мʼязів';

  @override
  String get userMaxLlmEnriched => 'LLM збагачення увімкнено';

  @override
  String get userMaxTopWeakMuscles => 'Топ слабких мʼязів';

  @override
  String get noData => 'Немає даних';

  @override
  String get userMaxStrengthByMuscle => 'Сила за мʼязами';

  @override
  String get userMaxTrends => 'Тренди';

  @override
  String get userMaxAnomalies => 'Аномалії';

  @override
  String get userMaxNoneDetected => 'Не виявлено';

  @override
  String userMaxAnalysisError(Object error) {
    return 'Помилка аналізу: $error';
  }

  @override
  String userMaxExerciseFallback(Object id) {
    return 'Вправа $id';
  }

  @override
  String get userMaxDeleteTitle => 'Видалити максимум?';

  @override
  String userMaxDeleteBody(Object exercise, Object reps, Object weight) {
    return '$exercise\n$weight кг × $reps повторень';
  }

  @override
  String get userMaxDeleted => 'Максимум видалено';

  @override
  String userMaxDeleteError(Object error) {
    return 'Не вдалося видалити максимум: $error';
  }

  @override
  String get userMaxDeleteTooltip => 'Видалити максимум';

  @override
  String get chatPlanGenTitle => 'Генерація плану (FSM)';

  @override
  String get chatPlanGenDesc =>
      'Запускає діалог finite state machine для складання тренувального плану.';

  @override
  String get chatMassEditDesc => 'Масове редагування плану за допомогою AI.';

  @override
  String get chatAssistantTitle => 'Чат асистента';

  @override
  String get chatInputHint => 'Введіть повідомлення...';

  @override
  String get chatSendTooltip => 'Надіслати';

  @override
  String get chatNoConnectionTooltip => 'Немає зʼєднання';

  @override
  String get chatStatusConnected => 'Підключено';

  @override
  String get chatStatusConnecting => 'Підключення...';

  @override
  String get chatStatusReconnecting => 'Перепідключення...';

  @override
  String get chatStatusError => 'Помилка зʼєднання';

  @override
  String get chatStatusDisconnected => 'Відключено';

  @override
  String get chatWorkoutLinkDesc => 'Посилання на тренування в активному плані';

  @override
  String get chatExerciseLinkDesc => 'Посилання на вправу';

  @override
  String chatSessionLabel(Object id) {
    return 'Сесія: $id';
  }

  @override
  String chatTypingStatus(Object session) {
    return 'Асистент друкує...$session';
  }

  @override
  String chatTypingSessionSuffix(Object id) {
    return ' (сесія $id)';
  }

  @override
  String loadErrorWithDetails(Object error) {
    return 'Помилка завантаження: $error';
  }

  @override
  String listLoadErrorWithDetails(Object error) {
    return 'Помилка завантаження списку: $error';
  }

  @override
  String get chartMetricRepsTotal => 'КПШ';

  @override
  String get chartMetricRepsPerSetAvg => 'Повт. у підході (сер.)';

  @override
  String get chartMetricKgAvg => 'Кілограми (сер.)';

  @override
  String get chartMetricTonnage => 'Тоннаж';

  @override
  String get chartMetricE1rm => 'Разовий максимум (розр.)';

  @override
  String get noOptions => 'Немає опцій';

  @override
  String get yAxisLabel => 'Вісь Y';

  @override
  String get musclesTitle => 'Мʼязи';

  @override
  String get statusCompleted => 'Завершена';

  @override
  String get statusInProgress => 'У процесі';

  @override
  String get statusPlanned => 'Запланована';

  @override
  String exerciseLoadError(Object error) {
    return 'Помилка завантаження вправ: $error';
  }

  @override
  String get exerciseSelectTitle => 'Оберіть вправу';

  @override
  String get exerciseSearchLabel => 'Пошук вправ';

  @override
  String get filterAll => 'Усі';

  @override
  String get exerciseEmptyTitle => 'Вправи не знайдено';

  @override
  String get exerciseEmptyDescription =>
      'Спробуйте змінити пошуковий запит або групу мʼязів.';

  @override
  String exerciseMuscleGroupMeta(Object group) {
    return 'Група мʼязів: $group';
  }

  @override
  String exerciseEquipmentMeta(Object equipment) {
    return 'Обладнання: $equipment';
  }

  @override
  String get signInTitle => 'Увійдіть, щоб продовжити';

  @override
  String get signInWelcomeBack => 'Ласкаво просимо! Увійдіть у свій акаунт.';

  @override
  String get signInCreateAccount => 'Створіть акаунт, щоб почати тренування.';

  @override
  String get signInLegalConsent =>
      'Продовжуючи, ви погоджуєтесь з Умовами використання та підтверджуєте ознайомлення з Політикою конфіденційності:';

  @override
  String get legalTermsOfService => 'Умови використання';

  @override
  String get legalPrivacyPolicy => 'Політика конфіденційності';

  @override
  String get legalMedicalDisclaimer => 'Мед. дисклеймер';

  @override
  String templateLoadError(Object error) {
    return 'Помилка завантаження шаблона: $error';
  }

  @override
  String get templateDetailsTitle => 'Деталі шаблона';

  @override
  String get descriptionSectionHeader => 'ОПИС';

  @override
  String get signOutTitle => 'Вийти з акаунта?';

  @override
  String get signOutConfirmBody => 'Ви впевнені, що хочете вийти?';

  @override
  String get signOutAction => 'Вийти';

  @override
  String signOutError(Object error) {
    return 'Помилка виходу: $error';
  }

  @override
  String get noDisplayDataTitle => 'Немає даних для відображення';

  @override
  String get workoutHistoryEmptyDesc =>
      'Завершені сесії за цим тренуванням зʼявляться тут.';

  @override
  String get settingsGeneral => 'Загальні';

  @override
  String get settingsImportWorkouts => 'Імпорт тренувань';

  @override
  String get settingsImportWorkoutsSubtitle =>
      'Імпортуйте історію тренувань з CSV-файлу Hevy';

  @override
  String get settingsAmplitudeTest => 'Amplitude Тест';

  @override
  String get settingsAmplitudeTestSubtitle =>
      'Діагностика та телеметрія подій воронки';

  @override
  String get settingsGeneralTitle => 'Загальні налаштування';

  @override
  String get settingsThemeMode => 'Режим теми';

  @override
  String get settingsThemeSystem => 'Системна';

  @override
  String get settingsThemeLight => 'Світла';

  @override
  String get settingsThemeDark => 'Темна';

  @override
  String get settingsInterfaceSize => 'Розмір інтерфейсу';

  @override
  String get settingsDensityCompact => 'Компактний';

  @override
  String get settingsDensityCompactSubtitle => 'Менше відступів між елементами';

  @override
  String get settingsDensityComfortable => 'Комфортний';

  @override
  String get settingsDensityComfortableSubtitle =>
      'Більше відступів між елементами';

  @override
  String get settingsDeleteAccountTitle => 'Видалити акаунт';

  @override
  String get settingsInterfaceConfig => 'Конфігурація інтерфейсу';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsShowActivityChart => 'Показувати графік активності';

  @override
  String get settingsShowWorkoutHistory => 'Показувати історію тренувань';

  @override
  String get settingsShowWorkoutAnalytics => 'Показувати аналітику тренувань';

  @override
  String get settingsShowAllTime => 'Показувати за весь час';

  @override
  String get settingsUseHorizontalScroll => 'Горизонтальна прокрутка';

  @override
  String get settingsTrainerControls => 'Керування тренера';

  @override
  String get settingsEnableCoaching => 'Увімкнути тренерство';

  @override
  String get settingsConnectStripe => 'Підключити виплати Stripe';

  @override
  String get settingsConnectStripeSubtitle =>
      'Налаштуйте прийом оплат за тренерство';

  @override
  String get settingsStripeConnected => 'Stripe підключено';

  @override
  String get settingsStripeConnectedSubtitle => 'Прийом оплат налаштовано';

  @override
  String get settingsEnableCoachingFeatures => 'Увімкнути функції тренера';

  @override
  String get settingsTaglineLabel => 'Слоган';

  @override
  String get settingsDescriptionLabel => 'Опис';

  @override
  String get settingsSpecializationsHeader => 'СПЕЦІАЛІЗАЦІЇ';

  @override
  String get settingsLanguagesHeader => 'МОВИ';

  @override
  String get settingsRatePerMonthUsd => 'Ставка на місяць (USD)';

  @override
  String get settingsTimezoneHint => 'напр. Europe/Kyiv';

  @override
  String get importCreatedWorkouts => 'Створено тренувань';

  @override
  String get importTotalRows => 'Усього рядків у файлі';

  @override
  String get importRowErrors => 'Помилок у рядках';

  @override
  String get amplitudeSendTestEvent => 'Надіслати тестову подію';

  @override
  String get amplitudeSendCustomEvent => 'Надіслати кастомну подію';

  @override
  String get amplitudeShowDebugInfo => 'Показати Debug Info';

  @override
  String get amplitudeTestFunnel => 'Тест воронки Time-to-First-Dollar';

  @override
  String get debugScreenTitle => 'Екран налагодження';

  @override
  String get debugCoachChatTitle => 'Дебаг чату тренера';

  @override
  String get debugChatEmbeddedTitle => 'Чат (вбудований)';

  @override
  String get statusCancelled => 'Скасовано';

  @override
  String get statusPlannedLabel => 'Заплановано';

  @override
  String get reviewRatingHeader => 'ОЦІНКА';

  @override
  String get reviewCommentHeader => 'КОМЕНТАР (ОПЦІОНАЛЬНО)';

  @override
  String get reviewShareExperienceHint => 'Поділіться враженнями...';

  @override
  String get actionSubmit => 'Надіслати';

  @override
  String get reviewSubmittedSuccess => 'Відгук успішно надіслано';

  @override
  String get sessionStartedHeader => 'ПОЧАТОК';

  @override
  String get sessionFinishedHeader => 'ЗАВЕРШЕННЯ';

  @override
  String get sessionDurationHeader => 'ТРИВАЛІСТЬ';

  @override
  String get sessionCompletedSetsHeader => 'ВИКОНАНІ ПІДХОДИ';

  @override
  String get planCardTargetSessionLength => 'Цільова тривалість сесії';

  @override
  String get avatarTooltip => 'Аватар';

  @override
  String get profileLoadErrorEyebrow => 'ПОМИЛКА ЗАВАНТАЖЕННЯ ПРОФІЛЮ';

  @override
  String failedToLoadProfile(Object error) {
    return 'Не вдалося завантажити профіль: $error';
  }

  @override
  String get appearanceEyebrow => 'ЗОВНІШНІЙ ВИГЛЯД';

  @override
  String get layoutScaleEyebrow => 'МАСШТАБ ІНТЕРФЕЙСУ';

  @override
  String get sessionAccessEyebrow => 'ДОСТУП ДО СЕСІЇ';

  @override
  String get irreversibleActionEyebrow => 'НЕЗВОРОТНА ДІЯ';

  @override
  String get deleteAccountConfirmMessage =>
      'Це запланує видалення даних вашого акаунта. Продовжити?';

  @override
  String get appearanceAndLocaleEyebrow => 'ЗОВНІШНІЙ ВИГЛЯД І МОВА';

  @override
  String get profileTelemetryEyebrow => 'ТЕЛЕМЕТРІЯ ПРОФІЛЮ';

  @override
  String get visibilityAndCharts => 'Видимість і графіки';

  @override
  String get coachingAndPayoutsEyebrow => 'ТРЕНЕРСТВО ТА ВИПЛАТИ';

  @override
  String get notAvailableForAccount => 'Недоступно для цього акаунта';

  @override
  String get accountZoneEyebrow => 'ЗОНА АКАУНТА';

  @override
  String get sessionAndDataTitle => 'Сесія та дані';

  @override
  String get notSetLabel => 'Не задано';

  @override
  String get ratePerMonthHelper =>
      'Сума вводиться в доларах (напр. 120 = \$120.00).';

  @override
  String get addMuscleTagLabel => 'Додати тег м\'яза';

  @override
  String get typeToSearchHint => 'Введіть для пошуку...';

  @override
  String get failedToReadFileBytes => 'Не вдалося прочитати вибраний файл';

  @override
  String get gifUploaded => 'GIF завантажено';

  @override
  String get imageUploaded => 'Зображення завантажено';

  @override
  String uploadFailed(Object error) {
    return 'Помилка завантаження: $error';
  }

  @override
  String get editExerciseTitle => 'Редагувати вправу';

  @override
  String get createExerciseTitle => 'Створити вправу';

  @override
  String get nameLabel => 'Назва';

  @override
  String get muscleGroupLabel => 'Група м\'язів';

  @override
  String get selectGroupHint => 'Виберіть групу';

  @override
  String get movementTypeLabel => 'Тип руху';

  @override
  String get movementTypeCompound => 'Базова';

  @override
  String get movementTypeIsolation => 'Ізольована';

  @override
  String get regionLabel => 'Регіон';

  @override
  String get regionUpper => 'Верх тіла';

  @override
  String get regionLower => 'Низ тіла';

  @override
  String failedToUpdateExercise(Object error) {
    return 'Не вдалося оновити вправу: $error';
  }

  @override
  String failedToCreateExercise(Object error) {
    return 'Не вдалося створити вправу: $error';
  }

  @override
  String get create => 'Створити';

  @override
  String get exercisesTitle => 'Вправи';

  @override
  String errorLoadingExercises(Object error) {
    return 'Помилка завантаження вправ: $error';
  }

  @override
  String get noExercisesTitle => 'Немає вправ';

  @override
  String get noExercisesDescription =>
      'Вправ не знайдено. Додайте свою першу вправу!';

  @override
  String get noMuscleGroup => 'Без групи м\'язів';

  @override
  String get noEquipment => 'Без обладнання';

  @override
  String get uploadImageTooltip => 'Завантажити зображення';

  @override
  String get deleteExerciseQuestion => 'Видалити вправу?';

  @override
  String failedToDeleteExercise(Object error) {
    return 'Не вдалося видалити вправу: $error';
  }

  @override
  String get exerciseTitle => 'Вправа';

  @override
  String failedToLoadExercise(Object error) {
    return 'Не вдалося завантажити вправу: $error';
  }

  @override
  String get exerciseNotFoundTitle => 'Вправу не знайдено';

  @override
  String get muscleGroupHeader => 'ГРУПА М\'ЯЗІВ';

  @override
  String get equipmentHeader => 'ОБЛАДНАННЯ';

  @override
  String get movementTypeHeader => 'ТИП РУХУ';

  @override
  String get regionHeader => 'РЕГІОН';

  @override
  String get targetMusclesHeader => 'ЦІЛЬОВІ М\'ЯЗИ';

  @override
  String get synergistMusclesHeader => 'М\'ЯЗИ-СИНЕРГІСТИ';

  @override
  String get parentExerciseEyebrow => 'БАЗОВА ВПРАВА';

  @override
  String get baseMovementTitle => 'Базовий рух';

  @override
  String get directVariantsTitle => 'Прямі варіанти';

  @override
  String get relatedSiblingsTitle => 'Пов\'язані варіанти';

  @override
  String failedToLoadData(Object error) {
    return 'Не вдалося завантажити дані: $error';
  }

  @override
  String errorSaving(Object error) {
    return 'Помилка збереження: $error';
  }

  @override
  String get progressionTemplateOptionalLabel =>
      'Шаблон прогресії (необов\'язково)';

  @override
  String get selectTemplateHint => 'Виберіть шаблон';

  @override
  String get noTemplateOption => 'Без шаблону';

  @override
  String get saveExercise => 'Зберегти вправу';

  @override
  String get exerciseDetailsTitle => 'Деталі вправи';

  @override
  String get exerciseNameLabel => 'Назва вправи';

  @override
  String get sets => 'Підходи';

  @override
  String get addSet => 'Додати підхід';

  @override
  String get removeSetTooltip => 'Видалити підхід';

  @override
  String get catalogEntryEyebrow => 'ЗАПИС КАТАЛОГУ';

  @override
  String get destructiveActionEyebrow => 'НЕЗВОРОТНА ДІЯ';

  @override
  String get allLabel => 'Усі';

  @override
  String get tryChangingFilterOrAddExercise =>
      'Спробуйте змінити фільтр або додайте нову вправу';

  @override
  String get sexLabel => 'Стать';

  @override
  String get sexMale => 'Чоловік';

  @override
  String get sexFemale => 'Жінка';

  @override
  String get experienceLevelLabel => 'Рівень досвіду';

  @override
  String get experienceBeginner => 'Початківець';

  @override
  String get experienceIntermediate => 'Середній';

  @override
  String get experienceAdvanced => 'Просунутий';

  @override
  String get primaryGoalLabel => 'Головна ціль';

  @override
  String get goalStrength => 'Сила';

  @override
  String get goalHypertrophy => 'Гіпертрофія';

  @override
  String get goalFatLoss => 'Схуднення';

  @override
  String get goalGeneralFitness => 'Загальний фітнес';

  @override
  String get trainingEnvironmentLabel => 'Місце тренувань';

  @override
  String get envCommercialGym => 'Тренажерний зал';

  @override
  String get envHome => 'Дім';

  @override
  String get envGarage => 'Гараж';

  @override
  String failedToApply(Object error) {
    return 'Не вдалося застосувати: $error';
  }

  @override
  String get useAsProfilePicture => 'Використати як фото профілю';

  @override
  String get describeYourAvatarHint => 'Опишіть свій аватар';

  @override
  String failedWithError(Object error) {
    return 'Помилка: $error';
  }

  @override
  String get generate => 'Згенерувати';

  @override
  String failedToLoadAnalytics(Object error) {
    return 'Не вдалося завантажити аналітику: $error';
  }

  @override
  String get addSeriesTooltip => 'Додати серію';

  @override
  String get clearTooltip => 'Очистити';

  @override
  String failedToApplyReadiness(Object error) {
    return 'Не вдалося застосувати готовність: $error';
  }

  @override
  String get failedToUpdateSetNotReady =>
      'Не вдалося оновити підхід: стан застосунку ще не готовий';

  @override
  String failedToUpdateSet(Object error) {
    return 'Не вдалося оновити підхід: $error';
  }

  @override
  String get deleteExerciseTitle => 'Видалити вправу';

  @override
  String get exerciseRemovedFromWorkout => 'Вправу видалено з тренування';

  @override
  String get errorCannotDeleteUnsavedExercise =>
      'Помилка: не можна видалити незбережену вправу';

  @override
  String failedToRemoveExercise(Object error) {
    return 'Не вдалося видалити вправу: $error';
  }

  @override
  String get cannotAddSetUnsavedExercise =>
      'Не можна додати підхід: вправа ще не збережена';

  @override
  String get setAddedSuccessfully => 'Підхід успішно додано';

  @override
  String failedToAddSet(Object error) {
    return 'Не вдалося додати підхід: $error';
  }

  @override
  String failedToLoadExercises(Object error) {
    return 'Не вдалося завантажити вправи: $error';
  }

  @override
  String get workoutUpdated => 'Тренування оновлено';

  @override
  String failedToUpdateWorkout(Object error) {
    return 'Не вдалося оновити тренування: $error';
  }

  @override
  String get workoutStarted => 'Тренування розпочато';

  @override
  String failedToStartSession(Object error) {
    return 'Не вдалося розпочати сесію: $error';
  }

  @override
  String get sessionCancelled => 'Сесію скасовано';

  @override
  String get workoutFinished => 'Тренування завершено';

  @override
  String failedToFinishSession(Object error) {
    return 'Не вдалося завершити сесію: $error';
  }

  @override
  String get allSetsAlreadyCompleted => 'Усі підходи вже виконано';

  @override
  String failedToCompleteAllSets(Object error) {
    return 'Не вдалося завершити всі підходи: $error';
  }

  @override
  String failedToUpdateSetCompletion(Object error) {
    return 'Не вдалося оновити статус підходу: $error';
  }

  @override
  String get deleteSetTitle => 'Видалити підхід';

  @override
  String get deleteSetConfirmMessage =>
      'Ви впевнені, що хочете видалити цей підхід? Цю дію не можна скасувати.';

  @override
  String get setDeletedSuccessfully => 'Підхід успішно видалено';

  @override
  String failedToDeleteSet(Object error) {
    return 'Не вдалося видалити підхід: $error';
  }

  @override
  String get exerciseAddedSuccessfully => 'Вправу успішно додано';

  @override
  String failedToAddExercise(Object error) {
    return 'Не вдалося додати вправу: $error';
  }

  @override
  String get exerciseUpdatedSuccessfully => 'Вправу успішно оновлено';

  @override
  String errorUpdatingExercise(Object error) {
    return 'Помилка оновлення вправи: $error';
  }

  @override
  String setCountLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ПІДХОДІВ',
      many: '$count ПІДХОДІВ',
      few: '$count ПІДХОДИ',
      one: '1 ПІДХІД',
    );
    return '$_temp0';
  }

  @override
  String get userMaxesTitle => 'Рекорди користувача';

  @override
  String get noMaxesSavedTitle => 'Рекордів ще немає';

  @override
  String get addFirstMaxWeightDescription =>
      'Додайте свою першу максимальну вагу';

  @override
  String get allSessionsLabel => 'Усі сесії';

  @override
  String get resetDatesTooltip => 'Скинути дати';

  @override
  String get collapseCalendarTooltip => 'Згорнути календар';

  @override
  String get selectDateRangeTooltip => 'Вибрати діапазон дат';

  @override
  String get calendarMonthLabel => 'Місяць';

  @override
  String get primaryMetricTrendHeader => 'ОСНОВНА МЕТРИКА (ТРЕНД)';

  @override
  String get trendLabel => 'Тренд';

  @override
  String get exerciseDetailNotFoundDescription =>
      'Не вдалося знайти вказане визначення вправи.';

  @override
  String variantsCountEyebrow(Object count) {
    return 'ВАРІАНТИ · $count';
  }

  @override
  String otherVariantsCountEyebrow(Object count) {
    return 'ІНШІ ВАРІАНТИ · $count';
  }

  @override
  String failedToLoadGroups(Object error) {
    return 'Не вдалося завантажити групи: $error';
  }

  @override
  String deleteExerciseConfirmBody(Object name) {
    return 'Ви впевнені, що хочете видалити \"$name\"?';
  }

  @override
  String get exerciseSpecEyebrow => '01 · ХАРАКТЕРИСТИКИ ВПРАВИ';

  @override
  String get pleaseEnterNameValidation => 'Будь ласка, введіть назву';

  @override
  String prescribedSetsEyebrow(Object count) {
    return '02 · ЗАПЛАНОВАНІ ПІДХОДИ ($count)';
  }

  @override
  String get requiredField => 'Обов\'язково';

  @override
  String setNumberLabel(Object number) {
    return 'ПІДХІД #$number';
  }

  @override
  String get removeExerciseConfirmBody =>
      'Ви впевнені, що хочете видалити цю вправу з тренування?';

  @override
  String allSetsMarkedCompleted(Object count) {
    return 'Усі підходи позначено як виконані ($count)';
  }

  @override
  String markedSetsPartial(Object failed, Object success) {
    return 'Позначено підходів: $success, помилок: $failed';
  }

  @override
  String get myAthletesTitle => 'Мої атлети';

  @override
  String get thresholdsAndFiltersTooltip => 'Пороги та фільтри';

  @override
  String get allSegmentsLabel => 'Усі сегменти';

  @override
  String get recentlyActiveLabel => 'Нещодавно активні';

  @override
  String get sessionsPerWeekLabel => 'Сесій / тижд.';

  @override
  String get adherenceLabel => 'Дотримання';

  @override
  String get visibleMetricLabel => 'ВИДИМО';

  @override
  String get linksMetricLabel => 'ЗВ\'ЯЗКИ';

  @override
  String get avgSessionsPerWeekMetricLabel => 'СЕР. С / ТИЖД.';

  @override
  String get atRiskMetricLabel => 'У ЗОНІ РИЗИКУ';

  @override
  String get rosterFiltersEyebrow => 'ФІЛЬТРИ СКЛАДУ';

  @override
  String get thresholdsFilterTitle => 'Пороги та фільтри';

  @override
  String get resetLabel => 'Скинути';

  @override
  String get doneLabel => 'Готово';

  @override
  String get viewDetailedAnalyticsLabel => 'Детальна аналітика';

  @override
  String get sessionsUpperLabel => 'СЕСІЇ';

  @override
  String get sessionsPerWeekUpperLabel => 'С / ТИЖД.';

  @override
  String get planPercentUpperLabel => 'ПЛАН %';

  @override
  String get rpeDistributionUpperLabel => 'РОЗПОДІЛ RPE';

  @override
  String get allUsersTitle => 'Усі користувачі';

  @override
  String get filterCoachesLabel => 'Фільтр тренерів';

  @override
  String get coachDirectoryEyebrow => 'КАТАЛОГ ТРЕНЕРІВ';

  @override
  String get filterCoachesTitle => 'Фільтр тренерів';

  @override
  String get allUsersPillLabel => 'Усі користувачі';

  @override
  String get coachesOnlyPillLabel => 'Лише тренери';

  @override
  String get filtersActiveLabel => 'Фільтри · Активні';

  @override
  String get showingUpperLabel => 'ПОКАЗАНО';

  @override
  String get publicUpperLabel => 'ПУБЛІЧНІ';

  @override
  String get coachesUpperLabel => 'ТРЕНЕРИ';

  @override
  String get sortUpperLabel => 'СОРТУВАННЯ';

  @override
  String get minRateUsdLabel => 'Мін. ставка (\$)';

  @override
  String get maxRateUsdLabel => 'Макс. ставка (\$)';

  @override
  String get sortByLabel => 'Сортувати за';

  @override
  String get sortCreatedAt => 'Датою створення';

  @override
  String get sortRating => 'Рейтингом';

  @override
  String get sortLastActive => 'Останньою активністю';

  @override
  String get applyFiltersLabel => 'Застосувати фільтри';

  @override
  String get volumeUpperLabel => 'ОБСЯГ';

  @override
  String get sessPerWeekUpperLabel => 'СЕСІЙ / ТИЖД.';

  @override
  String get intensityUpperLabel => 'ІНТЕНСИВНІСТЬ';

  @override
  String get avgRpeUpperLabel => 'СЕР. RPE';

  @override
  String get lastDayUpperLabel => 'ОСТ. ДЕНЬ';

  @override
  String get daysGapUpperLabel => 'ПЕРЕРВА (ДН.)';

  @override
  String get crmTitle => 'CRM';

  @override
  String get activeUpperLabel => 'АКТИВНІ';

  @override
  String get engagedUpperLabel => 'ЗАЛУЧЕНІ';

  @override
  String get inactiveUpperLabel => 'НЕАКТИВНІ';

  @override
  String get viewAthletesListLabel => 'Список атлетів';

  @override
  String get relationshipsAndChatLabel => 'Зв\'язки та чат';

  @override
  String get lastUpperLabel => 'ОСТ.';

  @override
  String get planUpperLabel => 'ПЛАН';

  @override
  String get relationshipEyebrow => 'ЗВ\'ЯЗОК';

  @override
  String failedToSendError(Object error) {
    return 'Не вдалося надіслати: $error';
  }

  @override
  String get typeMessageHint => 'Введіть повідомлення...';

  @override
  String get sendMessageTooltip => 'Надіслати повідомлення';

  @override
  String get adherenceUpperLabel => 'ДОТРИМАННЯ';

  @override
  String get startUpperLabel => 'ПОЧАТОК';

  @override
  String get endUpperLabel => 'КІНЕЦЬ';

  @override
  String get workoutNotesEyebrow => 'НОТАТКИ ТРЕНУВАННЯ';

  @override
  String get removeExerciseEyebrow => 'ВИДАЛЕННЯ ВПРАВИ';

  @override
  String get exerciseEditorEyebrow => 'РЕДАКТОР ВПРАВИ';

  @override
  String get massEditLabel => 'Масове редагування';

  @override
  String get myCoachesTitle => 'Мої тренери';

  @override
  String get analyticsLabel => 'Аналітика';

  @override
  String get chatLabel => 'Чат';

  @override
  String get subscribeLabel => 'Підписатися';

  @override
  String get invalidCheckoutUrl => 'Некоректне посилання для оплати';

  @override
  String get cannotOpenCheckoutUrl =>
      'Не вдалося відкрити посилання для оплати';

  @override
  String get profileTitle => 'Профіль';

  @override
  String get coachingRequestEyebrow => 'ЗАПИТ НА ТРЕНЕРСТВО';

  @override
  String requestCoachingFromTitle(Object name) {
    return 'Запит на тренерство до $name';
  }

  @override
  String get messageOptionalLabel => 'Повідомлення (необов\'язково)';

  @override
  String get sendLabel => 'Надіслати';

  @override
  String get requestSentMessage => 'Запит надіслано';

  @override
  String get writeReviewLabel => 'Написати відгук';

  @override
  String cannotReviewError(Object error) {
    return 'Не вдалося залишити відгук: $error';
  }

  @override
  String get workoutFeedTitle => 'Стрічка тренувань';

  @override
  String get allPostsLabel => 'Усі дописи';

  @override
  String get withStatsLabel => 'Зі статистикою';

  @override
  String get likedLabel => 'Уподобані';

  @override
  String get createPostLabel => 'Створити допис';

  @override
  String get socialFeedEyebrow => 'СОЦІАЛЬНА СТРІЧКА';

  @override
  String get visibilityUpperLabel => 'ВИДИМІСТЬ';

  @override
  String get visibilityPublic => 'Публічний';

  @override
  String get visibilityFollowers => 'Підписники';

  @override
  String get visibilityPrivate => 'Приватний';

  @override
  String get postLabel => 'Опублікувати';

  @override
  String get likeLabel => 'Подобається';

  @override
  String errorLoadingItems(Object error) {
    return 'Помилка завантаження елементів: $error';
  }

  @override
  String addItemTitle(Object name) {
    return 'Додати $name';
  }

  @override
  String get itemGenericName => 'Елемент';

  @override
  String dosageWithUnitLabel(Object unit) {
    return 'Дозування ($unit)';
  }

  @override
  String get addLabel => 'Додати';

  @override
  String genericError(Object error) {
    return 'Помилка: $error';
  }

  @override
  String get sessionConfigurationTitle => 'Налаштування сесії';

  @override
  String get sessionIdLabel => 'ID сесії';

  @override
  String get workoutIdOptionalLabel => 'ID тренування (необов\'язково)';

  @override
  String get appliedPlanWorkoutIdOptionalLabel =>
      'ID тренування плану (необов\'язково)';

  @override
  String get selectedEntriesTitle => 'Вибрані записи';

  @override
  String get availableItemsTitle => 'Доступні елементи';

  @override
  String get removeEntryTooltip => 'Видалити запис';

  @override
  String get addEntryTooltip => 'Додати запис';

  @override
  String get deleteSessionTitle => 'Видалити сесію';

  @override
  String get deleteSessionConfirm =>
      'Ви впевнені, що хочете видалити цю сесію?';

  @override
  String get sessionDeletedSuccess => 'Сесію успішно видалено';

  @override
  String get editSessionTooltip => 'Редагувати сесію';

  @override
  String get deleteSessionTooltip => 'Видалити сесію';

  @override
  String get kcalUpperLabel => 'ККАЛ';

  @override
  String get proteinUpperLabel => 'БІЛКИ';

  @override
  String get fatUpperLabel => 'ЖИРИ';

  @override
  String get carbUpperLabel => 'ВУГЛЕВОДИ';

  @override
  String get activeNutritionPlanTitle => 'Активний план харчування';

  @override
  String get noActiveCalendarPlan => 'Немає активного календарного плану';

  @override
  String get noNutritionPlanConfigured => 'План харчування не налаштовано';

  @override
  String get createSessionTooltip => 'Створити сесію';

  @override
  String failedToLoadNutritionSessions(Object error) {
    return 'Не вдалося завантажити сесії харчування: $error';
  }

  @override
  String get createSessionButton => 'Створити сесію';

  @override
  String get pleaseEnterPlanName => 'Введіть назву плану';

  @override
  String get planCreatedSuccess => 'План успішно створено';

  @override
  String failedToCreatePlan(Object error) {
    return 'Не вдалося створити план: $error';
  }

  @override
  String get createCalendarPlanTitle => 'Створити календарний план';

  @override
  String get planNameLabel => 'Назва плану';

  @override
  String get addMesocycleLabel => 'Додати мезоцикл';

  @override
  String get removeMesocycleTooltip => 'Видалити мезоцикл';

  @override
  String get mesocycleNameLabel => 'Назва мезоциклу';

  @override
  String get microcyclesLabel => 'Мікроцикли';

  @override
  String get microcycleLengthDaysLabel => 'Тривалість мікроциклу (дні)';

  @override
  String get addExerciseLabel => 'Додати вправу';

  @override
  String get planAppliedSuccess => 'План успішно застосовано';

  @override
  String get applyPlanButton => 'Застосувати план';

  @override
  String get noPlanWorkoutsAvailable => 'Немає доступних тренувань плану';

  @override
  String get removeRuleEyebrow => 'ВИДАЛИТИ ПРАВИЛО';

  @override
  String get deleteMacroTitle => 'Видалити макрос';

  @override
  String get planMacrosTitle => 'Макроси плану';

  @override
  String get previewApplyTooltip => 'Перегляд / Застосування';

  @override
  String get addMacroLabel => 'Додати макрос';

  @override
  String get noMacrosYet => 'Макросів ще немає';

  @override
  String allCountLabel(Object count) {
    return 'Усі ($count)';
  }

  @override
  String get noMatchingMacros => 'Немає відповідних макросів';

  @override
  String get switchFilterToViewRules =>
      'Перемкніть фільтр вище, щоб переглянути правила.';

  @override
  String get macroSuggestionsEyebrow => 'РЕКОМЕНДАЦІЇ МАКРОСІВ';

  @override
  String get sessionHistoryTitle => 'Історія сесій';

  @override
  String get loadSessionsLabel => 'Завантажити сесії';

  @override
  String get clearFilterLabel => 'Очистити фільтр';

  @override
  String errorLoadingHistory(Object error) {
    return 'Помилка завантаження історії: $error';
  }

  @override
  String get noSessionsFound => 'Сесій не знайдено';

  @override
  String get tryChangingYourFilter => 'Спробуйте змінити фільтр';

  @override
  String sessionNumberTitle(Object id) {
    return 'Сесія #$id';
  }

  @override
  String get workoutIdUpperLabel => 'ID ТРЕНУВАННЯ';

  @override
  String get statusUpperLabel => 'СТАТУС';

  @override
  String get startedUpperLabel => 'ПОЧАТО';

  @override
  String get finishedUpperLabel => 'ЗАВЕРШЕНО';

  @override
  String get durationUpperLabel => 'ТРИВАЛІСТЬ';

  @override
  String get noExerciseDataForWorkout =>
      'Немає даних про вправи для цього тренування';

  @override
  String get repsUpperLabel => 'ПОВТОРИ';

  @override
  String get plannedUpperLabel => 'ПЛАН';

  @override
  String get actualUpperLabel => 'ФАКТ';

  @override
  String get thresholdsLabel => 'Пороги';

  @override
  String get rosterTelemetryEyebrow => 'ТЕЛЕМЕТРІЯ СКЛАДУ';

  @override
  String minSessionsPerWeekSliderLabel(Object value) {
    return 'Мін. сесій / тижд.: $value';
  }

  @override
  String minAdherenceSliderLabel(Object percent) {
    return 'Мін. дотримання: $percent%';
  }

  @override
  String get workflowsChannelsEyebrow => 'ПРОЦЕСИ · КАНАЛИ';

  @override
  String get userIdFieldLabel => 'ID користувача';
}
