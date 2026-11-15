# Screen Design Guide

Цей документ описує основні UI-концепти, які використовуються в проєкті. Дотримуйтесь цих правил при створенні нових екранів, щоб зберігати єдиний стиль застосунку.

---

## 1. Каркас екрана (`AssistantChatHost` + `AmbientScaffoldShell` + Detached Orb/Pill Chrome)

Будь-який прикладний екран має бути обгорнутий у `AssistantChatHost` (для глобального AI-асистента та `contextBuilder`) і рендеритись усередині наскрізної реактивної оболонки `AmbientScaffoldShell` (`extendBodyBehindAppBar: true`, `extendBody: true`).

### Стандартний шаблон (3-Layer Spatial Instrument)

```dart /dev/null/template.dart#L1-48
@override
Widget build(BuildContext context) {
  final env = ref.watch(ambientEnvironmentProvider);
  final layout = ref.watch(interfaceMakerProvider);

  return AssistantChatHost(
    contextBuilder: () async => {
      'screen': 'calendar_plan_detail',
      'entities': {'plan_id': widget.plan.id},
    },
    builder: (context, openChat) {
      return AmbientScaffoldShell(
        environment: env,
        appBar: PrimaryAppBar.detail(
          title: widget.plan.name,
          onTitleTap: openChat,
          actions: [
            IconButton(
              icon: const Icon(Icons.grid_view_rounded),
              tooltip: 'Сетка и метрики',
              onPressed: () => InterfaceMakerSheet.show(context),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              // Layer 1: Canvas-level floating pill strip (без внешней карточки!)
              SliverToBoxAdapter(child: CanvasPillStrip(...)),
              // Layer 2: Самодостаточные модули с 1 внешним контуром (Max Border Depth = 1)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: UiDimensions.of(context).pagePadding),
                sliver: SliverList.list(
                  children: [
                    // Модули рендерятся согласно порядку в InterfaceMakerProvider
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
```

### Правила
- **Заборонено глухі плашки `#202A2D` (`AppColors.darkChrome`):** `PrimaryAppBar`, `FloatingHeaderBar` та `CustomBottomNavBar` працюють як парячі напівпрозорі скляні орби (`40×40`) та капсули (`borderRadius: 999`, `BackdropFilter`) поверх єдиного полотна `AmbientScaffoldShell`.
- **Заборонено зовнішні заголовки секцій із квадратними іконками між картками:** не створюйте рядки `[Boxed Icon] Active Plan` над картками. Кожен `InstrumentCard` сам містить власний внутрішній eyebrow, великий заголовок та індикатор фази.
- **Max Border Depth = 1 (`Zero Nested Boxes`):** усередині `InstrumentCard` заборонено обгортати метрики, теги обладнання, перемикачі чи фільтри у вкладені контейнери з `BoxDecoration(border: ...)`.

---

## 2. Кольорова й типографічна системи

У білді отримуйте `colorScheme` та `textTheme` через `Theme.of(context)`:

```dart /dev/null/template.dart#L1-3
final colorScheme = Theme.of(context).colorScheme;
final textTheme = Theme.of(context).textTheme;
```

Для констант використовуйте `lib/config/constants/theme_constants.dart`:
- **Кольори**: `AppColors.primary`, `AppColors.error`
- **Типографіка**: `AppTextStyles.titleLarge`
- **Геометрія екрана**: `UiDimensions.of(context)` з `lib/config/theme/ui_dimensions.dart`
- **Радіуси**: `AppBorderRadius.lg` (16.0)

> ⚠️ Не використовуйте `Colors.red`, `Colors.grey` напряму — беріть із теми (`colorScheme.error`, `colorScheme.onSurfaceVariant`), інакше зламається dark mode.

### Щільність інтерфейсу

Для повторюваної геометрії використовуйте ролі `UiDimensions.of(context)`:

```dart
final dimensions = UiDimensions.of(context);
return Padding(
  padding: EdgeInsets.all(dimensions.pagePadding),
  child: Card(
    child: Padding(
      padding: EdgeInsets.all(dimensions.cardPadding),
      child: content,
    ),
  ),
);
```

`pagePadding` задає зовнішній край екрана, `cardPadding` — вміст картки, `sectionGap` — відстань між блоками, `rowGap` — між рядками та елементами в одному блоці. Для щільних таблиць використовуйте `densePagePadding` і `denseCardPadding`. Обидві теми отримують ті самі розміри; вибір `Compact` / `Comfortable` зберігається в загальних налаштуваннях.

Залишайте локальні розміри для графіків, індикаторів і областей натискання, якщо вони випливають із вмісту або вимог доступності. Не зменшуйте системний масштаб тексту чи область натискання заради компактності.

