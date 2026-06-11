// App 多语言文案表。
//
// 所有页面展示文案按语言代码集中维护在这里。
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
      'chakra_power': '强度',
      'running': '正在运行',
      'waiting': '等待运行',
      'logout': '退出登录',
      'parameter_settings': '参数设置',

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
      'therapy_record_load_failed': '理疗记录加载失败',
      'no_history_records': '暂无历史记录',
      'no_therapy_records': '暂无理疗记录',
      'years_old_unit': '岁',
      'therapy_report': '理疗报告',
      'total_therapy_duration': '总治疗时长',
      'feedback_label': '感受：',
      'no_feedback': '暂无反馈',
      'treatment_modules': '治疗模块',
      'energy_score': '能量指数',
      'cell_score': '细胞活化',
      'relaxation_score': '放松指数',
      'immune_score': '免疫提升',
      'compared_to_last': '较上次',
      'session_once_1': '1次',
      'session_once_2': '2次',
      'session_once_3': '3次',
      'current_session': '本次',
      'health_effect_assessment': '健康效果评估',
      'status_good': '良好',
      'overall_score': '综合得分',
      'level_low': '低',
      'level_medium': '中',
      'level_high': '高',
      'therapy_feedback_hint': '请输入本次疗程的感受、身体反应等',
      'score_unit': '分',
      'minutes_unit': '分',
      'seconds_unit': '秒',
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
      'choose_therapy_user': '选择理疗用户',
      'search_user_hint': '输入用户姓名或手机号',
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
      'therapy_completed': '治疗完成',
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
      'redlight_strength_required': '红光660nm和850nm强度不能同时为0',
      'pemf_params_required': 'PEMF频率和强度都不能为0',
      'vat_params_required': 'VAT频率和强度都不能为0',
      'hydrogen_concentration_required': '分子氢浓度不能为0',

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
      'chakra_power': 'Power', // 强度
      'running': 'Running', // 正在运行
      'waiting': 'Waiting', // 等待运行
      'logout': 'Log out', // 退出登录
      'parameter_settings': 'Parameter Settings', // 参数设置
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
          'Failed to load therapy records', // 理疗记录加载失败
      'no_history_records': 'No history records', // 暂无历史记录
      'no_therapy_records': 'No therapy records', // 暂无理疗记录
      'years_old_unit': 'y', // 岁
      'therapy_report': 'Therapy Report', // 理疗报告
      'total_therapy_duration': 'Total Duration', // 总治疗时长
      'feedback_label': 'Feedback: ', // 感受：
      'no_feedback': 'No feedback', // 暂无反馈
      'treatment_modules': 'Treatment Modules', // 治疗模块
      'energy_score': 'Energy Score', // 能量指数
      'cell_score': 'Cell Activation', // 细胞活化
      'relaxation_score': 'Relaxation Score', // 放松指数
      'immune_score': 'Immune Boost', // 免疫提升
      'compared_to_last': 'Compared to last', // 较上次
      'session_once_1': '1st', // 1次
      'session_once_2': '2nd', // 2次
      'session_once_3': '3rd', // 3次
      'current_session': 'Current', // 本次
      'health_effect_assessment': 'Health Effect Assessment', // 健康效果评估
      'status_good': 'Good', // 良好
      'overall_score': 'Overall Score', // 综合得分
      'level_low': 'Low', // 低
      'level_medium': 'Medium', // 中
      'level_high': 'High', // 高
      'therapy_feedback_hint':
          'Enter your feelings and body response for this session', // 请输入本次疗程的感受、身体反应等
      'score_unit': 'pts', // 分
      'minutes_unit': 'min', // 分
      'seconds_unit': 's', // 秒
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
      'choose_therapy_user': 'Select Therapy User', // 选择理疗用户
      'search_user_hint': 'Enter user name or phone number', // 输入用户姓名或手机号
      'confirm_selection': 'Confirm Selection', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Confirm Selection', // 确认选择
      'music_resource_missing':
          'No audio resource for this music', // 当前音乐暂无音频资源
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
      'redlight_strength_required':
          'Red light 660nm and 850nm intensity cannot both be 0', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required':
          'PEMF frequency and intensity cannot both be 0', // PEMF频率和强度都不能为0
      'vat_params_required':
          'VAT frequency and intensity cannot both be 0', // VAT频率和强度都不能为0
      'hydrogen_concentration_required':
          'H₂ concentration cannot be 0', // 分子氢浓度不能为0
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
      'chakra_power': 'Pot.', // 强度
      'running': 'Activo', // 正在运行
      'waiting': 'Espera', // 等待运行
      'logout': 'Salir', // 退出登录
      'parameter_settings': 'Ajustes de parámetros', // 参数设置
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
          'Error al cargar registros de terapia', // 理疗记录加载失败
      'no_history_records': 'Sin historial', // 暂无历史记录
      'no_therapy_records': 'Sin registros de terapia', // 暂无理疗记录
      'years_old_unit': 'a', // 岁
      'therapy_report': 'Informe de terapia', // 理疗报告
      'total_therapy_duration': 'Duración total', // 总治疗时长
      'feedback_label': 'Sensación: ', // 感受：
      'no_feedback': 'Sin comentarios', // 暂无反馈
      'treatment_modules': 'Módulos de terapia', // 治疗模块
      'energy_score': 'Energía', // 能量指数
      'cell_score': 'Activación celular', // 细胞活化
      'relaxation_score': 'Relajación', // 放松指数
      'immune_score': 'Inmunidad', // 免疫提升
      'compared_to_last': 'Frente a la anterior', // 较上次
      'session_once_1': '1ª', // 1次
      'session_once_2': '2ª', // 2次
      'session_once_3': '3ª', // 3次
      'current_session': 'Actual', // 本次
      'health_effect_assessment': 'Evaluación de salud', // 健康效果评估
      'status_good': 'Bueno', // 良好
      'overall_score': 'Puntuación general', // 综合得分
      'level_low': 'Bajo', // 低
      'level_medium': 'Medio', // 中
      'level_high': 'Alto', // 高
      'therapy_feedback_hint':
          'Ingrese sensaciones y reacciones de esta sesión', // 请输入本次疗程的感受、身体反应等
      'score_unit': 'pts', // 分
      'minutes_unit': 'min', // 分
      'seconds_unit': 's', // 秒
      'user_management': 'Usuarios', // 用户管理
      'unsupported_language': 'Este idioma aún no es compatible', // 该语言暂未支持
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
      'choose_therapy_user': 'Elegir usuario', // 选择理疗用户
      'search_user_hint': 'Nombre o teléfono', // 输入用户姓名或手机号
      'confirm_selection': 'Confirmar selección', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Confirmar selección', // 确认选择
      'music_resource_missing':
          'Esta música no tiene audio disponible', // 当前音乐暂无音频资源
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
      'redlight_strength_required':
          'La intensidad de luz roja 660nm y 850nm no puede ser 0 a la vez', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required':
          'La frecuencia e intensidad de PEMF no pueden ser 0', // PEMF频率和强度都不能为0
      'vat_params_required':
          'La frecuencia e intensidad de VAT no pueden ser 0', // VAT频率和强度都不能为0
      'hydrogen_concentration_required':
          'La concentración de H₂ no puede ser 0', // 分子氢浓度不能为0
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
      'chakra_power': 'Pot.', // 强度
      'running': 'Em execução', // 正在运行
      'waiting': 'Em espera', // 等待运行
      'logout': 'Sair', // 退出登录
      'parameter_settings': 'Definições de parâmetros', // 参数设置
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
          'Falha ao carregar registos de terapia', // 理疗记录加载失败
      'no_history_records': 'Sem histórico', // 暂无历史记录
      'no_therapy_records': 'Sem registos de terapia', // 暂无理疗记录
      'years_old_unit': 'a', // 岁
      'therapy_report': 'Relatório de terapia', // 理疗报告
      'total_therapy_duration': 'Duração total', // 总治疗时长
      'feedback_label': 'Sensação: ', // 感受：
      'no_feedback': 'Sem feedback', // 暂无反馈
      'treatment_modules': 'Módulos de terapia', // 治疗模块
      'energy_score': 'Energia', // 能量指数
      'cell_score': 'Ativação celular', // 细胞活化
      'relaxation_score': 'Relaxamento', // 放松指数
      'immune_score': 'Imunidade', // 免疫提升
      'compared_to_last': 'Comparado ao anterior', // 较上次
      'session_once_1': '1.ª', // 1次
      'session_once_2': '2.ª', // 2次
      'session_once_3': '3.ª', // 3次
      'current_session': 'Atual', // 本次
      'health_effect_assessment': 'Avaliação de saúde', // 健康效果评估
      'status_good': 'Bom', // 良好
      'overall_score': 'Pontuação geral', // 综合得分
      'level_low': 'Baixo', // 低
      'level_medium': 'Médio', // 中
      'level_high': 'Alto', // 高
      'therapy_feedback_hint':
          'Introduza sensações e reações desta sessão', // 请输入本次疗程的感受、身体反应等
      'score_unit': 'pts', // 分
      'minutes_unit': 'min', // 分
      'seconds_unit': 's', // 秒
      'user_management': 'Utilizadores', // 用户管理
      'unsupported_language': 'Este idioma ainda não é suportado', // 该语言暂未支持
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
      'choose_therapy_user': 'Selecionar utilizador', // 选择理疗用户
      'search_user_hint': 'Introduza nome ou telefone', // 输入用户姓名或手机号
      'confirm_selection': 'Confirmar seleção', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Confirmar seleção', // 确认选择
      'music_resource_missing':
          'Esta música não tem áudio disponível', // 当前音乐暂无音频资源
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
      'redlight_strength_required':
          'A intensidade de luz vermelha 660nm e 850nm não pode ser 0 ao mesmo tempo', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required':
          'A frequência e intensidade PEMF não podem ser 0', // PEMF频率和强度都不能为0
      'vat_params_required':
          'A frequência e intensidade VAT não podem ser 0', // VAT频率和强度都不能为0
      'hydrogen_concentration_required':
          'A concentração de H₂ não pode ser 0', // 分子氢浓度不能为0
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
      'chakra_power': 'Мощ.', // 强度
      'running': 'Работает', // 正在运行
      'waiting': 'Ожидание', // 等待运行
      'logout': 'Выйти', // 退出登录
      'parameter_settings': 'Параметры', // 参数设置
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
          'Не удалось загрузить записи терапии', // 理疗记录加载失败
      'no_history_records': 'Нет записей истории', // 暂无历史记录
      'no_therapy_records': 'Нет записей терапии', // 暂无理疗记录
      'years_old_unit': 'г', // 岁
      'therapy_report': 'Отчет о терапии', // 理疗报告
      'total_therapy_duration': 'Общая длительность', // 总治疗时长
      'feedback_label': 'Ощущения: ', // 感受：
      'no_feedback': 'Нет отзыва', // 暂无反馈
      'treatment_modules': 'Модули терапии', // 治疗模块
      'energy_score': 'Энергия', // 能量指数
      'cell_score': 'Клеточная активация', // 细胞活化
      'relaxation_score': 'Расслабление', // 放松指数
      'immune_score': 'Иммунитет', // 免疫提升
      'compared_to_last': 'По сравнению с прошлым', // 较上次
      'session_once_1': '1-й', // 1次
      'session_once_2': '2-й', // 2次
      'session_once_3': '3-й', // 3次
      'current_session': 'Текущий', // 本次
      'health_effect_assessment': 'Оценка эффекта', // 健康效果评估
      'status_good': 'Хорошо', // 良好
      'overall_score': 'Общий балл', // 综合得分
      'level_low': 'Низк.', // 低
      'level_medium': 'Сред.', // 中
      'level_high': 'Выс.', // 高
      'therapy_feedback_hint':
          'Введите ощущения и реакцию тела после сеанса', // 请输入本次疗程的感受、身体反应等
      'score_unit': 'б', // 分
      'minutes_unit': 'мин', // 分
      'seconds_unit': 'с', // 秒
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
      'choose_therapy_user': 'Выберите пользователя', // 选择理疗用户
      'search_user_hint': 'Введите имя или телефон', // 输入用户姓名或手机号
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
      'therapy_completed': 'Терапия завершена', // 治疗完成
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
      'rename_plan': 'Ред.', // 重命名
      'plan_name_empty': 'Название плана не может быть пустым', // 方案名称不能为空
      'custom_plan_load_failed': 'Не удалось загрузить планы: ', // 自定义方案加载失败：
      'user_not_logged_in_retry':
          'Пользователь не вошел, войдите снова', // 用户未登录，请重新登录
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
      'redlight_strength_required':
          'Интенсивность красного света 660nm и 850nm не может быть 0 одновременно', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required':
          'Частота и интенсивность PEMF не могут быть 0', // PEMF频率和强度都不能为0
      'vat_params_required':
          'Частота и интенсивность VAT не могут быть 0', // VAT频率和强度都不能为0
      'hydrogen_concentration_required':
          'Концентрация H₂ не может быть 0', // 分子氢浓度不能为0
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
      'chakra_power': 'Puis.', // 强度
      'running': 'En cours', // 正在运行
      'waiting': 'En attente', // 等待运行
      'logout': 'Quitter', // 退出登录
      'parameter_settings': 'Paramètres', // 参数设置
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
          'Échec du chargement des séances', // 理疗记录加载失败
      'no_history_records': 'Aucun historique', // 暂无历史记录
      'no_therapy_records': 'Aucune séance', // 暂无理疗记录
      'years_old_unit': 'a', // 岁
      'therapy_report': 'Rapport de thérapie', // 理疗报告
      'total_therapy_duration': 'Durée totale', // 总治疗时长
      'feedback_label': 'Ressenti : ', // 感受：
      'no_feedback': 'Aucun retour', // 暂无反馈
      'treatment_modules': 'Modules de thérapie', // 治疗模块
      'energy_score': 'Énergie', // 能量指数
      'cell_score': 'Activation cellulaire', // 细胞活化
      'relaxation_score': 'Relaxation', // 放松指数
      'immune_score': 'Immunité', // 免疫提升
      'compared_to_last': 'Par rapport au précédent', // 较上次
      'session_once_1': '1re', // 1次
      'session_once_2': '2e', // 2次
      'session_once_3': '3e', // 3次
      'current_session': 'Actuelle', // 本次
      'health_effect_assessment': 'Évaluation santé', // 健康效果评估
      'status_good': 'Bon', // 良好
      'overall_score': 'Score global', // 综合得分
      'level_low': 'Bas', // 低
      'level_medium': 'Moyen', // 中
      'level_high': 'Haut', // 高
      'therapy_feedback_hint':
          'Saisir le ressenti et les réactions de cette séance', // 请输入本次疗程的感受、身体反应等
      'score_unit': 'pts', // 分
      'minutes_unit': 'min', // 分
      'seconds_unit': 's', // 秒
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
      'choose_therapy_user': 'Sélectionner l’utilisateur', // 选择理疗用户
      'search_user_hint':
          'Saisir le nom ou le numéro de téléphone', // 输入用户姓名或手机号
      'confirm_selection': 'Confirmer la sélection', // 确认选择
      // 音乐页面
      'confirm_music_selection': 'Confirmer la sélection', // 确认选择
      'music_resource_missing':
          'Aucune ressource audio pour cette musique', // 当前音乐暂无音频资源
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
      'redlight_strength_required':
          'Les intensités de lumière rouge 660nm et 850nm ne peuvent pas être toutes deux à 0', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required':
          'La fréquence et l’intensité PEMF ne peuvent pas être à 0', // PEMF频率和强度都不能为0
      'vat_params_required':
          'La fréquence et l’intensité VAT ne peuvent pas être à 0', // VAT频率和强度都不能为0
      'hydrogen_concentration_required':
          'La concentration H₂ ne peut pas être 0', // 分子氢浓度不能为0
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
      'chakra_power': '출력', // 强度
      'running': '실행 중', // 正在运行
      'waiting': '대기 중', // 等待运行
      'logout': '로그아웃', // 退出登录
      'parameter_settings': '파라미터 설정', // 参数设置
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
      'therapy_record_load_failed': '치료 기록을 불러오지 못했습니다', // 理疗记录加载失败
      'no_history_records': '기록 없음', // 暂无历史记录
      'no_therapy_records': '치료 기록 없음', // 暂无理疗记录
      'years_old_unit': '세', // 岁
      'therapy_report': '치료 보고서', // 理疗报告
      'total_therapy_duration': '총 치료 시간', // 总治疗时长
      'feedback_label': '느낌: ', // 感受：
      'no_feedback': '피드백 없음', // 暂无反馈
      'treatment_modules': '치료 모듈', // 治疗模块
      'energy_score': '에너지 지수', // 能量指数
      'cell_score': '세포 활성화', // 细胞活化
      'relaxation_score': '이완 지수', // 放松指数
      'immune_score': '면역 향상', // 免疫提升
      'compared_to_last': '지난번 대비', // 较上次
      'session_once_1': '1회', // 1次
      'session_once_2': '2회', // 2次
      'session_once_3': '3회', // 3次
      'current_session': '이번', // 本次
      'health_effect_assessment': '건강 효과 평가', // 健康效果评估
      'status_good': '양호', // 良好
      'overall_score': '종합 점수', // 综合得分
      'level_low': '낮음', // 低
      'level_medium': '중간', // 中
      'level_high': '높음', // 高
      'therapy_feedback_hint': '이번 치료의 느낌과 신체 반응을 입력하세요', // 请输入本次疗程的感受、身体反应等
      'score_unit': '점', // 分
      'minutes_unit': '분', // 分
      'seconds_unit': '초', // 秒
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
      'choose_therapy_user': '사용자 선택', // 选择理疗用户
      'search_user_hint': '이름/전화번호 입력', // 输入用户姓名或手机号
      'confirm_selection': '선택 확인', // 确认选择
      // 音乐页面
      'confirm_music_selection': '선택 확인', // 确认选择
      'music_resource_missing': '현재 음악에 오디오 리소스가 없습니다', // 当前音乐暂无音频资源
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
      'redlight_strength_required':
          '레드라이트 660nm와 850nm 강도는 동시에 0일 수 없습니다', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required': 'PEMF 주파수와 강도는 모두 0일 수 없습니다', // PEMF频率和强度都不能为0
      'vat_params_required': 'VAT 주파수와 강도는 모두 0일 수 없습니다', // VAT频率和强度都不能为0
      'hydrogen_concentration_required': '수소 농도는 0일 수 없습니다', // 分子氢浓度不能为0
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
      'chakra_power': 'قدرة', // 强度
      'running': 'قيد التشغيل', // 正在运行
      'waiting': 'في الانتظار', // 等待运行
      'logout': 'خروج', // 退出登录
      'parameter_settings': 'إعدادات المعلمات', // 参数设置
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
      'therapy_record_load_failed': 'فشل تحميل سجلات العلاج', // 理疗记录加载失败
      'no_history_records': 'لا توجد سجلات تاريخ', // 暂无历史记录
      'no_therapy_records': 'لا توجد سجلات علاج', // 暂无理疗记录
      'years_old_unit': 'س', // 岁
      'therapy_report': 'تقرير العلاج', // 理疗报告
      'total_therapy_duration': 'المدة الإجمالية', // 总治疗时长
      'feedback_label': 'الشعور: ', // 感受：
      'no_feedback': 'لا توجد ملاحظات', // 暂无反馈
      'treatment_modules': 'وحدات العلاج', // 治疗模块
      'energy_score': 'مؤشر الطاقة', // 能量指数
      'cell_score': 'تنشيط الخلايا', // 细胞活化
      'relaxation_score': 'مؤشر الاسترخاء', // 放松指数
      'immune_score': 'تعزيز المناعة', // 免疫提升
      'compared_to_last': 'مقارنة بالسابق', // 较上次
      'session_once_1': '1', // 1次
      'session_once_2': '2', // 2次
      'session_once_3': '3', // 3次
      'current_session': 'الحالية', // 本次
      'health_effect_assessment': 'تقييم التأثير الصحي', // 健康效果评估
      'status_good': 'جيد', // 良好
      'overall_score': 'النتيجة الإجمالية', // 综合得分
      'level_low': 'منخفض', // 低
      'level_medium': 'متوسط', // 中
      'level_high': 'مرتفع', // 高
      'therapy_feedback_hint':
          'أدخل شعورك واستجابة الجسم لهذه الجلسة', // 请输入本次疗程的感受、身体反应等
      'score_unit': 'نقطة', // 分
      'minutes_unit': 'د', // 分
      'seconds_unit': 'ث', // 秒
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
      'choose_therapy_user': 'اختيار مستخدم العلاج', // 选择理疗用户
      'search_user_hint': 'أدخل الاسم أو رقم الهاتف', // 输入用户姓名或手机号
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
      'therapy_completed': 'اكتمل العلاج', // 治疗完成
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
      'redlight_strength_required':
          'لا يمكن أن تكون شدة الضوء الأحمر 660nm و850nm صفرًا معًا', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required':
          'لا يمكن أن يكون تردد وشدة PEMF صفرًا', // PEMF频率和强度都不能为0
      'vat_params_required':
          'لا يمكن أن يكون تردد وشدة VAT صفرًا', // VAT频率和强度都不能为0
      'hydrogen_concentration_required':
          'لا يمكن أن يكون تركيز H₂ صفرًا', // 分子氢浓度不能为0
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
      'chakra_power': 'Leist.', // 强度
      'running': 'Läuft', // 正在运行
      'waiting': 'Warten', // 等待运行
      'logout': 'Abmelden', // 退出登录
      'parameter_settings': 'Parameter', // 参数设置
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
          'Therapiedaten konnten nicht geladen werden', // 理疗记录加载失败
      'no_history_records': 'Keine Verlaufsdaten', // 暂无历史记录
      'no_therapy_records': 'Keine Therapiedaten', // 暂无理疗记录
      'years_old_unit': 'J', // 岁
      'therapy_report': 'Therapiebericht', // 理疗报告
      'total_therapy_duration': 'Gesamtdauer', // 总治疗时长
      'feedback_label': 'Empfinden: ', // 感受：
      'no_feedback': 'Kein Feedback', // 暂无反馈
      'treatment_modules': 'Therapiemodule', // 治疗模块
      'energy_score': 'Energie', // 能量指数
      'cell_score': 'Zellaktivierung', // 细胞活化
      'relaxation_score': 'Entspannung', // 放松指数
      'immune_score': 'Immunstärkung', // 免疫提升
      'compared_to_last': 'Im Vergleich zur letzten', // 较上次
      'session_once_1': '1.', // 1次
      'session_once_2': '2.', // 2次
      'session_once_3': '3.', // 3次
      'current_session': 'Aktuell', // 本次
      'health_effect_assessment': 'Gesundheitsbewertung', // 健康效果评估
      'status_good': 'Gut', // 良好
      'overall_score': 'Gesamtpunktzahl', // 综合得分
      'level_low': 'Niedrig', // 低
      'level_medium': 'Mittel', // 中
      'level_high': 'Hoch', // 高
      'therapy_feedback_hint':
          'Empfinden und Körperreaktion dieser Sitzung eingeben', // 请输入本次疗程的感受、身体反应等
      'score_unit': 'Pkt', // 分
      'minutes_unit': 'min', // 分
      'seconds_unit': 's', // 秒
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
      'choose_therapy_user': 'Therapiebenutzer auswählen', // 选择理疗用户
      'search_user_hint': 'Name oder Telefonnummer eingeben', // 输入用户姓名或手机号
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
      'therapy_completed': 'Therapie abgeschlossen', // 治疗完成
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
      'redlight_strength_required':
          'Rotlicht 660nm und 850nm dürfen nicht beide 0 sein', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required':
          'PEMF-Frequenz und Intensität dürfen nicht 0 sein', // PEMF频率和强度都不能为0
      'vat_params_required':
          'VAT-Frequenz und Intensität dürfen nicht 0 sein', // VAT频率和强度都不能为0
      'hydrogen_concentration_required':
          'H₂-Konzentration darf nicht 0 sein', // 分子氢浓度不能为0
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
      'chakra_power': 'Güç', // 强度
      'running': 'Çalışıyor', // 正在运行
      'waiting': 'Bekliyor', // 等待运行
      'logout': 'Çıkış yap', // 退出登录
      'parameter_settings': 'Parametre Ayarları', // 参数设置
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
      'therapy_record_load_failed': 'Terapi kayıtları yüklenemedi', // 理疗记录加载失败
      'no_history_records': 'Geçmiş kaydı yok', // 暂无历史记录
      'no_therapy_records': 'Terapi kaydı yok', // 暂无理疗记录
      'years_old_unit': 'y', // 岁
      'therapy_report': 'Terapi Raporu', // 理疗报告
      'total_therapy_duration': 'Toplam Süre', // 总治疗时长
      'feedback_label': 'His: ', // 感受：
      'no_feedback': 'Geri bildirim yok', // 暂无反馈
      'treatment_modules': 'Terapi Modülleri', // 治疗模块
      'energy_score': 'Enerji', // 能量指数
      'cell_score': 'Hücre Aktivasyonu', // 细胞活化
      'relaxation_score': 'Rahatlama', // 放松指数
      'immune_score': 'Bağışıklık', // 免疫提升
      'compared_to_last': 'Öncekine göre', // 较上次
      'session_once_1': '1.', // 1次
      'session_once_2': '2.', // 2次
      'session_once_3': '3.', // 3次
      'current_session': 'Güncel', // 本次
      'health_effect_assessment': 'Sağlık Etkisi Değerlendirmesi', // 健康效果评估
      'status_good': 'İyi', // 良好
      'overall_score': 'Genel Puan', // 综合得分
      'level_low': 'Düşük', // 低
      'level_medium': 'Orta', // 中
      'level_high': 'Yüksek', // 高
      'therapy_feedback_hint':
          'Bu seans için hislerinizi ve vücut tepkisini girin', // 请输入本次疗程的感受、身体反应等
      'score_unit': 'puan', // 分
      'minutes_unit': 'dk', // 分
      'seconds_unit': 'sn', // 秒
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
      'choose_therapy_user': 'Terapi Kullanıcısı Seç', // 选择理疗用户
      'search_user_hint': 'Ad veya telefon girin', // 输入用户姓名或手机号
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
      'therapy_completed': 'Terapi Tamamlandı', // 治疗完成
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
      'redlight_strength_required':
          'Kırmızı ışık 660nm ve 850nm yoğunluğu aynı anda 0 olamaz', // 红光660nm和850nm强度不能同时为0
      'pemf_params_required':
          'PEMF frekansı ve yoğunluğu 0 olamaz', // PEMF频率和强度都不能为0
      'vat_params_required':
          'VAT frekansı ve yoğunluğu 0 olamaz', // VAT频率和强度都不能为0
      'hydrogen_concentration_required':
          'H₂ konsantrasyonu 0 olamaz', // 分子氢浓度不能为0
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
