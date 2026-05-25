import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    ///////////////////////////////////////////////////////////中文语言////////////////////////////////////////////////
    'zh_CN': {
      // 通用
      'settings': '设置',
      'administrator': '管理员',
      'back': '返回',
      'confirm': '确认',
      'cancel': '取消',
      'save': '保存',
      'delete': '删除',
      'select': '选择',
      'name': '姓名',
      'age': '年龄',
      'phone': '手机号',
      'gender': '性别',
      'male': '男',
      'female': '女',
      'frequency': '频率',
      'intensity': '强度',
      'mode': '模式',
      'waveform': '波形',
      'continuous': '连续',
      'pulse': '脉冲',
      'power': '功率',
      'running': '正在运行',
      'waiting': '等待运行',

      // 设置页面
      'setting_menu': '设置菜单',
      'language_setting': '语言设置',
      'language_switch': '语言切换',
      'save_changes': '保存更改',
      'date_time': '日期和时间',
      'device_info': '设备信息',
      'debug_mode': '调试模式',
      'history_record': '历史记录',
      'user_management': '用户管理',
      'unsupported_language': '该语言暂未支持',

      // 主页面
      'preset_mode': '预设理疗模式',
      'preset_mode_subtitle': '10种专业配方方案',
      'device_ready': '设备就绪',
      'custom_plan': '自定义方案',
      'deep_relax': '深度放松',
      'energy_boost': '能量提升',
      'pain_relief': '疼痛缓解',
      'sleep_enhancement': '睡眠改善',
      'sports_recovery': '运动恢复',
      'stress_release': '压力释放',
      'immune_boost': '免疫增强',
      'anti_aging': '抗衰老',
      'full_care': '全面养护',
      'mental_healing': '情绪疗愈',
      'device_fault': '设备故障',

      // 登录页面
      'login_phone_hint': '输入手机号',
      'login_password_hint': '输入密码',
      'forgot_password': '忘记密码?',
      'login': '登录',
      'register': '注册',
      'agree_prefix': '我已阅读并同意 ',
      'user_agreement': '《用户协议》',
      'and': ' 和 ',
      'privacy_policy': '《隐私政策》',

      // 用户选择页面
      'choose_therapy_user': '选择理疗用户',
      'search_user_hint': '输入用户姓名或手机号',
      'confirm_selection': '确认选择',

      // 音乐页面
      'confirm_music_selection': '确认选择',

      // 启动页面
      'red_light': '红光',
      'wavelength': '波长',
      'hydrogen_molecule': '分子氢',
      'hydrogen_concentration': '氢气浓度',
      'flow': '流量',
      'chakra': '脉轮',
      'terahertz': '太赫兹',
      'fragrance': '香氛',
      'therapy_completed': '治疗完成',
      'user': '使用者',
      'session_duration': '本次使用',
      'module_duration': '模块时长',
      'no_module_record': '暂无模块运行记录',
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

      // 自定义编辑页面
      'red_ther': '红光',
      'add_therapy_module': '添加治疗模块',
      'expand_feature': '拓展功能',
      'save_params': '保存参数',
      'save_plan': '保存方案',
      'complete_previous_node': '请先完成上一个 5 分钟节点',
      'node_saved_prefix': '第 ',
      'node_saved_suffix': ' 分钟节点参数已保存',
      'plan_naming': '方案命名',
      'plan_name_duplicate': '方案名称不能重复',
      'mode_select': '模式选择',
      'module_hydrogen': '分子氢',
      'module_expand': '拓展功能',

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

    //////////////////////////////////////////////////////英语语言/////////////////////////////////////////////////////////////////////
    'en_US': {
      // 通用
      'settings': 'Setting', // 设置
      'administrator': 'Admin', // 管理员
      'back': 'Back', // 返回
      'confirm': 'Confirm', // 确认
      'cancel': 'Cancel', // 取消
      'save': 'Save', // 保存
      'delete': 'Delete', // 删除
      'select': 'Select', // 选择
      'name': 'Name', // 姓名
      'age': 'Age', // 年龄
      'phone': 'Phone', // 手机号
      'gender': 'Gender', // 性别
      'male': 'M', // 男
      'female': 'F', // 女
      'frequency': 'Frequency', // 频率
      'intensity': 'Intensity', // 强度
      'mode': 'Mode', // 模式
      'waveform': 'Wave', // 波形
      'continuous': 'Conti. ', // 连续
      'pulse': 'Pulse', // 脉冲
      'power': 'Power', // 功率
      'running': 'Running', // 正在运行
      'waiting': 'Waiting', // 等待运行
      // 设置页面
      'setting_menu': 'Settings', // 设置菜单
      'language_setting': 'Language', // 语言设置
      'language_switch': 'Language Switch', // 语言切换
      'save_changes': 'Save', // 保存更改
      'date_time': 'Date&Time', // 日期和时间
      'device_info': 'Device Info', // 设备信息
      'debug_mode': 'Debug', // 调试模式
      'history_record': 'History', // 历史记录
      'user_management': 'Users', // 用户管理
      'unsupported_language': 'This language is not supported yet', // 该语言暂未支持
      // 主页面
      'preset_mode': 'Preset Therapy Modes', // 预设理疗模式
      'preset_mode_subtitle': '10 professional therapy programs', // 10种专业配方方案
      'device_ready': 'Device Ready', // 设备就绪
      'custom_plan': 'Custom Plan', // 自定义方案
      'deep_relax': 'Deep Relaxation', // 深度放松
      'energy_boost': 'Energy Boost', // 能量提升
      'pain_relief': 'Pain Relief', // 疼痛缓解
      'sleep_enhancement': 'Sleep Imp.', // 睡眠增强
      'sports_recovery': 'Sports Rec.', // 运动恢复
      'stress_release': 'Stress Relief', // 压力缓解
      'immune_boost': 'Immune Boost', // 免疫增强
      'anti_aging': 'Anti-Aging', // 抗衰老
      'full_care': 'Total Care', // 全面养护
      'mental_healing': 'Emo. Healing', // 情绪疗愈
      'device_fault': 'Device Fault', // 设备故障
      // 登录页面
      'login_phone_hint': 'Enter phone number', // 输入手机号
      'login_password_hint': 'Enter password', // 输入密码
      'forgot_password': 'Forgot password?', // 忘记密码?
      'login': 'Login', // 登录
      'register': 'Register', // 注册
      'agree_prefix': 'I have read and agree to ', // 我已阅读并同意
      'user_agreement': 'User Agreement', // 《用户协议》
      'and': ' and ', // 和
      'privacy_policy': 'Privacy Policy', // 《隐私政策》
      // 用户选择页面
      'choose_therapy_user': 'Select Therapy User', // 选择理疗用户
      'search_user_hint': 'Enter user name or phone number', // 输入用户姓名或手机号
      'confirm_selection': 'Confirm Selection', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Confirm Selection', // 确认选择
      // 启动页面
      'red_light': 'RED THERAPY', // 红光
      'wavelength': 'Wavelength', // 波长
      'hydrogen_molecule': 'H₂', // 分子氢
      'hydrogen_concentration': 'H₂ Conc.', // 氢气浓度
      'flow': 'Flow', // 流量
      'chakra': 'Chakra', // 脉轮
      'terahertz': 'Terahertz', // 太赫兹
      'fragrance': 'Aroma', // 香氛
      'therapy_completed': 'Therapy Completed', // 治疗完成
      'user': 'User', // 使用者
      'session_duration': 'Session Duration', // 本次使用
      'module_duration': 'Module Duration', // 模块时长
      'no_module_record': 'No module running records', // 暂无模块运行记录
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
      // 自定义编辑页面
      'red_ther': 'RED THER.', // 红光
      'add_therapy_module': 'Add Protocal', // 添加治疗模块
      'expand_feature': 'Expand Feature', // 拓展功能
      'save_params': 'Save', // 保存参数
      'save_plan': 'Save Plan', // 保存方案
      'complete_previous_node':
          'Please complete the previous 5-minute node first', // 请先完成上一个 5 分钟节点
      'node_saved_prefix': 'Minute ', // 第
      'node_saved_suffix': ' node parameters saved', // 分钟节点参数已保存
      'plan_naming': 'Plan Naming', // 方案命名
      'plan_name_duplicate': 'Plan name cannot be duplicated', // 方案名称不能重复
      'mode_select': 'Modes', // 模式选择
      'module_hydrogen': 'H₂', // 分子氢
      'module_expand': 'Expand', // 拓展功能
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
      // 通用
      'settings': 'Ajustes', // 设置
      'administrator': 'Admin', // 管理员
      'back': 'Atrás', // 返回
      'confirm': 'Confirmar', // 确认
      'cancel': 'Cancelar', // 取消
      'save': 'Guardar', // 保存
      'delete': 'Eliminar', // 删除
      'select': 'Elegir', // 选择
      'name': 'Nombre', // 姓名
      'age': 'Edad', // 年龄
      'phone': 'Teléfono', // 手机号
      'gender': 'Género', // 性别
      'male': 'M', // 男
      'female': 'F', // 女
      'frequency': 'Frecuencia', // 频率
      'intensity': 'Intensidad', // 强度
      'mode': 'Modo', // 模式
      'waveform': 'Onda', // 波形
      'continuous': 'Cont.', // 连续
      'pulse': 'Pulso', // 脉冲
      'power': 'Potencia', // 功率
      'running': 'Activo', // 正在运行
      'waiting': 'Espera', // 等待运行
      // 设置页面
      'setting_menu': 'Ajustes', // 设置菜单
      'language_setting': 'Idioma', // 语言设置
      'language_switch': 'Cambio de idioma', // 语言切换
      'save_changes': 'Guardar', // 保存更改
      'date_time': 'Fecha', // 日期和时间
      'device_info': 'Información', // 设备信息
      'debug_mode': 'Depuración', // 调试模式
      'history_record': 'Historial', // 历史记录
      'user_management': 'Usuarios', // 用户管理
      // 主页
      'preset_mode': 'Modos preestablecidos', // 预设理疗模式
      'preset_mode_subtitle': '10 programas pro', // 10种专业配方方案
      'device_ready': 'Dispositivo listo', // 设备就绪
      'custom_plan': 'Plan propio', // 自定义方案
      'deep_relax': 'Relajación', // 深度放松
      'energy_boost': 'Energía', // 能量提升
      'pain_relief': 'Alivio del dolor', // 疼痛缓解
      'sleep_enhancement': 'Mejora del sueño', // 睡眠改善
      'sports_recovery': 'Recuperación', // 运动恢复
      'stress_release': 'Estrés', // 压力释放
      'immune_boost': 'Inmunidad', // 免疫增强
      'anti_aging': 'Antiedad', // 抗衰老
      'full_care': 'Cuidado total', // 全面养护
      'mental_healing': 'Emoción', // 情绪疗愈
      'device_fault': 'Fallo de dispositivo', // 设备故障
      // 登录页面
      'login_phone_hint': 'Ingrese número de teléfono', // 输入手机号
      'login_password_hint': 'Ingrese contraseña', // 输入密码
      'forgot_password': '¿Olvidaste la contraseña?', // 忘记密码?
      'login': 'Iniciar sesión', // 登录
      'register': 'Registrarse', // 注册
      'agree_prefix': 'He leído y acepto ', // 我已阅读并同意
      'user_agreement': 'Acuerdo de usuario', // 《用户协议》
      'and': ' y ', // 和
      'privacy_policy': 'Política de privacidad', // 《隐私政策》
      // 用户选择页面
      'choose_therapy_user': 'Elegir usuario', // 选择理疗用户
      'search_user_hint': 'Nombre o teléfono', // 输入用户姓名或手机号
      'confirm_selection': 'Confirmar selección', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Confirmar selección', // 确认选择
      // 启动页面
      'red_light': 'TERAPIA ROJA', // 红光
      'wavelength': 'Long. onda', // 波长
      'hydrogen_molecule': 'H₂', // 分子氢
      'hydrogen_concentration': 'Conc. H₂', // 氢气浓度
      'flow': 'Flujo', // 流量
      'chakra': 'Chakra', // 脉轮
      'terahertz': 'THz', // 太赫兹
      'fragrance': 'Aroma', // 香氛
      'therapy_completed': 'Terapia completada', // 治疗完成
      'user': 'Usuario', // 使用者
      'session_duration': 'Duración de sesión', // 本次使用
      'module_duration': 'Tiempo módulo', // 模块时长
      'no_module_record': 'Sin registros de ejecución', // 暂无模块运行记录
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
      // 自定义编辑页面
      'red_ther': 'LUZ ROJA', // 红光
      'add_therapy_module': 'Agregar módulo', // 添加治疗模块
      'expand_feature': 'Funciones extra', // 拓展功能
      'save_params': 'Guardar', // 保存参数
      'save_plan': 'Guardar plan', // 保存方案
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
      // 通用
      'settings': 'Ajustes', // 设置
      'administrator': 'Admin', // 管理员
      'back': 'Voltar', // 返回
      'confirm': 'Confirmar', // 确认
      'cancel': 'Cancelar', // 取消
      'save': 'Guardar', // 保存
      'delete': 'Eliminar', // 删除
      'select': 'Usar', // 选择
      'name': 'Nome', // 姓名
      'age': 'Idade', // 年龄
      'phone': 'Telefone', // 手机号
      'gender': 'Género', // 性别
      'male': 'M', // 男
      'female': 'F', // 女
      'frequency': 'Frequência', // 频率
      'intensity': 'Intens.', // 强度
      'mode': 'Modo', // 模式
      'waveform': 'Onda', // 波形
      'continuous': 'Cont.', // 连续
      'pulse': 'Pulso', // 脉冲
      'power': 'Potência', // 功率
      'running': 'Em execução', // 正在运行
      'waiting': 'Em espera', // 等待运行
      // 设置页面
      'setting_menu': 'Menu de definições', // 设置菜单
      'language_setting': 'Idioma', // 语言设置
      'language_switch': 'Alterar idioma', // 语言切换
      'save_changes': 'Guardar', // 保存更改
      'date_time': 'Data e hora', // 日期和时间
      'device_info': 'Info', // 设备信息
      'debug_mode': 'Depuração', // 调试模式
      'history_record': 'Histórico', // 历史记录
      'user_management': 'Utilizadores', // 用户管理
      // 主页
      'preset_mode': 'Modos de terapia predefinidos', // 预设理疗模式
      'preset_mode_subtitle': '10 programas profissionais', // 10种专业配方方案
      'device_ready': 'Dispositivo pronto', // 设备就绪
      'custom_plan': 'Plano', // 自定义方案
      'deep_relax': 'Relaxar', // 深度放松
      'energy_boost': 'Impulso energ.', // 能量提升
      'pain_relief': 'Alivio del dolor', // 疼痛缓解
      'sleep_enhancement': 'Mejora sueño', // 睡眠改善
      'sports_recovery': 'Recup. dep.', // 运动恢复
      'stress_release': 'Antiestrés', // 压力释放
      'immune_boost': 'Imunidade', // 免疫增强
      'anti_aging': ' Cuidado Integ.', // 抗衰老
      'full_care': 'Cura Emociona.', // 全面养护
      'mental_healing': 'Eq. emocional', // 情绪疗愈
      'device_fault': 'Falha do dispositivo', // 设备故障
      // 登录页面
      'login_phone_hint': 'Introduza o número de telefone', // 输入手机号
      'login_password_hint': 'Introduza a palavra-passe', // 输入密码
      'forgot_password': 'Esqueceu-se da palavra-passe?', // 忘记密码?
      'login': 'Iniciar sessão', // 登录
      'register': 'Registar', // 注册
      'agree_prefix': 'Li e aceito ', // 我已阅读并同意
      'user_agreement': 'Acordo do utilizador', // 《用户协议》
      'and': ' e ', // 和
      'privacy_policy': 'Política de privacidade', // 《隐私政策》
      // 用户选择页面
      'choose_therapy_user': 'Selecionar utilizador', // 选择理疗用户
      'search_user_hint': 'Introduza nome ou telefone', // 输入用户姓名或手机号
      'confirm_selection': 'Confirmar seleção', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Confirmar seleção', // 确认选择
      // 启动页面
      'red_light': 'Luz Vermelha', // 红光
      'wavelength': 'Onda', // 波长
      'hydrogen_molecule': 'H₂', // 分子氢
      'hydrogen_concentration': 'Conc. de H₂', // 氢气浓度
      'flow': 'Fluxo', // 流量
      'chakra': 'Chakra', // 脉轮
      'terahertz': 'Terahertz', // 太赫兹
      'fragrance': 'Aroma', // 香氛
      'therapy_completed': 'Terapia concluída', // 治疗完成
      'user': 'Utilizador', // 使用者
      'session_duration': 'Duração da sessão', // 本次使用
      'module_duration': 'Duração do módulo', // 模块时长
      'no_module_record': 'Sem registos do módulo', // 暂无模块运行记录
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
      // 自定义编辑页面
      'red_ther': 'Ter. Roja', // 红光
      'add_therapy_module': 'Adicionar módulo', // 添加治疗模块
      'expand_feature': 'Funções extra', // 拓展功能
      'save_params': 'Salvar', // 保存参数
      'save_plan': 'Guardar plano', // 保存方案
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
      // 通用
      'settings': ' Настр.', // 设置
      'administrator': 'Админ', // 管理员
      'back': 'Назад', // 返回
      'confirm': 'Подтвердить', // 确认
      'cancel': 'Отмена', // 取消
      'save': 'Сохранить', // 保存
      'delete': 'Удалить', // 删除
      'select': 'Выбрать', // 选择
      'name': 'Имя', // 姓名
      'age': 'Возраст', // 年龄
      'phone': 'Телефон', // 手机号
      'gender': 'Пол', // 性别
      'male': 'М', // 男
      'female': 'Ж', // 女
      'frequency': 'Частота', // 频率
      'intensity': 'Интенсив.', // 强度
      'mode': 'Режим', // 模式
      'waveform': 'Волна', // 波形
      'continuous': 'Непр.', // 连续
      'pulse': 'Имп.', // 脉冲
      'power': 'Мощность', // 功率
      'running': 'Работает', // 正在运行
      'waiting': 'Ожидание', // 等待运行
      // 设置页面
      'setting_menu': 'Меню настроек', // 设置菜单
      'language_setting': 'Язык', // 语言设置
      'language_switch': 'Смена языка', // 语言切换
      'save_changes': 'Сохранить', // 保存更改
      'date_time': 'Дата и время', // 日期和时间
      'device_info': 'Информация', // 设备信息
      'debug_mode': 'Отладка', // 调试模式
      'history_record': 'История', // 历史记录
      'user_management': 'Пользователи', // 用户管理
      'unsupported_language': 'Этот язык пока не поддерживается', // 该语言暂未支持
      // 主页
      'preset_mode': 'Готовые режимы терапии', // 预设理疗模式
      'preset_mode_subtitle': '10 профессиональных программ', // 10种专业配方方案
      'device_ready': 'Устройство готово', // 设备就绪
      'custom_plan': 'Свой режим', // 自定义方案
      'deep_relax': 'Глубокий релакс', // 深度放松
      'energy_boost': 'Повышение сил', // 能量提升
      'pain_relief': 'Облегчение боли', // 疼痛缓解
      'sleep_enhancement': 'Улучшение сна', // 睡眠改善
      'sports_recovery': 'Восстановл.', // 运动恢复
      'stress_release': 'Антистресс', // 压力释放
      'immune_boost': 'Иммунитет', // 免疫增强
      'anti_aging': 'Омоложение', // 抗衰老
      'full_care': 'Общий уход', // 全面养护
      'mental_healing': 'Эмо-Баланс', // 情绪疗愈
      'device_fault': 'Ошибка устройства', // 设备故障
      // 登录页面
      'login_phone_hint': 'Введите номер телефона', // 输入手机号
      'login_password_hint': 'Введите пароль', // 输入密码
      'forgot_password': 'Забыли пароль?', // 忘记密码?
      'login': 'Войти', // 登录
      'register': 'Регистрация', // 注册
      'agree_prefix': 'Я прочитал и принимаю ', // 我已阅读并同意
      'user_agreement': 'Пользовательское соглашение', // 《用户协议》
      'and': ' и ', // 和
      'privacy_policy': 'Политику конфиденциальности', // 《隐私政策》
      // 用户选择页面
      'choose_therapy_user': 'Выберите пользователя', // 选择理疗用户
      'search_user_hint': 'Введите имя или телефон', // 输入用户姓名或手机号
      'confirm_selection': 'Подтвердить выбор', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Подтвердить выбор', // 确认选择
      // 启动页面
      'red_light': 'Красный свет', // 红光
      'wavelength': 'Волна', // 波长
      'hydrogen_molecule': 'H₂', // 分子氢
      'hydrogen_concentration': 'Конц. H₂', // 氢气浓度
      'flow': 'Поток', // 流量
      'chakra': 'Чакра', // 脉轮
      'terahertz': 'Терагерц', // 太赫兹
      'fragrance': 'Аромат', // 香氛
      'therapy_completed': 'Терапия завершена', // 治疗完成
      'user': 'Пользователь', // 使用者
      'session_duration': 'Время сеанса', // 本次使用
      'module_duration': 'Время модуля', // 模块时长
      'no_module_record': 'Нет записей работы модуля', // 暂无模块运行记录
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
      'rename_plan': 'Ред.', // 重命名
      'plan_name_empty': 'Название плана не может быть пустым', // 方案名称不能为空
      'custom_plan_load_failed': 'Не удалось загрузить планы: ', // 自定义方案加载失败：
      // 自定义编辑页面
      'red_ther': 'КРАСНЫЙ', // 红光
      'add_therapy_module': 'Добавить модуль', // 添加治疗模块
      'expand_feature': 'Доп. функции', // 拓展功能
      'save_params': 'Сохранить', // 保存参数
      'save_plan': 'Сохранить план', // 保存方案
      'complete_previous_node':
          'Сначала завершите предыдущий 5-минутный узел', // 请先完成上一个 5 分钟节点
      'node_saved_prefix': 'Параметры узла ', // 第
      'node_saved_suffix': ' мин сохранены', // 分钟节点参数已保存
      'plan_naming': 'Название плана', // 方案命名
      'plan_name_duplicate': 'Название плана не должно повторяться', // 方案名称不能重复
      'mode_select': 'Режим', // 模式选择
      'module_hydrogen': 'H₂', // 分子氢
      'module_expand': 'Доп.', // 拓展功能
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
      // 通用
      'settings': 'Config.', // 设置
      'administrator': 'Admin', // 管理员
      'back': 'Retour', // 返回
      'confirm': 'Confirmer', // 确认
      'cancel': 'Annuler', // 取消
      'save': 'Enregistrer', // 保存
      'delete': 'Supprimer', // 删除
      'select': 'Выб.', // 选择
      'name': 'Nom', // 姓名
      'age': 'Âge', // 年龄
      'phone': 'Téléphone', // 手机号
      'gender': 'Sexe', // 性别
      'male': 'H', // 男
      'female': 'F', // 女
      'frequency': 'Fréquence', // 频率
      'intensity': 'Intensité', // 强度
      'mode': 'Mode', // 模式
      'waveform': 'Onde', // 波形
      'continuous': 'Continu', // 连续
      'pulse': 'Pulsé', // 脉冲
      'power': 'Puissance', // 功率
      'running': 'En cours', // 正在运行
      'waiting': 'En attente', // 等待运行
      // 设置页面
      'setting_menu': 'Menu des paramètres', // 设置菜单
      'language_setting': 'Langue', // 语言设置
      'language_switch': 'Changer de langue', // 语言切换
      'save_changes': 'Enregistrer les modifications', // 保存更改
      'date_time': 'Date et heure', // 日期和时间
      'device_info': 'Infos appareil', // 设备信息
      'debug_mode': 'Mode débogage', // 调试模式
      'history_record': 'Historique', // 历史记录
      'user_management': 'Utilisateurs', // 用户管理
      'unsupported_language': 'Langue non prise en charge', // 该语言暂未支持
      // 主页面
      'preset_mode': 'Modes de thérapie prédéfinis', // 预设理疗模式
      'preset_mode_subtitle': '10 formules professionnelles', // 10种专业配方方案
      'device_ready': 'Appareil prêt', // 设备就绪
      'custom_plan': 'Programme', // 自定义方案
      'deep_relax': 'Détente', // 深度放松
      'energy_boost': 'Boost d’énergie', // 能量提升
      'pain_relief': 'Anti-douleur', // 疼痛缓解
      'sleep_enhancement': 'Mieux dormir', // 睡眠改善
      'sports_recovery': 'Récupération', // 运动恢复
      'stress_release': 'Anti-stress', // 压力释放
      'immune_boost': 'Boost immunité', // 免疫增强
      'anti_aging': 'Anti-âge', // 抗衰老
      'full_care': 'Soin complet', // 全面养护
      'mental_healing': 'Soin émotionnel', // 情绪疗愈
      'device_fault': 'Défaut de l’appareil', // 设备故障
      // 登录页面
      'login_phone_hint': 'Saisir le numéro de téléphone', // 输入手机号
      'login_password_hint': 'Saisir le mot de passe', // 输入密码
      'forgot_password': 'Mot de passe oublié ?', // 忘记密码?
      'login': 'Connexion', // 登录
      'register': 'Inscription', // 注册
      'agree_prefix': 'J’ai lu et j’accepte ', // 我已阅读并同意
      'user_agreement': '« Conditions d’utilisation »', // 《用户协议》
      'and': ' et ', // 和
      'privacy_policy': '« Politique de confidentialité »', // 《隐私政策》
      // 用户选择页面
      'choose_therapy_user': 'Sélectionner l’utilisateur', // 选择理疗用户
      'search_user_hint':
          'Saisir le nom ou le numéro de téléphone', // 输入用户姓名或手机号
      'confirm_selection': 'Confirmer la sélection', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Confirmer la sélection', // 确认选择
      // 启动页面
      'red_light': 'Thérapie rouge', // 红光
      'wavelength': 'Thér. rouge', // 波长
      'hydrogen_molecule': 'H₂', // 分子氢
      'hydrogen_concentration': 'Conc. H₂', // 氢气浓度
      'flow': 'Débit', // 流量
      'chakra': 'Chakra', // 脉轮
      'terahertz': 'Térahertz', // 太赫兹
      'fragrance': 'Parfum', // 香氛
      'therapy_completed': 'Thérapie terminée', // 治疗完成
      'user': 'Utilisateur', // 使用者
      'session_duration': 'Cette session', // 本次使用
      'module_duration': 'Durée du module', // 模块时长
      'no_module_record': 'Aucun historique de module', // 暂无模块运行记录
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
      // 自定义编辑页面
      'red_ther': 'Thér. rouge', // 红光
      'add_therapy_module': 'Ajouter module', // 添加治疗模块
      'expand_feature': 'Extras', // 拓展功能
      'save_params': 'Enregistrer', // 保存参数
      'save_plan': 'Enregistrer le programme', // 保存方案
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
      // 通用
      'settings': '설정', // 设置
      'administrator': '관리자', // 管理员
      'back': '뒤로', // 返回
      'confirm': '확인', // 确认
      'cancel': '취소', // 取消
      'save': '저장', // 保存
      'delete': '삭제', // 删除
      'select': '선택', // 选择
      'name': '이름', // 姓名
      'age': '나이', // 年龄
      'phone': '전화번호', // 手机号
      'gender': '성별', // 性别
      'male': '남', // 男
      'female': '여', // 女
      'frequency': '주파수', // 频率
      'intensity': '강도', // 强度
      'mode': '모드', // 模式
      'waveform': '파형', // 波形
      'continuous': '연속', // 连续
      'pulse': '펄스', // 脉冲
      'power': '출력', // 功率
      'running': '실행 중', // 正在运行
      'waiting': '대기 중', // 等待运行
      // 设置页面
      'setting_menu': '설정 메뉴', // 设置菜单
      'language_setting': '언어 설정', // 语言设置
      'language_switch': '언어 전환', // 语言切换
      'save_changes': '저장', // 保存更改
      'date_time': '날짜 및 시간', // 日期和时间
      'device_info': '장치 정보', // 设备信息
      'debug_mode': '디버그 모드', // 调试模式
      'history_record': '기록', // 历史记录
      'user_management': '사용자 관리', // 用户管理
      'unsupported_language': '이 언어는 아직 지원되지 않습니다', // 该语言暂未支持
      // 主页
      'preset_mode': '프리셋 치료 모드', // 预设理疗模式
      'preset_mode_subtitle': '전문 프로그램 10종', // 10种专业配方方案
      'device_ready': '장치 준비 완료', // 设备就绪
      'custom_plan': '맞춤 플랜', // 自定义方案
      'deep_relax': '심층 이완', // 深度放松
      'energy_boost': '에너지 향상', // 能量提升
      'pain_relief': '통증 완화', // 疼痛缓解
      'sleep_enhancement': '수면 개선', // 睡眠改善
      'sports_recovery': '운동 회복', // 运动恢复
      'stress_release': '스트레스 완화', // 压力释放
      'immune_boost': '면역 강화', // 免疫增强
      'anti_aging': '안티에이징', // 抗衰老
      'full_care': '토탈 케어', // 全面养护
      'mental_healing': '정서 치유', // 情绪疗愈
      'device_fault': '장치 고장', // 设备故障
      // 登录页面
      'login_phone_hint': '전화번호를 입력하세요', // 输入手机号
      'login_password_hint': '비밀번호를 입력하세요', // 输入密码
      'forgot_password': '비밀번호를 잊으셨나요?', // 忘记密码?
      'login': '로그인', // 登录
      'register': '회원가입', // 注册
      'agree_prefix': '다음을 읽고 동의합니다 ', // 我已阅读并同意
      'user_agreement': '사용자 약관', // 《用户协议》
      'and': ' 및 ', // 和
      'privacy_policy': '개인정보 처리방침', // 《隐私政策》
      // 用户选择页面
      'choose_therapy_user': '사용자 선택', // 选择理疗用户
      'search_user_hint': '이름/전화번호 입력', // 输入用户姓名或手机号
      'confirm_selection': '선택 확인', // 确认选择
      // 音乐页面
      'confirm_music_selection': '선택 확인', // 确认选择
      // 启动页面
      'red_light': '레드 테라피', // 红光
      'wavelength': '파장', // 波长
      'hydrogen_molecule': '수소', // 分子氢
      'hydrogen_concentration': '수소 농도', // 氢气浓度
      'flow': '유량', // 流量
      'chakra': '차크라', // 脉轮
      'terahertz': '테라헤르츠', // 太赫兹
      'fragrance': '아로마', // 香氛
      'therapy_completed': '치료 완료', // 治疗完成
      'user': '사용자', // 使用者
      'session_duration': '세션 시간', // 本次使用
      'module_duration': '모듈 시간', // 模块时长
      'no_module_record': '모듈 실행 기록 없음', // 暂无模块运行记录
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
      // 自定义编辑页面
      'red_ther': '레드 테라피', // 红光
      'add_therapy_module': '모듈 추가', // 添加治疗模块
      'expand_feature': '확장', // 拓展功能
      'save_params': '파라미터 저장', // 保存参数
      'save_plan': '플랜 저장', // 保存方案
      'complete_previous_node': '먼저 이전 5분 노드를 완료하세요', // 请先完成上一个 5 分钟节点
      'node_saved_prefix': '', // 第
      'node_saved_suffix': '분 노드 파라미터가 저장되었습니다', // 分钟节点参数已保存
      'plan_naming': '플랜 이름', // 方案命名
      'plan_name_duplicate': '플랜 이름은 중복될 수 없습니다', // 方案名称不能重复
      'mode_select': '모드 선택', // 模式选择
      'module_hydrogen': '수소', // 分子氢
      'module_expand': '확장', // 拓展功能
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
      // 通用
      'settings': 'الإعدادات', // 设置
      'administrator': 'المدير', // 管理员
      'back': 'رجوع', // 返回
      'confirm': 'تأكيد', // 确认
      'cancel': 'إلغاء', // 取消
      'save': 'حفظ', // 保存
      'delete': 'حذف', // 删除
      'select': 'اختيار', // 选择
      'name': 'الاسم', // 姓名
      'age': 'العمر', // 年龄
      'phone': 'الهاتف', // 手机号
      'gender': 'الجنس', // 性别
      'male': 'ذكر', // 男
      'female': 'أنثى', // 女
      'frequency': 'التردد', // 频率
      'intensity': 'الشدة', // 强度
      'mode': 'الوضع', // 模式
      'waveform': 'شكل الموجة', // 波形
      'continuous': 'مستمر', // 连续
      'pulse': 'نبضي', // 脉冲
      'power': 'القدرة', // 功率
      'running': 'قيد التشغيل', // 正在运行
      'waiting': 'في الانتظار', // 等待运行
      // 设置页面
      'setting_menu': 'قائمة الإعدادات', // 设置菜单
      'language_setting': 'اللغة', // 语言设置
      'language_switch': 'تبديل اللغة', // 语言切换
      'save_changes': 'حفظ', // 保存更改
      'date_time': 'التاريخ والوقت', // 日期和时间
      'device_info': 'معلومات الجهاز', // 设备信息
      'debug_mode': 'وضع التصحيح', // 调试模式
      'history_record': 'السجل', // 历史记录
      'user_management': 'المستخدمون', // 用户管理
      'unsupported_language': 'هذه اللغة غير مدعومة حاليًا', // 该语言暂未支持
      // 主页
      'preset_mode': 'أوضاع العلاج المسبقة', // 预设理疗模式
      'preset_mode_subtitle': '10 برامج علاجية احترافية', // 10种专业配方方案
      'device_ready': 'الجهاز جاهز', // 设备就绪
      'custom_plan': 'خطة مخصصة', // 自定义方案
      'deep_relax': 'استرخاء عميق', // 深度放松
      'energy_boost': 'تعزيز الطاقة', // 能量提升
      'pain_relief': 'تخفيف الألم', // 疼痛缓解
      'sleep_enhancement': 'تحسين النوم', // 睡眠改善
      'sports_recovery': 'تعافٍ رياضي', // 运动恢复
      'stress_release': 'تخفيف التوتر', // 压力释放
      'immune_boost': 'تعزيز المناعة', // 免疫增强
      'anti_aging': 'مكافحة الشيخوخة', // 抗衰老
      'full_care': 'رعاية شاملة', // 全面养护
      'mental_healing': 'شفاء عاطفي', // 情绪疗愈
      'device_fault': 'عطل الجهاز', // 设备故障
      // 登录页面
      'login_phone_hint': 'أدخل رقم الهاتف', // 输入手机号
      'login_password_hint': 'أدخل كلمة المرور', // 输入密码
      'forgot_password': 'هل نسيت كلمة المرور؟', // 忘记密码?
      'login': 'تسجيل الدخول', // 登录
      'register': 'تسجيل', // 注册
      'agree_prefix': 'لقد قرأت وأوافق على ', // 我已阅读并同意
      'user_agreement': 'اتفاقية المستخدم', // 《用户协议》
      'and': ' و ', // 和
      'privacy_policy': 'سياسة الخصوصية', // 《隐私政策》
      // 用户选择页面
      'choose_therapy_user': 'اختيار مستخدم العلاج', // 选择理疗用户
      'search_user_hint': 'أدخل الاسم أو رقم الهاتف', // 输入用户姓名或手机号
      'confirm_selection': 'تأكيد الاختيار', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'تأكيد الاختيار', // 确认选择
      // 启动页面
      'red_light': 'الضوء الأحمر', // 红光
      'wavelength': 'الطول الموجي', // 波长
      'hydrogen_molecule': 'H₂', // 分子氢
      'hydrogen_concentration': 'تركيز H₂', // 氢气浓度
      'flow': 'التدفق', // 流量
      'chakra': 'شاكرا', // 脉轮
      'terahertz': 'تيراهرتز', // 太赫兹
      'fragrance': 'العطر', // 香氛
      'therapy_completed': 'اكتمل العلاج', // 治疗完成
      'user': 'المستخدم', // 使用者
      'session_duration': 'مدة الجلسة', // 本次使用
      'module_duration': 'مدة الوحدة', // 模块时长
      'no_module_record': 'لا توجد سجلات تشغيل للوحدة', // 暂无模块运行记录
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
      // 自定义编辑页面
      'red_ther': 'الضوء الأحمر', // 红光
      'add_therapy_module': 'إضافة وحدة علاجية', // 添加治疗模块
      'expand_feature': 'ميزات إضافية', // 拓展功能
      'save_params': 'حفظ المعلمات', // 保存参数
      'save_plan': 'حفظ الخطة', // 保存方案
      'complete_previous_node':
          'يرجى إكمال نقطة الخمس دقائق السابقة أولًا', // 请先完成上一个 5 分钟节点
      'node_saved_prefix': 'تم حفظ معلمات نقطة ', // 第
      'node_saved_suffix': ' دقائق', // 分钟节点参数已保存
      'plan_naming': 'تسمية الخطة', // 方案命名
      'plan_name_duplicate': 'لا يمكن تكرار اسم الخطة', // 方案名称不能重复
      'mode_select': 'اختيار الوضع', // 模式选择
      'module_hydrogen': 'H₂', // 分子氢
      'module_expand': 'توسيع', // 拓展功能
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
      // 通用
      'settings': 'Einst.', // 设置
      'administrator': 'Admin', // 管理员
      'back': 'Zurück', // 返回
      'confirm': 'Bestätigen', // 确认
      'cancel': 'Abbrechen', // 取消
      'save': 'Speichern', // 保存
      'delete': 'Löschen', // 删除
      'select': 'Wählen', // 选择
      'name': 'Name', // 姓名
      'age': 'Alter', // 年龄
      'phone': 'Telefon', // 手机号
      'gender': 'Geschlecht', // 性别
      'male': 'M', // 男
      'female': 'W', // 女
      'frequency': 'Frequenz', // 频率
      'intensity': 'Intensität', // 强度
      'mode': 'Modus', // 模式
      'waveform': 'Welle', // 波形
      'continuous': 'Kont.', // 连续
      'pulse': 'Impuls', // 脉冲
      'power': 'Leistung', // 功率
      'running': 'Läuft', // 正在运行
      'waiting': 'Warten', // 等待运行
      // 设置页面
      'setting_menu': 'Einstellungsmenü', // 设置菜单
      'language_setting': 'Sprache', // 语言设置
      'language_switch': 'Sprache wechseln', // 语言切换
      'save_changes': 'Speichern', // 保存更改
      'date_time': 'Datum & Uhrzeit', // 日期和时间
      'device_info': 'Geräteinfo', // 设备信息
      'debug_mode': 'Debug-Modus', // 调试模式
      'history_record': 'Verlauf', // 历史记录
      'user_management': 'Benutzer', // 用户管理
      'unsupported_language':
          'Diese Sprache wird noch nicht unterstützt', // 该语言暂未支持
      // 主页
      'preset_mode': 'Voreingestellte Therapiemodi', // 预设理疗模式
      'preset_mode_subtitle': '10 professionelle Programme', // 10种专业配方方案
      'device_ready': 'Gerät bereit', // 设备就绪
      'custom_plan': 'Eigener Plan', // 自定义方案
      'deep_relax': 'Entspannung', // 深度放松
      'energy_boost': 'Energieschub', // 能量提升
      'pain_relief': 'Schmerzlinderung', // 疼痛缓解
      'sleep_enhancement': 'Besser Schlaf', // 睡眠改善
      'sports_recovery': 'Sport-Erholung', // 运动恢复
      'stress_release': 'Stressabbau', // 压力释放
      'immune_boost': 'Immunstärkung', // 免疫增强
      'anti_aging': 'Anti-Aging', // 抗衰老
      'full_care': 'Rundum-Pflege', // 全面养护
      'mental_healing': 'Emo-Heilung', // 情绪疗愈
      'device_fault': 'Gerätefehler', // 设备故障
      // 登录页面
      'login_phone_hint': 'Telefonnummer eingeben', // 输入手机号
      'login_password_hint': 'Passwort eingeben', // 输入密码
      'forgot_password': 'Passwort vergessen?', // 忘记密码?
      'login': 'Anmelden', // 登录
      'register': 'Registrieren', // 注册
      'agree_prefix': 'Ich habe gelesen und stimme zu ', // 我已阅读并同意
      'user_agreement': 'Nutzungsvereinbarung', // 《用户协议》
      'and': ' und ', // 和
      'privacy_policy': 'Datenschutzerklärung', // 《隐私政策》
      // 用户选择页面
      'choose_therapy_user': 'Therapiebenutzer auswählen', // 选择理疗用户
      'search_user_hint': 'Name oder Telefonnummer eingeben', // 输入用户姓名或手机号
      'confirm_selection': 'Auswahl bestätigen', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Auswahl bestätigen', // 确认选择
      // 启动页面
      'red_light': 'Rotlicht', // 红光
      'wavelength': 'Wellenlänge', // 波长
      'hydrogen_molecule': 'H₂', // 分子氢
      'hydrogen_concentration': 'H₂-Konz.', // 氢气浓度
      'flow': 'Durchfluss', // 流量
      'chakra': 'Chakra', // 脉轮
      'terahertz': 'Terahertz', // 太赫兹
      'fragrance': 'Aroma', // 香氛
      'therapy_completed': 'Therapie abgeschlossen', // 治疗完成
      'user': 'Benutzer', // 使用者
      'session_duration': 'Sitzungsdauer', // 本次使用
      'module_duration': 'Moduldauer', // 模块时长
      'no_module_record': 'Keine Modulaufzeichnungen', // 暂无模块运行记录
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
      // 自定义编辑页面
      'red_ther': 'Rotlicht', // 红光
      'add_therapy_module': 'Modul hinzufügen', // 添加治疗模块
      'expand_feature': 'Erweitern', // 拓展功能
      'save_params': 'Speichern', // 保存参数
      'save_plan': 'Plan speichern', // 保存方案
      'complete_previous_node':
          'Bitte zuerst den vorherigen 5-Minuten-Knoten abschließen', // 请先完成上一个 5 分钟节点
      'node_saved_prefix': 'Parameter des Knotens ', // 第
      'node_saved_suffix': ' Min. gespeichert', // 分钟节点参数已保存
      'plan_naming': 'Planname', // 方案命名
      'plan_name_duplicate': 'Planname darf nicht doppelt sein', // 方案名称不能重复
      'mode_select': 'Modus', // 模式选择
      'module_hydrogen': 'H₂', // 分子氢
      'module_expand': 'Erweitern', // 拓展功能
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
      // 通用
      'settings': 'Ayarlar', // 设置
      'administrator': 'Yönetici', // 管理员
      'back': 'Geri', // 返回
      'confirm': 'Onayla', // 确认
      'cancel': 'İptal', // 取消
      'save': 'Kaydet', // 保存
      'delete': 'Sil', // 删除
      'select': 'Seç', // 选择
      'name': 'Ad', // 姓名
      'age': 'Yaş', // 年龄
      'phone': 'Telefon', // 手机号
      'gender': 'Cinsiyet', // 性别
      'male': 'E', // 男
      'female': 'K', // 女
      'frequency': 'Frekans', // 频率
      'intensity': 'Yoğunluk', // 强度
      'mode': 'Mod', // 模式
      'waveform': 'Dalga', // 波形
      'continuous': 'Sürekli', // 连续
      'pulse': 'Darbeli', // 脉冲
      'power': 'Güç', // 功率
      'running': 'Çalışıyor', // 正在运行
      'waiting': 'Bekliyor', // 等待运行
      // 设置页面
      'setting_menu': 'Ayarlar Menüsü', // 设置菜单
      'language_setting': 'Dil', // 语言设置
      'language_switch': 'Dil Değiştir', // 语言切换
      'save_changes': 'Kaydet', // 保存更改
      'date_time': 'Tarih ve Saat', // 日期和时间
      'device_info': 'Cihaz Bilgisi', // 设备信息
      'debug_mode': 'Hata Ayıklama', // 调试模式
      'history_record': 'Geçmiş', // 历史记录
      'user_management': 'Kullanıcılar', // 用户管理
      'unsupported_language': 'Bu dil henüz desteklenmiyor', // 该语言暂未支持
      // 主页
      'preset_mode': 'Hazır Terapi Modları', // 预设理疗模式
      'preset_mode_subtitle': '10 profesyonel program', // 10种专业配方方案
      'device_ready': 'Cihaz Hazır', // 设备就绪
      'custom_plan': 'Özel Plan', // 自定义方案
      'deep_relax': 'Derin Rahatlama', // 深度放松
      'energy_boost': 'Enerji Artışı', // 能量提升
      'pain_relief': 'Ağrı Azaltma', // 疼痛缓解
      'sleep_enhancement': 'Uyku İyileştirme', // 睡眠改善
      'sports_recovery': 'Spor Top.', // 运动恢复
      'stress_release': 'Stres Azaltma', // 压力释放
      'immune_boost': 'Bağışıklık G.', // 免疫增强
      'anti_aging': 'Yaşlanma Karşıtı', // 抗衰老
      'full_care': 'Tam Bakım', // 全面养护
      'mental_healing': 'Duygusal İyil.', // 情绪疗愈
      'device_fault': 'Cihaz Arızası', // 设备故障
      // 登录页面
      'login_phone_hint': 'Telefon numarasını girin', // 输入手机号
      'login_password_hint': 'Şifreyi girin', // 输入密码
      'forgot_password': 'Şifrenizi mi unuttunuz?', // 忘记密码?
      'login': 'Giriş Yap', // 登录
      'register': 'Kayıt Ol', // 注册
      'agree_prefix': 'Okudum ve kabul ediyorum ', // 我已阅读并同意
      'user_agreement': 'Kullanıcı Sözleşmesi', // 《用户协议》
      'and': ' ve ', // 和
      'privacy_policy': 'Gizlilik Politikası', // 《隐私政策》
      // 用户选择页面
      'choose_therapy_user': 'Terapi Kullanıcısı Seç', // 选择理疗用户
      'search_user_hint': 'Ad veya telefon girin', // 输入用户姓名或手机号
      'confirm_selection': 'Seçimi Onayla', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Seçimi Onayla', // 确认选择
      // 启动页面
      'red_light': 'Kırmızı Işık', // 红光
      'wavelength': 'Dalga Boyu', // 波长
      'hydrogen_molecule': 'H₂', // 分子氢
      'hydrogen_concentration': 'H₂ Kons.', // 氢气浓度
      'flow': 'Akış', // 流量
      'chakra': 'Çakra', // 脉轮
      'terahertz': 'Terahertz', // 太赫兹
      'fragrance': 'Aroma', // 香氛
      'therapy_completed': 'Terapi Tamamlandı', // 治疗完成
      'user': 'Kullanıcı', // 使用者
      'session_duration': 'Seans Süresi', // 本次使用
      'module_duration': 'Modül Süresi', // 模块时长
      'no_module_record': 'Modül çalışma kaydı yok', // 暂无模块运行记录
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
      // 自定义编辑页面
      'red_ther': 'Kırmızı Işık', // 红光
      'add_therapy_module': 'Terapi Modülü Ekle', // 添加治疗模块
      'expand_feature': 'Доп. функции', // 拓展功能
      'save_params': 'Kaydet', // 保存参数
      'save_plan': 'Planı Kaydet', // 保存方案
      'complete_previous_node':
          'Lütfen önce önceki 5 dakikalık düğümü tamamlayın', // 请先完成上一个 5 分钟节点
      'node_saved_prefix': 'Düğüm ', // 第
      'node_saved_suffix': ' dk parametreleri kaydedildi', // 分钟节点参数已保存
      'plan_naming': 'Plan Adı', // 方案命名
      'plan_name_duplicate': 'Plan adı tekrar edemez', // 方案名称不能重复
      'mode_select': 'Mod Seçimi', // 模式选择
      'module_hydrogen': 'H₂', // 分子氢
      'module_expand': 'Genişlet', // 拓展功能
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
  };
}