---

## 3. Стани екрана (Loading, Error, Empty, Data)

Кожен екран зі завантаженням даних має чітко відображати стани:

- **Loading**: `const LoadingIndicator();`
- **Error**: 
  ```dart /dev/null/template.dart#L1-5
  ErrorState(
    message: 'Не вдалось завантажити дані: $error',
    onRetry: _load,
  );
  ```
- **Empty**:
  ```dart /dev/null/template.dart#L1-5
  const EmptyState(
    icon: Icons.fitness_center,
    title: 'Немає даних',
    description: 'Створіть перший запис',
  );
  ```

---

## 4. Списки, Картки та Складні Скроли

### 4.1 Прості списки
- Зовнішній скрол — `ListView` з `padding: EdgeInsets.symmetric(vertical: 12)`.
- «Вкладені» списки — `ListView.builder` з `shrinkWrap: true` та `physics: NeverScrollableScrollPhysics()`.

### 4.2 Складні скроли (Slivers)
Якщо екран має складну шапку (яка має ховатися) або комбінацію сіток (`GridView`) та списків, використовуйте `CustomScrollView`:

```dart /dev/null/template.dart#L1-10
CustomScrollView(
  slivers: [
    SliverToBoxAdapter(child: HeroCard()),
    SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(...),
      ),
    ),
  ],
)
```

### 4.3 Рядок списку
```dart /dev/null/template.dart#L1-6
ListTile(
  title: Text(item.name),
  subtitle: Text('Опис', style: TextStyle(color: colorScheme.onSurfaceVariant)),
  trailing: const Icon(Icons.chevron_right),
  onTap: _open,
);
```

---

## 5. Діалоги та Повноекранні Форми

### 5.1 Прості форми (Діалоги)
Для швидкого створення (1-2 поля) використовуйте `showDialog` + `AlertDialog` + `StatefulBuilder`.

### 5.2 Складні форми (Повноекранні)
Для сутностей з багатьма полями (наприклад, редактор плану) створюйте окремий екран із використанням `Form`:

```dart /dev/null/template.dart#L1-18
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: 'Назва', border: OutlineInputBorder()),
        validator: (value) => value?.isEmpty == true ? 'Обовʼязкове поле' : null,
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _save();
          }
        },
        child: const Text('Зберегти'),
      )
    ],
  ),
)
```
*Правило:* Завжди додавайте `FocusScope.of(context).unfocus();` при збереженні, щоб сховати клавіатуру.

---

## 6. State Management та Завантаження даних (Riverpod)

Нові екрани в проєкті використовують **Riverpod** (замість старого `Provider`). 

```dart /dev/null/template.dart#L1-20
class MyScreen extends ConsumerStatefulWidget {
  const MyScreen({super.key});
  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  bool _isLoading = false;

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      // Використовуємо ref.read для доступу до сервісів
      final service = ref.read(myServiceProvider);
      final data = await service.getData();
      // ...
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
```

*Правила:*
- Наслідуйтесь від `ConsumerStatefulWidget` або `ConsumerWidget`.
- Сервіси отримуйте через `ref.read(providerName)` у методах або `ref.watch(providerName)` у `build`.
- Завжди перевіряйте `if (mounted)` після `await`.

---

## 7. Навігація та Таби

- **Перехід на деталь**: `await Navigator.push<bool>(...)`. Якщо повертається `true`, викликаємо `_refresh()`.
- **Повернення результату**: `Navigator.pop(context, true)`.
- **Кореневі екрани з Bottom Navigation**: Не повинні мати кнопки «Назад» у `PrimaryAppBar` (використовуйте `.main`).

---

## 8. Сповіщення користувача

- Успіх/Помилка: `ScaffoldMessenger.of(context).showSnackBar(...)`.
- Деструктивні дії (видалення): обов'язкове підтвердження через `showDialog` з двома кнопками.

---

## 9. Чек-лист нового екрана

1. [ ] Огорнутий у `AssistantChatHost`? (Чи передано `contextBuilder` для складних екранів?)
2. [ ] Використовує `PrimaryAppBar` (а не стандартний `AppBar`)?
3. [ ] Тіло підтримує скрол (напр. `ListView` або `CustomScrollView`)?
4. [ ] Реалізовано 4 стани: loading / error / empty / data?
5. [ ] Використовуються `Theme.of(context)` та `AppColors`/`AppSpacing`, а не хардкод кольорів?
6. [ ] Використовується **Riverpod** (`ConsumerStatefulWidget`, `ref.read`) для нових екранів?
7. [ ] Перед `setState`/`Navigator` після `await` є перевірка `mounted`?
8. [ ] Контролери (`TextEditingController`) диспозяться у `dispose()`?
9. [ ] Повноекранні форми використовують `Form` та `TextFormField` з валідацією?
10. [ ] Деталь-екрани повертають `true` при змінах, щоб батьківський список оновився?

