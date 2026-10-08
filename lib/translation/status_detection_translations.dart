const statusDetectionTranslations = <String, Map<String, String>>{
  'zh_CN': {
    'status_detection': '状态检测',
    'status_tds_label': 'TDS 水质',
    'status_tds_reading': '正在读取水质…',
    'status_water_normal': '水质正常',
    'status_water_abnormal': '水质异常',
    'status_tds_unavailable': '水质状态暂不可用，请重新进入此页面检测。',
    'status_tds_rule': 'TDS 小于 10 为正常，大于或等于 10 为异常。',
    'status_detection_hint': '此处显示本次进入时的检测结果。更换水源后，请重新进入此页面检测。',
  },
  'en_US': {
    'status_detection': 'Status Check',
    'status_tds_label': 'Water TDS',
    'status_tds_reading': 'Reading water quality…',
    'status_water_normal': 'Water quality normal',
    'status_water_abnormal': 'Water quality abnormal',
    'status_tds_unavailable':
        'Water quality is unavailable. Reopen this page to check again.',
    'status_tds_rule':
        'TDS below 10 is normal. TDS of 10 or above is abnormal.',
    'status_detection_hint':
        'This result was read when you opened this page. Reopen it after replacing the water.',
  },
  'es_ES': {
    'status_detection': 'Comprobar estado',
    'status_tds_label': 'TDS del agua',
    'status_tds_reading': 'Leyendo la calidad del agua…',
    'status_water_normal': 'Calidad del agua normal',
    'status_water_abnormal': 'Calidad del agua anormal',
    'status_tds_unavailable':
        'Calidad del agua no disponible. Vuelva a abrir esta página para comprobarla.',
    'status_tds_rule':
        'TDS inferior a 10: normal. TDS de 10 o superior: anormal.',
    'status_detection_hint':
        'El resultado se leyó al abrir esta página. Vuelva a abrirla después de cambiar el agua.',
  },
  'pt_PT': {
    'status_detection': 'Verificar estado',
    'status_tds_label': 'TDS da água',
    'status_tds_reading': 'A ler a qualidade da água…',
    'status_water_normal': 'Qualidade da água normal',
    'status_water_abnormal': 'Qualidade da água anormal',
    'status_tds_unavailable':
        'Qualidade da água indisponível. Reabra esta página para verificar novamente.',
    'status_tds_rule':
        'TDS inferior a 10: normal. TDS igual ou superior a 10: anormal.',
    'status_detection_hint':
        'O resultado foi lido ao abrir esta página. Reabra-a após substituir a água.',
  },
  'ru_RU': {
    'status_detection': 'Проверка состояния',
    'status_tds_label': 'TDS воды',
    'status_tds_reading': 'Проверка качества воды…',
    'status_water_normal': 'Качество воды в норме',
    'status_water_abnormal': 'Отклонение качества воды',
    'status_tds_unavailable':
        'Данные о воде недоступны. Откройте эту страницу заново для проверки.',
    'status_tds_rule': 'TDS ниже 10 — норма. TDS от 10 и выше — отклонение.',
    'status_detection_hint':
        'Результат получен при открытии страницы. После замены воды откройте её заново.',
  },
  'fr_FR': {
    'status_detection': 'Vérification de l’état',
    'status_tds_label': 'TDS de l’eau',
    'status_tds_reading': 'Lecture de la qualité de l’eau…',
    'status_water_normal': 'Qualité de l’eau normale',
    'status_water_abnormal': 'Qualité de l’eau anormale',
    'status_tds_unavailable':
        'Qualité de l’eau indisponible. Rouvrez cette page pour vérifier à nouveau.',
    'status_tds_rule':
        'TDS inférieur à 10 : normal. TDS de 10 ou plus : anormal.',
    'status_detection_hint':
        'Ce résultat a été lu à l’ouverture de la page. Rouvrez-la après avoir changé l’eau.',
  },
  'ko_KR': {
    'status_detection': '상태 확인',
    'status_tds_label': '수질 TDS',
    'status_tds_reading': '수질을 읽는 중…',
    'status_water_normal': '수질 정상',
    'status_water_abnormal': '수질 이상',
    'status_tds_unavailable': '수질 정보를 확인할 수 없습니다. 이 페이지를 다시 열어 확인하세요.',
    'status_tds_rule': 'TDS가 10 미만이면 정상, 10 이상이면 이상입니다.',
    'status_detection_hint': '페이지를 열 때 확인한 결과입니다. 물을 교체한 후 페이지를 다시 열어 확인하세요.',
  },
  'ar_SA': {
    'status_detection': 'فحص الحالة',
    'status_tds_label': 'TDS المياه',
    'status_tds_reading': 'جارٍ قراءة جودة المياه…',
    'status_water_normal': 'جودة المياه طبيعية',
    'status_water_abnormal': 'جودة المياه غير طبيعية',
    'status_tds_unavailable':
        'بيانات جودة المياه غير متاحة. أعد فتح هذه الصفحة للفحص مجددًا.',
    'status_tds_rule': 'TDS أقل من 10 طبيعي. TDS يساوي 10 أو أكثر غير طبيعي.',
    'status_detection_hint':
        'هذه نتيجة الفحص عند فتح الصفحة. أعد فتحها بعد تغيير المياه.',
  },
  'de_DE': {
    'status_detection': 'Statusprüfung',
    'status_tds_label': 'Wasser-TDS',
    'status_tds_reading': 'Wasserqualität wird gelesen…',
    'status_water_normal': 'Wasserqualität normal',
    'status_water_abnormal': 'Wasserqualität auffällig',
    'status_tds_unavailable':
        'Wasserqualität nicht verfügbar. Öffnen Sie diese Seite erneut zur Prüfung.',
    'status_tds_rule': 'TDS unter 10 ist normal. TDS ab 10 ist auffällig.',
    'status_detection_hint':
        'Das Ergebnis wurde beim Öffnen dieser Seite gelesen. Öffnen Sie sie nach dem Wasserwechsel erneut.',
  },
  'tr_TR': {
    'status_detection': 'Durum kontrolü',
    'status_tds_label': 'Su TDS değeri',
    'status_tds_reading': 'Su kalitesi okunuyor…',
    'status_water_normal': 'Su kalitesi normal',
    'status_water_abnormal': 'Su kalitesi anormal',
    'status_tds_unavailable':
        'Su kalitesi alınamıyor. Yeniden kontrol etmek için bu sayfayı tekrar açın.',
    'status_tds_rule':
        '10 altındaki TDS normaldir. 10 ve üzerindeki TDS anormaldir.',
    'status_detection_hint':
        'Sonuç bu sayfa açıldığında okundu. Suyu değiştirdikten sonra sayfayı yeniden açın.',
  },
};

Map<String, Map<String, String>> withStatusDetectionTranslations(
  Map<String, Map<String, String>> existing,
) => {
  for (final entry in existing.entries)
    entry.key: {...entry.value, ...?statusDetectionTranslations[entry.key]},
};
