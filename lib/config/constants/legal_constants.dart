import 'package:flutter/material.dart';

enum LegalDocumentType {
  privacy,
  terms,
  healthDisclaimer,
}

/// Centralized configuration for operator/controller details.
/// Keep placeholders until production legal entity / sole proprietorship (ИП/ФОП/LLC)
/// details are ready to be published.
class LegalConfig {
  const LegalConfig._();

  static const String appName = 'Workout App';
  static const String policyVersion = '1.0.0';
  static const String lastUpdatedDate = '2026-11-14';

  // Non-sensitive placeholders — replace before production release:
  static const String operatorName = '[Operator / Legal Entity Name]';
  static const String registeredAddress = '[Registered Address]';
  static const String privacyEmail = 'privacy@workoutapp.example';
  static const String supportEmail = 'support@workoutapp.example';
  static const String governingJurisdiction = '[Applicable Jurisdiction]';
  static const int minimumAgeYears = 16;

  static bool get hasPlaceholders =>
      operatorName.startsWith('[') ||
      registeredAddress.startsWith('[') ||
      governingJurisdiction.startsWith('[') ||
      privacyEmail.endsWith('.example');
}

@immutable
class LegalTableRowData {
  final String col1;
  final String col2;
  final String col3;
  final String? col4;

  const LegalTableRowData({
    required this.col1,
    required this.col2,
    required this.col3,
    this.col4,
  });
}

@immutable
class LegalSectionData {
  final String number;
  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
  final List<String>? tableHeaders;
  final List<LegalTableRowData>? tableRows;
  final bool isHighlightedWarning;

  const LegalSectionData({
    required this.number,
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
    this.tableHeaders,
    this.tableRows,
    this.isHighlightedWarning = false,
  });
}

@immutable
class LegalDocumentData {
  final LegalDocumentType type;
  final String title;
  final String shortTitle;
  final String subtitle;
  final String tldrTitle;
  final List<String> tldrPoints;
  final List<LegalSectionData> sections;
  final String footerNote;

  const LegalDocumentData({
    required this.type,
    required this.title,
    required this.shortTitle,
    required this.subtitle,
    required this.tldrTitle,
    required this.tldrPoints,
    required this.sections,
    required this.footerNote,
  });
}

class LegalDocumentsRepository {
  const LegalDocumentsRepository._();

  static String resolveLanguageCode(Locale? locale) {
    final code = locale?.languageCode.toLowerCase() ?? 'en';
    if (code == 'uk' || code == 'ua') return 'uk';
    if (code == 'ru') return 'ru';
    return 'en';
  }

  static LegalDocumentData getDocument(
    LegalDocumentType type,
    String languageCode,
  ) {
    switch (type) {
      case LegalDocumentType.privacy:
        return _privacyPolicy(languageCode);
      case LegalDocumentType.terms:
        return _termsOfService(languageCode);
      case LegalDocumentType.healthDisclaimer:
        return _healthDisclaimer(languageCode);
    }
  }

  static List<LegalDocumentData> getAllDocuments(String languageCode) {
    return [
      getDocument(LegalDocumentType.privacy, languageCode),
      getDocument(LegalDocumentType.terms, languageCode),
      getDocument(LegalDocumentType.healthDisclaimer, languageCode),
    ];
  }