---

## 10. Стратегия UI/UX-рефакторинга: «Adaptive Training Instrument»

Концепция объединяет точность инструментальной визуализации (**Tide Guide**) и контекстную адаптивность (**CARROT Weather**), адаптированную под силовые тренировки.

### Приоритетные экраны первой волны
1. **Тренировки (входная точка и выполнение):** `workouts_screen.dart` (`workout_list_screen.dart`) и `workout_detail_screen.dart`.
2. **Планы (выбор, структура и ведение мезоцикла):** `calendar_plans_screen.dart`, `calendar_plan_detail.dart` и `active_plan_screen.dart`.
3. **Аналитика:** `analytics_screen.dart` и общий виджет `plan_analytics_chart.dart`.

---

### Блок А. Три функциональных режима экранов
1. **Execution Mode (Активная тренировка и ввод подходов — `workout_detail_screen.dart`, `plan_editor_screen.dart`)**
   - Приоритет №1 — скорость и безошибочность ввода одной рукой между подходами.
   - Максимальный контраст, области касания `>= 48×48dp` (даже в `UiDensity.compact`), минимум отвлекающих элементов, мгновенный отклик полей треугольника `Weight / Reps / RPE`.
2. **Overview / Explore Mode (Главные списки и детали планов — `workouts_screen.dart`, `calendar_plans_screen.dart`, `calendar_plan_detail.dart`, `active_plan_screen.dart`)**
   - Прогрессивное раскрытие (`Progressive disclosure`): на первом уровне — главный контекст (текущая/следующая тренировка по плану, ключевые параметры плана, статус сессии), второстепенные детали — по раскрытию или переходу.
   - Контекстные карточки состояния вместо декоративных баннеров-заглушек.
3. **Analysis Mode (Аналитика — `analytics_screen.dart`, `plan_analytics_chart.dart`)**
   - График — главная интерактивная поверхность, а не вторичная иллюстрация под громоздкими фильтрами.
   - Паттерн **Data Point Picker**: реактивное переключение метрик (`volume`, `effort`, `kpsh`, `reps`, `1rm`) чипами/сегментами без кнопки «Показать график» и компактный свёрнутый выбор диапазона дат.

---

### Блок Б. Честность данных (`Data Provenance`) и `Chart Grammar`
1. **Различать происхождение данных (`Provenance`)**
   - **В подходах (`Weight / Reps / RPE` из `rpe_table.dart`):** визуально разводить значения, введённые атлетом вручную (`user_reported`), и значения, автоматически вычисленные таблицей RPE (`auto_derived` — через специальный тонированный стиль ячейки, микро-бейдж или пунктирную индикацию).
   - **На графиках (`values` vs `actualValues`):** чётко разводить **План** (приглушённая линия / пунктир / полые точки) и **Факт** (контрастная сплошная линия / залитые точки).
2. **Контракт графиков (`Chart Grammar`)**
   - Тренировочные измерения дискретны: всегда показывать точки реальных тренировок (`FlDotData(show: true)`), не скрывать точки при `spots.length >= 2` и не использовать сглаживание сплайнами без защиты от ложных выбросов (`preventCurveOverShooting: true`).
   - `0 != null`: нулевая нагрузка / день отдыха и отсутствие данных (`null`) семантически различны (запрещена слепая фильтрация `v != 0.0`).
   - Единая библиотека рендеринга графиков — `fl_chart` (неиспользуемый `syncfusion_flutter_charts` подлежит удалению).

---

### Блок В. Архитектурные инварианты при UI-рефакторинге
1. **Неприкосновенность бизнес-логики:** формулы `RpeTable` / `rpe_service.dart`, правила автозаполнения треугольника `weight/reps/RPE`, логика `Readiness` и API-контракты не изменяются в рамках визуального рефакторинга без отдельной задачи.
2. **Сохранение системного каркаса:** обязательны `AssistantChatHost` (с актуальным `contextBuilder`), `PrimaryAppBar`, геометрия через `UiDimensions.of(context)` (`compact` / `comfortable`) и прохождение `test/responsive_layout_test.dart` (ширина `320px` + увеличенный системный шрифт).

---

### Блок Г. Визуальный язык UI (Instrument Aesthetics)
1. **Инструментальная типографика (Tide Guide Precision)**
   - Обязательное использование моноширинных цифр `FontFeature.tabularFigures()` для всех числовых показателей: вес, повторы, RPE, КПШ, тоннаж, таймер сессии (`00:14:22`), коэффициенты готовности (`x1.00`).
   - Высокий контраст пары «Число + Микро-лейбл»: крупные плотные цифры (`FontWeight.w700`, `letterSpacing: -0.5`) в паре с компактными uppercase-метками (`10–11px`, `FontWeight.w700`, `letterSpacing: 0.8`, цвет `onSurfaceVariant`).
