// App 多语言文案表。
//
// 所有页面展示文案按语言代码集中维护在这里。
import 'package:get/get.dart';
import 'package:infibo_app/config/app_brand.dart';
import 'water_quality_translations.dart';
import 'status_detection_translations.dart';
import 'ota_translations.dart';
import 'settings_menu_translations.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => withSettingsMenuTranslations(
    withOtaTranslations(withStatusDetectionTranslations(_baseKeys)),
  );

  Map<String, Map<String, String>>
  get _baseKeys => withWaterQualityTranslations({
    ///////////////////////////////////////////////////////////中文语言////////////////////////////////////////////////
    'zh_CN': {
      'prompt_volume': '提示音音量',
      'prompt_volume_hint': '调节欢迎、开始、结束和水提示音。0% 为静音，松手后自动保存。',
      'prompt_volume_update_failed': '音量调节失败，请重试',
      'prompt_volume_save_failed': '音量保存失败，请重新调节后重试',
      // 通用
      'settings': '设置',
      'administrator': '管理员',
      'back': '返回',
      'confirm': '确认',
      'cancel': '取消',
      'save': '保存',
      'delete': '删除',
      'select': '选择',
      'name': '输入姓名',
      'age': '输入年龄',
      'phone': '输入手机号',
      'gender': '性别',
      'male': '男',
      'female': '女',
      'frequency': '频率',
      'intensity': '强度',
      'mode': '模式',
      'waveform': '波形',
      'select_waveform': '选择波形',
      'continuous': '连续',
      'pulse': '脉冲',
      'power': '功率',
      'chakra_power': '强度',
      'running': '正在运行',
      'waiting': '等待运行',
      'logout': '退出登录',
      'parameter_settings': '参数设置',

      // Wi-Fi 与蓝牙连接提示
      'connection_prompt_title': '未连接',
      'connection_prompt_subtitle': '请连接后继续',
      'connection_prompt_wifi': 'WIFI',
      'connection_prompt_ble': 'BLE',
      'connection_status_checking': '检测中',
      'connection_status_connected': '已连接',
      'connection_status_disconnected': '未连接',
      'connection_prompt_skip': '跳过',
      'wifi_ble': 'WIFI & BLE',
      'wifi_name_unavailable': '无法获取网络名称',
      'wifi_no_connected_network': '未连接任何网络',
      'ble_no_connected_device': '未连接任何设备',

      // 设置页面
      'setting_menu': '设置菜单',
      'language_setting': '语言设置',
      'language_switch': '语言切换',
      'save_changes': '保存更改',
      'date_time': '日期和时间',
      'year_unit': '年',
      'month_unit': '月',
      'day_unit': '日',
      'hour_unit': '时',
      'am_label': '上午',
      'pm_label': '下午',
      'date_time_saved': '日期和时间已保存',
      'device_info': '设备信息',
      'debug_mode': '调试模式',
      'history_record': '历史记录',
      'history_detail_missing': '历史记录不存在',
      'current_account_not_logged_in': '当前账号未登录',
      'therapy_record_load_failed': '健康体验记录加载失败',
      'no_history_records': '暂无历史记录',
      'no_therapy_records': '暂无健康体验记录',
      'years_old_unit': '岁',
      'therapy_report': '健康体验报告',
      'total_therapy_duration': '健康时长',
      'feedback_label': '体验感受：',
      'no_feedback': '暂无体验感受',
      'treatment_modules': '健康模块',
      'energy_score': '能量指数',
      'cell_score': '活力指数',
      'relaxation_score': '放松指数',
      'immune_score': '健康指数',
      'compared_to_last': '较上次',
      'session_once_1': '1次',
      'session_once_2': '2次',
      'session_once_3': '3次',
      'current_session': '本次',
      'health_effect_assessment': '健康体验概览',
      'status_good': '良好',
      'overall_score': '综合得分',
      'level_low': '低',
      'level_medium': '中',
      'level_high': '高',
      'therapy_feedback_hint': '请输入健康体验感受',
      'score_unit': '分',
      'minutes_unit': '分',
      'seconds_unit': '秒',
      'user_management': '用户管理',
      'unsupported_language': '该语言暂未支持',

      // 主页面
      'preset_mode': '预设健康模式',
      'preset_mode_subtitle': '10种日常健康方案',
      'device_ready': '设备就绪',
      'custom_plan': '自定义方案',
      'deep_relax': '深度放松',
      'energy_boost': '焕新充能',
      'pain_relief': '柔和舒适',
      'sleep_enhancement': '夜间放松',
      'sports_recovery': '活动后放松',
      'stress_release': '舒缓放松',
      'immune_boost': '日常活力',
      'anti_aging': '焕采活力',
      'full_care': '全身焕新',
      'mental_healing': '心情平衡',
      'device_fault': '设备故障',
      'water_level_warning_title': '设备缺水提醒',
      'water_level_warning_message': '水箱水量不足，请及时加水后继续使用设备',
      'water_level_shortage_title': '设备缺水提醒',
      'water_level_shortage_message': '水量不足，请连接水源自动加水',
      'water_level_shortage_unavailable': '分子氢功能暂不可用',
      'water_level_filling_title': '注水中',
      'water_level_filling_message': '正在注水，请稍候...',
      'water_level_complete_title': '注水完成',
      'water_level_complete_message': '注水已完成，可以继续使用设备',
      'water_level_ready_button': '已备好水源？',
      'water_level_start_filling_button': '开始加水',

      // 登录页面
      'login_email_hint': '输入邮箱',
      'login_password_hint': '输入密码',
      'forgot_password': '忘记密码?',
      'login': '登录',
      'register': '注册',
      'agree_prefix': '我已阅读并同意 ',
      'user_agreement': '用户协议',
      'and': ' 和 ',
      'privacy_policy': '隐私政策',

      //注册页面
      'Admin': '管理员',
      'Operator': '操作员',
      'User': '个人',
      'verify_code': '输入验证码',
      'send_code': '发送中...',
      'get_code': '获取验证码',
      'registering': '注册中...',
      'already_have_account': '已有账号?',
      'login_now': '立即登录',
      'prompt': '提示',
      'email_empty': '请先输入邮箱',
      'email_invalid': '请输入正确的邮箱',
      'code_send_failed': '验证码发送失败',
      'register_success': '注册成功',
      'register_failed': '注册失败',
      'email_required': '请输入邮箱',
      'password_required': '请输入密码',
      'login_success_empty_user': '登录成功，但用户信息为空',
      'login_success': '登录成功',
      'login_failed': '登录失败',
      'error': '错误',
      'network_error': '网络连接失败，请检查网络或服务器',
      'unknown_error': '未知错误',
      'login_request_failed': '登录请求失败：',
      'new_password_hint': '输入新密码',
      'confirm_new_password_hint': '确认新密码',
      'resetting_password': '重置中...',
      'confirm_reset': '确认重置',
      'code_sent_backend_email': '验证码已发送至：',
      'verify_code_required': '请输入验证码',
      'new_password_required': '请输入新密码',
      'confirm_new_password_required': '请再次输入新密码',
      'passwords_not_match': '两次输入的密码不一致',
      'password_reset_success': '密码重置成功',
      'password_reset_failed': '密码重置失败',

      // 用户选择页面
      'choose_therapy_user': '选择体验用户',
      'search_user_hint': '输入用户姓名或手机号',
      'add_user': '添加用户',
      'user_name_label': '姓名',
      'user_age_label': '年龄',
      'user_phone_label': '电话',
      'user_email_label': '邮箱',
      'user_email_hint': '请输入邮箱',
      'user_gender_label': '性别',
      'user_male': '男',
      'user_female': '女',
      'user_remark_label': '备注',
      'user_remark_hint': '请输入备注',
      'user_required_fields': '请填写姓名、年龄和电话',
      'user_invalid_age': '请输入有效年龄',
      'add_user_failed': '添加用户失败',
      'confirm_selection': '确认选择',

      // 音乐页面
      'confirm_music_selection': '确认选择',
      'music_resource_missing': '当前音乐暂无音频资源',

      // 启动页面
      'red_light': '红光',
      'wavelength': '波长',
      'hydrogen_molecule': '分子氢',
      'hydrogen_concentration': '氢气浓度',
      'flow': '流量',
      'chakra': '脉轮',
      'terahertz': '太赫兹',
      'fragrance': '香氛',
      'therapy_completed': '健康体验完成',
      'user': '使用者',
      'session_duration': '本次使用',
      'module_duration': '模块时长',
      'no_module_record': '暂无模块运行记录',
      'not_running': '未运行',
      'running_label': '运行',
      'default_mode_title': '深度放松',
      'no_user_selected': '未选择用户',
      'error_send_params_failed': '参数下发失败：',
      'error_pause_failed': '暂停失败：',
      'error_resume_failed': '继续失败：',
      'error_stop_failed': '停止失败：',

      // 自定义列表页面
      'custom_plan_title': '自定义方案',
      'plan_search_hint': '输入方案名称',
      'add_plan': '添加方案',
      'rename_plan': '重命名',
      'plan_name_empty': '方案名称不能为空',
      'custom_plan_load_failed': '自定义方案加载失败：',
      'user_not_logged_in_retry': '用户未登录，请重新登录',

      // 自定义编辑页面
      'red_ther': '红光',
      'add_therapy_module': '添加健康模块',
      'expand_feature': '拓展功能',
      'save_params': '保存参数',
      'save_plan': '保存方案',
      'plan_saving': '正在保存，请稍后',
      'plan_save_slow': '保存响应较慢，请稍后',
      'plan_save_retry': '保存失败，请重试',
      'custom_plan_edit_invalid': '当前方案信息异常，请返回后重试',
      'complete_previous_node': '请先完成上一个 5 分钟节点',
      'node_saved_prefix': '第 ',
      'node_saved_suffix': ' 分钟节点参数已保存',
      'plan_naming': '方案命名',
      'plan_name_duplicate': '方案名称不能重复',
      'mode_select': '模式选择',
      'module_hydrogen': '分子氢',
      'module_expand': '拓展功能',
      'redlight_strength_required': '红光660nm和850nm强度不能同时为0',
      'pemf_params_required': 'PEMF频率和强度都不能为0',
      'vat_params_required': 'VAT频率和强度都不能为0',
      'hydrogen_concentration_required': '分子氢浓度不能为0',
      'expand_params_required': '请至少选择一个拓展功能',
      'node_copied_prefix': '已复制到',
      'node_copied_suffix': '分钟节点',

      // 拓展页面
      'fragrance_setting': '香氛设置',
      'terahertz_setting': '太赫兹设置',
      'chakra_setting': '脉轮设置',
      'hifem_setting': 'HIFEM设置',
      'rotation': '轮转',
      'independent': '独立',
      'gentle': '轻柔',
      'intense': '浓烈',
      'sleep': '睡眠',
      'flow_state': '心流',
      'meditation': '冥想',
      'sine_wave': '正弦波',
      'square_wave': '方波',
      'triangle_wave': '三角波',
      'rf': '射频',
      'crown_chakra': '顶轮',
      'crown_sub': '(松果体)',
      'third_eye_chakra': '眉心轮',
      'third_eye_sub': '(脑垂体)',
      'throat_chakra': '喉轮',
      'throat_sub': '(甲状腺)',
      'heart_chakra': '心轮',
      'heart_sub': '(胸腺)',
      'solar_plexus_chakra': '太阳神轮',
      'solar_plexus_sub': '(肾)',
      'sacral_chakra': '脐轮',
      'sacral_sub': '(肝、肾、脾)',
      'root_chakra': '海底轮',
      'root_sub': '(生殖腺)',
    },

    // 波兰语
    'pl_PL': {
      'prompt_volume': 'Głośność komunikatów',
      'prompt_volume_hint':
          'Dostosuj głośność komunikatów powitalnych, rozpoczęcia, zakończenia i dotyczących wody. 0% wycisza komunikaty. Zmiany zapisują się po zwolnieniu suwaka.',
      'prompt_volume_update_failed':
          'Nie udało się zmienić głośności. Spróbuj ponownie.',
      'prompt_volume_save_failed':
          'Nie udało się zapisać głośności. Przesuń suwak ponownie.',
      // 通用
      'settings': 'Ustawienia',
      'administrator': 'Administrator',
      'back': 'Wstecz',
      'confirm': 'Potwierdź',
      'cancel': 'Anuluj',
      'save': 'Zapisz',
      'delete': 'Usuń',
      'select': 'Wybierz',
      'name': 'Wpisz imię i nazwisko',
      'age': 'Podaj wiek',
      'phone': 'Podaj numer telefonu',
      'gender': 'Płeć',
      'male': 'M',
      'female': 'K',
      'frequency': 'Częstotliwość',
      'intensity': 'Intensywność',
      'mode': 'Tryb',
      'waveform': 'Przebieg',
      'runtime_waveform': 'Przeb.',
      'select_waveform': 'Wybierz przebieg',
      'continuous': 'Ciągły',
      'pulse': 'Impulsowy',
      'runtime_pulse': 'Imp.',
      'power': 'Moc',
      'chakra_power': 'Intensywność',
      'running': 'W trakcie',
      'waiting': 'Oczekiwanie',
      'logout': 'Wyloguj',
      'parameter_settings': 'Ustawienia parametrów',
      // Wi-Fi 和蓝牙
      'connection_prompt_title': 'Brak połączenia',
      'connection_prompt_subtitle': 'Połącz, aby kontynuować',
      'connection_prompt_wifi': 'WIFI',
      'connection_prompt_ble': 'BLE',
      'connection_status_checking': 'Sprawdzanie',
      'connection_status_connected': 'Połączono',
      'connection_status_disconnected': 'Brak połączenia',
      'connection_prompt_skip': 'Pomiń',
      'wifi_ble': 'WIFI i BLE',
      'wifi_name_unavailable': 'Nazwa sieci niedostępna',
      'wifi_no_connected_network': 'Brak połączenia z siecią',
      'ble_no_connected_device': 'Brak połączonego urządzenia',
      // 设置和历史记录
      'setting_menu': 'Ustawienia',
      'language_setting': 'Język',
      'language_switch': 'Zmiana języka',
      'save_changes': 'Zapisz',
      'date_time': 'Data i czas',
      'year_unit': 'r.',
      'month_unit': 'mies.',
      'day_unit': 'd.',
      'hour_unit': 'godz.',
      'am_label': 'Przed południem',
      'pm_label': 'Po południu',
      'date_time_saved': 'Zapisano datę i czas',
      'device_info': 'Informacje o urządzeniu',
      'debug_mode': 'Diagnostyka',
      'history_record': 'Historia',
      'history_detail_missing': 'Nie znaleziono wpisu w historii',
      'current_account_not_logged_in': 'Nie zalogowano się na bieżące konto',
      'therapy_record_load_failed': 'Nie udało się wczytać historii sesji',
      'no_history_records': 'Brak wpisów w historii',
      'no_therapy_records': 'Brak zapisanych sesji',
      'years_old_unit': 'lat',
      'therapy_report': 'Raport sesji',
      'total_therapy_duration': 'Czas sesji',
      'feedback_label': 'Wrażenia z sesji: ',
      'no_feedback': 'Brak wrażeń z sesji',
      'treatment_modules': 'Moduły sesji',
      'energy_score': 'Energia',
      'cell_score': 'Witalność',
      'relaxation_score': 'Relaks',
      'immune_score': 'Dobrostan',
      'compared_to_last': 'vs ost.',
      'session_once_1': '1.',
      'session_once_2': '2.',
      'session_once_3': '3.',
      'current_session': 'Bieżąca',
      'health_effect_assessment': 'Podsumowanie sesji',
      'status_good': 'Dobry',
      'overall_score': 'Ocena ogólna',
      'level_low': 'Niski',
      'level_medium': 'Średni',
      'level_high': 'Wysoki',
      'therapy_feedback_hint': 'Wpisz wrażenia z sesji',
      'score_unit': 'pkt',
      'minutes_unit': 'min',
      'seconds_unit': 's',
      'user_management': 'Użytkownicy',
      'unsupported_language': 'Ten język nie jest jeszcze obsługiwany',
      // 主页面和水位提示
      'preset_mode': 'Gotowe programy',
      'preset_mode_subtitle': '10 programów na co dzień',
      'device_ready': 'Urządzenie gotowe',
      'custom_plan': 'Własny plan',
      'deep_relax': 'GŁĘBOKI RELAKS',
      'energy_boost': 'NOWA ENERGIA',
      'pain_relief': 'KOMFORT',
      'sleep_enhancement': 'NA DOBRANOC',
      'sports_recovery': 'PO TRENINGU',
      'stress_release': 'WYCISZENIE',
      'immune_boost': 'WITALNOŚĆ',
      'anti_aging': 'BLASK I WIGOR',
      'full_care': 'RESET CIAŁA',
      'mental_healing': 'RÓWNOWAGA',
      'device_fault': 'Usterka urządzenia',
      'water_level_warning_title': 'Niski poziom wody',
      'water_level_warning_message':
          'Poziom wody w zbiorniku jest niski. Uzupełnij wodę przed dalszym użyciem.',
      'water_level_shortage_title': 'Niski poziom wody',
      'water_level_shortage_message':
          'Za mało wody. Podłącz źródło wody, aby rozpocząć automatyczne napełnianie.',
      'water_level_shortage_unavailable':
          'Funkcja wodoru cząsteczkowego jest chwilowo niedostępna',
      'water_level_filling_title': 'Napełnianie',
      'water_level_filling_message': 'Trwa napełnianie wodą. Proszę czekać…',
      'water_level_complete_title': 'Napełnianie zakończone',
      'water_level_complete_message':
          'Napełnianie zakończone. Możesz dalej korzystać z urządzenia.',
      'water_level_ready_button': 'Źródło wody gotowe?',
      'water_level_start_filling_button': 'Rozpocznij napełnianie',
      // 登录、注册和密码重置
      'login_email_hint': 'Wpisz adres e-mail',
      'login_password_hint': 'Wpisz hasło',
      'forgot_password': 'Nie pamiętasz hasła?',
      'login': 'Zaloguj się',
      'register': 'Zarejestruj się',
      'agree_prefix': 'Potwierdzam zapoznanie się z treścią i akceptuję ',
      'user_agreement': 'Regulamin użytkownika',
      'and': ' i ',
      'privacy_policy': 'Politykę prywatności',
      'Admin': 'Administrator',
      'Operator': 'Operator',
      'User': 'Osoba prywatna',
      'verify_code': 'Wpisz kod weryfikacyjny',
      'send_code': 'Wysyłanie…',
      'get_code': 'Pobierz kod',
      'registering': 'Rejestracja…',
      'already_have_account': 'Masz już konto?',
      'login_now': 'Zaloguj się teraz',
      'prompt': 'Informacja',
      'email_empty': 'Najpierw wpisz adres e-mail',
      'email_invalid': 'Wpisz prawidłowy adres e-mail',
      'code_send_failed': 'Nie udało się wysłać kodu weryfikacyjnego',
      'register_success': 'Rejestracja zakończona',
      'register_failed': 'Rejestracja nie powiodła się',
      'email_required': 'Wpisz adres e-mail',
      'password_required': 'Wpisz hasło',
      'login_success_empty_user': 'Zalogowano, ale brakuje danych użytkownika',
      'login_success': 'Zalogowano pomyślnie',
      'login_failed': 'Logowanie nie powiodło się',
      'error': 'Błąd',
      'network_error': 'Błąd połączenia z siecią. Sprawdź sieć lub serwer.',
      'unknown_error': 'Nieznany błąd',
      'login_request_failed': 'Żądanie logowania nie powiodło się: ',
      'new_password_hint': 'Wpisz nowe hasło',
      'confirm_new_password_hint': 'Potwierdź nowe hasło',
      'resetting_password': 'Resetowanie…',
      'confirm_reset': 'Potwierdź reset',
      'code_sent_backend_email': 'Kod weryfikacyjny wysłano na: ',
      'verify_code_required': 'Wpisz kod weryfikacyjny',
      'new_password_required': 'Wpisz nowe hasło',
      'confirm_new_password_required': 'Wpisz ponownie nowe hasło',
      'passwords_not_match': 'Hasła nie są zgodne',
      'password_reset_success': 'Hasło zostało zresetowane',
      'password_reset_failed': 'Nie udało się zresetować hasła',
      // 用户选择和音乐
      'choose_therapy_user': 'Wybierz użytkownika',
      'search_user_hint': 'Wpisz imię i nazwisko lub numer telefonu',
      'add_user': 'Dodaj użytkownika',
      'user_name_label': 'Imię i nazw.',
      'user_age_label': 'Wiek',
      'user_phone_label': 'Telefon',
      'user_email_label': 'E-mail',
      'user_email_hint': 'Wpisz adres e-mail',
      'user_gender_label': 'Płeć',
      'user_male': 'Mężczyzna',
      'user_female': 'Kobieta',
      'user_remark_label': 'Uwagi',
      'user_remark_hint': 'Wpisz uwagi',
      'user_required_fields': 'Podaj imię i nazwisko, wiek oraz numer telefonu',
      'user_invalid_age': 'Podaj prawidłowy wiek',
      'add_user_failed': 'Nie udało się dodać użytkownika',
      'confirm_selection': 'Potwierdź wybór',
      'confirm_music_selection': 'Potwierdź wybór',
      'music_resource_missing': 'Brak pliku dźwiękowego dla tego utworu',
      // 运行页面
      'red_light': 'RED Tec.',
      'wavelength': 'Długość fali',
      'runtime_wavelength': 'Dł. fali',
      'runtime_frequency': 'Częst.',
      'runtime_intensity': 'Intens.',
      'hydrogen_molecule': 'H₂',
      'hydrogen_concentration': 'Stężenie H₂',
      'flow': 'Przepływ',
      'chakra': 'Czakry',
      'terahertz': 'Teraherce',
      'fragrance': 'Aromat',
      'therapy_completed': 'Sesja zakończona',
      'user': 'Użytkownik',
      'session_duration': 'Czas sesji',
      'module_duration': 'Czas pracy modułu',
      'no_module_record': 'Brak zapisów pracy modułów',
      'not_running': 'Nieaktywny',
      'running_label': 'Czas pracy',
      'default_mode_title': 'Głęboki relaks',
      'no_user_selected': 'Nie wybrano użytkownika',
      'error_send_params_failed': 'Nie udało się wysłać parametrów: ',
      'error_pause_failed': 'Nie udało się wstrzymać: ',
      'error_resume_failed': 'Nie udało się wznowić: ',
      'error_stop_failed': 'Nie udało się zatrzymać: ',
      // 自定义方案
      'custom_plan_title': 'Własne plany',
      'plan_search_hint': 'Wpisz nazwę planu',
      'add_plan': 'Dodaj plan',
      'rename_plan': 'Zmień nazwę',
      'plan_name_empty': 'Nazwa planu nie może być pusta',
      'custom_plan_load_failed': 'Nie udało się wczytać własnych planów: ',
      'user_not_logged_in_retry':
          'Użytkownik nie jest zalogowany. Zaloguj się ponownie.',
      'red_ther': 'RED Tec.',
      'add_therapy_module': 'Dodaj moduł',
      'expand_feature': 'Dodatkowe funkcje',
      'save_params': 'Zapisz',
      'save_plan': 'Zapisz plan',
      'plan_saving': 'Zapisywanie. Proszę czekać',
      'plan_save_slow': 'Zapisywanie trwa dłużej niż zwykle. Proszę czekać',
      'plan_save_retry': 'Nie udało się zapisać. Spróbuj ponownie',
      'custom_plan_edit_invalid':
          'Bieżący plan jest nieprawidłowy. Wróć i spróbuj ponownie',
      'complete_previous_node': 'Najpierw uzupełnij poprzedni 5-minutowy etap',
      'node_saved_prefix': 'Zapisano parametry etapu: ',
      'node_saved_suffix': ' min',
      'plan_naming': 'Nazwa planu',
      'plan_name_duplicate': 'Nazwa planu nie może się powtarzać',
      'mode_select': 'Wybór trybu',
      'module_hydrogen': 'H₂',
      'module_expand': 'Dodatki',
      'redlight_strength_required':
          'Intensywność światła 660 nm i 850 nm nie może jednocześnie wynosić 0',
      'pemf_params_required':
          'Częstotliwość i intensywność PEMF muszą być większe od 0',
      'vat_params_required':
          'Częstotliwość i intensywność VAT muszą być większe od 0',
      'hydrogen_concentration_required': 'Stężenie H₂ nie może wynosić 0',
      'expand_params_required': 'Wybierz co najmniej jedną dodatkową funkcję',
      'node_copied_prefix': 'Skopiowano do etapu: ',
      'node_copied_suffix': ' min',
      // 拓展功能
      'fragrance_setting': 'Ustawienia aromatu',
      'terahertz_setting': 'Ustawienia teraherców',
      'chakra_setting': 'Ustawienia czakr',
      'hifem_setting': 'Ustawienia HIFEM',
      'rotation': 'Naprzemiennie',
      'independent': 'Niezależnie',
      'gentle': 'Delikatny',
      'intense': 'Intensywny',
      'sleep': 'Sen',
      'flow_state': 'Skupienie',
      'meditation': 'Medytacja',
      'sine_wave': 'Sinusoidalny',
      'square_wave': 'Prostokątny',
      'triangle_wave': 'Trójkątny',
      'rf': 'RF',
      'crown_chakra': 'Czakra korony',
      'crown_sub': '(Szyszynka)',
      'third_eye_chakra': 'Czakra trzeciego oka',
      'third_eye_sub': '(Przysadka mózgowa)',
      'throat_chakra': 'Czakra gardła',
      'throat_sub': '(Tarczyca)',
      'heart_chakra': 'Czakra serca',
      'heart_sub': '(Grasica)',
      'solar_plexus_chakra': 'Czakra splotu słonecznego',
      'solar_plexus_sub': '(Nerka)',
      'sacral_chakra': 'Czakra sakralna',
      'sacral_sub': '(Wątroba, nerka, śledziona)',
      'root_chakra': 'Czakra podstawy',
      'root_sub': '(Gonady)',
    },
    //////////////////////////////////////////////////////英语语言/////////////////////////////////////////////////////////////////////
    'en_US': {
      'prompt_volume': 'Prompt Volume',
      'prompt_volume_hint':
          'Adjust welcome, start, end and water prompts. 0% mutes prompts. Changes save when you release the slider.',
      'prompt_volume_update_failed':
          'Could not adjust volume. Please try again.',
      'prompt_volume_save_failed':
          'Could not save volume. Adjust the slider again to retry.',
      // 通用
      'settings': 'Setting', // 设置
      'administrator': 'Admin', // 管理员
      'back': 'Back', // 返回
      'confirm': 'Confirm', // 确认
      'cancel': 'Cancel', // 取消
      'save': 'Save', // 保存
      'delete': 'Delete', // 删除
      'select': 'Select', // 选择
      'name': 'Enter name', // 输入姓名
      'age': 'Enter age', // 输入年龄
      'phone': 'Enter phone', // 输入手机号
      'gender': 'Gender', // 性别
      'male': 'M', // 男
      'female': 'F', // 女
      'frequency': 'Frequency', // 频率
      'intensity': 'Intensity', // 强度
      'mode': 'Mode', // 模式
      'waveform': 'Wave', // 波形
      'select_waveform': 'Select Waveform', // 选择波形
      'continuous': 'Conti. ', // 连续
      'pulse': 'Pulse', // 脉冲
      'power': 'Power', // 功率
      'chakra_power': 'Power', // 强度
      'running': 'Running', // 正在运行
      'waiting': 'Waiting', // 等待运行
      'logout': 'Log out', // 退出登录
      'parameter_settings': 'Parameter Settings', // 参数设置
      // Wi-Fi and Bluetooth connection prompt
      'connection_prompt_title': 'Not connected',
      'connection_prompt_subtitle': 'Connect to continue',
      'connection_prompt_wifi': 'WIFI',
      'connection_prompt_ble': 'BLE',
      'connection_status_checking': 'Checking',
      'connection_status_connected': 'Connected',
      'connection_status_disconnected': 'Not connected',
      'connection_prompt_skip': 'Skip',
      'wifi_ble': 'WIFI & BLE',
      'wifi_name_unavailable': 'Network name unavailable',
      'wifi_no_connected_network': 'No network connected',
      'ble_no_connected_device': 'No device connected',
      // 设置页面
      'setting_menu': 'Settings', // 设置菜单
      'language_setting': 'Language', // 语言设置
      'language_switch': 'Language Switch', // 语言切换
      'save_changes': 'Save', // 保存更改
      'date_time': 'Date&Time', // 日期和时间
      'year_unit': 'Y', // 年
      'month_unit': 'M', // 月
      'day_unit': 'D', // 日
      'hour_unit': 'h', // 时
      'am_label': 'AM', // 上午
      'pm_label': 'PM', // 下午
      'date_time_saved': 'Date and time saved', // 日期和时间已保存
      'device_info': 'Device Info', // 设备信息
      'debug_mode': 'Debug', // 调试模式
      'history_record': 'History', // 历史记录
      'history_detail_missing': 'History record not found', // 历史记录不存在
      'current_account_not_logged_in':
          'Current account is not logged in', // 当前账号未登录
      'therapy_record_load_failed':
          'Failed to load wellness records', // 健康体验记录加载失败
      'no_history_records': 'No history records', // 暂无历史记录
      'no_therapy_records': 'No wellness records', // 暂无健康体验记录
      'years_old_unit': 'y', // 岁
      'therapy_report': 'Wellness Report', // 健康体验报告
      'total_therapy_duration': 'Wellness Time', // 健康时长
      'feedback_label': 'Wellness Notes: ', // 体验感受：
      'no_feedback': 'No wellness notes', // 暂无体验感受
      'treatment_modules': 'Wellness Modules', // 健康模块
      'energy_score': 'Energy Idx.', // 能量指数
      'cell_score': 'Vitality Idx.', // 活力指数
      'relaxation_score': 'Relax Idx.', // 放松指数
      'immune_score': 'Wellness Idx.', // 健康指数
      'compared_to_last': 'vs last', // 较上次
      'session_once_1': '1st', // 1次
      'session_once_2': '2nd', // 2次
      'session_once_3': '3rd', // 3次
      'current_session': 'Current', // 本次
      'health_effect_assessment': 'Wellness Overview', // 健康体验概览
      'status_good': 'Good', // 良好
      'overall_score': 'Overall Score', // 综合得分
      'level_low': 'Low', // 低
      'level_medium': 'Medium', // 中
      'level_high': 'High', // 高
      'therapy_feedback_hint': 'Enter wellness notes', // 请输入健康体验感受
      'score_unit': 'pts', // 分
      'minutes_unit': 'min', // 分
      'seconds_unit': 's', // 秒
      'user_management': 'Users', // 用户管理
      'unsupported_language': 'This language is not supported yet', // 该语言暂未支持
      // 主页面
      'preset_mode': 'Preset Wellness Modes', // 预设健康模式
      'preset_mode_subtitle': '10 daily wellness programs', // 10种日常健康方案
      'device_ready': 'Device Ready', // 设备就绪
      'custom_plan': 'Custom Plan', // 自定义方案
      'deep_relax': 'DEEP RELAX', // 深度放松
      'energy_boost': 'RE-ENERGIZE', // 焕新充能
      'pain_relief': 'GENTLE COMFORT', // 柔和舒适
      'sleep_enhancement': 'NIGHT UNWIND', // 夜间放松
      'sports_recovery': 'COOL DOWN', // 活动后放松
      'stress_release': 'CALM&RELAX', // 舒缓放松
      'immune_boost': 'DAILY BOOST', // 日常活力
      'anti_aging': 'RADIANT VITALITY', // 焕彩活力
      'full_care': 'BODY RESET', // 全身焕新
      'mental_healing': 'MOOD BOOST', // 心情平衡
      'device_fault': 'Device Fault', // 设备故障
      'water_level_warning_title': 'Low Water Alert',
      'water_level_warning_message':
          'Water tank level is low. Please refill before continuing.',
      'water_level_shortage_title': 'Low Water Alert',
      'water_level_shortage_message':
          'Low water level. Please connect a water source for automatic refilling.',
      'water_level_shortage_unavailable':
          'Molecular hydrogen is temporarily unavailable',
      'water_level_filling_title': 'Filling',
      'water_level_filling_message': 'Filling water, please wait...',
      'water_level_complete_title': 'Filling Complete',
      'water_level_complete_message':
          'Water filling complete. You may continue using the device.',
      'water_level_ready_button': 'Ready?',
      'water_level_start_filling_button': 'Start Filling',
      // 登录页面
      'login_email_hint': 'Enter email address', // 输入邮箱
      'login_password_hint': 'Enter password', // 输入密码
      'forgot_password': 'Forgot password?', // 忘记密码?
      'login': 'Login', // 登录
      'register': 'Register', // 注册
      'agree_prefix': 'I have read and agree to ', // 我已阅读并同意
      'user_agreement': 'User Agreement', // 《用户协议》
      'and': ' and ', // 和
      'privacy_policy': 'Privacy Policy', // 《隐私政策》
      // Registration page
      'Admin': 'Administrator', // 管理员
      'Operator': 'Operator', // 操作员
      'User': 'Individual', // 个人
      'verify_code': 'Enter verification code', // 输入验证码
      'send_code': 'Sending...', // 发送中...
      'get_code': 'Get Code', // 获取验证码
      'registering': 'Registering...', // 注册中...
      'already_have_account': 'Already have an account?', // 已有账号?
      'login_now': 'Log in now', // 立即登录
      'prompt': 'Notice', // 提示
      'email_empty': 'Please enter your email first', // 请先输入邮箱
      'email_invalid': 'Please enter a valid email address', // 请输入正确的邮箱
      'code_send_failed': 'Failed to send verification code', // 验证码发送失败
      'register_success': 'Registration successful', // 注册成功
      'register_failed': 'Registration failed', // 注册失败
      'email_required': 'Please enter your email address', // 请输入邮箱
      'password_required': 'Please enter your password', // 请输入密码
      'login_success_empty_user':
          'Login succeeded, but user information is empty', // 登录成功，但用户信息为空
      'login_success': 'Login successful', // 登录成功
      'login_failed': 'Login failed', // 登录失败
      'error': 'Error', // 错误
      'network_error':
          'Network connection failed, please check network or server',
      'unknown_error': 'Unknown error',
      'login_request_failed': 'Login request failed: ', // 登录请求失败：
      'new_password_hint': 'Enter new password', // 输入新密码
      'confirm_new_password_hint': 'Confirm new password', // 确认新密码
      'resetting_password': 'Resetting...', // 重置中...
      'confirm_reset': 'Confirm Reset', // 确认重置
      'code_sent_backend_email': 'Verification code sent to: ', // 验证码已发送至：
      'verify_code_required': 'Please enter the verification code', // 请输入验证码
      'new_password_required': 'Please enter a new password', // 请输入新密码
      'confirm_new_password_required':
          'Please confirm the new password', // 请再次输入新密码
      'passwords_not_match': 'The passwords do not match', // 两次输入的密码不一致
      'password_reset_success': 'Password reset successful', // 密码重置成功
      'password_reset_failed': 'Password reset failed', // 密码重置失败
      // 用户选择页面
      'choose_therapy_user': 'Select Wellness User', // 选择体验用户
      'search_user_hint': 'Enter user name or phone number', // 输入用户姓名或手机号
      'add_user': 'Add User', // 添加用户
      'user_name_label': 'Name',
      'user_age_label': 'Age',
      'user_phone_label': 'Phone',
      'user_email_label': 'Email',
      'user_email_hint': 'Enter email address',
      'user_gender_label': 'Gender',
      'user_male': 'Male',
      'user_female': 'Female',
      'user_remark_label': 'Notes',
      'user_remark_hint': 'Enter notes',
      'user_required_fields': 'Please enter name, age, and phone',
      'user_invalid_age': 'Please enter a valid age',
      'add_user_failed': 'Failed to add user',
      'confirm_selection': 'Confirm Selection', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Confirm Selection', // 确认选择
      'music_resource_missing':
          'No audio resource for this music', // 当前音乐暂无音频资源
      // 启动页面
      'red_light': 'Red Tec.', // 红光
      'wavelength': 'Wavelength', // 波长
      'hydrogen_molecule': 'H₂', // 分子氢
      'hydrogen_concentration': 'H₂ Conc.', // 氢气浓度
      // 英国版英文氢气面板显示强度，其他版本保留流量。
      'flow': AppBrand.current.flavor == 'britain' ? 'Intensity' : 'Flow',
      'chakra': 'Chakra', // 脉轮
      'terahertz': 'Terahertz', // 太赫兹
      'fragrance': 'Aroma', // 香氛
      'therapy_completed': 'Wellness Complete', // 健康体验完成
      'user': 'User', // 使用者
      'session_duration': 'Session Duration', // 本次使用
      'module_duration': 'Module Duration', // 模块时长
      'no_module_record': 'No module running records', // 暂无模块运行记录
      'not_running': 'Not running', // 未运行
      'running_label': 'Running', // 运行
      'default_mode_title': 'Deep Relaxation', // 深度放松
      'no_user_selected': 'No user selected', // 未选择用户
      'error_send_params_failed': 'Failed to send parameters: ', // 参数下发失败：
      'error_pause_failed': 'Pause failed: ', // 暂停失败：
      'error_resume_failed': 'Resume failed: ', // 继续失败：
      'error_stop_failed': 'Stop failed: ', // 停止失败：
      // 自定义列表页面
      'custom_plan_title': 'Custom Plans', // 自定义方案
      'plan_search_hint': 'Enter plan name', // 输入方案名称
      'add_plan': 'Add Plan', // 添加方案
      'rename_plan': 'Rename', // 重命名
      'plan_name_empty': 'Plan name cannot be empty', // 方案名称不能为空
      'custom_plan_load_failed': 'Failed to load custom plans: ', // 自定义方案加载失败：
      'user_not_logged_in_retry':
          'User not logged in, please log in again', // 用户未登录，请重新登录
      // 自定义编辑页面
      'red_ther': 'RED Tec.', // 红光
      'add_therapy_module': 'Add Wellness Module', // 添加健康模块
      'expand_feature': 'Expand Feature', // 拓展功能
      'save_params': 'Save', // 保存参数
      'save_plan': 'Save Plan', // 保存方案
      'plan_saving': 'Saving, please wait',
      'plan_save_slow': 'Saving is taking longer than expected, please wait',
      'plan_save_retry': 'Save failed, please try again',
      'custom_plan_edit_invalid':
          'The current plan is invalid. Go back and try again',
      'complete_previous_node':
          'Please complete the previous 5-minute node first', // 请先完成上一个 5 分钟节点
      'node_saved_prefix': 'Minute ', // 第
      'node_saved_suffix': ' node parameters saved', // 分钟节点参数已保存
      'plan_naming': 'Plan Naming', // 方案命名
      'plan_name_duplicate': 'Plan name cannot be duplicated', // 方案名称不能重复
      'mode_select': 'Modes', // 模式选择
      'module_hydrogen': 'H₂', // 分子氢
      'module_expand': 'Expand', // 拓展功能
      'redlight_strength_required':
          'Red light 660nm and 850nm intensity cannot both be 0', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required':
          'PEMF frequency and intensity cannot both be 0', // PEMF频率和强度都不能为0
      'vat_params_required':
          'VAT frequency and intensity cannot both be 0', // VAT频率和强度都不能为0
      'hydrogen_concentration_required':
          'H₂ concentration cannot be 0', // 分子氢浓度不能为0
      'expand_params_required': 'Please select at least one expand feature',
      'node_copied_prefix': 'Copied to ',
      'node_copied_suffix': ' min node',
      // 拓展页面
      'fragrance_setting': 'Aroma Setting', // 香氛设置
      'terahertz_setting': 'Terahertz Setting', // 太赫兹设置
      'chakra_setting': 'Chakra Setting', // 脉轮设置
      'hifem_setting': 'HIFEM Setting', // HIFEM设置
      'rotation': 'Rotation', // 轮转
      'independent': 'Independent', // 独立
      'gentle': 'Gentle', // 轻柔
      'intense': 'Intense', // 浓烈
      'sleep': 'Sleep', // 睡眠
      'flow_state': 'Flow', // 心流
      'meditation': 'Zen', // 冥想
      'sine_wave': 'Sine', // 正弦波
      'square_wave': 'Square', // 方波
      'triangle_wave': 'Triangle', // 三角波
      'rf': 'RF', // 射频
      'crown_chakra': 'Crown Chakra', // 顶轮
      'crown_sub': '(Pineal Gland)', // 松果体
      'third_eye_chakra': 'Third Eye Chakra', // 眉心轮
      'third_eye_sub': '(Pituitary Gland)', // 脑垂体
      'throat_chakra': 'Throat Chakra', // 喉轮
      'throat_sub': '(Thyroid)', // 甲状腺
      'heart_chakra': 'Heart Chakra', // 心轮
      'heart_sub': '(Thymus)', // 胸腺
      'solar_plexus_chakra': 'Solar Plexus Chakra', // 太阳神轮
      'solar_plexus_sub': '(Kidney)', // 肾
      'sacral_chakra': 'Sacral Chakra', // 脐轮
      'sacral_sub': '(Liver, Kidney, Spleen)', // 肝、肾、脾
      'root_chakra': 'Root Chakra', // 海底轮
      'root_sub': '(Gonads)', // 生殖腺
    },
    ///////////////////////////////////////////////////////西班牙语语言/////////////////////////////////////////////////////////////////////
    'es_ES': {
      'prompt_volume': 'Volumen de avisos',
      'prompt_volume_hint':
          'Ajusta los avisos de bienvenida, inicio, fin y agua. 0% los silencia. Se guarda al soltar el control.',
      'prompt_volume_update_failed':
          'No se pudo ajustar el volumen. Inténtalo de nuevo.',
      'prompt_volume_save_failed':
          'No se pudo guardar el volumen. Vuelve a ajustar el control.',
      // 通用
      'settings': 'Ajustes', // 设置
      'administrator': 'Admin', // 管理员
      'back': 'Atrás', // 返回
      'confirm': 'Confirmar', // 确认
      'cancel': 'Cancelar', // 取消
      'save': 'Guardar', // 保存
      'delete': 'Eliminar', // 删除
      'select': 'Elegir', // 选择
      'name': 'Ingrese nombre', // 输入姓名
      'age': 'Ingrese edad', // 输入年龄
      'phone': 'Ingrese teléfono', // 输入手机号
      'gender': 'Género', // 性别
      'male': 'M', // 男
      'female': 'F', // 女
      'frequency': 'Frecuencia', // 频率
      'intensity': 'Intensidad', // 强度
      'mode': 'Modo', // 模式
      'waveform': 'Onda', // 波形
      'select_waveform': 'Seleccionar forma de onda', // 选择波形
      'continuous': 'Cont.', // 连续
      'pulse': 'Pulso', // 脉冲
      'power': 'Potencia', // 功率
      'chakra_power': 'Pot.', // 强度
      'running': 'Activo', // 正在运行
      'waiting': 'Espera', // 等待运行
      'logout': 'Salir', // 退出登录
      'parameter_settings': 'Ajustes de parámetros', // 参数设置
      // Aviso de conexión Wi-Fi y Bluetooth
      'connection_prompt_title': 'No conectado',
      'connection_prompt_subtitle': 'Conecta para continuar',
      'connection_prompt_wifi': 'WIFI',
      'connection_prompt_ble': 'BLE',
      'connection_status_checking': 'Comprobando',
      'connection_status_connected': 'Conectado',
      'connection_status_disconnected': 'No conectado',
      'connection_prompt_skip': 'Omitir',
      'wifi_ble': 'WIFI & BLE',
      'wifi_name_unavailable': 'Nombre de red no disponible',
      'wifi_no_connected_network': 'Ninguna red conectada',
      'ble_no_connected_device': 'Ningún dispositivo conectado',
      // 设置页面
      'setting_menu': 'Ajustes', // 设置菜单
      'language_setting': 'Idioma', // 语言设置
      'language_switch': 'Cambio de idioma', // 语言切换
      'save_changes': 'Guardar', // 保存更改
      'date_time': 'Fecha', // 日期和时间
      'year_unit': 'A', // 年
      'month_unit': 'M', // 月
      'day_unit': 'D', // 日
      'hour_unit': 'h', // 时
      'am_label': 'AM', // 上午
      'pm_label': 'PM', // 下午
      'date_time_saved': 'Fecha y hora guardadas', // 日期和时间已保存
      'device_info': 'Información', // 设备信息
      'debug_mode': 'Depuración', // 调试模式
      'history_record': 'Historial', // 历史记录
      'history_detail_missing': 'Registro no encontrado', // 历史记录不存在
      'current_account_not_logged_in':
          'La cuenta actual no ha iniciado sesión', // 当前账号未登录
      'therapy_record_load_failed':
          'Error al cargar registros de bienestar', // 健康体验记录加载失败
      'no_history_records': 'Sin historial', // 暂无历史记录
      'no_therapy_records': 'Sin registros de bienestar', // 暂无健康体验记录
      'years_old_unit': 'a', // 岁
      'therapy_report': 'Informe de bienestar', // 健康体验报告
      'total_therapy_duration': 'Tiempo de bienestar', // 健康时长
      'feedback_label': 'Notas de bienestar: ', // 体验感受：
      'no_feedback': 'Sin notas de bienestar', // 暂无体验感受
      'treatment_modules': 'Módulos de bienestar', // 健康模块
      'energy_score': 'Energía', // 能量指数
      'cell_score': 'Índ. vitalidad', // 活力指数
      'relaxation_score': 'Relajación', // 放松指数
      'immune_score': 'Índ. bienestar', // 健康指数
      'compared_to_last': 'vs ant.', // 较上次
      'session_once_1': '1ª', // 1次
      'session_once_2': '2ª', // 2次
      'session_once_3': '3ª', // 3次
      'current_session': 'Actual', // 本次
      'health_effect_assessment': 'Resumen de bienestar', // 健康体验概览
      'status_good': 'Bueno', // 良好
      'overall_score': 'Puntuación general', // 综合得分
      'level_low': 'Bajo', // 低
      'level_medium': 'Medio', // 中
      'level_high': 'Alto', // 高
      'therapy_feedback_hint': 'Añade notas de bienestar', // 请输入健康体验感受
      'score_unit': 'pts', // 分
      'minutes_unit': 'min', // 分
      'seconds_unit': 's', // 秒
      'user_management': 'Usuarios', // 用户管理
      'unsupported_language': 'Este idioma aún no es compatible', // 该语言暂未支持
      // 主页
      'preset_mode': 'Modos de bienestar', // 预设健康模式
      'preset_mode_subtitle': '10 programas de bienestar', // 10种日常健康方案
      'device_ready': 'Dispositivo listo', // 设备就绪
      'custom_plan': 'Plan propio', // 自定义方案
      'deep_relax': 'RELAX PROFUNDO', // 深度放松
      'energy_boost': 'RECÁRGATE', // 焕新充能
      'pain_relief': 'CONFORT SUAVE', // 柔和舒适
      'sleep_enhancement': 'CALMA NOCT.', // 夜间放松
      'sports_recovery': 'RELAJACIÓN', // 活动后放松
      'stress_release': 'CALMA & RELAX', // 舒缓放松
      'immune_boost': 'IMPULSO DIARIO', // 日常活力
      'anti_aging': 'VITALIDAD RAD.', // 焕彩活力
      'full_care': 'RENUEVA', // 全身焕新
      'mental_healing': 'BUEN ÁNIMO', // 心情平衡
      'device_fault': 'Fallo de dispositivo', // 设备故障
      'water_level_warning_title': 'Aviso de agua insuficiente',
      'water_level_warning_message':
          'El nivel del tanque de agua es bajo. Rellénelo para continuar.',
      'water_level_shortage_title': 'Falta de agua',
      'water_level_shortage_message':
          'Agua insuficiente. Conecte el suministro de agua para el llenado automático.',
      'water_level_shortage_unavailable':
          'Hidrógeno molecular no disponible temporalmente',
      'water_level_filling_title': 'Llenando',
      'water_level_filling_message': 'Llenando agua, espere...',
      'water_level_complete_title': 'Llenado completo',
      'water_level_complete_message':
          'Llenado de agua completo. Puede continuar usando el dispositivo.',
      'water_level_ready_button': '¿Listo?',
      'water_level_start_filling_button': 'Iniciar llenado',
      // 登录页面
      'login_email_hint': 'Ingrese correo electrónico', // 输入邮箱
      'login_password_hint': 'Ingrese contraseña', // 输入密码
      'forgot_password': '¿Olvidaste la contraseña?', // 忘记密码?
      'login': 'Iniciar sesión', // 登录
      'register': 'Registrarse', // 注册
      'agree_prefix': 'Acepto ', // 我已阅读并同意
      'user_agreement': 'Acuerdo de usuario', // 《用户协议》
      'and': ' y ', // 和
      'privacy_policy': 'Política de privacidad', // 《隐私政策》
      // 注册页面
      'Admin': 'Administrador', // 管理员
      'Operator': 'Operador', // 操作员
      'User': 'Particular', // 个人
      'verify_code': 'Código de verificación', // 输入验证码
      'send_code': 'Enviando...', // 发送中...
      'get_code': 'Obtener código', // 获取验证码
      'registering': 'Registrando...', // 注册中...
      'already_have_account': '¿Ya tiene una cuenta?', // 已有账号?
      'login_now': 'Iniciar sesión ahora', // 立即登录
      'prompt': 'Aviso', // 提示
      'email_empty': 'Ingrese primero su correo electrónico', // 请先输入邮箱
      'email_invalid': 'Ingrese un correo electrónico válido', // 请输入正确的邮箱
      'code_send_failed':
          'Error al enviar el código de verificación', // 验证码发送失败
      'register_success': 'Registro exitoso', // 注册成功
      'register_failed': 'Error de registro', // 注册失败
      'email_required': 'Ingrese su correo electrónico', // 请输入邮箱
      'password_required': 'Ingrese su contraseña', // 请输入密码
      'login_success_empty_user':
          'Inicio de sesión correcto, pero faltan los datos del usuario', // 登录成功，但用户信息为空
      'login_success': 'Inicio de sesión correcto', // 登录成功
      'login_failed': 'Error al iniciar sesión', // 登录失败
      'error': 'Error', // 错误
      'network_error': 'Error de conexión, compruebe la red o el servidor',
      'unknown_error': 'Error desconocido',
      'login_request_failed':
          'Error en la solicitud de inicio de sesión: ', // 登录请求失败：
      'new_password_hint': 'Ingrese la nueva contraseña', // 输入新密码
      'confirm_new_password_hint': 'Confirme la nueva contraseña', // 确认新密码
      'resetting_password': 'Restableciendo...', // 重置中...
      'confirm_reset': 'Confirmar restablecimiento', // 确认重置
      'code_sent_backend_email':
          'Código de verificación enviado a: ', // 验证码已发送至：
      'verify_code_required': 'Ingrese el código de verificación', // 请输入验证码
      'new_password_required': 'Ingrese una nueva contraseña', // 请输入新密码
      'confirm_new_password_required':
          'Confirme la nueva contraseña', // 请再次输入新密码
      'passwords_not_match': 'Las contraseñas no coinciden', // 两次输入的密码不一致
      'password_reset_success':
          'Contraseña restablecida correctamente', // 密码重置成功
      'password_reset_failed': 'Error al restablecer la contraseña', // 密码重置失败
      // 用户选择页面
      'choose_therapy_user': 'Elegir usuario', // 选择体验用户
      'search_user_hint': 'Nombre o teléfono', // 输入用户姓名或手机号
      'add_user': 'Agregar usuario', // 添加用户
      'user_name_label': 'Nombre',
      'user_age_label': 'Edad',
      'user_phone_label': 'Teléfono',
      'user_email_label': 'Correo',
      'user_email_hint': 'Ingrese correo electrónico',
      'user_gender_label': 'Género',
      'user_male': 'Hombre',
      'user_female': 'Mujer',
      'user_remark_label': 'Notas',
      'user_remark_hint': 'Ingrese notas',
      'user_required_fields': 'Complete nombre, edad y teléfono',
      'user_invalid_age': 'Ingrese una edad válida',
      'add_user_failed': 'No se pudo agregar el usuario',
      'confirm_selection': 'Confirmar selección', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Confirmar selección', // 确认选择
      'music_resource_missing':
          'Esta música no tiene audio disponible', // 当前音乐暂无音频资源
      // 启动页面
      'red_light': 'Luz roja', // 红光
      'wavelength': 'Long. onda', // 波长
      'hydrogen_molecule': 'H₂', // 分子氢
      'hydrogen_concentration': 'Conc. H₂', // 氢气浓度
      'flow': 'Flujo', // 流量
      'chakra': 'Chakra', // 脉轮
      'terahertz': 'THz', // 太赫兹
      'fragrance': 'Aroma', // 香氛
      'therapy_completed': 'Bienestar completado', // 健康体验完成
      'user': 'Usuario', // 使用者
      'session_duration': 'Duración de sesión', // 本次使用
      'module_duration': 'Tiempo módulo', // 模块时长
      'no_module_record': 'Sin registros de ejecución', // 暂无模块运行记录
      'not_running': 'Sin ejecutar', // 未运行
      'running_label': 'Ejecutando', // 运行
      'default_mode_title': 'Relajación profunda', // 深度放松
      'no_user_selected': 'No hay usuario seleccionado', // 未选择用户
      'error_send_params_failed': 'Error al enviar parámetros: ', // 参数下发失败：
      'error_pause_failed': 'Error al pausar: ', // 暂停失败：
      'error_resume_failed': 'Error al continuar: ', // 继续失败：
      'error_stop_failed': 'Error al detener: ', // 停止失败：
      // 自定义列表页面
      'custom_plan_title': 'Planes personalizados', // 自定义方案
      'plan_search_hint': 'Ingrese nombre del plan', // 输入方案名称
      'add_plan': 'Agregar plan', // 添加方案
      'rename_plan': 'Renombrar', // 重命名
      'plan_name_empty': 'El nombre no puede estar vacío', // 方案名称不能为空
      'custom_plan_load_failed': 'Error al cargar planes: ', // 自定义方案加载失败：
      'user_not_logged_in_retry':
          'Usuario no conectado, inicie sesión de nuevo', // 用户未登录，请重新登录
      // 自定义编辑页面
      'red_ther': 'LUZ ROJA', // 红光
      'add_therapy_module': 'Añadir módulo', // 添加健康模块
      'expand_feature': 'Funciones extra', // 拓展功能
      'save_params': 'Guardar', // 保存参数
      'save_plan': 'Guardar plan', // 保存方案
      'plan_saving': 'Guardando, espere por favor',
      'plan_save_slow':
          'El guardado tarda más de lo esperado, espere por favor',
      'plan_save_retry': 'Error al guardar, inténtelo de nuevo',
      'custom_plan_edit_invalid':
          'El plan actual no es válido. Vuelva e inténtelo de nuevo',
      'complete_previous_node':
          'Complete primero el nodo anterior de 5 minutos', // 请先完成上一个 5 分钟节点
      'node_saved_prefix': 'Nodo de ', // 第
      'node_saved_suffix': ' minutos guardado', // 分钟节点参数已保存
      'plan_naming': 'Nombre del plan', // 方案命名
      'plan_name_duplicate':
          'El nombre del plan no puede duplicarse', // 方案名称不能重复
      'mode_select': 'Modo', // 模式选择
      'module_hydrogen': 'H₂', // 分子氢
      'module_expand': 'Expansión', // 拓展功能
      'redlight_strength_required':
          'La intensidad de luz roja 660nm y 850nm no puede ser 0 a la vez', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required':
          'La frecuencia e intensidad de PEMF no pueden ser 0', // PEMF频率和强度都不能为0
      'vat_params_required':
          'La frecuencia e intensidad de VAT no pueden ser 0', // VAT频率和强度都不能为0
      'hydrogen_concentration_required':
          'La concentración de H₂ no puede ser 0', // 分子氢浓度不能为0
      'expand_params_required': 'Seleccione al menos una función extra',
      'node_copied_prefix': 'Copiado al nodo de ', // 已复制到
      'node_copied_suffix': ' min', // 分钟节点
      // 拓展页面
      'fragrance_setting': 'Configuración de aroma', // 香氛设置
      'terahertz_setting': 'Ajuste terahercios', // 太赫兹设置
      'chakra_setting': 'Configuración de chakra', // 脉轮设置
      'hifem_setting': 'Ajuste HIFEM', // HIFEM设置
      'rotation': 'Rotación', // 轮转
      'independent': 'Independiente', // 独立
      'gentle': 'Suave', // 轻柔
      'intense': 'Intenso', // 浓烈
      'sleep': 'Sueño', // 睡眠
      'flow_state': 'Flujo', // 心流
      'meditation': 'Meditac', // 冥想
      'sine_wave': 'Seno', // 正弦波
      'square_wave': 'Cuad.', // 方波
      'triangle_wave': 'Triang.', // 三角波
      'rf': 'RF', // 射频
      'crown_chakra': 'Chakra corona', // 顶轮
      'crown_sub': '(Glándula pineal)', // 松果体
      'third_eye_chakra': 'Chakra tercer ojo', // 眉心轮
      'third_eye_sub': '(Hipófisis)', // 脑垂体
      'throat_chakra': 'Chakra garganta', // 喉轮
      'throat_sub': '(Tiroides)', // 甲状腺
      'heart_chakra': 'Chakra corazón', // 心轮
      'heart_sub': '(Timo)', // 胸腺
      'solar_plexus_chakra': 'Chakra plexo solar', // 太阳神轮
      'solar_plexus_sub': '(Riñón)', // 肾
      'sacral_chakra': 'Chakra sacro', // 脐轮
      'sacral_sub': '(Hígado, riñón, bazo)', // 肝、肾、脾
      'root_chakra': 'Chakra raíz', // 海底轮
      'root_sub': '(Gónadas)', // 生殖腺
    },
    ///////////////////////////////////////////////////////////葡萄牙语言////////////////////////////////////////////////
    'pt_PT': {
      'prompt_volume': 'Volume dos avisos',
      'prompt_volume_hint':
          'Ajuste os avisos de boas-vindas, início, fim e água. 0% silencia os avisos. O valor é guardado ao soltar o controlo.',
      'prompt_volume_update_failed':
          'Não foi possível ajustar o volume. Tente novamente.',
      'prompt_volume_save_failed':
          'Não foi possível guardar o volume. Ajuste novamente o controlo.',
      // 通用
      'settings': 'Ajustes', // 设置
      'administrator': 'Admin', // 管理员
      'back': 'Voltar', // 返回
      'confirm': 'Confirmar', // 确认
      'cancel': 'Cancelar', // 取消
      'save': 'Guardar', // 保存
      'delete': 'Eliminar', // 删除
      'select': 'Usar', // 选择
      'name': 'Introduzir nome', // 输入姓名
      'age': 'Introduzir idade', // 输入年龄
      'phone': 'Introduzir telefone', // 输入手机号
      'gender': 'Género', // 性别
      'male': 'M', // 男
      'female': 'F', // 女
      'frequency': 'Frequência', // 频率
      'intensity': 'Intens.', // 强度
      'mode': 'Modo', // 模式
      'waveform': 'Onda', // 波形
      'select_waveform': 'Selecionar forma de onda', // 选择波形
      'continuous': 'Cont.', // 连续
      'pulse': 'Pulso', // 脉冲
      'power': 'Potência', // 功率
      'chakra_power': 'Pot.', // 强度
      'running': 'Em execução', // 正在运行
      'waiting': 'Em espera', // 等待运行
      'logout': 'Sair', // 退出登录
      'parameter_settings': 'Definições de parâmetros', // 参数设置
      // Aviso de ligação Wi-Fi e Bluetooth
      'connection_prompt_title': 'Não conectado',
      'connection_prompt_subtitle': 'Conecte para continuar',
      'connection_prompt_wifi': 'WIFI',
      'connection_prompt_ble': 'BLE',
      'connection_status_checking': 'A verificar',
      'connection_status_connected': 'Conectado',
      'connection_status_disconnected': 'Não conectado',
      'connection_prompt_skip': 'Ignorar',
      'wifi_ble': 'WIFI & BLE',
      'wifi_name_unavailable': 'Nome da rede indisponível',
      'wifi_no_connected_network': 'Nenhuma rede ligada',
      'ble_no_connected_device': 'Nenhum dispositivo ligado',
      // 设置页面
      'setting_menu': 'Menu de definições', // 设置菜单
      'language_setting': 'Idioma', // 语言设置
      'language_switch': 'Alterar idioma', // 语言切换
      'save_changes': 'Guardar', // 保存更改
      'date_time': 'Data e hora', // 日期和时间
      'year_unit': 'A', // 年
      'month_unit': 'M', // 月
      'day_unit': 'D', // 日
      'hour_unit': 'h', // 时
      'am_label': 'AM', // 上午
      'pm_label': 'PM', // 下午
      'date_time_saved': 'Data e hora guardadas', // 日期和时间已保存
      'device_info': 'Info', // 设备信息
      'debug_mode': 'Depuração', // 调试模式
      'history_record': 'Histórico', // 历史记录
      'history_detail_missing': 'Registo histórico não encontrado', // 历史记录不存在
      'current_account_not_logged_in':
          'A conta atual não iniciou sessão', // 当前账号未登录
      'therapy_record_load_failed':
          'Falha ao carregar registos de bem-estar', // 健康体验记录加载失败
      'no_history_records': 'Sem histórico', // 暂无历史记录
      'no_therapy_records': 'Sem registos de bem-estar', // 暂无健康体验记录
      'years_old_unit': 'a', // 岁
      'therapy_report': 'Relatório de bem-estar', // 健康体验报告
      'total_therapy_duration': 'Tempo de bem-estar', // 健康时长
      'feedback_label': 'Notas de bem-estar: ', // 体验感受：
      'no_feedback': 'Sem notas de bem-estar', // 暂无体验感受
      'treatment_modules': 'Módulos de bem-estar', // 健康模块
      'energy_score': 'Energia', // 能量指数
      'cell_score': 'Índ. vitalidade', // 活力指数
      'relaxation_score': 'Índ. relax.', // 放松指数
      'immune_score': 'Índ. bem-estar', // 健康指数
      'compared_to_last': 'vs ant.', // 较上次
      'session_once_1': '1.ª', // 1次
      'session_once_2': '2.ª', // 2次
      'session_once_3': '3.ª', // 3次
      'current_session': 'Atual', // 本次
      'health_effect_assessment': 'Resumo de bem-estar', // 健康体验概览
      'status_good': 'Bom', // 良好
      'overall_score': 'Pontuação geral', // 综合得分
      'level_low': 'Baixo', // 低
      'level_medium': 'Médio', // 中
      'level_high': 'Alto', // 高
      'therapy_feedback_hint': 'Introduza notas de bem-estar', // 请输入健康体验感受
      'score_unit': 'pts', // 分
      'minutes_unit': 'min', // 分
      'seconds_unit': 's', // 秒
      'user_management': 'Utilizadores', // 用户管理
      'unsupported_language': 'Este idioma ainda não é suportado', // 该语言暂未支持
      // 主页
      'preset_mode': 'Modos de bem-estar', // 预设健康模式
      'preset_mode_subtitle': '10 programas de bem-estar', // 10种日常健康方案
      'device_ready': 'Dispositivo pronto', // 设备就绪
      'custom_plan': 'Plano', // 自定义方案
      'deep_relax': 'RELAX PROFUNDO', // 深度放松
      'energy_boost': 'REENERGIZAR', // 焕新充能
      'pain_relief': 'CONFORTO SUAVE', // 柔和舒适
      'sleep_enhancement': 'CALMA NOTURNA', // 夜间放松
      'sports_recovery': 'RELAXAMENTO', // 活动后放松
      'stress_release': 'CALMA & RELAX', // 舒缓放松
      'immune_boost': 'ENERGIA DIÁRIA', // 日常活力
      'anti_aging': 'VITALIDADE', // 焕彩活力
      'full_care': 'RENOVA-TE', // 全身焕新
      'mental_healing': 'BOM HUMOR', // 心情平衡
      'device_fault': 'Falha do dispositivo', // 设备故障
      'water_level_warning_title': 'Aviso de falta de água',
      'water_level_warning_message':
          'O nível do reservatório está baixo. Reabasteça antes de continuar.',
      'water_level_shortage_title': 'Falta de água',
      'water_level_shortage_message':
          'Água insuficiente. Ligue o abastecimento de água para enchimento automático.',
      'water_level_shortage_unavailable':
          'Hidrogénio molecular temporariamente indisponível',
      'water_level_filling_title': 'Enchendo',
      'water_level_filling_message': 'Enchendo água, aguarde...',
      'water_level_complete_title': 'Enchimento concluído',
      'water_level_complete_message':
          'Enchimento de água concluído. Pode continuar a utilizar o dispositivo.',
      'water_level_ready_button': 'Pronto?',
      'water_level_start_filling_button': 'Iniciar enchimento',
      // 登录页面
      'login_email_hint': 'Introduza o e-mail', // 输入邮箱
      'login_password_hint': 'Introduza a palavra-passe', // 输入密码
      'forgot_password': 'Esqueceu-se da palavra-passe?', // 忘记密码?
      'login': 'Iniciar sessão', // 登录
      'register': 'Registar', // 注册
      'agree_prefix': 'Li e aceito ', // 我已阅读并同意
      'user_agreement': 'Acordo do utilizador', // 《用户协议》
      'and': ' e ', // 和
      'privacy_policy': 'Política de privacidade', // 《隐私政策》
      // Página de registo
      'Admin': 'Administrador', // 管理员
      'Operator': 'Operador', // 操作员
      'User': 'Particular', // 个人
      'verify_code': 'Introduza o código de verificação', // 输入验证码
      'send_code': 'A enviar...', // 发送中...
      'get_code': 'Obter código', // 获取验证码
      'registering': 'A registar...', // 注册中...
      'already_have_account': 'Já tem uma conta?', // 已有账号?
      'login_now': 'Iniciar sessão agora', // 立即登录
      'prompt': 'Aviso', // 提示
      'email_empty': 'Introduza primeiro o seu e-mail', // 请先输入邮箱
      'email_invalid': 'Introduza um e-mail válido', // 请输入正确的邮箱
      'code_send_failed': 'Falha ao enviar o código de verificação', // 验证码发送失败
      'register_success': 'Registo concluído', // 注册成功
      'register_failed': 'Falha no registo', // 注册失败
      'email_required': 'Introduza o seu e-mail', // 请输入邮箱
      'password_required': 'Introduza a palavra-passe', // 请输入密码
      'login_success_empty_user':
          'Sessão iniciada, mas os dados do utilizador estão vazios', // 登录成功，但用户信息为空
      'login_success': 'Sessão iniciada com sucesso', // 登录成功
      'login_failed': 'Falha ao iniciar sessão', // 登录失败
      'error': 'Erro', // 错误
      'network_error':
          'Falha na conexão de rede, verifique a rede ou o servidor',
      'unknown_error': 'Erro desconhecido',
      'login_request_failed':
          'Falha no pedido de início de sessão: ', // 登录请求失败：
      'new_password_hint': 'Introduza a nova palavra-passe', // 输入新密码
      'confirm_new_password_hint': 'Confirme a nova palavra-passe', // 确认新密码
      'resetting_password': 'A repor...', // 重置中...
      'confirm_reset': 'Confirmar reposição', // 确认重置
      'code_sent_backend_email':
          'Código de verificação enviado para: ', // 验证码已发送至：
      'verify_code_required': 'Introduza o código de verificação', // 请输入验证码
      'new_password_required': 'Introduza uma nova palavra-passe', // 请输入新密码
      'confirm_new_password_required':
          'Confirme a nova palavra-passe', // 请再次输入新密码
      'passwords_not_match': 'As palavras-passe não coincidem', // 两次输入的密码不一致
      'password_reset_success': 'Palavra-passe reposta com sucesso', // 密码重置成功
      'password_reset_failed': 'Falha ao repor a palavra-passe', // 密码重置失败
      // 用户选择页面
      'choose_therapy_user': 'Selecionar utilizador', // 选择体验用户
      'search_user_hint': 'Introduza nome ou telefone', // 输入用户姓名或手机号
      'add_user': 'Adicionar utilizador', // 添加用户
      'user_name_label': 'Nome',
      'user_age_label': 'Idade',
      'user_phone_label': 'Telefone',
      'user_email_label': 'E-mail',
      'user_email_hint': 'Introduza o e-mail',
      'user_gender_label': 'Género',
      'user_male': 'Masculino',
      'user_female': 'Feminino',
      'user_remark_label': 'Observações',
      'user_remark_hint': 'Introduza observações',
      'user_required_fields': 'Preencha o nome, idade e telefone',
      'user_invalid_age': 'Introduza uma idade válida',
      'add_user_failed': 'Falha ao adicionar utilizador',
      'confirm_selection': 'Confirmar seleção', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Confirmar seleção', // 确认选择
      'music_resource_missing':
          'Esta música não tem áudio disponível', // 当前音乐暂无音频资源
      // 启动页面
      'red_light': 'Luz vermelha', // 红光
      'wavelength': 'Onda', // 波长
      'hydrogen_molecule': 'H₂', // 分子氢
      'hydrogen_concentration': 'Conc. de H₂', // 氢气浓度
      'flow': 'Fluxo', // 流量
      'chakra': 'Chakra', // 脉轮
      'terahertz': 'Terahertz', // 太赫兹
      'fragrance': 'Aroma', // 香氛
      'therapy_completed': 'Bem-estar concluído', // 健康体验完成
      'user': 'Utilizador', // 使用者
      'session_duration': 'Duração da sessão', // 本次使用
      'module_duration': 'Duração do módulo', // 模块时长
      'no_module_record': 'Sem registos do módulo', // 暂无模块运行记录
      'not_running': 'Não executado', // 未运行
      'running_label': 'Em execução', // 运行
      'default_mode_title': 'Relaxamento profundo', // 深度放松
      'no_user_selected': 'Nenhum utilizador selecionado', // 未选择用户
      'error_send_params_failed': 'Falha ao enviar parâmetros: ', // 参数下发失败：
      'error_pause_failed': 'Falha ao pausar: ', // 暂停失败：
      'error_resume_failed': 'Falha ao retomar: ', // 继续失败：
      'error_stop_failed': 'Falha ao parar: ', // 停止失败：
      // 自定义列表页面
      'custom_plan_title': 'Planos personalizados', // 自定义方案
      'plan_search_hint': 'Introduza o nome do plano', // 输入方案名称
      'add_plan': 'Adicionar plano', // 添加方案
      'rename_plan': 'Renomear', // 重命名
      'plan_name_empty': 'O nome do plano não pode estar vazio', // 方案名称不能为空
      'custom_plan_load_failed': 'Falha ao carregar planos: ', // 自定义方案加载失败：
      'user_not_logged_in_retry':
          'Utilizador não autenticado, inicie sessão novamente', // 用户未登录，请重新登录
      // 自定义编辑页面
      'red_ther': 'RED TEC.', // 红光
      'add_therapy_module': 'Adicionar módulo', // 添加健康模块
      'expand_feature': 'Funções extra', // 拓展功能
      'save_params': 'Salvar', // 保存参数
      'save_plan': 'Guardar plano', // 保存方案
      'plan_saving': 'Salvando, aguarde',
      'plan_save_slow': 'O salvamento está demorando, aguarde',
      'plan_save_retry': 'Falha ao salvar, tente novamente',
      'custom_plan_edit_invalid':
          'O plano atual é inválido. Volte e tente novamente',
      'complete_previous_node':
          'Conclua primeiro o nó anterior de 5 minutos', // 请先完成上一个 5 分钟节点
      'node_saved_prefix': 'Parâmetros do nó ', // 第
      'node_saved_suffix': ' min guardados', // 分钟节点参数已保存
      'plan_naming': 'Nome do plano', // 方案命名
      'plan_name_duplicate':
          'O nome do plano não pode ser duplicado', // 方案名称不能重复
      'mode_select': ' Modo', // 模式选择
      'module_hydrogen': 'H₂', // 分子氢
      'module_expand': 'Expandir', // 拓展功能
      'redlight_strength_required':
          'A intensidade de luz vermelha 660nm e 850nm não pode ser 0 ao mesmo tempo', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required':
          'A frequência e intensidade PEMF não podem ser 0', // PEMF频率和强度都不能为0
      'vat_params_required':
          'A frequência e intensidade VAT não podem ser 0', // VAT频率和强度都不能为0
      'hydrogen_concentration_required':
          'A concentração de H₂ não pode ser 0', // 分子氢浓度不能为0
      'expand_params_required': 'Selecione pelo menos uma função extra',
      'node_copied_prefix': 'Copiado para o nó de ', // 已复制到
      'node_copied_suffix': ' min', // 分钟节点
      // 拓展页面
      'fragrance_setting': 'Definições de aroma', // 香氛设置
      'terahertz_setting': 'Definições de terahertz', // 太赫兹设置
      'chakra_setting': 'Definições de chakra', // 脉轮设置
      'hifem_setting': 'Definições HIFEM', // HIFEM设置
      'rotation': 'Rotação', // 轮转
      'independent': 'Independente', // 独立
      'gentle': 'Suave', // 轻柔
      'intense': 'Intenso', // 浓烈
      'sleep': 'Sono', // 睡眠
      'flow_state': 'Fluxo', // 心流
      'meditation': 'Meditar', // 冥想
      'sine_wave': 'Senoidal', // 正弦波
      'square_wave': 'Quad.', // 方波
      'triangle_wave': 'Triâng.', // 三角波
      'rf': 'RF', // 射频
      'crown_chakra': 'Chakra coronário', // 顶轮
      'crown_sub': '(glândula pineal)', // 松果体
      'third_eye_chakra': 'Chakra do terceiro olho', // 眉心轮
      'third_eye_sub': '(hipófise)', // 脑垂体
      'throat_chakra': 'Chakra da garganta', // 喉轮
      'throat_sub': '(tiroide)', // 甲状腺
      'heart_chakra': 'Chakra do coração', // 心轮
      'heart_sub': '(timo)', // 胸腺
      'solar_plexus_chakra': 'Chakra do plexo solar', // 太阳神轮
      'solar_plexus_sub': '(rim)', // 肾
      'sacral_chakra': 'Chakra sacral', // 脐轮
      'sacral_sub': '(fígado, rim, baço)', // 肝、肾、脾
      'root_chakra': 'Chakra raiz', // 海底轮
      'root_sub': '(gónadas)', // 生殖腺
    },
    //////////////////////////////////////////////////////////////////////俄语语言/////////////////////////////////////////////////////////////////////
    'ru_RU': {
      'prompt_volume': 'Громкость подсказок',
      'prompt_volume_hint':
          'Громкость приветствия, начала, завершения и уведомления о воде. 0% отключает звук. Отпустите ползунок для сохранения.',
      'prompt_volume_update_failed':
          'Не удалось изменить громкость. Повторите попытку.',
      'prompt_volume_save_failed':
          'Не удалось сохранить громкость. Передвиньте ползунок ещё раз.',
      // 通用
      'settings': ' Настр.', // 设置
      'administrator': 'Админ', // 管理员
      'back': 'Назад', // 返回
      'confirm': 'Подтвердить', // 确认
      'cancel': 'Отмена', // 取消
      'save': 'Сохранить', // 保存
      'delete': 'Удалить', // 删除
      'select': 'Выбрать', // 选择
      'name': 'Введите имя', // 输入姓名
      'age': 'Введите возраст', // 输入年龄
      'phone': 'Введите телефон', // 输入手机号
      'gender': 'Пол', // 性别
      'male': 'М', // 男
      'female': 'Ж', // 女
      'frequency': 'Частота', // 频率
      'intensity': 'Интенсив.', // 强度
      'mode': 'Режим', // 模式
      'waveform': 'Волна', // 波形
      'select_waveform': 'Выбор формы волны', // 选择波形
      'continuous': 'Непр.', // 连续
      'pulse': 'Имп.', // 脉冲
      'power': 'Мощность', // 功率
      'chakra_power': 'Мощ.', // 强度
      'running': 'Работает', // 正在运行
      'waiting': 'Ожидание', // 等待运行
      'logout': 'Выйти', // 退出登录
      'parameter_settings': 'Параметры', // 参数设置
      // Уведомление о подключении Wi-Fi и Bluetooth
      'connection_prompt_title': 'Не подключено',
      'connection_prompt_subtitle': 'Сначала подключитесь',
      'connection_prompt_wifi': 'WIFI',
      'connection_prompt_ble': 'BLE',
      'connection_status_checking': 'Проверка',
      'connection_status_connected': 'Подключено',
      'connection_status_disconnected': 'Не подключено',
      'connection_prompt_skip': 'Пропустить',
      'wifi_ble': 'WIFI & BLE',
      'wifi_name_unavailable': 'Имя сети недоступно',
      'wifi_no_connected_network': 'Нет подключенной сети',
      'ble_no_connected_device': 'Нет подключенных устройств',
      // 设置页面
      'setting_menu': 'Меню настроек', // 设置菜单
      'language_setting': 'Язык', // 语言设置
      'language_switch': 'Смена языка', // 语言切换
      'save_changes': 'Сохранить', // 保存更改
      'date_time': 'Дата и время', // 日期和时间
      'year_unit': 'г', // 年
      'month_unit': 'м', // 月
      'day_unit': 'д', // 日
      'hour_unit': 'ч', // 时
      'am_label': 'AM', // 上午
      'pm_label': 'PM', // 下午
      'date_time_saved': 'Дата и время сохранены', // 日期和时间已保存
      'device_info': 'Информация', // 设备信息
      'debug_mode': 'Отладка', // 调试模式
      'history_record': 'История', // 历史记录
      'history_detail_missing': 'Запись истории не найдена', // 历史记录不存在
      'current_account_not_logged_in':
          'Текущая учетная запись не вошла в систему', // 当前账号未登录
      'therapy_record_load_failed':
          'Не удалось загрузить велнес-записи', // 健康体验记录加载失败
      'no_history_records': 'Нет записей истории', // 暂无历史记录
      'no_therapy_records': 'Нет велнес-записей', // 暂无健康体验记录
      'years_old_unit': 'г', // 岁
      'therapy_report': 'Велнес-отчет', // 健康体验报告
      'total_therapy_duration': 'Время велнес', // 健康时长
      'feedback_label': 'Велнес-заметки: ', // 体验感受：
      'no_feedback': 'Нет велнес-заметок', // 暂无体验感受
      'treatment_modules': 'Велнес-модули', // 健康模块
      'energy_score': 'Энергия', // 能量指数
      'cell_score': 'Инд. тонуса', // 活力指数
      'relaxation_score': 'Инд. рел.', // 放松指数
      'immune_score': 'Индекс велнес', // 健康指数
      'compared_to_last': 'к прошл.', // 较上次
      'session_once_1': '1-й', // 1次
      'session_once_2': '2-й', // 2次
      'session_once_3': '3-й', // 3次
      'current_session': 'Текущий', // 本次
      'health_effect_assessment': 'Обзор велнес', // 健康体验概览
      'status_good': 'Хорошо', // 良好
      'overall_score': 'Общий балл', // 综合得分
      'level_low': 'Низк.', // 低
      'level_medium': 'Сред.', // 中
      'level_high': 'Выс.', // 高
      'therapy_feedback_hint': 'Введите велнес-заметки', // 请输入健康体验感受
      'score_unit': 'б', // 分
      'minutes_unit': 'мин', // 分
      'seconds_unit': 'с', // 秒
      'user_management': 'Пользователи', // 用户管理
      'unsupported_language': 'Этот язык пока не поддерживается', // 该语言暂未支持
      // 主页
      'preset_mode': 'Готовые велнес-режимы', // 预设健康模式
      'preset_mode_subtitle': '10 велнес-программ', // 10种日常健康方案
      'device_ready': 'Устройство готово', // 设备就绪
      'custom_plan': 'Свой режим', // 自定义方案
      'deep_relax': 'Глубокий релакс', // 深度放松
      'energy_boost': 'ЗАРЯД ЭНЕРГИИ', // 焕新充能
      'pain_relief': 'МЯГКИЙ КОМФОРТ', // 柔和舒适
      'sleep_enhancement': 'ВЕЧ. РЕЛАКС', // 夜间放松
      'sports_recovery': 'ЗАМИНКА', // 活动后放松
      'stress_release': 'СПОКОЙСТВИЕ', // 舒缓放松
      'immune_boost': 'БОДРОСТЬ ДНЯ', // 日常活力
      'anti_aging': 'СИЯНИЕ', // 焕彩活力
      'full_care': 'ОБНОВЛЕНИЕ', // 全身焕新
      'mental_healing': 'БАЛ. НАСТ.', // 心情平衡
      'device_fault': 'Ошибка устройства', // 设备故障
      'water_level_warning_title': 'Предупреждение о нехватке воды',
      'water_level_warning_message':
          'Низкий уровень воды. Долейте перед продолжением.',
      'water_level_shortage_title': 'Нехватка воды',
      'water_level_shortage_message':
          'Недостаточно воды. Подключите подачу воды для автоматического наполнения.',
      'water_level_shortage_unavailable':
          'Функция молекулярного водорода временно недоступна',
      'water_level_filling_title': 'Наполнение',
      'water_level_filling_message': 'Идет наполнение водой, подождите...',
      'water_level_complete_title': 'Наполнение завершено',
      'water_level_complete_message':
          'Наполнение водой завершено. Можно продолжать использование устройства.',
      'water_level_ready_button': 'Готовы?',
      'water_level_start_filling_button': 'Начать заполнение',
      // 登录页面
      'login_email_hint': 'Введите адрес электронной почты', // 输入邮箱
      'login_password_hint': 'Введите пароль', // 输入密码
      'forgot_password': 'Забыли пароль?', // 忘记密码?
      'login': 'Войти', // 登录
      'register': 'Регистрация', // 注册
      'agree_prefix': 'Принимаю', // 我已阅读并同意
      'user_agreement': 'Условия использования', // 《用户协议》
      'and': ' и ', // 和
      'privacy_policy': 'Политику', // 《隐私政策》
      // 注册页面
      'Admin': 'Админ', // 管理员
      'Operator': 'Оператор', // 操作员
      'User': 'Частное лицо', // 个人
      'verify_code': 'Введите код подтверждения', // 输入验证码
      'send_code': 'Отправка...', // 发送中...
      'get_code': 'Получить код', // 获取验证码
      'registering': 'Регистрация...', // 注册中...
      'already_have_account': 'Уже есть аккаунт?', // 已有账号?
      'login_now': 'Войти сейчас', // 立即登录
      'prompt': 'Уведомление', // 提示
      'email_empty': 'Сначала введите адрес электронной почты', // 请先输入邮箱
      'email_invalid': 'Введите корректный адрес электронной почты', // 请输入正确的邮箱
      'code_send_failed': 'Не удалось отправить код подтверждения', // 验证码发送失败
      'register_success': 'Регистрация завершена', // 注册成功
      'register_failed': 'Ошибка регистрации', // 注册失败
      'email_required': 'Введите адрес электронной почты', // 请输入邮箱
      'password_required': 'Введите пароль', // 请输入密码
      'login_success_empty_user':
          'Вход выполнен, но данные пользователя отсутствуют', // 登录成功，但用户信息为空
      'login_success': 'Вход выполнен', // 登录成功
      'login_failed': 'Не удалось войти', // 登录失败
      'error': 'Ошибка', // 错误
      'network_error': 'Ошибка подключения к сети, проверьте сеть или сервер',
      'unknown_error': 'Неизвестная ошибка',
      'login_request_failed': 'Ошибка запроса входа: ', // 登录请求失败：
      'new_password_hint': 'Введите новый пароль', // 输入新密码
      'confirm_new_password_hint': 'Подтвердите новый пароль', // 确认新密码
      'resetting_password': 'Сброс...', // 重置中...
      'confirm_reset': 'Подтвердить сброс', // 确认重置
      'code_sent_backend_email': 'Код подтверждения отправлен на: ', // 验证码已发送至：
      'verify_code_required': 'Введите код подтверждения', // 请输入验证码
      'new_password_required': 'Введите новый пароль', // 请输入新密码
      'confirm_new_password_required': 'Подтвердите новый пароль', // 请再次输入新密码
      'passwords_not_match': 'Пароли не совпадают', // 两次输入的密码不一致
      'password_reset_success': 'Пароль успешно сброшен', // 密码重置成功
      'password_reset_failed': 'Не удалось сбросить пароль', // 密码重置失败
      // 用户选择页面
      'choose_therapy_user': 'Выберите пользователя', // 选择体验用户
      'search_user_hint': 'Введите имя или телефон', // 输入用户姓名或手机号
      'add_user': 'Добавить пользователя', // 添加用户
      'user_name_label': 'Имя',
      'user_age_label': 'Возраст',
      'user_phone_label': 'Телефон',
      'user_email_label': 'Эл. почта',
      'user_email_hint': 'Введите адрес эл. почты',
      'user_gender_label': 'Пол',
      'user_male': 'Мужской',
      'user_female': 'Женский',
      'user_remark_label': 'Примечание',
      'user_remark_hint': 'Введите примечание',
      'user_required_fields': 'Укажите имя, возраст и телефон',
      'user_invalid_age': 'Введите корректный возраст',
      'add_user_failed': 'Не удалось добавить пользователя',
      'confirm_selection': 'Подтвердить выбор', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Подтвердить выбор', // 确认选择
      'music_resource_missing': 'Для этой музыки нет аудио', // 当前音乐暂无音频资源
      // 启动页面
      'red_light': 'Красный свет', // 红光
      'wavelength': 'Волна', // 波长
      'hydrogen_molecule': 'H₂', // 分子氢
      'hydrogen_concentration': 'Конц. H₂', // 氢气浓度
      'flow': 'Поток', // 流量
      'chakra': 'Чакра', // 脉轮
      'terahertz': 'Терагерц', // 太赫兹
      'fragrance': 'Аромат', // 香氛
      'therapy_completed': 'Велнес завершён', // 健康体验完成
      'user': 'Пользователь', // 使用者
      'session_duration': 'Время сеанса', // 本次使用
      'module_duration': 'Время модуля', // 模块时长
      'no_module_record': 'Нет записей работы модуля', // 暂无模块运行记录
      'not_running': 'Не запущено', // 未运行
      'running_label': 'Работает', // 运行
      'default_mode_title': 'Глубокое расслабление', // 深度放松
      'no_user_selected': 'Пользователь не выбран', // 未选择用户
      'error_send_params_failed': 'Не удалось отправить параметры: ', // 参数下发失败：
      'error_pause_failed': 'Не удалось поставить на паузу: ', // 暂停失败：
      'error_resume_failed': 'Не удалось продолжить: ', // 继续失败：
      'error_stop_failed': 'Не удалось остановить: ', // 停止失败：
      // 自定义列表页面
      'custom_plan_title': 'Свой режим', // 自定义方案
      'plan_search_hint': 'Введите название плана', // 输入方案名称
      'add_plan': 'Добавить план', // 添加方案
      'rename_plan': 'Редак.', // 重命名
      'plan_name_empty': 'Название плана не может быть пустым', // 方案名称不能为空
      'custom_plan_load_failed': 'Не удалось загрузить планы: ', // 自定义方案加载失败：
      'user_not_logged_in_retry':
          'Пользователь не вошел, войдите снова', // 用户未登录，请重新登录
      // 自定义编辑页面
      'red_ther': 'RED TEC.', // 红光
      'add_therapy_module': 'Добавить модуль', // 添加模块
      'expand_feature': 'Доп. функции', // 拓展功能
      'save_params': 'Сохранить', // 保存参数
      'save_plan': 'Сохранить план', // 保存方案
      'plan_saving': 'Сохранение, пожалуйста, подождите',
      'plan_save_slow':
          'Сохранение занимает больше времени, пожалуйста, подождите',
      'plan_save_retry': 'Не удалось сохранить, повторите попытку',
      'custom_plan_edit_invalid':
          'Текущий план недействителен. Вернитесь и повторите попытку',
      'complete_previous_node':
          'Сначала завершите предыдущий 5-минутный узел', // 请先完成上一个 5 分钟节点
      'node_saved_prefix': 'Параметры узла ', // 第
      'node_saved_suffix': ' мин сохранены', // 分钟节点参数已保存
      'plan_naming': 'Название плана', // 方案命名
      'plan_name_duplicate': 'Название плана не должно повторяться', // 方案名称不能重复
      'mode_select': 'Режим', // 模式选择
      'module_hydrogen': 'H₂', // 分子氢
      'module_expand': 'Доп.', // 拓展功能
      'redlight_strength_required':
          'Интенсивность красного света 660nm и 850nm не может быть 0 одновременно', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required':
          'Частота и интенсивность PEMF не могут быть 0', // PEMF频率和强度都不能为0
      'vat_params_required':
          'Частота и интенсивность VAT не могут быть 0', // VAT频率和强度都不能为0
      'hydrogen_concentration_required':
          'Концентрация H₂ не может быть 0', // 分子氢浓度不能为0
      'expand_params_required': 'Выберите хотя бы одну доп. функцию',
      'node_copied_prefix': 'Скопировано в узел ', // 已复制到
      'node_copied_suffix': ' мин', // 分钟节点
      // 拓展页面
      'fragrance_setting': 'Настройки аромата', // 香氛设置
      'terahertz_setting': 'Настройки терагерц', // 太赫兹设置
      'chakra_setting': 'Настройки чакр', // 脉轮设置
      'hifem_setting': 'Настройки HIFEM', // HIFEM设置
      'rotation': 'Ротация', // 轮转
      'independent': 'Независимый', // 独立
      'gentle': 'Мягкий', // 轻柔
      'intense': 'Сильно', // 浓烈
      'sleep': 'Сон', // 睡眠
      'flow_state': 'Поток', // 心流
      'meditation': 'Медит', // 冥想
      'sine_wave': 'Синус', // 正弦波
      'square_wave': 'Квадр.', // 方波
      'triangle_wave': 'Треуг.', // 三角波
      'rf': 'RF', // 射频
      'crown_chakra': 'Коронная чакра', // 顶轮
      'crown_sub': '(эпифиз)', // 松果体
      'third_eye_chakra': 'Чакра третьего глаза', // 眉心轮
      'third_eye_sub': '(гипофиз)', // 脑垂体
      'throat_chakra': 'Горловая чакра', // 喉轮
      'throat_sub': '(щитовидная железа)', // 甲状腺
      'heart_chakra': 'Сердечная чакра', // 心轮
      'heart_sub': '(тимус)', // 胸腺
      'solar_plexus_chakra': 'Чакра солнечного сплетения', // 太阳神轮
      'solar_plexus_sub': '(почки)', // 肾
      'sacral_chakra': 'Сакральная чакра', // 脐轮
      'sacral_sub': '(печень, почки, селезёнка)', // 肝、肾、脾
      'root_chakra': 'Корневая чакра', // 海底轮
      'root_sub': '(гонады)', // 生殖腺
    },
    ///////////////////////////////////////////////////////////法语语言////////////////////////////////////////////////
    'fr_FR': {
      'prompt_volume': 'Volume des annonces',
      'prompt_volume_hint':
          'Réglez les annonces de bienvenue, de début, de fin et concernant l’eau. 0% coupe le son. Relâchez le curseur pour enregistrer.',
      'prompt_volume_update_failed':
          'Impossible de régler le volume. Réessayez.',
      'prompt_volume_save_failed':
          'Impossible d’enregistrer le volume. Déplacez à nouveau le curseur.',
      // 通用
      'settings': 'Config.', // 设置
      'administrator': 'Admin', // 管理员
      'back': 'Retour', // 返回
      'confirm': 'Confirmer', // 确认
      'cancel': 'Annuler', // 取消
      'save': 'Enregistrer', // 保存
      'delete': 'Supprimer', // 删除
      'select': 'Выб.', // 选择
      'name': 'Saisir le nom', // 输入姓名
      'age': 'Saisir l’âge', // 输入年龄
      'phone': 'Saisir le téléphone', // 输入手机号
      'gender': 'Sexe', // 性别
      'male': 'H', // 男
      'female': 'F', // 女
      'frequency': 'Fréquence', // 频率
      'intensity': 'Intensité', // 强度
      'mode': 'Mode', // 模式
      'waveform': 'Onde', // 波形
      'select_waveform': 'Choisir la forme d’onde', // 选择波形
      'continuous': 'Continu', // 连续
      'runtime_continuous': 'Cont.',
      'pulse': 'Pulsé', // 脉冲
      'power': 'Puissance', // 功率
      'chakra_power': 'Puis.', // 强度
      'running': 'En cours', // 正在运行
      'waiting': 'En attente', // 等待运行
      'logout': 'Quitter', // 退出登录
      'parameter_settings': 'Paramètres', // 参数设置
      // Invite de connexion Wi-Fi et Bluetooth
      'connection_prompt_title': 'Non connecté',
      'connection_prompt_subtitle': 'Connectez-vous d’abord',
      'connection_prompt_wifi': 'WIFI',
      'connection_prompt_ble': 'BLE',
      'connection_status_checking': 'Vérification',
      'connection_status_connected': 'Connecté',
      'connection_status_disconnected': 'Non connecté',
      'connection_prompt_skip': 'Ignorer',
      'wifi_ble': 'WIFI & BLE',
      'wifi_name_unavailable': 'Nom du réseau indisponible',
      'wifi_no_connected_network': 'Aucun réseau connecté',
      'ble_no_connected_device': 'Aucun appareil connecté',
      // 设置页面
      'setting_menu': 'Menu des paramètres', // 设置菜单
      'language_setting': 'Langue', // 语言设置
      'language_switch': 'Changer de langue', // 语言切换
      'save_changes': 'Enregistrer les modifications', // 保存更改
      'date_time': 'Date et heure', // 日期和时间
      'year_unit': 'A', // 年
      'month_unit': 'M', // 月
      'day_unit': 'J', // 日
      'hour_unit': 'h', // 时
      'am_label': 'AM', // 上午
      'pm_label': 'PM', // 下午
      'date_time_saved': 'Date et heure enregistrées', // 日期和时间已保存
      'device_info': 'Infos appareil', // 设备信息
      'debug_mode': 'Mode débogage', // 调试模式
      'history_record': 'Historique', // 历史记录
      'history_detail_missing': 'Historique introuvable', // 历史记录不存在
      'current_account_not_logged_in':
          'Le compte actuel n’est pas connecté', // 当前账号未登录
      'therapy_record_load_failed':
          'Échec du chargement des données bien-être', // 健康体验记录加载失败
      'no_history_records': 'Aucun historique', // 暂无历史记录
      'no_therapy_records': 'Aucune donnée bien-être', // 暂无健康体验记录
      'years_old_unit': 'a', // 岁
      'therapy_report': 'Rapport bien-être', // 健康体验报告
      'total_therapy_duration': 'Temps bien-être', // 健康时长
      'feedback_label': 'Notes bien-être : ', // 体验感受：
      'no_feedback': 'Aucune note bien-être', // 暂无体验感受
      'treatment_modules': 'Modules bien-être', // 健康模块
      'energy_score': 'Énergie', // 能量指数
      'cell_score': 'Indice vitalité', // 活力指数
      'relaxation_score': 'Relaxation', // 放松指数
      'immune_score': 'Indice bien-être', // 健康指数
      'compared_to_last': 'vs préc.', // 较上次
      'session_once_1': '1re', // 1次
      'session_once_2': '2e', // 2次
      'session_once_3': '3e', // 3次
      'current_session': 'Actuelle', // 本次
      'health_effect_assessment': 'Aperçu bien-être', // 健康体验概览
      'status_good': 'Bon', // 良好
      'overall_score': 'Score global', // 综合得分
      'level_low': 'Bas', // 低
      'level_medium': 'Moyen', // 中
      'level_high': 'Haut', // 高
      'therapy_feedback_hint': 'Saisir notes bien-être', // 请输入健康体验感受
      'score_unit': 'pts', // 分
      'minutes_unit': 'min', // 分
      'seconds_unit': 's', // 秒
      'user_management': 'Utilisateurs', // 用户管理
      'unsupported_language': 'Langue non prise en charge', // 该语言暂未支持
      // 主页面
      'preset_mode': 'Modes bien-être', // 预设健康模式
      'preset_mode_subtitle': '10 programmes bien-être', // 10种日常健康方案
      'device_ready': 'Appareil prêt', // 设备就绪
      'custom_plan': 'Programme', // 自定义方案
      'deep_relax': 'DÉTENTE PROF.', // 深度放松
      'energy_boost': 'REVITALISER', // 焕新充能
      'pain_relief': 'CONFORT DOUX', // 柔和舒适
      'sleep_enhancement': 'CALME DU SOIR', // 夜间放松
      'sports_recovery': 'RETOUR&CALME', // 活动后放松
      'stress_release': 'CALME & RELAX', // 舒缓放松
      'immune_boost': 'ÉLAN QUOTIDIEN', // 日常活力
      'anti_aging': 'VITALITÉ', // 焕彩活力
      'full_care': 'RENOUVEAU', // 全身焕新
      'mental_healing': 'HUMEUR', // 心情平衡
      'device_fault': 'Défaut de l’appareil', // 设备故障
      'water_level_warning_title': 'Alerte niveau d’eau faible',
      'water_level_warning_message':
          'Le niveau du réservoir d’eau est bas. Ajoutez de l’eau pour continuer.',
      'water_level_shortage_title': 'Niveau d’eau bas',
      'water_level_shortage_message':
          'Manque d’eau. Raccordez l’arrivée d’eau pour le remplissage automatique.',
      'water_level_shortage_unavailable':
          'Hydrogène moléculaire temporairement indisponible',
      'water_level_filling_title': 'Remplissage',
      'water_level_filling_message':
          'Remplissage en cours, veuillez patienter...',
      'water_level_complete_title': 'Remplissage terminé',
      'water_level_complete_message':
          'Remplissage d’eau terminé. Vous pouvez continuer à utiliser l’appareil.',
      'water_level_ready_button': 'Prêt ?',
      'water_level_start_filling_button': 'Démarrer le remplissage',
      // 登录页面
      'login_email_hint': 'Saisir l’adresse e-mail', // 输入邮箱
      'login_password_hint': 'Saisir le mot de passe', // 输入密码
      'forgot_password': 'Mot de passe oublié ?', // 忘记密码?
      'login': 'Connexion', // 登录
      'register': 'Inscription', // 注册
      'agree_prefix': 'J’accepte ', // 我已阅读并同意
      'user_agreement': 'les Conditions', // 《用户协议》
      'and': ' et ', // 和
      'privacy_policy': 'la Politique de confidentialité', // 《隐私政策》
      // 注册页面
      'Admin': 'Administrateur', // 管理员
      'Operator': 'Opérateur', // 操作员
      'User': 'Particulier', // 个人
      'verify_code': 'Saisir le code de vérification', // 输入验证码
      'send_code': 'Envoi...', // 发送中...
      'get_code': 'Obtenir le code', // 获取验证码
      'registering': 'Inscription...', // 注册中...
      'already_have_account': 'Vous avez déjà un compte ?', // 已有账号?
      'login_now': 'Se connecter maintenant', // 立即登录
      'prompt': 'Information', // 提示
      'email_empty': 'Veuillez d’abord saisir votre e-mail', // 请先输入邮箱
      'email_invalid': 'Veuillez saisir une adresse e-mail valide', // 请输入正确的邮箱
      'code_send_failed': 'Échec de l’envoi du code de vérification', // 验证码发送失败
      'register_success': 'Inscription réussie', // 注册成功
      'register_failed': 'Échec de l’inscription', // 注册失败
      'email_required': 'Veuillez saisir votre adresse e-mail', // 请输入邮箱
      'password_required': 'Veuillez saisir votre mot de passe', // 请输入密码
      'login_success_empty_user':
          'Connexion réussie, mais les informations utilisateur sont vides', // 登录成功，但用户信息为空
      'login_success': 'Connexion réussie', // 登录成功
      'login_failed': 'Échec de la connexion', // 登录失败
      'error': 'Erreur', // 错误
      'network_error':
          'Échec de la connexion réseau, vérifiez le réseau ou le serveur',
      'unknown_error': 'Erreur inconnue',
      'login_request_failed': 'Échec de la demande de connexion : ', // 登录请求失败：
      'new_password_hint': 'Saisir le nouveau mot de passe', // 输入新密码
      'confirm_new_password_hint': 'Confirmer le nouveau mot de passe', // 确认新密码
      'resetting_password': 'Réinitialisation...', // 重置中...
      'confirm_reset': 'Confirmer la réinitialisation', // 确认重置
      'code_sent_backend_email': 'Code de vérification envoyé à : ', // 验证码已发送至：
      'verify_code_required':
          'Veuillez saisir le code de vérification', // 请输入验证码
      'new_password_required':
          'Veuillez saisir un nouveau mot de passe', // 请输入新密码
      'confirm_new_password_required':
          'Veuillez confirmer le nouveau mot de passe', // 请再次输入新密码
      'passwords_not_match':
          'Les mots de passe ne correspondent pas', // 两次输入的密码不一致
      'password_reset_success':
          'Mot de passe réinitialisé avec succès', // 密码重置成功
      'password_reset_failed':
          'Échec de la réinitialisation du mot de passe', // 密码重置失败
      // 用户选择页面
      'choose_therapy_user': 'Sélectionner l’utilisateur', // 选择体验用户
      'search_user_hint':
          'Saisir le nom ou le numéro de téléphone', // 输入用户姓名或手机号
      'add_user': 'Ajouter un utilisateur', // 添加用户
      'user_name_label': 'Nom',
      'user_age_label': 'Âge',
      'user_phone_label': 'Téléphone',
      'user_email_label': 'E-mail',
      'user_email_hint': 'Saisissez l’adresse e-mail',
      'user_gender_label': 'Sexe',
      'user_male': 'Homme',
      'user_female': 'Femme',
      'user_remark_label': 'Remarque',
      'user_remark_hint': 'Saisissez une remarque',
      'user_required_fields': 'Renseignez le nom, l’âge et le téléphone',
      'user_invalid_age': 'Saisissez un âge valide',
      'add_user_failed': 'Impossible d’ajouter l’utilisateur',
      'confirm_selection': 'Confirmer la sélection', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Confirmer la sélection', // 确认选择
      'music_resource_missing':
          'Aucune ressource audio pour cette musique', // 当前音乐暂无音频资源
      // 启动页面
      'red_light': 'RED TEC.', // 红光
      'wavelength': 'Thér. rouge', // 波长
      'hydrogen_molecule': 'H₂', // 分子氢
      'hydrogen_concentration': 'Conc. H₂', // 氢气浓度
      'flow': 'Débit', // 流量
      'chakra': 'Chakra', // 脉轮
      'terahertz': 'Térahertz', // 太赫兹
      'fragrance': 'Parfum', // 香氛
      'therapy_completed': 'Bien-être terminé', // 健康体验完成
      'user': 'Utilisateur', // 使用者
      'session_duration': 'Cette session', // 本次使用
      'module_duration': 'Durée du module', // 模块时长
      'no_module_record': 'Aucun historique de module', // 暂无模块运行记录
      'not_running': 'Non exécuté', // 未运行
      'running_label': 'En cours', // 运行
      'default_mode_title': 'Relaxation profonde', // 深度放松
      'no_user_selected': 'Aucun utilisateur sélectionné', // 未选择用户
      'error_send_params_failed':
          'Échec de l’envoi des paramètres :', // 参数下发失败：
      'error_pause_failed': 'Échec de la pause :', // 暂停失败：
      'error_resume_failed': 'Échec de la reprise :', // 继续失败：
      'error_stop_failed': 'Échec de l’arrêt :', // 停止失败：
      // 自定义列表页面
      'custom_plan_title': 'Programme', // 自定义方案
      'plan_search_hint': 'Saisir le nom du programme', // 输入方案名称
      'add_plan': 'Ajouter un programme', // 添加方案
      'rename_plan': 'Renommer', // 重命名
      'plan_name_empty':
          'Le nom du programme ne peut pas être vide', // 方案名称不能为空
      'custom_plan_load_failed':
          'Échec du chargement du programme personnalisé :', // 自定义方案加载失败：
      'user_not_logged_in_retry':
          'Utilisateur non connecté, veuillez vous reconnecter', // 用户未登录，请重新登录
      // 自定义编辑页面
      'red_ther': 'RED TEC.', // 红光
      'add_therapy_module': 'Ajouter module', // 添加模块
      'expand_feature': 'Extras', // 拓展功能
      'save_params': 'Enregistrer', // 保存参数
      'save_plan': 'Enregistrer le programme', // 保存方案
      'plan_saving': 'Enregistrement en cours, veuillez patienter',
      'plan_save_slow':
          'La réponse d’enregistrement est plus longue que prévu, veuillez patienter',
      'plan_save_retry': 'Échec de l’enregistrement, veuillez réessayer',
      'custom_plan_edit_invalid':
          'Le programme actuel est invalide. Revenez en arrière et réessayez',
      'complete_previous_node':
          'Veuillez d’abord terminer le segment précédent de 5 minutes', // 请先完成上一个 5 分钟节点
      'node_saved_prefix': 'Paramètres du point à ', // 第
      'node_saved_suffix': ' minutes enregistrés', // 分钟节点参数已保存
      'plan_naming': 'Nom du programme', // 方案命名
      'plan_name_duplicate':
          'Le nom du programme ne doit pas être dupliqué', // 方案名称不能重复
      'mode_select': 'Mode', // 模式选择
      'module_hydrogen': 'H₂', // 分子氢
      'module_expand': 'Extras', // 拓展功能
      'redlight_strength_required':
          'Les intensités de lumière rouge 660nm et 850nm ne peuvent pas être toutes deux à 0', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required':
          'La fréquence et l’intensité PEMF ne peuvent pas être à 0', // PEMF频率和强度都不能为0
      'vat_params_required':
          'La fréquence et l’intensité VAT ne peuvent pas être à 0', // VAT频率和强度都不能为0
      'hydrogen_concentration_required':
          'La concentration H₂ ne peut pas être 0', // 分子氢浓度不能为0
      'expand_params_required': 'Sélectionnez au moins une fonction extra',
      'node_copied_prefix': 'Copié vers le nœud de ', // 已复制到
      'node_copied_suffix': ' min', // 分钟节点
      // 拓展页面
      'fragrance_setting': 'Paramètres du parfum', // 香氛设置
      'terahertz_setting': 'Paramètres térahertz', // 太赫兹设置
      'chakra_setting': 'Paramètres des chakras', // 脉轮设置
      'hifem_setting': 'Paramètres HIFEM', // HIFEM设置
      'rotation': 'Rotation', // 轮转
      'independent': 'Indépendant', // 独立
      'gentle': 'Doux', // 轻柔
      'intense': 'Intense', // 浓烈
      'sleep': 'Sommeil', // 睡眠
      'flow_state': 'Flow', // 心流
      'meditation': 'Méditation', // 冥想
      'sine_wave': 'Sine', // 正弦波
      'square_wave': 'Carrée', // 方波
      'triangle_wave': 'Triangle', // 三角波
      'rf': 'RF', // 射频
      'crown_chakra': 'Chakra coronal', // 顶轮
      'crown_sub': '(glande pinéale)', // 松果体
      'third_eye_chakra': 'Chakra du troisième œil', // 眉心轮
      'third_eye_sub': '(hypophyse)', // 脑垂体
      'throat_chakra': 'Chakra de la gorge', // 喉轮
      'throat_sub': '(thyroïde)', // 甲状腺
      'heart_chakra': 'Chakra du cœur', // 心轮
      'heart_sub': '(thymus)', // 胸腺
      'solar_plexus_chakra': 'Chakra du plexus solaire', // 太阳神轮
      'solar_plexus_sub': '(reins)', // 肾
      'sacral_chakra': 'Chakra sacré', // 脐轮
      'sacral_sub': '(foie, reins, rate)', // 肝、肾、脾
      'root_chakra': 'Chakra racine', // 海底轮
      'root_sub': '(gonades)', // 生殖腺
    },
    ///////////////////////////////////////////////////////韩语语言/////////////////////////////////////////////////////////////////////
    'ko_KR': {
      'prompt_volume': '안내 음량',
      'prompt_volume_hint':
          '환영, 시작, 종료 및 물 안내 음량을 조절합니다. 0%는 음소거이며 슬라이더에서 손을 떼면 자동 저장됩니다.',
      'prompt_volume_update_failed': '음량을 조절하지 못했습니다. 다시 시도해 주세요.',
      'prompt_volume_save_failed': '음량을 저장하지 못했습니다. 슬라이더를 다시 조절해 주세요.',
      // 通用
      'settings': '설정', // 设置
      'administrator': '관리자', // 管理员
      'back': '뒤로', // 返回
      'confirm': '확인', // 确认
      'cancel': '취소', // 取消
      'save': '저장', // 保存
      'delete': '삭제', // 删除
      'select': '선택', // 选择
      'name': '이름 입력', // 输入姓名
      'age': '나이 입력', // 输入年龄
      'phone': '전화번호 입력', // 输入手机号
      'gender': '성별', // 性别
      'male': '남', // 男
      'female': '여', // 女
      'frequency': '주파수', // 频率
      'intensity': '강도', // 强度
      'mode': '모드', // 模式
      'waveform': '파형', // 波形
      'select_waveform': '파형 선택', // 选择波形
      'continuous': '연속', // 连续
      'pulse': '펄스', // 脉冲
      'power': '출력', // 功率
      'chakra_power': '출력', // 强度
      'running': '실행 중', // 正在运行
      'waiting': '대기 중', // 等待运行
      'logout': '로그아웃', // 退出登录
      'parameter_settings': '파라미터 설정', // 参数设置
      // Wi-Fi 및 Bluetooth 연결 안내
      'connection_prompt_title': '연결 안 됨',
      'connection_prompt_subtitle': '연결 후 계속하세요',
      'connection_prompt_wifi': 'WIFI',
      'connection_prompt_ble': 'BLE',
      'connection_status_checking': '확인 중',
      'connection_status_connected': '연결됨',
      'connection_status_disconnected': '연결 안 됨',
      'connection_prompt_skip': '건너뛰기',
      'wifi_ble': 'WIFI & BLE',
      'wifi_name_unavailable': '네트워크 이름을 가져올 수 없음',
      'wifi_no_connected_network': '연결된 네트워크 없음',
      'ble_no_connected_device': '연결된 기기 없음',
      // 设置页面
      'setting_menu': '설정 메뉴', // 设置菜单
      'language_setting': '언어 설정', // 语言设置
      'language_switch': '언어 전환', // 语言切换
      'save_changes': '저장', // 保存更改
      'date_time': '날짜 및 시간', // 日期和时间
      'year_unit': '년', // 年
      'month_unit': '월', // 月
      'day_unit': '일', // 日
      'hour_unit': '시', // 时
      'am_label': '오전', // 上午
      'pm_label': '오후', // 下午
      'date_time_saved': '날짜와 시간이 저장되었습니다', // 日期和时间已保存
      'device_info': '장치 정보', // 设备信息
      'debug_mode': '디버그 모드', // 调试模式
      'history_record': '기록', // 历史记录
      'history_detail_missing': '기록을 찾을 수 없습니다', // 历史记录不存在
      'current_account_not_logged_in': '현재 계정이 로그인되어 있지 않습니다', // 当前账号未登录
      'therapy_record_load_failed': '웰니스 기록을 불러오지 못했습니다', // 健康体验记录加载失败
      'no_history_records': '기록 없음', // 暂无历史记录
      'no_therapy_records': '웰니스 기록 없음', // 暂无健康体验记录
      'years_old_unit': '세', // 岁
      'therapy_report': '웰니스 보고서', // 健康体验报告
      'total_therapy_duration': '웰니스 시간', // 健康时长
      'feedback_label': '웰니스 메모: ', // 体验感受：
      'no_feedback': '웰니스 메모 없음', // 暂无体验感受
      'treatment_modules': '웰니스 모듈', // 健康模块
      'energy_score': '에너지 지수', // 能量指数
      'cell_score': '활력 지수', // 活力指数
      'relaxation_score': '이완 지수', // 放松指数
      'immune_score': '웰니스 지수', // 健康指数
      'compared_to_last': '지난번 대비', // 较上次
      'session_once_1': '1회', // 1次
      'session_once_2': '2회', // 2次
      'session_once_3': '3회', // 3次
      'current_session': '이번', // 本次
      'health_effect_assessment': '웰니스 개요', // 健康体验概览
      'status_good': '양호', // 良好
      'overall_score': '종합 점수', // 综合得分
      'level_low': '낮음', // 低
      'level_medium': '중간', // 中
      'level_high': '높음', // 高
      'therapy_feedback_hint': '웰니스 메모 입력', // 请输入健康体验感受
      'score_unit': '점', // 分
      'minutes_unit': '분', // 分
      'seconds_unit': '초', // 秒
      'user_management': '사용자 관리', // 用户管理
      'unsupported_language': '이 언어는 아직 지원되지 않습니다', // 该语言暂未支持
      // 主页
      'preset_mode': '프리셋 웰니스 모드', // 预设健康模式
      'preset_mode_subtitle': '일상 웰니스 프로그램 10종', // 10种日常健康方案
      'device_ready': '장치 준비 완료', // 设备就绪
      'custom_plan': '맞춤 플랜', // 自定义方案
      'deep_relax': '깊은 휴식', // 深度放松
      'energy_boost': '에너지 충전', // 焕新充能
      'pain_relief': '편안한 휴식', // 柔和舒适
      'sleep_enhancement': '밤의 휴식', // 夜间放松
      'sports_recovery': '쿨다운', // 活动后放松
      'stress_release': '차분한 휴식', // 舒缓放松
      'immune_boost': '일상 활력', // 日常活力
      'anti_aging': '빛나는 활력', // 焕彩活力
      'full_care': '전신 리셋', // 全身焕新
      'mental_healing': '기분 전환', // 心情平衡
      'device_fault': '장치 고장', // 设备故障
      'water_level_warning_title': '물 부족 알림',
      'water_level_warning_message': '물탱크 수위가 낮습니다. 계속 사용하려면 물을 보충하세요.',
      'water_level_shortage_title': '물 부족',
      'water_level_shortage_message': '물이 부족합니다. 자동 급수를 위해 급수원을 연결해 주세요.',
      'water_level_shortage_unavailable': '분자 수소 기능을 일시적으로 사용할 수 없습니다',
      'water_level_filling_title': '물 보충 중',
      'water_level_filling_message': '물을 보충하고 있습니다. 잠시만 기다려 주세요...',
      'water_level_complete_title': '물 보충 완료',
      'water_level_complete_message': '물 보충이 완료되었습니다. 장치를 계속 사용할 수 있습니다.',
      'water_level_ready_button': '준비되셨나요?',
      'water_level_start_filling_button': '물 채우기 시작',
      // 登录页面
      'login_email_hint': '이메일을 입력하세요', // 输入邮箱
      'login_password_hint': '비밀번호를 입력하세요', // 输入密码
      'forgot_password': '비밀번호를 잊으셨나요?', // 忘记密码?
      'login': '로그인', // 登录
      'register': '회원가입', // 注册
      'agree_prefix': '다음을 읽고 동의합니다 ', // 我已阅读并同意
      'user_agreement': '사용자 약관', // 《用户协议》
      'and': ' 및 ', // 和
      'privacy_policy': '개인정보 처리방침', // 《隐私政策》
      // 회원가입 페이지
      'Admin': '관리자', // 管理员
      'Operator': '운영자', // 操作员
      'User': '개인', // 个人
      'verify_code': '인증 코드를 입력하세요', // 输入验证码
      'send_code': '전송 중...', // 发送中...
      'get_code': '인증 코드 받기', // 获取验证码
      'registering': '가입 중...', // 注册中...
      'already_have_account': '이미 계정이 있으신가요?', // 已有账号?
      'login_now': '지금 로그인', // 立即登录
      'prompt': '안내', // 提示
      'email_empty': '먼저 이메일을 입력하세요', // 请先输入邮箱
      'email_invalid': '올바른 이메일 주소를 입력하세요', // 请输入正确的邮箱
      'code_send_failed': '인증 코드 전송에 실패했습니다', // 验证码发送失败
      'register_success': '회원가입이 완료되었습니다', // 注册成功
      'register_failed': '회원가입에 실패했습니다', // 注册失败
      'email_required': '이메일을 입력하세요', // 请输入邮箱
      'password_required': '비밀번호를 입력하세요', // 请输入密码
      'login_success_empty_user': '로그인했지만 사용자 정보가 없습니다', // 登录成功，但用户信息为空
      'login_success': '로그인 성공', // 登录成功
      'login_failed': '로그인 실패', // 登录失败
      'error': '오류', // 错误
      'network_error': '네트워크 연결 실패, 네트워크 또는 서버를 확인하세요',
      'unknown_error': '알 수 없는 오류',
      'login_request_failed': '로그인 요청 실패: ', // 登录请求失败：
      'new_password_hint': '새 비밀번호를 입력하세요', // 输入新密码
      'confirm_new_password_hint': '새 비밀번호를 확인하세요', // 确认新密码
      'resetting_password': '재설정 중...', // 重置中...
      'confirm_reset': '재설정 확인', // 确认重置
      'code_sent_backend_email': '인증 코드 전송 위치: ', // 验证码已发送至：
      'verify_code_required': '인증 코드를 입력하세요', // 请输入验证码
      'new_password_required': '새 비밀번호를 입력하세요', // 请输入新密码
      'confirm_new_password_required': '새 비밀번호를 다시 입력하세요', // 请再次输入新密码
      'passwords_not_match': '비밀번호가 일치하지 않습니다', // 两次输入的密码不一致
      'password_reset_success': '비밀번호가 재설정되었습니다', // 密码重置成功
      'password_reset_failed': '비밀번호 재설정에 실패했습니다', // 密码重置失败
      // 用户选择页面
      'choose_therapy_user': '사용자 선택', // 选择体验用户
      'search_user_hint': '이름/전화번호 입력', // 输入用户姓名或手机号
      'add_user': '사용자 추가', // 添加用户
      'user_name_label': '이름',
      'user_age_label': '나이',
      'user_phone_label': '전화번호',
      'user_email_label': '이메일',
      'user_email_hint': '이메일 주소 입력',
      'user_gender_label': '성별',
      'user_male': '남성',
      'user_female': '여성',
      'user_remark_label': '메모',
      'user_remark_hint': '메모 입력',
      'user_required_fields': '이름, 나이, 전화번호를 입력하세요',
      'user_invalid_age': '올바른 나이를 입력하세요',
      'add_user_failed': '사용자를 추가하지 못했습니다',
      'confirm_selection': '선택 확인', // 确认选择
      // 音乐页面
      'confirm_music_selection': '선택 확인', // 确认选择
      'music_resource_missing': '현재 음악에 오디오 리소스가 없습니다', // 当前音乐暂无音频资源
      // 启动页面
      'red_light': '레드 라이트', // 红光
      'wavelength': '파장', // 波长
      'hydrogen_molecule': '수소', // 分子氢
      'hydrogen_concentration': '수소 농도', // 氢气浓度
      'flow': '유량', // 流量
      'chakra': '차크라', // 脉轮
      'terahertz': '테라헤르츠', // 太赫兹
      'fragrance': '아로마', // 香氛
      'therapy_completed': '웰니스 완료', // 健康体验完成
      'user': '사용자', // 使用者
      'session_duration': '세션 시간', // 本次使用
      'module_duration': '모듈 시간', // 模块时长
      'no_module_record': '모듈 실행 기록 없음', // 暂无模块运行记录
      'not_running': '미실행', // 未运行
      'running_label': '실행', // 运行
      'default_mode_title': '심층 이완', // 深度放松
      'no_user_selected': '선택된 사용자가 없습니다', // 未选择用户
      'error_send_params_failed': '파라미터 전송 실패: ', // 参数下发失败：
      'error_pause_failed': '일시정지 실패: ', // 暂停失败：
      'error_resume_failed': '재개 실패: ', // 继续失败：
      'error_stop_failed': '정지 실패: ', // 停止失败：
      // 自定义列表页面
      'custom_plan_title': '맞춤 플랜', // 自定义方案
      'plan_search_hint': '플랜 이름 입력', // 输入方案名称
      'add_plan': '플랜 추가', // 添加方案
      'rename_plan': '이름 변경', // 重命名
      'plan_name_empty': '플랜 이름은 비워둘 수 없습니다', // 方案名称不能为空
      'custom_plan_load_failed': '맞춤 플랜 로드 실패: ', // 自定义方案加载失败：
      'user_not_logged_in_retry': '로그인이 필요합니다. 다시 로그인하세요', // 用户未登录，请重新登录
      // 自定义编辑页面
      'red_ther': '레드 라이트', // 红光
      'add_therapy_module': '웰니스 모듈 추가', // 添加健康模块
      'expand_feature': '확장', // 拓展功能
      'save_params': '파라미터 저장', // 保存参数
      'save_plan': '플랜 저장', // 保存方案
      'plan_saving': '저장 중입니다. 잠시만 기다려 주세요',
      'plan_save_slow': '저장 응답이 지연되고 있습니다. 잠시만 기다려 주세요',
      'plan_save_retry': '저장하지 못했습니다. 다시 시도해 주세요',
      'custom_plan_edit_invalid': '현재 플랜 정보가 올바르지 않습니다. 돌아가서 다시 시도해 주세요',
      'complete_previous_node': '먼저 이전 5분 노드를 완료하세요', // 请先完成上一个 5 分钟节点
      'node_saved_prefix': '', // 第
      'node_saved_suffix': '분 노드 파라미터가 저장되었습니다', // 分钟节点参数已保存
      'plan_naming': '플랜 이름', // 方案命名
      'plan_name_duplicate': '플랜 이름은 중복될 수 없습니다', // 方案名称不能重复
      'mode_select': '모드 선택', // 模式选择
      'module_hydrogen': '수소', // 分子氢
      'module_expand': '확장', // 拓展功能
      'redlight_strength_required':
          '레드라이트 660nm와 850nm 강도는 동시에 0일 수 없습니다', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required': 'PEMF 주파수와 강도는 모두 0일 수 없습니다', // PEMF频率和强度都不能为0
      'vat_params_required': 'VAT 주파수와 강도는 모두 0일 수 없습니다', // VAT频率和强度都不能为0
      'hydrogen_concentration_required': '수소 농도는 0일 수 없습니다', // 分子氢浓度不能为0
      'expand_params_required': '최소 하나의 확장 기능을 선택하세요',
      'node_copied_prefix': '', // 已复制到
      'node_copied_suffix': '분 노드에 복사됨', // 分钟节点
      // 拓展页面
      'fragrance_setting': '아로마 설정', // 香氛设置
      'terahertz_setting': '테라헤르츠', // 太赫兹设置
      'chakra_setting': '차크라 설정', // 脉轮设置
      'hifem_setting': 'HIFEM', // HIFEM设置
      'rotation': '순환', // 轮转
      'independent': '독립', // 独立
      'gentle': '부드럽게', // 轻柔
      'intense': '강하게', // 浓烈
      'sleep': '수면', // 睡眠
      'flow_state': '몰입', // 心流
      'meditation': '명상', // 冥想
      'sine_wave': '사인파', // 正弦波
      'square_wave': '사각파', // 方波
      'triangle_wave': '삼각파', // 三角波
      'rf': 'RF', // 射频
      'crown_chakra': '정수리 차크라', // 顶轮
      'crown_sub': '(송과선)', // 松果体
      'third_eye_chakra': '제3의 눈 차크라', // 眉心轮
      'third_eye_sub': '(뇌하수체)', // 脑垂体
      'throat_chakra': '목 차크라', // 喉轮
      'throat_sub': '(갑상선)', // 甲状腺
      'heart_chakra': '심장 차크라', // 心轮
      'heart_sub': '(흉선)', // 胸腺
      'solar_plexus_chakra': '태양신경총 차크라', // 太阳神轮
      'solar_plexus_sub': '(신장)', // 肾
      'sacral_chakra': '천골 차크라', // 脐轮
      'sacral_sub': '(간, 신장, 비장)', // 肝、肾、脾
      'root_chakra': '뿌리 차크라', // 海底轮
      'root_sub': '(생식선)', // 生殖腺
    },
    ///////////////////////////////////////////////////////////////////阿拉伯语语言////////////////////////////////////////////////
    'ar_SA': {
      'prompt_volume': 'مستوى صوت التنبيهات',
      'prompt_volume_hint':
          'اضبط تنبيهات الترحيب والبدء والانتهاء والماء. تكتم نسبة 0% الصوت. يُحفظ التغيير عند إفلات شريط التمرير.',
      'prompt_volume_update_failed': 'تعذر ضبط مستوى الصوت. حاول مرة أخرى.',
      'prompt_volume_save_failed':
          'تعذر حفظ مستوى الصوت. اضبط شريط التمرير مرة أخرى.',
      // 通用
      'settings': 'الإعدادات', // 设置
      'administrator': 'المدير', // 管理员
      'back': 'رجوع', // 返回
      'confirm': 'تأكيد', // 确认
      'cancel': 'إلغاء', // 取消
      'save': 'حفظ', // 保存
      'delete': 'حذف', // 删除
      'select': 'اختيار', // 选择
      'name': 'أدخل الاسم', // 输入姓名
      'age': 'أدخل العمر', // 输入年龄
      'phone': 'أدخل الهاتف', // 输入手机号
      'gender': 'الجنس', // 性别
      'male': 'ذ', // 男
      'female': 'أ', // 女
      'frequency': 'التردد', // 频率
      'intensity': 'الشدة', // 强度
      'mode': 'الوضع', // 模式
      'waveform': 'شكل الموجة', // 波形
      'runtime_waveform': 'موجة',
      'select_waveform': 'اختيار شكل الموجة', // 选择波形
      'continuous': 'مستمر', // 连续
      'pulse': 'نبضي', // 脉冲
      'power': 'القدرة', // 功率
      'chakra_power': 'قدرة', // 强度
      'running': 'قيد التشغيل', // 正在运行
      'waiting': 'في الانتظار', // 等待运行
      'logout': 'خروج', // 退出登录
      'parameter_settings': 'إعدادات المعلمات', // 参数设置
      // تنبيه اتصال Wi-Fi وBluetooth
      'connection_prompt_title': 'غير متصل',
      'connection_prompt_subtitle': 'يرجى الاتصال للمتابعة',
      'connection_prompt_wifi': 'WIFI',
      'connection_prompt_ble': 'BLE',
      'connection_status_checking': 'جارٍ التحقق',
      'connection_status_connected': 'متصل',
      'connection_status_disconnected': 'غير متصل',
      'connection_prompt_skip': 'تخطي',
      'wifi_ble': 'WIFI & BLE',
      'wifi_name_unavailable': 'اسم الشبكة غير متاح',
      'wifi_no_connected_network': 'لا توجد شبكة متصلة',
      'ble_no_connected_device': 'لا يوجد جهاز متصل',
      // 设置页面
      'setting_menu': 'قائمة الإعدادات', // 设置菜单
      'language_setting': 'اللغة', // 语言设置
      'language_switch': 'تبديل اللغة', // 语言切换
      'save_changes': 'حفظ', // 保存更改
      'date_time': 'التاريخ والوقت', // 日期和时间
      'year_unit': 'س', // 年
      'month_unit': 'ش', // 月
      'day_unit': 'ي', // 日
      'hour_unit': 'س', // 时
      'am_label': 'ص', // 上午
      'pm_label': 'م', // 下午
      'date_time_saved': 'تم حفظ التاريخ والوقت', // 日期和时间已保存
      'device_info': 'معلومات الجهاز', // 设备信息
      'debug_mode': 'وضع التصحيح', // 调试模式
      'history_record': 'السجل', // 历史记录
      'history_detail_missing': 'سجل التاريخ غير موجود', // 历史记录不存在
      'current_account_not_logged_in':
          'الحساب الحالي غير مسجل الدخول', // 当前账号未登录
      'therapy_record_load_failed': 'فشل تحميل سجلات العافية', // 健康体验记录加载失败
      'no_history_records': 'لا توجد سجلات تاريخ', // 暂无历史记录
      'no_therapy_records': 'لا توجد سجلات عافية', // 暂无健康体验记录
      'years_old_unit': 'س', // 岁
      'therapy_report': 'تقرير العافية', // 健康体验报告
      'total_therapy_duration': 'وقت العافية', // 健康时长
      'feedback_label': 'ملاحظات العافية: ', // 体验感受：
      'no_feedback': 'لا توجد ملاحظات عافية', // 暂无体验感受
      'treatment_modules': 'وحدات العافية', // 健康模块
      'energy_score': 'مؤشر الطاقة', // 能量指数
      'cell_score': 'مؤشر الحيوية', // 活力指数
      'relaxation_score': 'مؤشر الاسترخاء', // 放松指数
      'immune_score': 'مؤشر العافية', // 健康指数
      'compared_to_last': 'مقابل السابق', // 较上次
      'session_once_1': '1', // 1次
      'session_once_2': '2', // 2次
      'session_once_3': '3', // 3次
      'current_session': 'الحالية', // 本次
      'health_effect_assessment': 'ملخص العافية', // 健康体验概览
      'status_good': 'جيد', // 良好
      'overall_score': 'النتيجة الإجمالية', // 综合得分
      'level_low': 'منخفض', // 低
      'level_medium': 'متوسط', // 中
      'level_high': 'مرتفع', // 高
      'therapy_feedback_hint': 'أدخل ملاحظات العافية', // 请输入健康体验感受
      'score_unit': 'نقطة', // 分
      'minutes_unit': 'د', // 分
      'seconds_unit': 'ث', // 秒
      'user_management': 'المستخدمون', // 用户管理
      'unsupported_language': 'هذه اللغة غير مدعومة حاليًا', // 该语言暂未支持
      // 主页
      'preset_mode': 'أوضاع العافية', // 预设健康模式
      'preset_mode_subtitle': '10 برامج عافية يومية', // 10种日常健康方案
      'device_ready': 'الجهاز جاهز', // 设备就绪
      'custom_plan': 'خطة مخصصة', // 自定义方案
      'deep_relax': 'استرخاء عميق', // 深度放松
      'energy_boost': 'تجدد ونشاط', // 焕新充能
      'pain_relief': 'راحة لطيفة', // 柔和舒适
      'sleep_enhancement': 'هدوء مسائي', // 夜间放松
      'sports_recovery': 'تهدئة', // 活动后放松
      'stress_release': 'هدوء واسترخاء', // 舒缓放松
      'immune_boost': 'نشاط يومي', // 日常活力
      'anti_aging': 'حيوية مشرقة', // 焕彩活力
      'full_care': 'تجدد الجسم', // 全身焕新
      'mental_healing': 'مزاج أفضل', // 心情平衡
      'device_fault': 'عطل الجهاز', // 设备故障
      'water_level_warning_title': 'تنبيه نقص الماء',
      'water_level_warning_message':
          'مستوى الماء في الخزان منخفض. يرجى تعبئته قبل المتابعة.',
      'water_level_shortage_title': 'نقص الماء',
      'water_level_shortage_message':
          'الماء غير كافٍ. يرجى توصيل مصدر الماء للتعبئة التلقائية.',
      'water_level_shortage_unavailable':
          'وظيفة الهيدروجين الجزيئي غير متاحة مؤقتًا',
      'water_level_filling_title': 'جارٍ تعبئة الماء',
      'water_level_filling_message': 'جارٍ تعبئة الماء، يرجى الانتظار...',
      'water_level_complete_title': 'اكتملت تعبئة الماء',
      'water_level_complete_message':
          'اكتملت تعبئة الماء، ويمكنك متابعة استخدام الجهاز.',
      'water_level_ready_button': 'هل أنت مستعد؟',
      'water_level_start_filling_button': 'بدء التعبئة',
      // 登录页面
      'login_email_hint': 'أدخل البريد الإلكتروني', // 输入邮箱
      'login_password_hint': 'أدخل كلمة المرور', // 输入密码
      'forgot_password': 'هل نسيت كلمة المرور؟', // 忘记密码?
      'login': 'تسجيل الدخول', // 登录
      'register': 'تسجيل', // 注册
      'agree_prefix': 'لقد قرأت وأوافق على ', // 我已阅读并同意
      'user_agreement': 'اتفاقية المستخدم', // 《用户协议》
      'and': ' و ', // 和
      'privacy_policy': 'سياسة الخصوصية', // 《隐私政策》
      // صفحة التسجيل
      'Admin': 'مسؤول', // 管理员
      'Operator': 'مشغل', // 操作员
      'User': 'فرد', // 个人
      'verify_code': 'أدخل رمز التحقق', // 输入验证码
      'send_code': 'جارٍ الإرسال...', // 发送中...
      'get_code': 'الحصول على الرمز', // 获取验证码
      'registering': 'جارٍ التسجيل...', // 注册中...
      'already_have_account': 'لديك حساب بالفعل؟', // 已有账号?
      'login_now': 'تسجيل الدخول الآن', // 立即登录
      'prompt': 'تنبيه', // 提示
      'email_empty': 'يرجى إدخال البريد الإلكتروني أولاً', // 请先输入邮箱
      'email_invalid': 'يرجى إدخال بريد إلكتروني صحيح', // 请输入正确的邮箱
      'code_send_failed': 'فشل إرسال رمز التحقق', // 验证码发送失败
      'register_success': 'تم التسجيل بنجاح', // 注册成功
      'register_failed': 'فشل التسجيل', // 注册失败
      'email_required': 'يرجى إدخال البريد الإلكتروني', // 请输入邮箱
      'password_required': 'يرجى إدخال كلمة المرور', // 请输入密码
      'login_success_empty_user':
          'تم تسجيل الدخول لكن معلومات المستخدم فارغة', // 登录成功，但用户信息为空
      'login_success': 'تم تسجيل الدخول بنجاح', // 登录成功
      'login_failed': 'فشل تسجيل الدخول', // 登录失败
      'error': 'خطأ', // 错误
      'network_error': 'فشل الاتصال بالشبكة، يرجى التحقق من الشبكة أو الخادم',
      'unknown_error': 'خطأ غير معروف',
      'login_request_failed': 'فشل طلب تسجيل الدخول: ', // 登录请求失败：
      'new_password_hint': 'أدخل كلمة المرور الجديدة', // 输入新密码
      'confirm_new_password_hint': 'أكد كلمة المرور الجديدة', // 确认新密码
      'resetting_password': 'جارٍ إعادة التعيين...', // 重置中...
      'confirm_reset': 'تأكيد إعادة التعيين', // 确认重置
      'code_sent_backend_email': 'تم إرسال رمز التحقق إلى: ', // 验证码已发送至：
      'verify_code_required': 'يرجى إدخال رمز التحقق', // 请输入验证码
      'new_password_required': 'يرجى إدخال كلمة مرور جديدة', // 请输入新密码
      'confirm_new_password_required':
          'يرجى تأكيد كلمة المرور الجديدة', // 请再次输入新密码
      'passwords_not_match': 'كلمتا المرور غير متطابقتين', // 两次输入的密码不一致
      'password_reset_success': 'تمت إعادة تعيين كلمة المرور بنجاح', // 密码重置成功
      'password_reset_failed': 'فشلت إعادة تعيين كلمة المرور', // 密码重置失败
      // 用户选择页面
      'choose_therapy_user': 'اختيار المستخدم', // 选择体验用户
      'search_user_hint': 'أدخل الاسم أو رقم الهاتف', // 输入用户姓名或手机号
      'add_user': 'إضافة مستخدم', // 添加用户
      'user_name_label': 'الاسم',
      'user_age_label': 'العمر',
      'user_phone_label': 'الهاتف',
      'user_email_label': 'البريد الإلكتروني',
      'user_email_hint': 'أدخل البريد الإلكتروني',
      'user_gender_label': 'الجنس',
      'user_male': 'ذكر',
      'user_female': 'أنثى',
      'user_remark_label': 'ملاحظات',
      'user_remark_hint': 'أدخل الملاحظات',
      'user_required_fields': 'يرجى إدخال الاسم والعمر والهاتف',
      'user_invalid_age': 'يرجى إدخال عمر صحيح',
      'add_user_failed': 'تعذرت إضافة المستخدم',
      'confirm_selection': 'تأكيد الاختيار', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'تأكيد الاختيار', // 确认选择
      'music_resource_missing': 'لا يوجد ملف صوتي لهذه الموسيقى', // 当前音乐暂无音频资源
      // 启动页面
      'red_light': 'الضوء الأحمر', // 红光
      'wavelength': 'الطول الموجي', // 波长
      'hydrogen_molecule': 'H₂', // 分子氢
      'hydrogen_concentration': 'تركيز H₂', // 氢气浓度
      'flow': 'التدفق', // 流量
      'chakra': 'شاكرا', // 脉轮
      'terahertz': 'تيراهرتز', // 太赫兹
      'fragrance': 'العطر', // 香氛
      'therapy_completed': 'اكتملت جلسة العافية', // 健康体验完成
      'user': 'المستخدم', // 使用者
      'session_duration': 'مدة الجلسة', // 本次使用
      'module_duration': 'مدة الوحدة', // 模块时长
      'no_module_record': 'لا توجد سجلات تشغيل للوحدة', // 暂无模块运行记录
      'not_running': 'لم يعمل', // 未运行
      'running_label': 'تشغيل', // 运行
      'default_mode_title': 'استرخاء عميق', // 深度放松
      'no_user_selected': 'لم يتم اختيار مستخدم', // 未选择用户
      'error_send_params_failed': 'فشل إرسال المعلمات: ', // 参数下发失败：
      'error_pause_failed': 'فشل الإيقاف المؤقت: ', // 暂停失败：
      'error_resume_failed': 'فشل الاستئناف: ', // 继续失败：
      'error_stop_failed': 'فشل الإيقاف: ', // 停止失败：
      // 自定义列表页面
      'custom_plan_title': 'خطط مخصصة', // 自定义方案
      'plan_search_hint': 'أدخل اسم الخطة', // 输入方案名称
      'add_plan': 'إضافة خطة', // 添加方案
      'rename_plan': 'إعادة تسمية', // 重命名
      'plan_name_empty': 'لا يمكن أن يكون اسم الخطة فارغًا', // 方案名称不能为空
      'custom_plan_load_failed': 'فشل تحميل الخطط المخصصة: ', // 自定义方案加载失败：
      'user_not_logged_in_retry':
          'المستخدم غير مسجل الدخول، يرجى تسجيل الدخول مرة أخرى', // 用户未登录，请重新登录
      // 自定义编辑页面
      'red_ther': 'الضوء الأحمر', // 红光
      'add_therapy_module': 'إضافة وحدة عافية', // 添加健康模块
      'expand_feature': 'ميزات إضافية', // 拓展功能
      'save_params': 'حفظ المعلمات', // 保存参数
      'save_plan': 'حفظ الخطة', // 保存方案
      'plan_saving': 'جارٍ الحفظ، يرجى الانتظار',
      'plan_save_slow': 'يستغرق الحفظ وقتًا أطول، يرجى الانتظار',
      'plan_save_retry': 'فشل الحفظ، يرجى المحاولة مرة أخرى',
      'custom_plan_edit_invalid':
          'الخطة الحالية غير صالحة. ارجع وحاول مرة أخرى',
      'complete_previous_node':
          'يرجى إكمال نقطة الخمس دقائق السابقة أولًا', // 请先完成上一个 5 分钟节点
      'node_saved_prefix': 'تم حفظ معلمات نقطة ', // 第
      'node_saved_suffix': ' دقائق', // 分钟节点参数已保存
      'plan_naming': 'تسمية الخطة', // 方案命名
      'plan_name_duplicate': 'لا يمكن تكرار اسم الخطة', // 方案名称不能重复
      'mode_select': 'اختيار الوضع', // 模式选择
      'module_hydrogen': 'H₂', // 分子氢
      'module_expand': 'توسيع', // 拓展功能
      'redlight_strength_required':
          'لا يمكن أن تكون شدة الضوء الأحمر 660nm و850nm صفرًا معًا', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required':
          'لا يمكن أن يكون تردد وشدة PEMF صفرًا', // PEMF频率和强度都不能为0
      'vat_params_required':
          'لا يمكن أن يكون تردد وشدة VAT صفرًا', // VAT频率和强度都不能为0
      'hydrogen_concentration_required':
          'لا يمكن أن يكون تركيز H₂ صفرًا', // 分子氢浓度不能为0
      'expand_params_required': 'يرجى تحديد ميزة إضافية واحدة على الأقل',
      'node_copied_prefix': 'تم النسخ إلى عقدة ', // 已复制到
      'node_copied_suffix': ' دقيقة', // 分钟节点
      // 拓展页面
      'fragrance_setting': 'إعدادات العطر', // 香氛设置
      'terahertz_setting': 'إعدادات التيراهرتز', // 太赫兹设置
      'chakra_setting': 'إعدادات الشاكرا', // 脉轮设置
      'hifem_setting': 'إعدادات HIFEM', // HIFEM设置
      'rotation': 'تناوب', // 轮转
      'independent': 'مستقل', // 独立
      'gentle': 'لطيف', // 轻柔
      'intense': 'قوي', // 浓烈
      'sleep': 'النوم', // 睡眠
      'flow_state': 'التدفق', // 心流
      'meditation': 'تأمل', // 冥想
      'sine_wave': 'موجة جيبية', // 正弦波
      'square_wave': 'موجة مربعة', // 方波
      'triangle_wave': 'موجة مثلثية', // 三角波
      'rf': 'RF', // 射频
      'crown_chakra': 'شاكرا التاج', // 顶轮
      'crown_sub': '(الغدة الصنوبرية)', // 松果体
      'third_eye_chakra': 'شاكرا العين الثالثة', // 眉心轮
      'third_eye_sub': '(الغدة النخامية)', // 脑垂体
      'throat_chakra': 'شاكرا الحلق', // 喉轮
      'throat_sub': '(الغدة الدرقية)', // 甲状腺
      'heart_chakra': 'شاكرا القلب', // 心轮
      'heart_sub': '(الغدة الزعترية)', // 胸腺
      'solar_plexus_chakra': 'شاكرا الضفيرة الشمسية', // 太阳神轮
      'solar_plexus_sub': '(الكلى)', // 肾
      'sacral_chakra': 'شاكرا العجز', // 脐轮
      'sacral_sub': '(الكبد، الكلى، الطحال)', // 肝、肾、脾
      'root_chakra': 'شاكرا الجذر', // 海底轮
      'root_sub': '(الغدد التناسلية)', // 生殖腺
    },
    /////////////////////////////////////////////////////////////////德语语言////////////////////////////////////////////////
    'de_DE': {
      'prompt_volume': 'Hinweislautstärke',
      'prompt_volume_hint':
          'Lautstärke für Begrüßung, Start, Ende und Wasserhinweise. 0% schaltet die Hinweise stumm. Beim Loslassen wird gespeichert.',
      'prompt_volume_update_failed':
          'Lautstärke konnte nicht angepasst werden. Bitte erneut versuchen.',
      'prompt_volume_save_failed':
          'Lautstärke konnte nicht gespeichert werden. Regler erneut bewegen.',
      // 通用
      'settings': 'Einst.', // 设置
      'administrator': 'Admin', // 管理员
      'back': 'Zurück', // 返回
      'confirm': 'Bestätigen', // 确认
      'cancel': 'Abbrechen', // 取消
      'save': 'Speichern', // 保存
      'delete': 'Löschen', // 删除
      'select': 'Wählen', // 选择
      'name': 'Namen eingeben', // 输入姓名
      'age': 'Alter eingeben', // 输入年龄
      'phone': 'Telefon eingeben', // 输入手机号
      'gender': 'Geschlecht', // 性别
      'male': 'M', // 男
      'female': 'W', // 女
      'frequency': 'Frequenz', // 频率
      'intensity': 'Intensität', // 强度
      'mode': 'Modus', // 模式
      'waveform': 'Welle', // 波形
      'select_waveform': 'Wellenform wählen', // 选择波形
      'continuous': 'Kont.', // 连续
      'pulse': 'Impuls', // 脉冲
      'power': 'Leistung', // 功率
      'chakra_power': 'Leist.', // 强度
      'running': 'Läuft', // 正在运行
      'waiting': 'Warten', // 等待运行
      'logout': 'Abmelden', // 退出登录
      'parameter_settings': 'Parameter', // 参数设置
      // Hinweis zur Wi-Fi- und Bluetooth-Verbindung
      'connection_prompt_title': 'Nicht verbunden',
      'connection_prompt_subtitle': 'Zum Fortfahren verbinden',
      'connection_prompt_wifi': 'WIFI',
      'connection_prompt_ble': 'BLE',
      'connection_status_checking': 'Wird geprüft',
      'connection_status_connected': 'Verbunden',
      'connection_status_disconnected': 'Nicht verbunden',
      'connection_prompt_skip': 'Überspringen',
      'wifi_ble': 'WIFI & BLE',
      'wifi_name_unavailable': 'Netzwerkname nicht verfügbar',
      'wifi_no_connected_network': 'Kein Netzwerk verbunden',
      'ble_no_connected_device': 'Kein Gerät verbunden',
      // 设置页面
      'setting_menu': 'Einstellungsmenü', // 设置菜单
      'language_setting': 'Sprache', // 语言设置
      'language_switch': 'Sprache wechseln', // 语言切换
      'save_changes': 'Speichern', // 保存更改
      'date_time': 'Datum & Uhrzeit', // 日期和时间
      'year_unit': 'J', // 年
      'month_unit': 'M', // 月
      'day_unit': 'T', // 日
      'hour_unit': 'h', // 时
      'am_label': 'AM', // 上午
      'pm_label': 'PM', // 下午
      'date_time_saved': 'Datum und Uhrzeit gespeichert', // 日期和时间已保存
      'device_info': 'Geräteinfo', // 设备信息
      'debug_mode': 'Debug-Modus', // 调试模式
      'history_record': 'Verlauf', // 历史记录
      'history_detail_missing': 'Verlauf nicht gefunden', // 历史记录不存在
      'current_account_not_logged_in':
          'Aktuelles Konto ist nicht angemeldet', // 当前账号未登录
      'therapy_record_load_failed':
          'Wellness-Daten konnten nicht geladen werden', // 健康体验记录加载失败
      'no_history_records': 'Keine Verlaufsdaten', // 暂无历史记录
      'no_therapy_records': 'Keine Wellness-Daten', // 暂无健康体验记录
      'years_old_unit': 'J', // 岁
      'therapy_report': 'Wellness-Bericht', // 健康体验报告
      'total_therapy_duration': 'Wellness-Zeit', // 健康时长
      'feedback_label': 'Wellness-Notizen: ', // 体验感受：
      'no_feedback': 'Keine Wellness-Notizen', // 暂无体验感受
      'treatment_modules': 'Wellness-Module', // 健康模块
      'energy_score': 'Energie', // 能量指数
      'cell_score': 'Vitalitätsidx.', // 活力指数
      'relaxation_score': 'Entspannung', // 放松指数
      'immune_score': 'Wellness-Idx.', // 健康指数
      'compared_to_last': 'vs letzte', // 较上次
      'session_once_1': '1.', // 1次
      'session_once_2': '2.', // 2次
      'session_once_3': '3.', // 3次
      'current_session': 'Aktuell', // 本次
      'health_effect_assessment': 'Wellness-Übersicht', // 健康体验概览
      'status_good': 'Gut', // 良好
      'overall_score': 'Gesamtpunktzahl', // 综合得分
      'level_low': 'Niedrig', // 低
      'level_medium': 'Mittel', // 中
      'level_high': 'Hoch', // 高
      'therapy_feedback_hint': 'Wellness-Notizen eingeben', // 请输入健康体验感受
      'score_unit': 'Pkt', // 分
      'minutes_unit': 'min', // 分
      'seconds_unit': 's', // 秒
      'user_management': 'Benutzer', // 用户管理
      'unsupported_language':
          'Diese Sprache wird noch nicht unterstützt', // 该语言暂未支持
      // 主页
      'preset_mode': 'Wellness-Modi', // 预设健康模式
      'preset_mode_subtitle': '10 Wellness-Programme', // 10种日常健康方案
      'device_ready': 'Gerät bereit', // 设备就绪
      'custom_plan': 'Eigener Plan', // 自定义方案
      'deep_relax': 'TIEF ENTSPANNT', // 深度放松
      'energy_boost': 'NEUE ENERGIE', // 焕新充能
      'pain_relief': 'SANFTER KOMFORT', // 柔和舒适
      'sleep_enhancement': 'ABENDRUHE', // 夜间放松
      'sports_recovery': 'COOL-DOWN', // 活动后放松
      'stress_release': 'RUHE & RELAX', // 舒缓放松
      'immune_boost': 'TAGESKRAFT', // 日常活力
      'anti_aging': 'VITALITÄT', // 焕彩活力
      'full_care': 'KÖRPER-RESET', // 全身焕新
      'mental_healing': 'GUTE LAUNE', // 心情平衡
      'device_fault': 'Gerätefehler', // 设备故障
      'water_level_warning_title': 'Wasserstand zu niedrig',
      'water_level_warning_message':
          'Der Wasserstand im Tank ist niedrig. Bitte vor der Nutzung auffüllen.',
      'water_level_shortage_title': 'Wassermangel',
      'water_level_shortage_message':
          'Zu wenig Wasser. Wasserzufuhr zum automatischen Befüllen anschließen.',
      'water_level_shortage_unavailable':
          'Molekularer Wasserstoff ist vorübergehend nicht verfügbar',
      'water_level_filling_title': 'Wasser wird eingefüllt',
      'water_level_filling_message': 'Wasser wird eingefüllt, bitte warten ...',
      'water_level_complete_title': 'Wasserfüllung abgeschlossen',
      'water_level_complete_message':
          'Das Wasser wurde vollständig eingefüllt. Sie können das Gerät weiter verwenden.',
      'water_level_ready_button': 'Bereit?',
      'water_level_start_filling_button': 'Füllen starten',
      // 登录页面
      'login_email_hint': 'E-Mail-Adresse eingeben', // 输入邮箱
      'login_password_hint': 'Passwort eingeben', // 输入密码
      'forgot_password': 'Passwort vergessen?', // 忘记密码?
      'login': 'Anmelden', // 登录
      'register': 'Registrieren', // 注册
      'agree_prefix': 'Ich akzeptiere ', // 我已阅读并同意
      'user_agreement': 'die AGB', // 《用户协议》
      'and': ' und ', // 和
      'privacy_policy': 'die Datenschutzerklärung', // 《隐私政策》
      // Registrierungsseite
      'Admin': 'Administrator', // 管理员
      'Operator': 'Bediener', // 操作员
      'User': 'Privatperson', // 个人
      'verify_code': 'Bestätigungscode eingeben', // 输入验证码
      'send_code': 'Wird gesendet...', // 发送中...
      'get_code': 'Code anfordern', // 获取验证码
      'registering': 'Registrierung...', // 注册中...
      'already_have_account': 'Bereits ein Konto?', // 已有账号?
      'login_now': 'Jetzt anmelden', // 立即登录
      'prompt': 'Hinweis', // 提示
      'email_empty': 'Bitte zuerst die E-Mail-Adresse eingeben', // 请先输入邮箱
      'email_invalid': 'Bitte eine gültige E-Mail-Adresse eingeben', // 请输入正确的邮箱
      'code_send_failed':
          'Bestätigungscode konnte nicht gesendet werden', // 验证码发送失败
      'register_success': 'Registrierung erfolgreich', // 注册成功
      'register_failed': 'Registrierung fehlgeschlagen', // 注册失败
      'email_required': 'Bitte E-Mail-Adresse eingeben', // 请输入邮箱
      'password_required': 'Bitte Passwort eingeben', // 请输入密码
      'login_success_empty_user':
          'Anmeldung erfolgreich, aber Benutzerdaten fehlen', // 登录成功，但用户信息为空
      'login_success': 'Anmeldung erfolgreich', // 登录成功
      'login_failed': 'Anmeldung fehlgeschlagen', // 登录失败
      'error': 'Fehler', // 错误
      'network_error':
          'Netzwerkverbindung fehlgeschlagen, bitte Netzwerk oder Server prüfen',
      'unknown_error': 'Unbekannter Fehler',
      'login_request_failed': 'Anmeldeanfrage fehlgeschlagen: ', // 登录请求失败：
      'new_password_hint': 'Neues Passwort eingeben', // 输入新密码
      'confirm_new_password_hint': 'Neues Passwort bestätigen', // 确认新密码
      'resetting_password': 'Wird zurückgesetzt...', // 重置中...
      'confirm_reset': 'Zurücksetzen bestätigen', // 确认重置
      'code_sent_backend_email': 'Bestätigungscode gesendet an: ', // 验证码已发送至：
      'verify_code_required': 'Bitte Bestätigungscode eingeben', // 请输入验证码
      'new_password_required': 'Bitte neues Passwort eingeben', // 请输入新密码
      'confirm_new_password_required':
          'Bitte neues Passwort bestätigen', // 请再次输入新密码
      'passwords_not_match':
          'Die Passwörter stimmen nicht überein', // 两次输入的密码不一致
      'password_reset_success': 'Passwort erfolgreich zurückgesetzt', // 密码重置成功
      'password_reset_failed':
          'Passwort konnte nicht zurückgesetzt werden', // 密码重置失败
      // 用户选择页面
      'choose_therapy_user': 'Benutzer auswählen', // 选择体验用户
      'search_user_hint': 'Name oder Telefonnummer eingeben', // 输入用户姓名或手机号
      'add_user': 'Benutzer hinzufügen', // 添加用户
      'user_name_label': 'Name',
      'user_age_label': 'Alter',
      'user_phone_label': 'Telefon',
      'user_email_label': 'E-Mail',
      'user_email_hint': 'E-Mail-Adresse eingeben',
      'user_gender_label': 'Geschlecht',
      'user_male': 'Männlich',
      'user_female': 'Weiblich',
      'user_remark_label': 'Notiz',
      'user_remark_hint': 'Notiz eingeben',
      'user_required_fields': 'Bitte Name, Alter und Telefon eingeben',
      'user_invalid_age': 'Bitte gültiges Alter eingeben',
      'add_user_failed': 'Benutzer konnte nicht hinzugefügt werden',
      'confirm_selection': 'Auswahl bestätigen', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Auswahl bestätigen', // 确认选择
      'music_resource_missing':
          'Für diese Musik ist kein Audio verfügbar', // 当前音乐暂无音频资源
      // 启动页面
      'red_light': 'Rotlicht', // 红光
      'wavelength': 'Wellenlänge', // 波长
      'hydrogen_molecule': 'H₂', // 分子氢
      'hydrogen_concentration': 'H₂-Konz.', // 氢气浓度
      'flow': 'Durchfluss', // 流量
      'chakra': 'Chakra', // 脉轮
      'terahertz': 'Terahertz', // 太赫兹
      'fragrance': 'Aroma', // 香氛
      'therapy_completed': 'Wellness abgeschlossen', // 健康体验完成
      'user': 'Benutzer', // 使用者
      'session_duration': 'Sitzungsdauer', // 本次使用
      'module_duration': 'Moduldauer', // 模块时长
      'no_module_record': 'Keine Modulaufzeichnungen', // 暂无模块运行记录
      'not_running': 'Nicht ausgeführt', // 未运行
      'running_label': 'Läuft', // 运行
      'default_mode_title': 'Tiefenentspannung', // 深度放松
      'no_user_selected': 'Kein Benutzer ausgewählt', // 未选择用户
      'error_send_params_failed':
          'Parameterübertragung fehlgeschlagen: ', // 参数下发失败：
      'error_pause_failed': 'Pause fehlgeschlagen: ', // 暂停失败：
      'error_resume_failed': 'Fortsetzen fehlgeschlagen: ', // 继续失败：
      'error_stop_failed': 'Stopp fehlgeschlagen: ', // 停止失败：
      // 自定义列表页面
      'custom_plan_title': 'Eigener Plan', // 自定义方案
      'plan_search_hint': 'Plannamen eingeben', // 输入方案名称
      'add_plan': 'Plan hinzufügen', // 添加方案
      'rename_plan': 'Benennung', // 重命名
      'plan_name_empty': 'Planname darf nicht leer sein', // 方案名称不能为空
      'custom_plan_load_failed':
          'Benutzerdefinierte Pläne konnten nicht geladen werden: ', // 自定义方案加载失败：
      'user_not_logged_in_retry':
          'Benutzer nicht angemeldet, bitte erneut anmelden', // 用户未登录，请重新登录
      // 自定义编辑页面
      'red_ther': 'Rotlicht', // 红光
      'add_therapy_module': 'Modul hinzufügen', // 添加模块
      'expand_feature': 'Erweitern', // 拓展功能
      'save_params': 'Speichern', // 保存参数
      'save_plan': 'Plan speichern', // 保存方案
      'plan_saving': 'Wird gespeichert, bitte warten',
      'plan_save_slow':
          'Das Speichern dauert länger als erwartet, bitte warten',
      'plan_save_retry': 'Speichern fehlgeschlagen, bitte erneut versuchen',
      'custom_plan_edit_invalid':
          'Der aktuelle Plan ist ungültig. Bitte zurückgehen und erneut versuchen',
      'complete_previous_node':
          'Bitte zuerst den vorherigen 5-Minuten-Knoten abschließen', // 请先完成上一个 5 分钟节点
      'node_saved_prefix': 'Parameter des Knotens ', // 第
      'node_saved_suffix': ' Min. gespeichert', // 分钟节点参数已保存
      'plan_naming': 'Planname', // 方案命名
      'plan_name_duplicate': 'Planname darf nicht doppelt sein', // 方案名称不能重复
      'mode_select': 'Modus', // 模式选择
      'module_hydrogen': 'H₂', // 分子氢
      'module_expand': 'Erweitern', // 拓展功能
      'redlight_strength_required':
          'Rotlicht 660nm und 850nm dürfen nicht beide 0 sein', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required':
          'PEMF-Frequenz und Intensität dürfen nicht 0 sein', // PEMF频率和强度都不能为0
      'vat_params_required':
          'VAT-Frequenz und Intensität dürfen nicht 0 sein', // VAT频率和强度都不能为0
      'hydrogen_concentration_required':
          'H₂-Konzentration darf nicht 0 sein', // 分子氢浓度不能为0
      'expand_params_required':
          'Bitte mindestens eine Erweiterungsfunktion auswählen',
      'node_copied_prefix': 'Kopiert zum ', // 已复制到
      'node_copied_suffix': '-Min.-Knoten', // 分钟节点
      // 拓展页面
      'fragrance_setting': 'Aroma-Einstellungen', // 香氛设置
      'terahertz_setting': 'Terahertz-Einstellungen', // 太赫兹设置
      'chakra_setting': 'Chakra-Einstellungen', // 脉轮设置
      'hifem_setting': 'HIFEM-Einstellungen', // HIFEM设置
      'rotation': 'Rotation', // 轮转
      'independent': 'Unabhängig', // 独立
      'gentle': 'Sanft', // 轻柔
      'intense': 'Intensiv', // 浓烈
      'sleep': 'Schlaf', // 睡眠
      'flow_state': 'Flow', // 心流
      'meditation': 'Meditation', // 冥想
      'sine_wave': 'Sinus', // 正弦波
      'square_wave': 'Rechteck', // 方波
      'triangle_wave': 'Drei.', // 三角波
      'rf': 'RF', // 射频
      'crown_chakra': 'Kronenchakra', // 顶轮
      'crown_sub': '(Zirbeldrüse)', // 松果体
      'third_eye_chakra': 'Drittes-Auge-Chakra', // 眉心轮
      'third_eye_sub': '(Hypophyse)', // 脑垂体
      'throat_chakra': 'Halschakra', // 喉轮
      'throat_sub': '(Schilddrüse)', // 甲状腺
      'heart_chakra': 'Herzchakra', // 心轮
      'heart_sub': '(Thymus)', // 胸腺
      'solar_plexus_chakra': 'Solarplexus-Chakra', // 太阳神轮
      'solar_plexus_sub': '(Niere)', // 肾
      'sacral_chakra': 'Sakralchakra', // 脐轮
      'sacral_sub': '(Leber, Niere, Milz)', // 肝、肾、脾
      'root_chakra': 'Wurzelchakra', // 海底轮
      'root_sub': '(Gonaden)', // 生殖腺
    },
    ////////////////////////////////////////////////////////////////土耳其语言///////////////////////////////
    'tr_TR': {
      'prompt_volume': 'Uyarı sesi düzeyi',
      'prompt_volume_hint':
          'Karşılama, başlangıç, bitiş ve su uyarılarını ayarlayın. %0 sesi kapatır. Kaydırıcıyı bıraktığınızda kaydedilir.',
      'prompt_volume_update_failed':
          'Ses düzeyi ayarlanamadı. Lütfen tekrar deneyin.',
      'prompt_volume_save_failed':
          'Ses düzeyi kaydedilemedi. Kaydırıcıyı yeniden ayarlayın.',
      // 通用
      'settings': 'Ayarlar', // 设置
      'administrator': 'Yönetici', // 管理员
      'back': 'Geri', // 返回
      'confirm': 'Onayla', // 确认
      'cancel': 'İptal', // 取消
      'save': 'Kaydet', // 保存
      'delete': 'Sil', // 删除
      'select': 'Seç', // 选择
      'name': 'Ad girin', // 输入姓名
      'age': 'Yaş girin', // 输入年龄
      'phone': 'Telefon girin', // 输入手机号
      'gender': 'Cinsiyet', // 性别
      'male': 'E', // 男
      'female': 'K', // 女
      'frequency': 'Frekans', // 频率
      'intensity': 'Yoğunluk', // 强度
      'mode': 'Mod', // 模式
      'waveform': 'Dalga', // 波形
      'select_waveform': 'Dalga biçimi seç', // 选择波形
      'continuous': 'Sürekli', // 连续
      'pulse': 'Darbeli', // 脉冲
      'power': 'Güç', // 功率
      'chakra_power': 'Güç', // 强度
      'running': 'Çalışıyor', // 正在运行
      'waiting': 'Bekliyor', // 等待运行
      'logout': 'Çıkış yap', // 退出登录
      'parameter_settings': 'Parametre Ayarları', // 参数设置
      // Wi-Fi ve Bluetooth bağlantı uyarısı
      'connection_prompt_title': 'Bağlı değil',
      'connection_prompt_subtitle': 'Bağlanıp devam edin',
      'connection_prompt_wifi': 'WIFI',
      'connection_prompt_ble': 'BLE',
      'connection_status_checking': 'Kontrol ediliyor',
      'connection_status_connected': 'Bağlı',
      'connection_status_disconnected': 'Bağlı değil',
      'connection_prompt_skip': 'Atla',
      'wifi_ble': 'WIFI & BLE',
      'wifi_name_unavailable': 'Ağ adı alınamıyor',
      'wifi_no_connected_network': 'Bağlı ağ yok',
      'ble_no_connected_device': 'Bağlı cihaz yok',
      // 设置页面
      'setting_menu': 'Ayarlar Menüsü', // 设置菜单
      'language_setting': 'Dil', // 语言设置
      'language_switch': 'Dil Değiştir', // 语言切换
      'save_changes': 'Kaydet', // 保存更改
      'date_time': 'Tarih ve Saat', // 日期和时间
      'year_unit': 'Y', // 年
      'month_unit': 'A', // 月
      'day_unit': 'G', // 日
      'hour_unit': 'sa', // 时
      'am_label': 'ÖÖ', // 上午
      'pm_label': 'ÖS', // 下午
      'date_time_saved': 'Tarih ve saat kaydedildi', // 日期和时间已保存
      'device_info': 'Cihaz Bilgisi', // 设备信息
      'debug_mode': 'Hata Ayıklama', // 调试模式
      'history_record': 'Geçmiş', // 历史记录
      'history_detail_missing': 'Geçmiş kaydı bulunamadı', // 历史记录不存在
      'current_account_not_logged_in':
          'Geçerli hesap giriş yapmamış', // 当前账号未登录
      'therapy_record_load_failed':
          'İyi yaşam kayıtları yüklenemedi', // 健康体验记录加载失败
      'no_history_records': 'Geçmiş kaydı yok', // 暂无历史记录
      'no_therapy_records': 'İyi yaşam kaydı yok', // 暂无健康体验记录
      'years_old_unit': 'y', // 岁
      'therapy_report': 'İyi Yaşam Raporu', // 健康体验报告
      'total_therapy_duration': 'İyi Yaşam Süresi', // 健康时长
      'feedback_label': 'İyi yaşam notları: ', // 体验感受：
      'no_feedback': 'İyi yaşam notu yok', // 暂无体验感受
      'treatment_modules': 'İyi Yaşam Modülleri', // 健康模块
      'energy_score': 'Enerji', // 能量指数
      'cell_score': 'Canlılık End.', // 活力指数
      'relaxation_score': 'Rahatlama', // 放松指数
      'immune_score': 'İyi Yaşam End.', // 健康指数
      'compared_to_last': 'son vs', // 较上次
      'session_once_1': '1.', // 1次
      'session_once_2': '2.', // 2次
      'session_once_3': '3.', // 3次
      'current_session': 'Güncel', // 本次
      'health_effect_assessment': 'İyi Yaşam Özeti', // 健康体验概览
      'status_good': 'İyi', // 良好
      'overall_score': 'Genel Puan', // 综合得分
      'level_low': 'Düşük', // 低
      'level_medium': 'Orta', // 中
      'level_high': 'Yüksek', // 高
      'therapy_feedback_hint': 'İyi yaşam notu girin', // 请输入健康体验感受
      'score_unit': 'puan', // 分
      'minutes_unit': 'dk', // 分
      'seconds_unit': 'sn', // 秒
      'user_management': 'Kullanıcılar', // 用户管理
      'unsupported_language': 'Bu dil henüz desteklenmiyor', // 该语言暂未支持
      // 主页
      'preset_mode': 'Hazır İyi Yaşam Modları', // 预设健康模式
      'preset_mode_subtitle': '10 günlük iyi yaşam programı', // 10种日常健康方案
      'device_ready': 'Cihaz Hazır', // 设备就绪
      'custom_plan': 'Özel Plan', // 自定义方案
      'deep_relax': 'DERİN RAHATLAMA', // 深度放松
      'energy_boost': 'YENİ ENERJİ', // 焕新充能
      'pain_relief': 'HAFİF KONFOR', // 柔和舒适
      'sleep_enhancement': 'GECE RAHATLA', // 夜间放松
      'sports_recovery': 'SOĞUMA', // 活动后放松
      'stress_release': 'SAKİN & RAHAT', // 舒缓放松
      'immune_boost': 'GÜNLÜK ENERJİ', // 日常活力
      'anti_aging': 'PARLAK CANLILIK', // 焕彩活力
      'full_care': 'VÜCUT YENİLE', // 全身焕新
      'mental_healing': 'İYİ RUH HALİ', // 心情平衡
      'device_fault': 'Cihaz Arızası', // 设备故障
      'water_level_warning_title': 'Su seviyesi düşük',
      'water_level_warning_message':
          'Su tankı seviyesi düşük. Devam etmeden önce lütfen su ekleyin.',
      'water_level_shortage_title': 'Su Eksik',
      'water_level_shortage_message':
          'Su yetersiz. Otomatik dolum için su kaynağını bağlayın.',
      'water_level_shortage_unavailable':
          'Moleküler hidrojen işlevi geçici olarak kullanılamıyor',
      'water_level_filling_title': 'Su Dolduruluyor',
      'water_level_filling_message': 'Su dolduruluyor, lütfen bekleyin...',
      'water_level_complete_title': 'Su Dolumu Tamamlandı',
      'water_level_complete_message':
          'Su dolumu tamamlandı. Cihazı kullanmaya devam edebilirsiniz.',
      'water_level_ready_button': 'Hazır mısınız?',
      'water_level_start_filling_button': 'Doldurmayı Başlat',
      // 登录页面
      'login_email_hint': 'E-posta adresini girin', // 输入邮箱
      'login_password_hint': 'Şifreyi girin', // 输入密码
      'forgot_password': 'Şifrenizi mi unuttunuz?', // 忘记密码?
      'login': 'Giriş Yap', // 登录
      'register': 'Kayıt Ol', // 注册
      'agree_prefix': 'Kabul ediyorum: ', // 我已阅读并同意
      'user_agreement': 'Kullanım Şartları', // 《用户协议》
      'and': ' ve ', // 和
      'privacy_policy': 'Gizlilik Politikası', // 《隐私政策》
      // Kayıt sayfası
      'Admin': 'Yönetici', // 管理员
      'Operator': 'Operatör', // 操作员
      'User': 'Bireysel', // 个人
      'verify_code': 'Doğrulama kodunu girin', // 输入验证码
      'send_code': 'Gönderiliyor...', // 发送中...
      'get_code': 'Kod al', // 获取验证码
      'registering': 'Kayıt yapılıyor...', // 注册中...
      'already_have_account': 'Zaten hesabınız var mı?', // 已有账号?
      'login_now': 'Şimdi giriş yap', // 立即登录
      'prompt': 'Bilgi', // 提示
      'email_empty': 'Lütfen önce e-posta adresini girin', // 请先输入邮箱
      'email_invalid': 'Lütfen geçerli bir e-posta adresi girin', // 请输入正确的邮箱
      'code_send_failed': 'Doğrulama kodu gönderilemedi', // 验证码发送失败
      'register_success': 'Kayıt başarılı', // 注册成功
      'register_failed': 'Kayıt başarısız', // 注册失败
      'email_required': 'Lütfen e-posta adresini girin', // 请输入邮箱
      'password_required': 'Lütfen şifreyi girin', // 请输入密码
      'login_success_empty_user':
          'Giriş başarılı ancak kullanıcı bilgileri boş', // 登录成功，但用户信息为空
      'login_success': 'Giriş başarılı', // 登录成功
      'login_failed': 'Giriş başarısız', // 登录失败
      'error': 'Hata', // 错误
      'network_error':
          'Ağ bağlantısı başarısız, lütfen ağı veya sunucuyu kontrol edin',
      'unknown_error': 'Bilinmeyen hata',
      'login_request_failed': 'Giriş isteği başarısız: ', // 登录请求失败：
      'new_password_hint': 'Yeni şifreyi girin', // 输入新密码
      'confirm_new_password_hint': 'Yeni şifreyi doğrulayın', // 确认新密码
      'resetting_password': 'Sıfırlanıyor...', // 重置中...
      'confirm_reset': 'Sıfırlamayı onayla', // 确认重置
      'code_sent_backend_email': 'Doğrulama kodu gönderildi: ', // 验证码已发送至：
      'verify_code_required': 'Lütfen doğrulama kodunu girin', // 请输入验证码
      'new_password_required': 'Lütfen yeni bir şifre girin', // 请输入新密码
      'confirm_new_password_required':
          'Lütfen yeni şifreyi doğrulayın', // 请再次输入新密码
      'passwords_not_match': 'Şifreler eşleşmiyor', // 两次输入的密码不一致
      'password_reset_success': 'Şifre başarıyla sıfırlandı', // 密码重置成功
      'password_reset_failed': 'Şifre sıfırlanamadı', // 密码重置失败
      // 用户选择页面
      'choose_therapy_user': 'Kullanıcı Seç', // 选择体验用户
      'search_user_hint': 'Ad veya telefon girin', // 输入用户姓名或手机号
      'add_user': 'Kullanıcı Ekle', // 添加用户
      'user_name_label': 'Ad',
      'user_age_label': 'Yaş',
      'user_phone_label': 'Telefon',
      'user_email_label': 'E-posta',
      'user_email_hint': 'E-posta adresini girin',
      'user_gender_label': 'Cinsiyet',
      'user_male': 'Erkek',
      'user_female': 'Kadın',
      'user_remark_label': 'Not',
      'user_remark_hint': 'Not girin',
      'user_required_fields': 'Lütfen ad, yaş ve telefon girin',
      'user_invalid_age': 'Lütfen geçerli bir yaş girin',
      'add_user_failed': 'Kullanıcı eklenemedi',
      'confirm_selection': 'Seçimi Onayla', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Seçimi Onayla', // 确认选择
      'music_resource_missing': 'Bu müzik için ses kaynağı yok', // 当前音乐暂无音频资源
      // 启动页面
      'red_light': 'Kırmızı Işık', // 红光
      'wavelength': 'Dalga Boyu', // 波长
      'hydrogen_molecule': 'H₂', // 分子氢
      'hydrogen_concentration': 'H₂ Kons.', // 氢气浓度
      'flow': 'Akış', // 流量
      'chakra': 'Çakra', // 脉轮
      'terahertz': 'Terahertz', // 太赫兹
      'fragrance': 'Aroma', // 香氛
      'therapy_completed': 'İyi Yaşam Tamamlandı', // 健康体验完成
      'user': 'Kullanıcı', // 使用者
      'session_duration': 'Seans Süresi', // 本次使用
      'module_duration': 'Modül Süresi', // 模块时长
      'no_module_record': 'Modül çalışma kaydı yok', // 暂无模块运行记录
      'not_running': 'Çalışmadı', // 未运行
      'running_label': 'Çalışıyor', // 运行
      'default_mode_title': 'Derin Rahatlama', // 深度放松
      'no_user_selected': 'Kullanıcı seçilmedi', // 未选择用户
      'error_send_params_failed': 'Parametre gönderilemedi: ', // 参数下发失败：
      'error_pause_failed': 'Duraklatma başarısız: ', // 暂停失败：
      'error_resume_failed': 'Devam ettirme başarısız: ', // 继续失败：
      'error_stop_failed': 'Durdurma başarısız: ', // 停止失败：
      // 自定义列表页面
      'custom_plan_title': 'Özel Planlar', // 自定义方案
      'plan_search_hint': 'Plan adını girin', // 输入方案名称
      'add_plan': 'Plan Ekle', // 添加方案
      'rename_plan': 'Adlandırma', // 重命名
      'plan_name_empty': 'Plan adı boş olamaz', // 方案名称不能为空
      'custom_plan_load_failed': 'Özel planlar yüklenemedi: ', // 自定义方案加载失败：
      'user_not_logged_in_retry':
          'Kullanıcı giriş yapmamış, lütfen tekrar giriş yapın', // 用户未登录，请重新登录
      // 自定义编辑页面
      'red_ther': 'Kırmızı Işık', // 红光
      'add_therapy_module': 'Modül Ekle', // 添加模块
      'expand_feature': 'Доп. функции', // 拓展功能
      'save_params': 'Kaydet', // 保存参数
      'save_plan': 'Planı Kaydet', // 保存方案
      'plan_saving': 'Kaydediliyor, lütfen bekleyin',
      'plan_save_slow': 'Kaydetme yanıtı gecikiyor, lütfen bekleyin',
      'plan_save_retry': 'Kaydetme başarısız oldu, lütfen tekrar deneyin',
      'custom_plan_edit_invalid':
          'Geçerli plan bilgileri hatalı. Geri dönüp tekrar deneyin',
      'complete_previous_node':
          'Lütfen önce önceki 5 dakikalık düğümü tamamlayın', // 请先完成上一个 5 分钟节点
      'node_saved_prefix': 'Düğüm ', // 第
      'node_saved_suffix': ' dk parametreleri kaydedildi', // 分钟节点参数已保存
      'plan_naming': 'Plan Adı', // 方案命名
      'plan_name_duplicate': 'Plan adı tekrar edemez', // 方案名称不能重复
      'mode_select': 'Mod Seçimi', // 模式选择
      'module_hydrogen': 'H₂', // 分子氢
      'module_expand': 'Genişlet', // 拓展功能
      'redlight_strength_required':
          'Kırmızı ışık 660nm ve 850nm yoğunluğu aynı anda 0 olamaz', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required':
          'PEMF frekansı ve yoğunluğu 0 olamaz', // PEMF频率和强度都不能为0
      'vat_params_required':
          'VAT frekansı ve yoğunluğu 0 olamaz', // VAT频率和强度都不能为0
      'hydrogen_concentration_required':
          'H₂ konsantrasyonu 0 olamaz', // 分子氢浓度不能为0
      'expand_params_required': 'En az bir genişletme işlevi seçin',
      'node_copied_prefix': '', // 已复制到
      'node_copied_suffix': ' dk düğümüne kopyalandı', // 分钟节点
      // 拓展页面
      'fragrance_setting': 'Aroma Ayarları', // 香氛设置
      'terahertz_setting': 'Terahertz Ayarları', // 太赫兹设置
      'chakra_setting': 'Çakra Ayarları', // 脉轮设置
      'hifem_setting': 'HIFEM Ayarları', // HIFEM设置
      'rotation': 'Döngü', // 轮转
      'independent': 'Bağımsız', // 独立
      'gentle': 'Hafif', // 轻柔
      'intense': 'Yoğun', // 浓烈
      'sleep': 'Uyku', // 睡眠
      'flow_state': 'Akış', // 心流
      'meditation': 'Tefekkür', // 冥想
      'sine_wave': 'Sinüs', // 正弦波
      'square_wave': 'Kare', // 方波
      'triangle_wave': 'Üçgen', // 三角波
      'rf': 'RF', // 射频
      'crown_chakra': 'Taç Çakra', // 顶轮
      'crown_sub': '(epifiz bezi)', // 松果体
      'third_eye_chakra': 'Üçüncü Göz Çakrası', // 眉心轮
      'third_eye_sub': '(hipofiz bezi)', // 脑垂体
      'throat_chakra': 'Boğaz Çakrası', // 喉轮
      'throat_sub': '(tiroid)', // 甲状腺
      'heart_chakra': 'Kalp Çakrası', // 心轮
      'heart_sub': '(timus)', // 胸腺
      'solar_plexus_chakra': 'Solar Pleksus Çakrası', // 太阳神轮
      'solar_plexus_sub': '(böbrek)', // 肾
      'sacral_chakra': 'Sakral Çakra', // 脐轮
      'sacral_sub': '(karaciğer, böbrek, dalak)', // 肝、肾、脾
      'root_chakra': 'Kök Çakra', // 海底轮
      'root_sub': '(gonadlar)', // 生殖腺
    },
  });
}