  // ---------------------------------------------------------------------------
  // 1. PRIVACY POLICY (Grounded in actual codebase + GDPR / App Store / Play)
  // ---------------------------------------------------------------------------
  static LegalDocumentData _privacyPolicy(String lang) {
    if (lang == 'ru') {
      return const LegalDocumentData(
        type: LegalDocumentType.privacy,
        title: 'Политика конфиденциальности',
        shortTitle: 'Конфиденциальность',
        subtitle:
            'Как ${LegalConfig.appName} собирает, использует и защищает ваши данные (GDPR / CCPA / App Store & Google Play)',
        tldrTitle: 'Коротко о главном (TL;DR)',
        tldrPoints: [
          'Мы собираем только те данные, которые нужны для работы приложения: профиль, дневник тренировок, планы, питание и настройки.',
          'Антропометрия (вес, рост, возраст, пол) и записи о питании/добавках заполняются добровольно для расчёта нагрузок (RPE, 1RM) и прогресса.',
          'Платежи за коучинг обрабатываются напрямую через Stripe — мы не храним номера банковских карт.',
          'Мы НЕ продаём ваши персональные данные третьим лицам и не передаём их рекламным сетям.',
          'Вы можете в любой момент удалить свой аккаунт и все данные прямо в приложении: Настройки → Общие → Удалить аккаунт.',
        ],
        sections: [
          LegalSectionData(
            number: '1',
            title: 'Кто мы (Оператор / Контроллер данных)',
            paragraphs: [
              'Оператором (контроллером) ваших персональных данных в приложении ${LegalConfig.appName} является ${LegalConfig.operatorName} («мы», «нас», «наш»).',
              'Адрес для корреспонденции: ${LegalConfig.registeredAddress}.\nПо всем вопросам конфиденциальности и защиты данных: ${LegalConfig.privacyEmail}.',
            ],
          ),
          LegalSectionData(
            number: '2',
            title: 'Какие данные мы собираем и откуда',
            paragraphs: [
              'В соответствии со ст. 13–14 GDPR и требованиями Apple App Store / Google Play Data Safety мы перечисляем только те категории данных, которые реально обрабатываются в коде приложения:',
            ],
            tableHeaders: [
              'Категория',
              'Примеры данных в приложении',
              'Источник',
            ],
            tableRows: [
              LegalTableRowData(
                col1: 'Аккаунт и вход',
                col2:
                    'UID пользователя, email, отображаемое имя (displayName), фото профиля (photoUrl), токены сессии.',
                col3: 'Напрямую от вас / через Firebase Auth и Google Sign-In',
              ),
              LegalTableRowData(
                col1: 'Параметры тела и фитнес-профиль',
                col2:
                    'Вес (bodyweightKg), рост (heightCm), возраст, пол, стаж и уровень тренировок, основная цель, условия тренировок.',
                col3: 'Напрямую от вас (заполняется добровольно)',
              ),
              LegalTableRowData(
                col1: 'Тренировки, планы и максимумы',
                col2:
                    'Упражнения, подходы, повторения, рабочие веса, RPE, 1RM (userMax), мезо- и микроциклы, календарные планы, импортированные файлы тренировок.',
                col3: 'Напрямую от вас / при работе с планами',
              ),
              LegalTableRowData(
                col1: 'Дневник питания и добавок',
                col2:
                    'Записи приёмов пищи (Food), спортивных добавок (Supplements) и медикаментов/витаминов (Medications) с дозировками и датами.',
                col3: 'Напрямую от вас (опциональный модуль)',
              ),
              LegalTableRowData(
                col1: 'Коучинг и социальные функции',
                col2:
                    'Статус публичного профиля (isPublic), анкета тренера (описание, специализации, языки, тариф), связки тренер–атлет, сообщения в чате и отзывы.',
                col3: 'Напрямую от вас при использовании коучинга',
              ),
              LegalTableRowData(
                col1: 'Платежи тренерам (Stripe Connect)',
                col2:
                    'Идентификатор аккаунта Stripe Connect (у тренеров), статус прямой подписки атлета на тренера и сессии оплаты. Данные карт обрабатывает исключительно Stripe.',
                col3: 'Платёжный провайдер Stripe',
              ),
              LegalTableRowData(
                col1: 'Диалоги с AI-ассистентом',
                col2:
                    'Текстовые запросы в чате ассистента и контекст активного тренировочного плана для генерации подсказок или массового редактирования плана.',
                col3: 'Напрямую от вас при обращении к AI-чату',
              ),
              LegalTableRowData(
                col1: 'Технические данные и аналитика',
                col2:
                    'События использования экранов и функций (Amplitude), настройки темы, плотности интерфейса, часового пояса и языка (SharedPreferences).',
                col3: 'Автоматически при работе приложения',
              ),
            ],
          ),
          LegalSectionData(
            number: '3',
            title: 'Цели обработки и правовые основания (GDPR Art. 6 и Art. 9)',
            paragraphs: [
              'Мы обрабатываем ваши данные строго для указанных ниже целей и только при наличии законного основания:',
            ],
            tableHeaders: [
              'Цель обработки',
              'Правовое основание (GDPR)',
              'Срок хранения',
            ],
            tableRows: [
              LegalTableRowData(
                col1:
                    'Создание аккаунта, синхронизация тренировок, планов и работа чата с тренером',
                col2: 'Исполнение договора (Art. 6(1)(b) GDPR)',
                col3: 'До удаления аккаунта пользователем',
              ),
              LegalTableRowData(
                col1:
                    'Хранение антропометрии (вес, рост, возраст) и дневника питания/добавок для расчёта прогрессии и RPE',
                col2:
                    'Явное согласие пользователя (Art. 6(1)(a) и Art. 9(2)(a) GDPR)',
                col3: 'До очистки полей в профиле или удаления аккаунта',
              ),
              LegalTableRowData(
                col1:
                    'Обеспечение прямых расчётов между атлетом и независимым тренером через Stripe Connect (с удержанием комиссии площадки)',
                col2:
                    'Исполнение договора (Art. 6(1)(b)) и требования финансового учёта (Art. 6(1)(c))',
                col3:
                    'На время активной подписки на тренера + срок хранения финансовой отчётности по закону',
              ),
              LegalTableRowData(
                col1:
                    'Продуктовая аналитика (Amplitude) и защита от сбоев и злоупотреблений',
                col2:
                    'Законный интерес (Art. 6(1)(f) GDPR — улучшение стабильности и UX) либо согласие (где требуется)',
                col3: 'В обезличенном/агрегированном виде до 24 месяцев',
              ),
            ],
          ),
          LegalSectionData(
            number: '4',
            title: 'Кому мы передаём данные (Субпроцессоры)',
            paragraphs: [
              'Мы не продаём ваши данные и не передаём их брокерам данных. Доступ к данным получают только инфраструктурные подрядчики (обработчики по ст. 28 GDPR), обеспечивающие работу функций приложения:',
            ],
            bullets: [
              'Google Firebase (Google LLC) — аутентификация (Firebase Auth, Google Sign-In) и облачная инфраструктура.',
              'Stripe, Inc. — обработка платежей, подписок и выплат тренерам (Stripe Connect).',
              'Amplitude, Inc. — продуктовая аналитика пользовательских сценариев (без передачи медицинских записей).',
              'Провайдеры AI-моделей (через наш защищённый серверный шлюз) — обработка команд в чате AI-ассистента по тренировкам.',
              'Другие пользователи приложения — только если вы сами включили «Публичный профиль» (Public profile) в настройках или отправили запрос тренеру.',
            ],
          ),
          LegalSectionData(
            number: '5',
            title: 'AI-ассистент и автоматизированные решения (EU AI Act Art. 50)',
            paragraphs: [
              'В приложение встроен интерактивный AI-ассистент для помощи с тренировочными планами (включая инструменты массового редактирования подходов и сдвига расписания).',
            ],
            bullets: [
              'Прозрачность: общаясь в чате ассистента, вы взаимодействуете с системой искусственного интеллекта.',
              'Контроль человека: любые изменения в тренировочном плане (Mass Edit, Schedule Shift) показываются вам в режиме предпросмотра и применяются только после вашего подтверждения.',
              'Обучение моделей: мы не используем ваши персональные данные и дневники тренировок для обучения сторонних публичных AI-моделей.',
            ],
          ),
          LegalSectionData(
            number: '6',
            title: 'Хранение и удаление аккаунта (Apple 5.1.1(v) / GDPR Art. 17)',
            paragraphs: [
              'Вы полностью контролируете свои данные. Вы можете изменить данные профиля или отключить публичный доступ в разделе «Настройки → Общие».',
              'Чтобы полностью удалить аккаунт и связанные с ним данные, перейдите в «Настройки → Общие → Удалить аккаунт» (Delete account) или напишите нам на ${LegalConfig.privacyEmail}. После подтверждения запускается процедура очистки (purge) ваших данных с наших серверов.',
            ],
          ),
          LegalSectionData(
            number: '7',
            title: 'Ваши права (GDPR / UK GDPR / CCPA)',
            paragraphs: [
              'В зависимости от вашей юрисдикции вы имеете право:',
            ],
            bullets: [
              'Запросить доступ к копии ваших персональных данных (Art. 15 GDPR) и их переносимость (Art. 20 GDPR).',
              'Исправить неточные данные (Art. 16 GDPR) или удалить их — «право на забвение» (Art. 17 GDPR).',
              'Ограничить обработку (Art. 18 GDPR) или отозвать ранее данное согласие в любое время (Art. 7(3) GDPR).',
              'Право на возражение (Art. 21 GDPR): вы можете в любой момент возразить против обработки данных на основании нашего законного интереса.',
              'Подать жалобу в уполномоченный надзорный орган по защите данных в вашей стране.',
            ],
          ),
          LegalSectionData(
            number: '8',
            title: 'Безопасность, возрастные ограничения и обновления',
            bullets: [
              'Безопасность (Art. 32 GDPR): мы используем шифрование при передаче данных (HTTPS/WSS), токен-авторизацию Firebase и разграничение прав доступа. При этом ни один метод передачи данных через интернет не может гарантировать 100% абсолютную защищённость.',
              'Дети: сервис не предназначен для лиц младше ${LegalConfig.minimumAgeYears} лет. Мы сознательно не собираем данные детей. Если вы узнали о такой передаче, напишите на ${LegalConfig.privacyEmail} для немедленного удаления.',
              'Изменения политики: при существенных изменениях мы обновим дату «Последнее обновление» и уведомим вас через приложение или по электронной почте.',
            ],
          ),
        ],
        footerNote:
            'Версия ${LegalConfig.policyVersion} · Последнее обновление: ${LegalConfig.lastUpdatedDate} · Контакт: ${LegalConfig.privacyEmail}',
      );
    }

    if (lang == 'uk') {
      return const LegalDocumentData(
        type: LegalDocumentType.privacy,
        title: 'Політика конфіденційності',
        shortTitle: 'Конфіденційність',
        subtitle:
            'Як ${LegalConfig.appName} збирає, використовує та захищає ваші дані (GDPR / CCPA / App Store & Google Play)',
        tldrTitle: 'Коротко про головне (TL;DR)',
        tldrPoints: [
          'Ми збираємо лише ті дані, які необхідні для роботи застосунку: профіль, щоденник тренувань, плани, харчування та налаштування.',
          'Антропометрія (вага, зріст, вік, стать) та записи про харчування/добавки заповнюються добровільно для розрахунку навантажень (RPE, 1RM) і прогресу.',
          'Платежі за коучинг обробляються напряму через Stripe — ми не зберігаємо номери банківських карток.',
          'Ми НЕ продаємо ваші персональні дані третім особам і не передаємо їх рекламним мережам.',
          'Ви можете будь-коли видалити свій акаунт і всі дані прямо в застосунку: Налаштування → Загальні → Видалити акаунт.',
        ],
        sections: [
          LegalSectionData(
            number: '1',
            title: 'Хто ми (Володілець / Контролер даних)',
            paragraphs: [
              'Контролером ваших персональних даних у застосунку ${LegalConfig.appName} є ${LegalConfig.operatorName} («ми», «нас», «наш»).',
              'Адреса для кореспонденції: ${LegalConfig.registeredAddress}.\nЗ усіх питань конфіденційності та захисту даних: ${LegalConfig.privacyEmail}.',
            ],
          ),
          LegalSectionData(
            number: '2',
            title: 'Які дані ми збираємо та звідки',
            paragraphs: [
              'Відповідно до ст. 13–14 GDPR та вимог Apple App Store / Google Play Data Safety ми перелічуємо лише ті категорії даних, які реально обробляються в коді застосунку:',
            ],
            tableHeaders: [
              'Категорія',
              'Приклади даних у застосунку',
              'Джерело',
            ],
            tableRows: [
              LegalTableRowData(
                col1: 'Акаунт і вхід',
                col2:
                    'UID користувача, email, відображуване імʼя (displayName), фото профілю (photoUrl), токени сесії.',
                col3: 'Напряму від вас / через Firebase Auth і Google Sign-In',
              ),
              LegalTableRowData(
                col1: 'Параметри тіла та фітнес-профіль',
                col2:
                    'Вага (bodyweightKg), зріст (heightCm), вік, стать, стаж і рівень тренувань, основна ціль, умови тренувань.',
                col3: 'Напряму від вас (заповнюється добровільно)',
              ),
              LegalTableRowData(
                col1: 'Тренування, плани та максимуми',
                col2:
                    'Вправи, підходи, повторення, робочі ваги, RPE, 1RM (userMax), мезо- та мікроцикли, календарні плани, імпортовані файли тренувань.',
                col3: 'Напряму від вас / під час роботи з планами',
              ),
              LegalTableRowData(
                col1: 'Щоденник харчування та добавок',
                col2:
                    'Записи прийомів їжі (Food), спортивних добавок (Supplements) та медикаментів/вітамінів (Medications) із дозуванням і датами.',
                col3: 'Напряму від вас (опціональний модуль)',
              ),
              LegalTableRowData(
                col1: 'Коучинг і соціальні функції',
                col2:
                    'Статус публічного профілю (isPublic), анкета тренера (опис, спеціалізації, мови, тариф), звʼязки тренер–атлет, повідомлення в чаті та відгуки.',
                col3: 'Напряму від вас під час використання коучингу',
              ),
              LegalTableRowData(
                col1: 'Платежі тренерам (Stripe Connect)',
                col2:
                    'Ідентифікатор акаунта Stripe Connect (у тренерів), статус прямої підписки атлета на тренера та сесії оплати. Дані карток обробляє виключно Stripe.',
                col3: 'Платіжний провайдер Stripe',
              ),
              LegalTableRowData(
                col1: 'Діалоги з AI-асистентом',
                col2:
                    'Текстові запити в чаті асистента та контекст активного тренувального плану для генерації підказок або масового редагування плану.',
                col3: 'Напряму від вас під час звернення до AI-чату',
              ),
              LegalTableRowData(
                col1: 'Технічні дані та аналітика',
                col2:
                    'Події використання екранів і функцій (Amplitude), налаштування теми, щільності інтерфейсу, часового поясу та мови (SharedPreferences).',
                col3: 'Автоматично під час роботи застосунку',
              ),
            ],
          ),
          LegalSectionData(
            number: '3',
            title: 'Цілі обробки та правові підстави (GDPR Art. 6 і Art. 9)',
            paragraphs: [
              'Ми обробляємо ваші дані суворо для зазначених нижче цілей і лише за наявності законної підстави:',
            ],
            tableHeaders: [
              'Ціль обробки',
              'Правова підстава (GDPR)',
              'Строк зберігання',
            ],
            tableRows: [
              LegalTableRowData(
                col1:
                    'Створення акаунта, синхронізація тренувань, планів і робота чату з тренером',
                col2: 'Виконання договору (Art. 6(1)(b) GDPR)',
                col3: 'До видалення акаунта користувачем',
              ),
              LegalTableRowData(
                col1:
                    'Зберігання антропометрії (вага, зріст, вік) та щоденника харчування/добавок для розрахунку прогресії та RPE',
                col2:
                    'Явна згода користувача (Art. 6(1)(a) та Art. 9(2)(a) GDPR)',
                col3: 'До очищення полів у профілі або видалення акаунта',
              ),
              LegalTableRowData(
                col1:
                    'Забезпечення прямих розрахунків між атлетом і незалежним тренером через Stripe Connect (з утриманням комісії майданчика)',
                col2:
                    'Виконання договору (Art. 6(1)(b)) та вимоги фінансового обліку (Art. 6(1)(c))',
                col3:
                    'На час активної підписки на тренера + строк зберігання фінансової звітності за законом',
              ),
              LegalTableRowData(
                col1:
                    'Продуктова аналітика (Amplitude) та захист від збоїв і зловживань',
                col2:
                    'Законний інтерес (Art. 6(1)(f) GDPR — покращення стабільності та UX) або згода',
                col3: 'В знесобленому/агрегованому вигляді до 24 місяців',
              ),
            ],
          ),
          LegalSectionData(
            number: '4',
            title: 'Кому ми передаємо дані (Субпроцесори)',
            paragraphs: [
              'Ми не продаємо ваші дані та не передаємо їх брокерам даних. Доступ отримують лише інфраструктурні підрядники (обробники за ст. 28 GDPR), що забезпечують роботу функцій застосунку:',
            ],
            bullets: [
              'Google Firebase (Google LLC) — автентифікація (Firebase Auth, Google Sign-In) та хмарна інфраструктура.',
              'Stripe, Inc. — обробка платежів, підписок і виплат тренерам (Stripe Connect).',
              'Amplitude, Inc. — продуктова аналітика користувацьких сценаріїв.',
              'Провайдери AI-моделей (через наш захищений серверний шлюз) — обробка команд у чаті AI-асистента з тренувань.',
              'Інші користувачі застосунку — лише якщо ви самі увімкнули «Публічний профіль» у налаштуваннях або надіслали запит тренеру.',
            ],
          ),
          LegalSectionData(
            number: '5',
            title: 'AI-асистент та автоматизовані рішення (EU AI Act Art. 50)',
            paragraphs: [
              'У застосунок вбудовано інтерактивний AI-асистент для допомоги з тренувальними планами (включно з інструментами масового редагування підходів та зсуву розкладу).',
            ],
            bullets: [
              'Прозорість: спілкуючись у чаті асистента, ви взаємодієте зі системою штучного інтелекту.',
              'Контроль людини: будь-які зміни в тренувальному плані (Mass Edit, Schedule Shift) показуються вам у режимі попереднього перегляду та застосовуються лише після вашого підтвердження.',
              'Навчання моделей: ми не використовуємо ваші персональні дані та щоденники тренувань для навчання сторонніх публічних AI-моделей.',
            ],
          ),
          LegalSectionData(
            number: '6',
            title: 'Зберігання та видалення акаунта (Apple 5.1.1(v) / GDPR Art. 17)',
            paragraphs: [
              'Ви повністю контролюєте свої дані. Ви можете змінити дані профілю або вимкнути публічний доступ у розділі «Налаштування → Загальні».',
              'Щоб повністю видалити акаунт і повʼязані з ним дані, перейдіть у «Налаштування → Загальні → Видалити акаунт» (Delete account) або напишіть нам на ${LegalConfig.privacyEmail}. Після підтвердження запускається процедура очищення (purge) ваших даних.',
            ],
          ),
          LegalSectionData(
            number: '7',
            title: 'Ваші права (GDPR / UK GDPR / CCPA)',
            paragraphs: [
              'Залежно від вашої юрисдикції ви маєте право:',
            ],
            bullets: [
              'Запитати доступ до копії ваших персональних даних (Art. 15 GDPR) та їх переносимість (Art. 20 GDPR).',
              'Виправити неточні дані (Art. 16 GDPR) або видалити їх — «право на забуття» (Art. 17 GDPR).',
              'Обмежити обробку (Art. 18 GDPR) або відкликати раніше надану згоду в будь-який час (Art. 7(3) GDPR).',
              'Право на заперечення (Art. 21 GDPR): ви можете будь-коли заперечити проти обробки даних на підставі нашого законного інтересу.',
              'Подати скаргу до уповноваженого наглядового органу із захисту даних у вашій країні.',
            ],
          ),
          LegalSectionData(
            number: '8',
            title: 'Безпека, вікові обмеження та оновлення',
            bullets: [
              'Безпека (Art. 32 GDPR): ми використовуємо шифрування під час передачі даних (HTTPS/WSS), токен-авторизацію Firebase та розмежування прав доступу. Водночас жоден метод передачі даних через інтернет не гарантує 100% абсолютної безпеки.',
              'Діти: сервіс не призначений для осіб молодше ${LegalConfig.minimumAgeYears} років. Ми свідомо не збираємо дані дітей. Якщо вам стало відомо про таку передачу, напишіть на ${LegalConfig.privacyEmail} для негайного видалення.',
              'Зміни політики: у разі суттєвих змін ми оновимо дату «Останнє оновлення» та повідомимо вас через застосунок або електронною поштою.',
            ],
          ),
        ],
        footerNote:
            'Версія ${LegalConfig.policyVersion} · Останнє оновлення: ${LegalConfig.lastUpdatedDate} · Контакт: ${LegalConfig.privacyEmail}',
      );
    }

    return const LegalDocumentData(
      type: LegalDocumentType.privacy,
      title: 'Privacy Policy',
      shortTitle: 'Privacy Policy',
      subtitle:
          'How ${LegalConfig.appName} collects, uses, and protects your personal data (GDPR / CCPA / App Store & Google Play)',
      tldrTitle: 'In Short (Summary)',
      tldrPoints: [
        'We only collect data required to power your workout tracker: account profile, workout logs, training plans, nutrition diary, and app preferences.',
        'Body metrics (weight, height, age, sex) and nutrition/supplement logs are optional and used to calculate training loads (RPE, 1RM) and progression.',
        'Coaching payments and payouts are processed directly by Stripe — we never store your payment card numbers.',
        'We do NOT sell your personal data to third parties or share it with ad networks or data brokers.',
        'You can permanently delete your account and purge your data at any time inside the app via Settings → General → Delete account.',
      ],
      sections: [
        LegalSectionData(
          number: '1',
          title: 'Who We Are (Data Controller)',
          paragraphs: [
            '${LegalConfig.operatorName} ("we", "us", "our") is the data controller responsible for your personal data in ${LegalConfig.appName}.',
            'Address: ${LegalConfig.registeredAddress}.\nPrivacy & Data Protection Contact: ${LegalConfig.privacyEmail}.',
          ],
        ),
        LegalSectionData(
          number: '2',
          title: 'What Personal Data We Collect and How',
          paragraphs: [
            'In accordance with GDPR Articles 13–14, Apple App Store Guideline 5.1.1, and Google Play Data Safety requirements, below are the exact categories of data processed by the application:',
          ],
          tableHeaders: [
            'Category',
            'Examples in the App',
            'Source',
          ],
          tableRows: [
            LegalTableRowData(
              col1: 'Account & Authentication',
              col2:
                  'User ID (UID), email address, display name, profile photo URL, and authentication tokens.',
              col3: 'Directly from you / via Firebase Auth & Google Sign-In',
            ),
            LegalTableRowData(
              col1: 'Body Metrics & Fitness Profile',
              col2:
                  'Bodyweight (kg), height (cm), age, sex, training experience years/level, primary fitness goal, and training environment.',
              col3: 'Directly from you (optional profile fields)',
            ),
            LegalTableRowData(
              col1: 'Workouts, Plans & 1RM Maxes',
              col2:
                  'Exercises, sets, reps, weights, RPE, 1RM records (userMax), mesocycles, microcycles, calendar plans, and imported workout files.',
              col3: 'Directly from you as you log or import workouts',
            ),
            LegalTableRowData(
              col1: 'Nutrition, Supplements & Medications Log',
              col2:
                  'Logged food items, supplements, and medication entries including optional dosage notes and timestamps.',
              col3: 'Directly from you (optional nutrition module)',
            ),
            LegalTableRowData(
              col1: 'Coaching & Social Features',
              col2:
                  'Public profile toggle (isPublic), coach bio/specializations/languages/rate plan, coach–athlete links, direct chat messages, and coach reviews.',
              col3: 'Directly from you when using social or coaching features',
            ),
            LegalTableRowData(
              col1: 'Coach Payments (Stripe Connect)',
              col2:
                  'Stripe Connect account ID (for coaches), direct athlete-to-coach subscription status, and checkout session metadata. Card details are handled solely by Stripe.',
              col3: 'Stripe payment processor',
            ),
            LegalTableRowData(
              col1: 'AI Assistant Interactions',
              col2:
                  'Chat prompts and active workout plan context sent to the in-app AI Assistant to generate suggestions, mass edits, or schedule shifts.',
              col3: 'Directly from you when using the AI chat assistant',
            ),
            LegalTableRowData(
              col1: 'Usage Analytics & Local Preferences',
              col2:
                  'Screen open and feature interaction events (Amplitude), plus local device preferences (theme mode, UI density, locale, timezone).',
              col3: 'Automatically during app usage',
            ),
          ],
        ),
        LegalSectionData(
          number: '3',
          title: 'Why We Use Your Data and Our Legal Basis (GDPR Art. 6 & Art. 9)',
          paragraphs: [
            'We process your personal data only for specific, explicit purposes backed by a lawful basis:',
          ],
          tableHeaders: [
            'Purpose',
            'Lawful Basis (GDPR)',
            'Retention Period',
          ],
          tableRows: [
            LegalTableRowData(
              col1:
                  'Providing your account, syncing workouts/plans, and enabling coach–athlete messaging',
              col2: 'Performance of a Contract (Art. 6(1)(b) GDPR)',
              col3: 'Until you delete your account',
            ),
            LegalTableRowData(
              col1:
                  'Processing optional body metrics and nutrition/supplement logs to compute training loads (RPE, 1RM)',
              col2:
                  'Explicit Consent (Art. 6(1)(a) & Art. 9(2)(a) GDPR)',
              col3: 'Until you clear the fields or delete your account',
            ),
            LegalTableRowData(
              col1:
                  'Facilitating direct user-to-user coaching payments via Stripe Connect (with a platform commission)',
              col2:
                  'Contract (Art. 6(1)(b)) & Legal Obligation for financial records (Art. 6(1)(c))',
              col3: 'Duration of active coach subscription + statutory tax retention period',
            ),
            LegalTableRowData(
              col1:
                  'Product analytics (Amplitude), troubleshooting, and platform security',
              col2:
                  'Legitimate Interests (Art. 6(1)(f) — app reliability and UX improvement) or Consent where required',
              col3: 'Up to 24 months in pseudonymized/aggregated form',
            ),
          ],
        ),
        LegalSectionData(
          number: '4',
          title: 'Who We Share Your Data With (Sub-Processors)',
          paragraphs: [
            'We do not sell your personal data or share it for cross-context behavioral advertising. We share data only with service providers bound by data processing agreements (GDPR Art. 28):',
          ],
          bullets: [
            'Google Firebase (Google LLC) — authentication (Firebase Auth, Google Sign-In) and cloud hosting infrastructure.',
            'Stripe, Inc. — payment processing for coaching subscriptions and Stripe Connect trainer payouts.',
            'Amplitude, Inc. — product usage analytics to help us understand feature adoption and fix bugs.',
            'AI Inference Providers (via our backend gateway) — processing workout assistant chat messages and plan adjustment commands.',
            'Other App Users — only when you explicitly enable "Public profile" in Settings or link with a coach.',
          ],
        ),
        LegalSectionData(
          number: '5',
          title: 'AI Assistant & Automated Processing (EU AI Act Art. 50)',
          paragraphs: [
            '${LegalConfig.appName} includes an AI-powered workout assistant that can answer training questions and propose bulk plan adjustments (Mass Edit and Schedule Shift).',
          ],
          bullets: [
            'AI Transparency: When using the assistant chat overlay, you are interacting with an artificial intelligence system.',
            'Human-in-the-Loop Control: Proposed plan modifications are always presented in a preview dialog and never alter your schedule unless you explicitly confirm them.',
            'No Model Training on Personal Data: We do not use your personal workout logs or health metrics to train public third-party foundation models.',
          ],
        ),
        LegalSectionData(
          number: '6',
          title: 'Data Retention & In-App Account Deletion (Apple 5.1.1(v) / GDPR Art. 17)',
          paragraphs: [
            'You can update your profile data or switch your profile between public and private at any time in Settings → General.',
            'To permanently delete your account and purge your personal data, open Settings → General → Delete account inside the app, or email ${LegalConfig.privacyEmail}. Confirming deletion triggers our account purge workflow.',
          ],
        ),
        LegalSectionData(
          number: '7',
          title: 'Your Privacy Rights (GDPR / UK GDPR / US State Laws)',
          paragraphs: [
            'Depending on where you live, you have the following rights free of charge:',
          ],
          bullets: [
            'Access & Portability (Arts. 15 & 20 GDPR): Request a copy of your personal data in a structured format.',
            'Rectification & Erasure (Arts. 16 & 17 GDPR): Correct inaccurate data or request deletion ("right to be forgotten").',
            'Restriction & Withdrawal of Consent (Arts. 18 & 7(3) GDPR): Restrict processing or withdraw consent at any time without affecting prior lawful processing.',
            'Right to Object (Art. 21 GDPR): You have the right to object at any time to processing based on our legitimate interests.',
            'US / California Rights (CCPA/CPRA): Right to know, delete, correct, limit the use of sensitive personal information, and non-discrimination.',
            'Right to Complain: You may lodge a complaint with your local data protection supervisory authority (such as an EU Data Protection Authority or the UK ICO).',
          ],
        ),
        LegalSectionData(
          number: '8',
          title: 'Security, Children, and Policy Updates',
          bullets: [
            'Security (Art. 32 GDPR): We implement reasonable administrative and technical safeguards, including TLS/WSS encryption in transit and token-based access controls. However, no method of electronic transmission or storage is 100% secure.',
            'Children: Our service is not directed to individuals under ${LegalConfig.minimumAgeYears} years of age, and we do not knowingly collect personal data from children.',
            'Changes to This Policy: When we make material changes, we will update the "Last updated" date and notify you via an in-app notice or email.',
          ],
        ),
      ],
      footerNote:
          'Version ${LegalConfig.policyVersion} · Last updated: ${LegalConfig.lastUpdatedDate} · Contact: ${LegalConfig.privacyEmail}',
    );
  }