2. **Поверхности и границы вместо размытых теней**
   - Отказ от тяжёлых теней (`BoxShadow(color: Colors.black12)`) и случайных захардкоженных цветов (`#E8ECFF`, `#4CAF50`, персиковых градиентов-заглушек) в пользу чистой слоистой геометрии: `surfaceContainerLow` / `surfaceContainer` + тонкая `1px` граница `outlineVariant.withValues(alpha: 0.45)`.
   - Согласование палитры `PrimaryAppBar` / `CustomBottomNavBar` с карточками контента.
3. **Дизайн таблиц подходов и контролов (`Instrument Controls`)**
   - Вместо слипшихся `TextField` с тяжёлыми `OutlineInputBorder` — структурированная строка-капсула подхода с явными отступами между колонками `SET`, `WEIGHT`, `REPS`, `RPE`, чистыми pill-ячейками ввода (`surfaceContainerHighest` в покое, акцентная рамка `1.5px` в фокусе) и наглядным переходом строки в состояние `Completed`.
4. **Семантическая цветовая шкала нагрузки (RPE & Readiness Spectrum)**
   - Единая температурная палитра интенсивности/усилия (через `ThemeExtension`), работающая и в светлой, и в тёмной теме:
     - Лёгкая/умеренная зона (`RPE <= 7`): спокойный бирюзово-синий / стальной.
     - Рабочая/целевая зона (`RPE 7.5–8.5`): насыщенный изумрудный / янтарный.
     - Предельная зона (`RPE 9–10`): кораллово-красный акцент.

---

## 11. Обязательная архитектура синтеза: `CARROT Ambient Environment` × `CARROT Interface Maker` × `Tide Guide Spatial Precision`

> **ВНИМАНИЕ (Разморожено и обязательно к исполнению):** Эти системы являются **ядром архитектуры экранов**, а не косметическими надстройками. Запрещено реализовывать их через поверхностные врезки в старые деревья `ListView`.

1. **Пространственная дисциплина (Tide Guide Spatial Precision):**
   - **Detached Orb & Pill Chrome:** Верхний бар (`PrimaryAppBar` / `FloatingHeaderBar`) рендерится как отдельные парящие круглые стеклянные кнопки (`40×40`) по краям и компактная полупрозрачная капсула заголовка/чата по центру поверх радиального свечения `AmbientScaffoldShell`. Нижний док (`CustomBottomNavBar`) — парящая полупрозрачная капсула (`borderRadius: 999`, `extendBody: true`), под которой прокручивается контент.
   - **Bleed-to-Edge Telemetry & Zero Nested Boxes:** Внутри карточки `InstrumentCard` (`borderRadius: 22`, единственный внешний контур `1px`) график `fl_chart` растягивается от левой до правой стенки карточки без боковых отступов (`horizontal padding: 0`), а под ним располагаются тонкие hairline-строки статуса и открытая 4-колоночная матрица `InstrumentMetricMatrix` (`Data Point Picker`) без единой вложенной рамки.
2. **Реактивная фоновая среда (`CARROT Ambient Environment` — `lib/providers/ambient_environment_provider.dart`):**
   - Вычисляет физиологическое состояние `TrainingEnvironmentState` (`deload`, `workingVolume`, `cnsStorm`, `liveExecution`) из реальных подходов (RPE, `% 1RM`, активный таймер сессии).
   - Управляет обсидиановым полотном (`#0A0E14`), верхним радиальным куполом свечения, акцентным контуром главной карточки, цветом кривой графика и генерацией контекстной тактической/дерзкой сводки (`Command Briefing`).
   - В режиме `liveExecution` и при `MediaQuery.disableAnimations` отключает декоративные градиенты и анимации ради максимального контраста ввода одной рукой.
3. **Конструктор интерфейса и метрик (`CARROT Interface Maker` — `lib/providers/interface_maker_provider.dart`):**
   - Управляет как 4 слотами метрик (`MetricSlot`) в `InstrumentMetricMatrix`, так и **порядком/видимостью модулей самого экрана (`LayoutModule`)** с сохранением в `SharedPreferences`.
   - Поддерживает пресеты `Powerlifter (5/3/1)`, `Volume / Hypertrophy`, `Minimalist` (сворачивает графики и вторичные блоки в компактный пульт) и `Custom` через `InterfaceMakerSheet` (`⊞ Сетка`).

