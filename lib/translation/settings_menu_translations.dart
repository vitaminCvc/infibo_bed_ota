// Compact navigation labels. Full panel titles and descriptions retain their
// existing translations.
const _shortMenuLabels = <String, Map<String, String>>{
  'zh_CN': {},
  'en_US': {'prompt_volume': 'Voice Volume', 'system_update': 'Updates'},
  'pl_PL': {
    'device_info': 'O urządzeniu',
    'prompt_volume': 'Głośność',
    'system_update': 'Aktualizacje',
  },
  'es_ES': {
    'prompt_volume': 'Vol. avisos',
    'status_detection': 'Estado',
    'system_update': 'Actualizar',
  },
  'pt_PT': {
    'title': 'Definições',
    'prompt_volume': 'Vol. avisos',
    'status_detection': 'Estado',
    'system_update': 'Atualizações',
  },
  'ru_RU': {
    'title': 'Настройки',
    'prompt_volume': 'Громкость',
    'status_detection': 'Диагностика',
    'system_update': 'Обновления',
  },
  'fr_FR': {
    'title': 'Paramètres',
    'prompt_volume': 'Volume vocal',
    'status_detection': 'Contrôle',
    'system_update': 'Mises à jour',
  },
  'ko_KR': {'system_update': '업데이트'},
  'ar_SA': {
    'title': 'الإعدادات',
    'date_time': 'تاريخ ووقت',
    'device_info': 'عن الجهاز',
    'prompt_volume': 'الصوت',
    'system_update': 'التحديثات',
  },
  'de_DE': {
    'title': 'Einstellungen',
    'date_time': 'Datum & Zeit',
    'prompt_volume': 'Lautstärke',
    'system_update': 'Updates',
  },
  'tr_TR': {
    'title': 'Ayarlar',
    'prompt_volume': 'Uyarı sesi',
    'status_detection': 'Durum',
    'system_update': 'Güncelleme',
  },
};

const _menuKeys = [
  'language_setting',
  'date_time',
  'device_info',
  'wifi_ble',
  'history_record',
  'prompt_volume',
  'status_detection',
  'system_update',
];

Map<String, Map<String, String>> withSettingsMenuTranslations(
  Map<String, Map<String, String>> source,
) => {
  for (final entry in source.entries)
    entry.key: {
      ...entry.value,
      'settings_menu_title':
          _shortMenuLabels[entry.key]?['title'] ??
          entry.value['setting_menu'] ??
          '',
      for (final key in _menuKeys)
        'settings_menu_$key':
            _shortMenuLabels[entry.key]?[key] ?? entry.value[key] ?? key,
    },
};