  // ---------------------------------------------------------------------------
  // 2. TERMS OF SERVICE (Audited against tos-clause-scanner R1–R7)
  // ---------------------------------------------------------------------------
  static LegalDocumentData _termsOfService(String lang) {
    if (lang == 'ru') {
      return const LegalDocumentData(
        type: LegalDocumentType.terms,
        title: 'Условия использования (Terms of Service)',
        shortTitle: 'Условия (ToS)',
        subtitle:
            'Правила использования приложения ${LegalConfig.appName}, тренировочных планов, AI-ассистента и маркетплейса тренеров',
        tldrTitle: 'Ключевые принципы честного сервиса',
        tldrPoints: [
          'Ваши тренировочные планы, заметки и история тренировок принадлежат вам — мы не забираем на них эксклюзивные права.',
          'Весь программный функционал приложения доступен без платных подписок. Единственные платежи в сервисе — прямая оплата от пользователя к независимому тренеру через Stripe Connect (с комиссией площадки) за личное взаимодействие и ведение.',
          'При существенных изменениях условий мы предупреждаем заранее, а вы всегда можете выгрузить данные или удалить аккаунт.',
        ],
        sections: [
          LegalSectionData(
            number: '1',
            title: 'Принятие условий и требования к пользователю',
            paragraphs: [
              'Настоящие Условия использования регулируют ваш доступ к приложению ${LegalConfig.appName}, предоставляемому ${LegalConfig.operatorName} (связь с поддержкой: ${LegalConfig.supportEmail}).',
              'Создавая аккаунт или используя приложение, вы подтверждаете, что достигли возраста ${LegalConfig.minimumAgeYears} лет и соглашаетесь с настоящими Условиями и Медицинским дисклеймером.',
            ],
          ),
          LegalSectionData(
            number: '2',
            title: 'Аккаунт и правила допустимого использования',
            bullets: [
              'Вы несёте ответственность за сохранность учётных данных своего аккаунта (Email / Google Sign-In).',
              'Запрещается использовать приложение для рассылки спама, публикации незаконного или оскорбительного контента, попыток несанкционированного доступа к API/WebSocket-серверам или нарушения работы сервиса.',
            ],
          ),
          LegalSectionData(
            number: '3',
            title: 'Ваш контент и тренировочные планы (Интеллектуальная собственность)',
            paragraphs: [
              'Вы сохраняете все права собственности на создаваемые вами тренировочные программы, мезоциклы, макросы прогрессии, записи тренировок и отзывы.',
              'Вы предоставляете нам ограниченную, неисключительную, отзывную лицензию исключительно для хранения, отображения и синхронизации ваших данных в рамках работы приложения (а также для показа вашего профиля или планов другим пользователям, если вы сами сделали их публичными или поделились ими с тренером).',
            ],
          ),
          LegalSectionData(
            number: '4',
            title: 'Прямые расчёты «Атлет ↔ Тренер» (P2P через Stripe Connect)',
            paragraphs: [
              'В приложении отсутствуют платные подписки за доступ к программным функциям самого приложения. Единственный вид платежей — прямые расчёты между пользователями (от атлета к выбранному тренеру) через инфраструктуру Stripe Connect.',
            ],
            bullets: [
              'Предмет подписки (Person-to-Person): подписка оплачивает исключительно личное взаимодействие, наставничество и сопровождение со стороны выбранного вами независимого тренера и НЕ открывает никакого нового цифрового функционала приложения.',
              'Статус тренеров и комиссия площадки: тренеры — это независимые пользователи платформы, не связанные трудовыми или агентскими отношениями с ${LegalConfig.appName}. Тренер сам устанавливает стоимость своих услуг и получает оплату напрямую через Stripe Connect за вычетом сервисной комиссии площадки за техническое сопровождение сделки.',
              'Прозрачность оплаты и простая отмена: стоимость услуг тренера отображается до оформления в Stripe Checkout. Вы можете в любой момент приостановить или прекратить подписку на тренера в разделе «Коуч ↔ Атлеты» / «Мои тренеры» до начала следующего расчётного периода без скрытых штрафов.',
            ],
          ),
          LegalSectionData(
            number: '5',
            title: 'Использование AI-ассистента',
            paragraphs: [
              'Функции AI-чата и автоматического редактирования плана предоставляются как вспомогательный инструмент планирования. Вы обязуетесь проверять предпросмотр любых изменений (рабочие веса, объём, RPE, сдвиг дат) перед их подтверждением.',
            ],
          ),
          LegalSectionData(
            number: '6',
            title: 'Изменение условий и прекращение доступа',
            bullets: [
              'Вы можете прекратить использование сервиса и удалить свой аккаунт в любой момент в разделе «Настройки → Общие → Удалить аккаунт».',
              'Мы можем ограничить или заблокировать доступ к аккаунту в случае существенного нарушения настоящих Условий, мошенничества или угрозы безопасности платформы, направив вам уведомление с указанием причины.',
              'О существенных изменениях настоящих Условий мы уведомляем заранее через приложение или по электронной почте.',
            ],
          ),
          LegalSectionData(
            number: '7',
            title: 'Ограничение ответственности и применимое право',
            paragraphs: [
              'Приложение предоставляется по принципу «как есть» (as is). В максимальной степени, допустимой законом, мы не несём ответственности за косвенные убытки или спортивные травмы, полученные в ходе самостоятельных тренировок.',
              'Ничто в настоящих Условиях не ограничивает ваши неотъемлемые права потребителя, предусмотренные императивными нормами законодательства вашей страны проживания. Применимое право: ${LegalConfig.governingJurisdiction}.',
            ],
          ),
        ],
        footerNote:
            'Версия ${LegalConfig.policyVersion} · Последнее обновление: ${LegalConfig.lastUpdatedDate} · Поддержка: ${LegalConfig.supportEmail}',
      );
    }

    if (lang == 'uk') {
      return const LegalDocumentData(
        type: LegalDocumentType.terms,
        title: 'Умови використання (Terms of Service)',
        shortTitle: 'Умови (ToS)',
        subtitle:
            'Правила використання застосунку ${LegalConfig.appName}, тренувальних планів, AI-асистента та маркетплейсу тренерів',
        tldrTitle: 'Ключові принципи чесного сервісу',
        tldrPoints: [
          'Ваші тренувальні плани, нотатки та історія тренувань належать вам — ми не забираємо на них ексклюзивні права.',
          'Весь програмний функціонал застосунку доступний без платних підписок. Єдині платежі в сервісі — пряма оплата від користувача до незалежного тренера через Stripe Connect (з комісією майданчика) за особисту взаємодію та супровід.',
          'Про суттєві зміни умов ми попереджаємо заздалегідь, а ви завжди можете видалити акаунт у налаштуваннях.',
        ],
        sections: [
          LegalSectionData(
            number: '1',
            title: 'Прийняття умов та вимоги до користувача',
            paragraphs: [
              'Ці Умови використання регулюють ваш доступ до застосунку ${LegalConfig.appName}, що надається ${LegalConfig.operatorName} (звʼязок із підтримкою: ${LegalConfig.supportEmail}).',
              'Створюючи акаунт або використовуючи застосунок, ви підтверджуєте, що досягли віку ${LegalConfig.minimumAgeYears} років і погоджуєтеся з цими Умовами та Медичним застереженням.',
            ],
          ),
          LegalSectionData(
            number: '2',
            title: 'Акаунт і правила допустимого використання',
            bullets: [
              'Ви несете відповідальність за збереження облікових даних свого акаунта (Email / Google Sign-In).',
              'Забороняється використовувати застосунок для розсилання спаму, публікації незаконного чи образливого контенту, спроб несанкціонованого доступу до API/WebSocket-серверів або порушення роботи сервісу.',
            ],
          ),
          LegalSectionData(
            number: '3',
            title: 'Ваш контент і тренувальні плани (Інтелектуальна власність)',
            paragraphs: [
              'Ви зберігаєте всі права власності на створювані вами тренувальні програми, мезоцикли, макроси прогресії, записи тренувань і відгуки.',
              'Ви надаєте нам обмежену, невиключну, відкличну ліцензію виключно для зберігання, відображення та синхронізації ваших даних у межах роботи застосунку (а також для показу вашого профілю чи планів іншим користувачам, якщо ви самі зробили їх публічними або поділилися ними з тренером).',
            ],
          ),
          LegalSectionData(
            number: '4',
            title: 'Прямі розрахунки «Атлет ↔ Тренер» (P2P через Stripe Connect)',
            paragraphs: [
              'У застосунку відсутні платні підписки за доступ до програмних функцій самого застосунку. Єдиний вид платежів — прямі розрахунки між користувачами (від атлета до обраного тренера) через інфраструктуру Stripe Connect.',
            ],
            bullets: [
              'Предмет підписки (Person-to-Person): підписка оплачує виключно особисту взаємодію, наставництво та супровід з боку обраного вами незалежного тренера і НЕ відкриває жодного нового цифрового функціоналу застосунку.',
              'Статус тренерів і комісія майданчика: тренери — це незалежні користувачі платформи, які не повʼязані трудовими чи агентськими відносинами з ${LegalConfig.appName}. Тренер сам встановлює вартість своїх послуг і отримує оплату напряму через Stripe Connect за вирахуванням сервісної комісії майданчика за технічний супровід транзакції.',
              'Прозорість оплати та просте скасування: вартість послуг тренера відображається до оформлення у Stripe Checkout. Ви можете будь-коли призупинити або припинити підписку на тренера у розділі «Коуч ↔ Атлети» / «Мої тренери» до початку наступного розрахункового періоду без прихованих штрафів.',
            ],
          ),
          LegalSectionData(
            number: '5',
            title: 'Використання AI-асистента',
            paragraphs: [
              'Функції AI-чату та автоматичного редагування плану надаються як допоміжний інструмент планування. Ви зобовʼязуєтеся перевіряти попередній перегляд будь-яких змін (робочі ваги, обсяг, RPE, зсув дат) перед їх підтвердженням.',
            ],
          ),
          LegalSectionData(
            number: '6',
            title: 'Зміна умов та припинення доступу',
            bullets: [
              'Ви можете припинити використання сервісу та видалити свій акаунт у будь-який момент у розділі «Налаштування → Загальні → Видалити акаунт».',
              'Ми можемо обмежити або заблокувати доступ до акаунта у разі суттєвого порушення цих Умов, шахрайства або загрози безпеці платформи, надіславши вам повідомлення із зазначенням причини.',
              'Про суттєві зміни цих Умов ми повідомляємо заздалегідь через застосунок або електронною поштою.',
            ],
          ),
          LegalSectionData(
            number: '7',
            title: 'Обмеження відповідальності та застосовне право',
            paragraphs: [
              'Застосунок надається за принципом «як є» (as is). У максимальному ступені, дозволеному законом, ми не несемо відповідальності за непрямі збитки або спортивні травми, отримані під час самостійних тренувань.',
              'Ніщо в цих Умовах не обмежує ваші невідʼємні права споживача, передбачені імперативними нормами законодавства вашої країни проживання. Застосовне право: ${LegalConfig.governingJurisdiction}.',
            ],
          ),
        ],
        footerNote:
            'Версія ${LegalConfig.policyVersion} · Останнє оновлення: ${LegalConfig.lastUpdatedDate} · Підтримка: ${LegalConfig.supportEmail}',
      );
    }

    return const LegalDocumentData(
      type: LegalDocumentType.terms,
      title: 'Terms of Service',
      shortTitle: 'Terms of Service',
      subtitle:
          'Rules governing your use of ${LegalConfig.appName}, workout plans, AI assistant tools, and the coaching marketplace',
      tldrTitle: 'Fair Terms Summary (TL;DR)',
      tldrPoints: [
        'You retain full ownership of your workout logs, custom training plans, macros, and reviews.',
        'All software features of the app are available without paid app subscriptions. The only payments are direct person-to-person (P2P) payments from an athlete to an independent coach via Stripe Connect (with a platform fee) for personal coaching interaction.',
        'We give advance notice of material changes to these terms, and you can delete your account at any time in Settings.',
      ],
      sections: [
        LegalSectionData(
          number: '1',
          title: 'Acceptance of Terms & Eligibility',
          paragraphs: [
            'These Terms of Service ("Terms") govern your access to and use of ${LegalConfig.appName}, operated by ${LegalConfig.operatorName} (Support contact: ${LegalConfig.supportEmail}).',
            'By creating an account or using the app, you confirm that you are at least ${LegalConfig.minimumAgeYears} years old and agree to these Terms and our Health & Fitness Disclaimer.',
          ],
        ),
        LegalSectionData(
          number: '2',
          title: 'Account Security & Acceptable Use',
          bullets: [
            'You are responsible for safeguarding your login credentials (Email or Google Sign-In) and all activity under your account.',
            'You agree not to misuse the platform, send spam, post unlawful or abusive content, or attempt unauthorized access to our API or WebSocket services.',
          ],
        ),
        LegalSectionData(
          number: '3',
          title: 'Your Content & Training Plans (Intellectual Property)',
          paragraphs: [
            'You retain ownership of all workout logs, custom exercises, mesocycles, progression macros, nutrition logs, and reviews you create in ${LegalConfig.appName}.',
            'You grant us a limited, non-exclusive, revocable license solely to host, store, sync, and display your content to provide the service to you (and to display your profile, plans, or workout history to your connected coach or other users only when you explicitly enable public visibility or coaching links).',
          ],
        ),
        LegalSectionData(
          number: '4',
          title: 'Person-to-Person Coaching Payments (Stripe Connect)',
          paragraphs: [
            '${LegalConfig.appName} does not charge subscriptions for unlocking software features of the application. The only payments processed through the platform are direct user-to-user payments from an athlete to a selected coach via Stripe Connect.',
          ],
          bullets: [
            'Scope of Coaching Subscription (Person-to-Person): A coaching subscription pays solely for personal interaction, plan supervision, and mentoring from an independent human coach, and does NOT unlock any additional digital features or software functionality within the app.',
            'Independent Coaches & Platform Commission: Coaches are independent users unaffiliated with ${LegalConfig.appName}. Each coach sets their own rate and receives payments directly via Stripe Connect, net of a platform service commission retained for facilitating the transaction.',
            'Transparent Billing & Easy Cancellation: The coach’s rate is displayed prior to Stripe Checkout. You may pause or cancel your coaching subscription at any time in the app ("Coach ↔ Athletes" / "My Coaches") before the next billing cycle without cancellation penalties.',
          ],
        ),
        LegalSectionData(
          number: '5',
          title: 'AI Workout Assistant',
          paragraphs: [
            'The in-app AI Assistant helps you analyze workouts and prepare bulk plan edits. Because AI outputs can make mistakes, you are responsible for reviewing the preview of any proposed weight, rep, RPE, or schedule changes before applying them to your plan.',
          ],
        ),
        LegalSectionData(
          number: '6',
          title: 'Changes to Terms & Account Termination',
          bullets: [
            'Termination by You: You may stop using ${LegalConfig.appName} and permanently delete your account at any time via Settings → General → Delete account.',
            'Termination for Cause: We may suspend or terminate accounts that materially breach these Terms, engage in fraud, or harm platform security, with notice explaining the reason.',
            'Updates to Terms: We will provide advance notice of material updates to these Terms via in-app notification or email.',
          ],
        ),
        LegalSectionData(
          number: '7',
          title: 'Limitation of Liability & Governing Law',
          paragraphs: [
            '${LegalConfig.appName} is provided "as is" without warranties of guaranteed athletic results. To the maximum extent permitted by law, we are not liable for indirect damages or physical injuries arising from your training activities.',
            'Nothing in these Terms limits or excludes mandatory consumer protection rights available to you under the laws of your country of residence. Governing law: ${LegalConfig.governingJurisdiction}.',
          ],
        ),
      ],
      footerNote:
          'Version ${LegalConfig.policyVersion} · Last updated: ${LegalConfig.lastUpdatedDate} · Support: ${LegalConfig.supportEmail}',
    );
  }

  // ---------------------------------------------------------------------------
  // 3. HEALTH & FITNESS DISCLAIMER (Essential for workout / RPE / nutrition app)
  // ---------------------------------------------------------------------------
  static LegalDocumentData _healthDisclaimer(String lang) {
    if (lang == 'ru') {
      return const LegalDocumentData(
        type: LegalDocumentType.healthDisclaimer,
        title: 'Медицинский и фитнес-дисклеймер',
        shortTitle: 'Мед. дисклеймер',
        subtitle:
            'Важное предупреждение о безопасности тренировок, расчётах нагрузок (1RM / RPE) и ведении дневника питания и добавок',
        tldrTitle: 'Главное правило безопасности',
        tldrPoints: [
          '${LegalConfig.appName} — это дневник и планировщик тренировок, а НЕ медицинское устройство и НЕ врач.',
          'Любые расчёты весов, 1RM, RPE, макросов прогрессии и подсказки AI-ассистента носят исключительно информационный характер.',
          'При появлении острой боли, головокружения или дискомфорта немедленно прекратите выполнение упражнения и обратитесь к врачу.',
        ],
        sections: [
          LegalSectionData(
            number: '1',
            title: 'Отказ от медицинских консультаций',
            isHighlightedWarning: true,
            paragraphs: [
              'Все материалы, тренировочные планы, оценки одноповторного максимума (1RM / e1RM), таблицы RPE, правила авто-прогрессии (макросы), а также ответы AI-ассистента в ${LegalConfig.appName} предназначены исключительно для информационных и образовательных целей.',
              'Приложение не ставит медицинских диагнозов, не назначает лечение и не заменяет консультацию квалифицированного врача, физиотерапевта или спортивного медика.',
            ],
          ),
          LegalSectionData(
            number: '2',
            title: 'Консультация со специалистом перед началом тренировок',
            paragraphs: [
              'Перед началом любой новой программы силовых или кардио-тренировок, а также перед изменением рациона питания обязательно проконсультируйтесь с врачом — особенно если у вас есть сердечно-сосудистые заболевания, травмы опорно-двигательного аппарата, хронические заболевания или противопоказания к физическим нагрузкам.',
            ],
          ),
          LegalSectionData(
            number: '3',
            title: 'Техника безопасности и оценка собственных рисков',
            bullets: [
              'Силовые тренировки со свободными весами и на тренажёрах сопряжены с естественным риском получения травм.',
              'Вы самостоятельно принимаете решение о выборе рабочего веса, количества повторений и интенсивности (RPE) в каждом подходе.',
              'Даже если алгоритм прогрессии, шаблон плана или AI-ассистент предлагает увеличить рабочий вес или объём, ориентируйтесь на своё реальное самочувствие, используйте страховку и соблюдайте правильную технику.',
              'Немедленно прекратите тренировку при возникновении острой боли в суставах/мышцах, боли в груди, одышки или головокружения.',
            ],
          ),
          LegalSectionData(
            number: '4',
            title: 'Дневник питания, добавок и медикаментов',
            paragraphs: [
              'Раздел «Питание» (Nutrition Sessions) позволяет вести личный учёт приёмов пищи (Food), спортивных добавок (Supplements) и медикаментов (Medications) и их дозировок.',
              'Приложение НЕ проверяет совместимость препаратов, безопасность дозировок или наличие противопоказаний и аллергий. Приём любых лекарственных средств и биологически активных добавок должен согласовываться с вашим лечащим врачом.',
            ],
          ),
          LegalSectionData(
            number: '5',
            title: 'Рекомендации независимых тренеров',
            paragraphs: [
              'Тренеры, использующие платформу ${LegalConfig.appName}, действуют самостоятельно. Платформа не сертифицирует медицинскую квалификацию тренеров. Если вы работаете с тренером через приложение, обязательно сообщайте ему о любых травмах, ограничениях по здоровью и болевых ощущениях.',
            ],
          ),
        ],
        footerNote:
            'Версия ${LegalConfig.policyVersion} · Последнее обновление: ${LegalConfig.lastUpdatedDate}',
      );
    }

    if (lang == 'uk') {
      return const LegalDocumentData(
        type: LegalDocumentType.healthDisclaimer,
        title: 'Медичне та фітнес-застереження',
        shortTitle: 'Мед. застереження',
        subtitle:
            'Важливе попередження щодо безпеки тренувань, розрахунків навантажень (1RM / RPE) та ведення щоденника харчування і добавок',
        tldrTitle: 'Головне правило безпеки',
        tldrPoints: [
          '${LegalConfig.appName} — це щоденник і планувальник тренувань, а НЕ медичний виріб і НЕ лікар.',
          'Будь-які розрахунки ваги, 1RM, RPE, макросів прогресії та підказки AI-асистента мають виключно інформаційний характер.',
          'У разі появи гострого болю, запаморочення або дискомфорту негайно припиніть виконання вправи та зверніться до лікаря.',
        ],
        sections: [
          LegalSectionData(
            number: '1',
            title: 'Відмова від медичних консультацій',
            isHighlightedWarning: true,
            paragraphs: [
              'Усі матеріали, тренувальні плани, оцінки одноповторного максимуму (1RM / e1RM), таблиці RPE, правила авто-прогресії (макроси), а також відповіді AI-асистента у ${LegalConfig.appName} призначені виключно для інформаційних та освітніх цілей.',
              'Застосунок не ставить медичних діагнозів, не призначає лікування і не замінює консультацію кваліфікованого лікаря, фізіотерапевта чи спортивного медика.',
            ],
          ),
          LegalSectionData(
            number: '2',
            title: 'Консультація з фахівцем перед початком тренувань',
            paragraphs: [
              'Перед початком будь-якої нової програми силових або кардіо-тренувань, а також перед зміною раціону харчування обовʼязково проконсультуйтеся з лікарем — особливо якщо у вас є серцево-судинні захворювання, травми опорно-рухового апарату, хронічні стани або протипоказання до фізичних навантажень.',
            ],
          ),
          LegalSectionData(
            number: '3',
            title: 'Техніка безпеки та оцінка власних ризиків',
            bullets: [
              'Силові тренування з вільними вагами та на тренажерах повʼязані з природним ризиком отримання травм.',
              'Ви самостійно приймаєте рішення щодо вибору робочої ваги, кількості повторень та інтенсивності (RPE) у кожному підході.',
              'Навіть якщо алгоритм прогресії, шаблон плану або AI-асистент пропонує збільшити робочу вагу чи обсяг, орієнтуйтеся на своє реальне самопочуття, використовуйте страховку та дотримуйтеся правильної техніки.',
              'Негайно припиніть тренування у разі виникнення гострого болю в суглобах/мʼязах, болю в грудях, задишки або запаморочення.',
            ],
          ),
          LegalSectionData(
            number: '4',
            title: 'Щоденник харчування, добавок і медикаментів',
            paragraphs: [
              'Розділ «Сесії харчування» (Nutrition Sessions) дозволяє вести особистий облік прийомів їжі (Food), спортивних добавок (Supplements) та медикаментів (Medications) і їх дозувань.',
              'Застосунок НЕ перевіряє сумісність препаратів, безпеку дозувань або наявність протипоказань та алергій. Прийом будь-яких лікарських засобів і добавок має узгоджуватися з вашим лікарем.',
            ],
          ),
          LegalSectionData(
            number: '5',
            title: 'Рекомендації незалежних тренерів',
            paragraphs: [
              'Тренери, які використовують платформу ${LegalConfig.appName}, діють самостійно. Платформа не сертифікує медичну кваліфікацію тренерів. Якщо ви працюєте з тренером через застосунок, обовʼязково повідомляйте йому про будь-які травми, обмеження за здоровʼям і больові відчуття.',
            ],
          ),
        ],
        footerNote:
            'Версія ${LegalConfig.policyVersion} · Останнє оновлення: ${LegalConfig.lastUpdatedDate}',
      );
    }

    return const LegalDocumentData(
      type: LegalDocumentType.healthDisclaimer,
      title: 'Health & Fitness Disclaimer',
      shortTitle: 'Health Disclaimer',
      subtitle:
          'Important safety notice regarding strength training, load calculations (1RM / RPE), coaching, and nutrition/supplement logging',
      tldrTitle: 'Key Safety Principle (TL;DR)',
      tldrPoints: [
        '${LegalConfig.appName} is a workout tracking and planning tool — NOT a medical device or healthcare provider.',
        'All load calculations, 1RM estimates, RPE targets, progression macros, and AI assistant suggestions are for informational purposes only.',
        'Stop exercising immediately if you experience sharp pain, dizziness, chest discomfort, or shortness of breath, and consult a physician.',
      ],
      sections: [
        LegalSectionData(
          number: '1',
          title: 'Not Medical Advice',
          isHighlightedWarning: true,
          paragraphs: [
            'All workout templates, calendar plans, one-rep max (1RM / e1RM) calculations, RPE tables, automated progression macros, and AI assistant responses inside ${LegalConfig.appName} are provided for informational and educational purposes only.',
            'Nothing in the application constitutes medical advice, clinical diagnosis, physical therapy, or treatment. Always seek the advice of a qualified physician or healthcare professional regarding any medical condition.',
          ],
        ),
        LegalSectionData(
          number: '2',
          title: 'Consult a Physician Before Training',
          paragraphs: [
            'Consult a qualified healthcare professional before starting any new strength, conditioning, or nutrition program — especially if you have a history of cardiovascular conditions, joint or spinal injuries, chronic illness, or any other physical limitation.',
          ],
        ),
        LegalSectionData(
          number: '3',
          title: 'Assumption of Risk & Exercise Safety',
          bullets: [
            'Strength training and physical exercise carry inherent risks of musculoskeletal or cardiovascular injury.',
            'You are solely responsible for selecting weights, repetitions, and effort levels (RPE) appropriate for your current ability and recovery state.',
            'Even when an automated progression rule, training plan, or AI assistant suggests increasing weight or volume, always prioritize proper form, equipment safety, and your bodily signals.',
            'Stop exercising immediately if you feel sharp pain, dizziness, lightheadedness, or unusual shortness of breath.',
          ],
        ),
        LegalSectionData(
          number: '4',
          title: 'Nutrition, Supplements & Medications Logging',
          paragraphs: [
            'The Nutrition Sessions feature is a personal diary for recording food, supplements, and medications along with user-entered dosages.',
            '${LegalConfig.appName} does NOT verify dosage safety, medical appropriateness, contraindications, or drug–supplement interactions. Never start, stop, or alter any medication or supplement regimen without consulting a licensed physician or pharmacist.',
          ],
        ),
        LegalSectionData(
          number: '5',
          title: 'Independent Coaches',
          paragraphs: [
            'Coaches connected through ${LegalConfig.appName} are independent third-party providers. We do not certify medical or clinical qualifications of coaches. Always inform your coach promptly of any pain, injury, or medical restriction.',
          ],
        ),
      ],
      footerNote:
          'Version ${LegalConfig.policyVersion} · Last updated: ${LegalConfig.lastUpdatedDate}',
    );
  }
}
