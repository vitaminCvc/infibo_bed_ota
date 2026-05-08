// App 图片资源路径集中管理。
//
// 约定：
// - 这里只放图片路径，不放业务逻辑。
// - 每个常量上方都写清楚图片用途和所在页面，方便改素材时快速定位。
// - 资源目录统一使用英文命名，避免 Android / Windows 调试时中文路径造成排查困难。
class Assets {
  // 登录页：品牌 Logo。
  static const String logo = "assets/Loginimages/logo.png";

  // 登录页：输入框毛玻璃背景。
  static const String glassLogo = "assets/Loginimages/glass.png";

  // 登录页：手机号输入框左侧图标。
  static const String phoneLogo = "assets/Loginimages/phone.png";

  // 登录页：密码输入框左侧图标。
  static const String passwordLogo = "assets/Loginimages/password.png";

  // 主页：中间人体主视觉图片。
  static const String mainBodyLogo = "assets/Mainimages/body.png";

  // 主页 / 公共页头：顶部品牌 Logo。
  static const String mainLogo = "assets/Mainimages/mainlogo.png";

  // 公共页头：顶部添加按钮图片。
  static const String addLogo = "assets/Mainimages/add.png";

  // 公共页头：管理员入口按钮图片。
  static const String adminMainLogo = "assets/Mainimages/admin.png";

  // 主页：底部氛围灯关闭状态按钮。
  static const String lightCloseLogo = "assets/Mainimages/lightclose.png";

  // 主页：底部氛围灯开启状态按钮。
  static const String lightOpenLogo = "assets/Mainimages/lighton.png";

  // 公共页头：设置按钮图片。
  static const String settingLogo = "assets/Mainimages/setting.png";

  // 主页：右下角升降杆控制盘背景。
  static const String liftControlLogo =
      "assets/Mainimages/atmosphere_default.png";

  // 主页模式卡：深度放松模式卡片底图。
  static const String deepRelaxLogo = "assets/Mode/DeepRelaxation.png";

  // 主页模式卡：能量提升模式卡片底图。
  static const String energyBoostLogo = "assets/Mode/EnergyBoost.png";

  // 主页模式卡：疼痛缓解模式卡片底图。
  static const String painReliefLogo = "assets/Mode/PainRelief.png";

  // 主页模式卡：睡眠改善模式卡片底图。
  static const String sleepEnhancementLogo = "assets/Mode/SleepEnhancement.png";

  // 主页模式卡：运动恢复模式卡片底图。
  static const String sportsRehabilitationLogo =
      "assets/Mode/SportsRehabilitation.png";

  // 主页模式卡：压力释放模式卡片底图。
  static const String stressReliefLogo = "assets/Mode/StressRelief.png";

  // 主页模式卡：免疫增强模式卡片底图。
  static const String immuneBoostLogo = "assets/Mode/ImmuneBoost.png";

  // 主页模式卡：抗衰老模式卡片底图。
  static const String antiAgingLogo = "assets/Mode/AntiAging.png";

  // 主页模式卡：全面养护模式卡片底图。
  static const String fullCareLogo = "assets/Mode/FullCare.png";

  // 主页模式卡：情绪疗愈模式卡片底图。
  static const String mentalHealingLogo = "assets/Mode/EmotonnalHealing.png";

  // 选择用户 / 自定义方案列表：搜索框背景。
  static const String choseUserSearchBg = "assets/Choseusers/searchBox.png";

  // 选择用户 / 自定义方案列表：搜索图标。
  static const String choseUserSearchIcon = "assets/Choseusers/search.png";

  // 选择用户 / 自定义方案列表：用户或方案卡片背景。
  static const String choseUserItemBg = "assets/Choseusers/usersBox.png";

  // 选择用户：头像外框。
  static const String choseUserAvatarFrame =
      "assets/Choseusers/AvatarFrame.png";

  // 选择用户：性别年龄信息标签背景。
  static const String choseUserInfoBg = "assets/Choseusers/informationBox.png";

  // 启动治疗页：人体主视觉图片。
  static const String startBodyLogo = "assets/Start/startBody.png";

  // 启动治疗页：红光功能参数面板背景。
  static const String startRedLightPanel =
      "assets/Start/Function/redLightpage.png";

  // 启动治疗页：PEMF 功能参数面板背景。
  static const String startPemfPanel = "assets/Start/Function/PEMFpage.png";

  // 启动治疗页：VAT 功能参数面板背景。
  static const String startVatPanel = "assets/Start/Function/VATpage.png";

  // 启动治疗页：分子氢功能参数面板背景。
  static const String startHydrogenPanel =
      "assets/Start/Function/hydrogenpage.png";

  // 启动治疗页：拓展功能参数面板背景。
  static const String startExpandPanel = "assets/Start/Function/expandpage.png";

  // 启动治疗页：倒计时圆环背景。
  static const String startTimerRing = "assets/Start/Countdown/countdown.png";

  // 启动治疗页：倒计时进度条。
  static const String startTimerProgress =
      "assets/Start/Countdown/ProgressBar.png";

  // 启动治疗页：倒计时进度点。
  static const String startTimerDot =
      "assets/Start/Countdown/countdownPoint.png";

  // 启动治疗页：开始按钮默认状态。
  static const String startPlayButton = "assets/Start/Switch/Start.png";

  // 启动治疗页：开始按钮按下状态。
  static const String startPlayActiveButton =
      "assets/Start/Switch/startClick.png";

  // 启动治疗页：停止按钮默认状态。
  static const String startPauseButton = "assets/Start/Switch/stop.png";

  // 启动治疗页：停止按钮按下状态。
  static const String startPauseActiveButton =
      "assets/Start/Switch/stopClick.png";

  // 启动治疗页：红光效果示意图。
  static const String startRedLightWave = "assets/Start/Expand/redlight.png";

  // 启动治疗页：PEMF 波形效果示意图。
  static const String startPemfWave = "assets/Start/Expand/PEMF.png";

  // 启动治疗页：VAT 波形效果示意图。
  static const String startVatWave = "assets/Start/Expand/VAT.png";

  // 启动治疗页：分子氢效果示意图。
  static const String startHydrogenMolecule =
      "assets/Start/Expand/hydrogen.png";

  // 启动治疗页：拓展功能连续模式图标。
  static const String startExpandContinuous =
      "assets/Start/Expand/continuous.png";

  // 启动治疗页：拓展功能正弦波图标。
  static const String startExpandSine = "assets/Start/Expand/sine.png";

  // 自定义红光 / 启动页：脉冲模式曲线图。
  static const String redLightPulseWave = "assets/10个波形图/脉冲.png";

  // 启动治疗页：红光未启动状态图标。
  static const String startRedLightIconOff = "assets/Start/icon/redlight.png";

  // 启动治疗页：红光启动状态图标。
  static const String startRedLightIconOn =
      "assets/Start/icon/redlightStart.png";

  // 启动治疗页：PEMF 未启动状态图标。
  static const String startPemfIconOff = "assets/Start/icon/PEMF.png";

  // 启动治疗页：PEMF 启动状态图标。
  static const String startPemfIconOn = "assets/Start/icon/PEMFStart.png";

  // 启动治疗页：VAT 未启动状态图标。
  static const String startVatIconOff = "assets/Start/icon/VAT.png";

  // 启动治疗页：VAT 启动状态图标。
  static const String startVatIconOn = "assets/Start/icon/VATStart.png";

  // 启动治疗页：分子氢未启动状态图标。
  static const String startHydrogenIconOff = "assets/Start/icon/hydrogen.png";

  // 启动治疗页：分子氢启动状态图标。
  static const String startHydrogenIconOn =
      "assets/Start/icon/hydrogenStart.png";

  // 启动治疗页：脉轮拓展未启动状态图标。
  static const String startExpandIconOff = "assets/Start/icon/Chakras.png";

  // 启动治疗页：脉轮拓展启动状态图标。
  static const String startExpandIconOn = "assets/Start/icon/ChakrasStart.png";

  // 启动治疗页：太赫兹未启动状态图标。
  static const String startTerahertzIconOff = "assets/Start/icon/Terahertz.png";

  // 启动治疗页：太赫兹启动状态图标。
  static const String startTerahertzIconOn =
      "assets/Start/icon/TerahertzStart.png";

  // 启动治疗页：HIFEM 未启动状态图标。
  static const String startHifemIconOff = "assets/Start/icon/hifem.png";

  // 启动治疗页：HIFEM 启动状态图标。
  static const String startHifemIconOn = "assets/Start/icon/hifemStart.png";

  // 启动治疗页：香氛未启动状态图标。
  static const String startFragranceIconOff = "assets/Start/icon/Fragrance.png";

  // 启动治疗页：香氛启动状态图标。
  static const String startFragranceIconOn =
      "assets/Start/icon/FragranceStart.png";

  // 自定义方案列表：左滑删除按钮图标。
  static const String customizedDeleteIcon = "assets/customized/delete.png";

  // 自定义方案编辑页：拓展功能模块未选中图标。
  static const String expandIconOff = "assets/customized/expandno.png";

  // 自定义方案编辑页：拓展功能模块选中图标。
  static const String expandIcon = "assets/customized/expand.png";

  // 自定义方案编辑页：红光模块选中加号图标。
  static const String redLightAddIcon = "assets/customized/redLightAdd.png";

  // 自定义方案编辑页：PEMF 模块选中加号图标。
  static const String pemfAddIcon = "assets/customized/pemfAdd.png";

  // 自定义方案编辑页：VAT 模块选中加号图标。
  static const String vatAddIcon = "assets/customized/vatAdd.png";

  // 自定义方案编辑页：分子氢模块选中加号图标。
  static const String hydrogenAddIcon = "assets/customized/hydrogenAdd.png";

  // 自定义方案编辑页：拓展功能模块选中加号图标。
  static const String expandAddIcon = "assets/customized/expandAdd.png";

  // 自定义方案列表：添加方案按钮图标。
  static const String customizedSchemeIcon = "assets/customized/Scheme.png";

  // 自定义方案编辑页：中间人体主视觉图片。
  static const String customizedBody = "assets/customized/customizedBody.png";

  // 自定义方案编辑页：时间轴图片。
  static const String customizedTimeline = "assets/customized/timeline.png";

  // 自定义方案编辑页：保存方案按钮不可点击背景。
  static const String customizedSavePlanBox =
      "assets/customized/savePlanBox.png";

  // 自定义方案编辑页：默认模块图标或默认状态素材。
  static const String customizedDefault = "assets/customized/default.png";

  // 自定义方案编辑页：模式选项图标素材。
  static const String customizedModeOptionIcon =
      "assets/customized/modeOptionIcon.png";

  // 自定义方案编辑页：添加治疗模块面板背景。
  static const String addTreatmentIcon =
      "assets/customized/editor/module_panel_bg.png";

  // 自定义方案编辑页：治疗模块行默认背景。
  static const String addTreatmentRowDefault =
      "assets/customized/editor/module_rows/default_bg.png";

  // 自定义方案编辑页：红光模块行选中背景。
  static const String addTreatmentRedLight =
      "assets/customized/editor/module_rows/redlight_bg.png";

  // 自定义方案编辑页：PEMF 模块行选中背景。
  static const String addTreatmentPemf =
      "assets/customized/editor/module_rows/pemf_bg.png";

  // 自定义方案编辑页：VAT 模块行选中背景。
  static const String addTreatmentVat =
      "assets/customized/editor/module_rows/vat_bg.png";

  // 自定义方案编辑页：分子氢模块行选中背景。
  static const String addTreatmentHydrogen =
      "assets/customized/editor/module_rows/hydrogen_bg.png";

  // 自定义方案编辑页：拓展功能模块行选中背景。
  static const String addTreatmentExpand =
      "assets/customized/editor/module_rows/expand_bg.png";

  // 自定义方案编辑页：红光右侧参数面板背景。
  static const String customizedRedLightPanelBg =
      "assets/customized/editor/panels/redlight_panel_bg.png";

  // 自定义方案编辑页：PEMF 右侧参数面板背景。
  static const String customizedPemfPanelBg =
      "assets/customized/editor/panels/pemf_panel_bg.png";

  // 自定义方案编辑页：VAT 右侧参数面板背景。
  static const String customizedVatPanelBg =
      "assets/customized/editor/panels/vat_panel_bg.png";

  // 自定义方案编辑页：分子氢右侧参数面板背景。
  static const String customizedHydrogenPanelBg =
      "assets/customized/editor/panels/hydrogen_panel_bg.png";

  // 自定义方案编辑页：拓展功能参数面板背景。
  static const String customizedExpandPanelBg =
      "assets/customized/editor/panels/expand_panel_bg.png";

  // 自定义方案编辑页：拓展功能未选中右箭头图标。
  static const String customizedExpandChevronDefault =
      "assets/customized/editor/expand_icons/chevron_default.png";

  // 自定义方案编辑页：拓展功能已选中勾选图标。
  static const String customizedExpandCheckSelected =
      "assets/customized/editor/expand_icons/check_selected.png";

  // 自定义方案编辑页：脉轮拓展默认图标。
  static const String customizedExpandChakraDefault =
      "assets/customized/editor/expand_icons/chakra_default.png";

  // 自定义方案编辑页：脉轮拓展选中图标。
  static const String customizedExpandChakraSelected =
      "assets/customized/editor/expand_icons/chakra_selected.png";

  // 自定义方案编辑页：太赫兹拓展默认图标。
  static const String customizedExpandTerahertzDefault =
      "assets/customized/editor/expand_icons/terahertz_default.png";

  // 自定义方案编辑页：太赫兹拓展选中图标。
  static const String customizedExpandTerahertzSelected =
      "assets/customized/editor/expand_icons/terahertz_selected.png";

  // 自定义方案编辑页：HIFEM 拓展默认图标。
  static const String customizedExpandHifemDefault =
      "assets/customized/editor/expand_icons/hifem_default.png";

  // 自定义方案编辑页：HIFEM 拓展选中图标。
  static const String customizedExpandHifemSelected =
      "assets/customized/editor/expand_icons/hifem_selected.png";

  // 自定义方案编辑页：香氛拓展默认图标。
  static const String customizedExpandFragranceDefault =
      "assets/customized/editor/expand_icons/fragrance_default.png";

  // 自定义方案编辑页：香氛拓展选中图标。
  static const String customizedExpandFragranceSelected =
      "assets/customized/editor/expand_icons/fragrance_selected.png";

  // 脉轮设置页：盘坐人体主视觉图片。
  static const String chakraBody = "assets/expand_settings/chakra/body.png";

  // 脉轮设置页：强度输入浮层背景。
  static const String chakraIntensityPanel =
      "assets/expand_settings/chakra/strength_panel.png";

  // 脉轮设置页：确认按钮不可点击状态背景。
  static const String chakraConfirmDisabled =
      "assets/expand_settings/chakra/confirm_disabled.png";

  // 脉轮设置页：确认按钮可点击状态背景。
  static const String chakraConfirmEnabled =
      "assets/expand_settings/chakra/confirm_enabled.png";

  // 脉轮设置页：返回按钮箭头图标。
  static const String chakraReturnIcon =
      "assets/expand_settings/common/back.png";

  // 脉轮设置页：顶轮默认图标。
  static const String chakraCrown =
      "assets/expand_settings/chakra/icons/crown_default.png";

  // 脉轮设置页：顶轮选中图标。
  static const String chakraCrownSelected =
      "assets/expand_settings/chakra/icons/crown_selected.png";

  // 脉轮设置页：眉心轮默认图标。
  static const String chakraThirdEye =
      "assets/expand_settings/chakra/icons/third_eye_default.png";

  // 脉轮设置页：眉心轮选中图标。
  static const String chakraThirdEyeSelected =
      "assets/expand_settings/chakra/icons/third_eye_selected.png";

  // 脉轮设置页：喉轮默认图标。
  static const String chakraThroat =
      "assets/expand_settings/chakra/icons/throat_default.png";

  // 脉轮设置页：喉轮选中图标。
  static const String chakraThroatSelected =
      "assets/expand_settings/chakra/icons/throat_selected.png";

  // 脉轮设置页：心轮默认图标。
  static const String chakraHeart =
      "assets/expand_settings/chakra/icons/heart_default.png";

  // 脉轮设置页：心轮选中图标。
  static const String chakraHeartSelected =
      "assets/expand_settings/chakra/icons/heart_selected.png";

  // 脉轮设置页：太阳神经丛默认图标。
  static const String chakraSolarPlexus =
      "assets/expand_settings/chakra/icons/solar_plexus_default.png";

  // 脉轮设置页：太阳神经丛选中图标。
  static const String chakraSolarPlexusSelected =
      "assets/expand_settings/chakra/icons/solar_plexus_selected.png";

  // 脉轮设置页：脐轮默认图标。
  static const String chakraSacral =
      "assets/expand_settings/chakra/icons/sacral_default.png";

  // 脉轮设置页：脐轮选中图标。
  static const String chakraSacralSelected =
      "assets/expand_settings/chakra/icons/sacral_selected.png";

  // 脉轮设置页：海底轮默认图标。
  static const String chakraRoot =
      "assets/expand_settings/chakra/icons/root_default.png";

  // 脉轮设置页：海底轮选中图标。
  static const String chakraRootSelected =
      "assets/expand_settings/chakra/icons/root_selected.png";

  // 香氛设置页：整页默认状态设计图。
  static const String fragrancePageDefault =
      "assets/expand_settings/fragrance/page_default.jpg";

  // 香氛设置页：整页选中状态设计图。
  static const String fragrancePageSelected =
      "assets/expand_settings/fragrance/page_selected.jpg";

  // 香氛设置页：香氛设备主视觉图片。
  static const String fragranceDiffuser =
      "assets/expand_settings/fragrance/diffuser.png";

  // 香氛设置页：底部香型选择面板背景。
  static const String fragranceChoicePanel =
      "assets/expand_settings/fragrance/choice_panel.png";

  // 香氛设置页：香型图标底部横线。
  static const String fragranceChoiceLine =
      "assets/expand_settings/fragrance/choice_line.png";

  // 香氛设置页：确认按钮不可点击状态背景。
  static const String fragranceConfirmDisabled =
      "assets/expand_settings/fragrance/confirm_disabled.png";

  // 香氛设置页：确认按钮可点击状态背景。
  static const String fragranceConfirmEnabled =
      "assets/expand_settings/fragrance/confirm_enabled.png";

  // 香氛设置页：轻柔香型默认图标。
  static const String fragranceSoftDefault =
      "assets/expand_settings/fragrance/icons/soft_default.png";

  // 香氛设置页：轻柔香型选中图标。
  static const String fragranceSoftSelected =
      "assets/expand_settings/fragrance/icons/soft_selected.png";

  // 香氛设置页：浓烈香型默认图标。
  static const String fragranceStrongDefault =
      "assets/expand_settings/fragrance/icons/strong_default.png";

  // 香氛设置页：浓烈香型选中图标。
  static const String fragranceStrongSelected =
      "assets/expand_settings/fragrance/icons/strong_selected.png";

  // 香氛设置页：睡眠香型默认图标。
  static const String fragranceSleepDefault =
      "assets/expand_settings/fragrance/icons/sleep_default.png";

  // 香氛设置页：睡眠香型选中图标。
  static const String fragranceSleepSelected =
      "assets/expand_settings/fragrance/icons/sleep_selected.png";

  // 香氛设置页：心流香型默认图标。
  static const String fragranceFlowDefault =
      "assets/expand_settings/fragrance/icons/flow_default.png";

  // 香氛设置页：心流香型选中图标。
  static const String fragranceFlowSelected =
      "assets/expand_settings/fragrance/icons/flow_selected.png";

  // 香氛设置页：冥想香型默认图标。
  static const String fragranceMeditationDefault =
      "assets/expand_settings/fragrance/icons/meditation_default.png";

  // 香氛设置页：冥想香型选中图标。
  static const String fragranceMeditationSelected =
      "assets/expand_settings/fragrance/icons/meditation_selected.png";

  // 太赫兹设置页：整页默认状态设计图。
  static const String terahertzPageDefault =
      "assets/expand_settings/terahertz/page_default.jpg";

  // 太赫兹设置页：整页选中状态设计图。
  static const String terahertzPageSelected =
      "assets/expand_settings/terahertz/page_selected.jpg";

  // 太赫兹设置页：太赫兹圆环主视觉图片。
  static const String terahertzBody =
      "assets/expand_settings/terahertz/body.png";

  // 太赫兹设置页：确认按钮不可点击状态背景。
  static const String terahertzConfirmDisabled =
      "assets/expand_settings/terahertz/confirm_disabled.png";

  // 太赫兹设置页：确认按钮可点击状态背景。
  static const String terahertzConfirmEnabled =
      "assets/expand_settings/terahertz/confirm_enabled.png";

  // 太赫兹设置页：模式/波形单选按钮默认状态。
  static const String terahertzRadioDefault =
      "assets/expand_settings/terahertz/radio_default.png";

  // 太赫兹设置页：模式/波形单选按钮选中状态。
  static const String terahertzRadioSelected =
      "assets/expand_settings/terahertz/radio_selected.png";

  // 太赫兹设置页：进度条默认轨道。
  static const String terahertzProgressDefaultBar =
      "assets/expand_settings/terahertz/progress/default_bar.png";

  // 太赫兹设置页：进度条默认圆点。
  static const String terahertzProgressDefaultThumb =
      "assets/expand_settings/terahertz/progress/default_thumb.png";

  // 太赫兹设置页：频率进度条轨道。
  static const String terahertzFrequencyBar =
      "assets/expand_settings/terahertz/progress/frequency_bar.png";

  // 太赫兹设置页：频率进度条圆点。
  static const String terahertzFrequencyThumb =
      "assets/expand_settings/terahertz/progress/frequency_thumb.png";

  // 太赫兹设置页：功率进度条轨道。
  static const String terahertzPowerBar =
      "assets/expand_settings/terahertz/progress/power_bar.png";

  // 太赫兹设置页：功率进度条圆点。
  static const String terahertzPowerThumb =
      "assets/expand_settings/terahertz/progress/power_thumb.png";

  // 太赫兹设置页：时间进度条轨道。
  static const String terahertzTimeBar =
      "assets/expand_settings/terahertz/progress/time_bar.png";

  // 太赫兹设置页：时间进度条圆点。
  static const String terahertzTimeThumb =
      "assets/expand_settings/terahertz/progress/time_thumb.png";

  // HIFEM 设置页：整页默认状态设计图。
  static const String hifemPageDefault =
      "assets/expand_settings/hifem/page_default.jpg";

  // HIFEM 设置页：整页选中状态设计图。
  static const String hifemPageSelected =
      "assets/expand_settings/hifem/page_selected.jpg";

  // HIFEM 设置页：确认按钮背景。
  static const String hifemConfirmButton =
      "assets/expand_settings/hifem/confirm_button.png";

  // HIFEM 设置页：人头基础主视觉。
  static const String hifemHeadBase =
      "assets/expand_settings/hifem/head/base.png";

  // HIFEM 设置页：左额头默认贴片。
  static const String hifemForeheadLeftDefault =
      "assets/expand_settings/hifem/head/forehead_left_default.png";

  // HIFEM 设置页：左额头选中贴片。
  static const String hifemForeheadLeftSelected =
      "assets/expand_settings/hifem/head/forehead_left_selected.png";

  // HIFEM 设置页：右额头默认贴片。
  static const String hifemForeheadRightDefault =
      "assets/expand_settings/hifem/head/forehead_right_default.png";

  // HIFEM 设置页：右额头选中贴片。
  static const String hifemForeheadRightSelected =
      "assets/expand_settings/hifem/head/forehead_right_selected.png";

  // HIFEM 设置页：左脸颊默认贴片。
  static const String hifemCheekLeftDefault =
      "assets/expand_settings/hifem/head/cheek_left_default.png";

  // HIFEM 设置页：左脸颊选中贴片。
  static const String hifemCheekLeftSelected =
      "assets/expand_settings/hifem/head/cheek_left_selected.png";

  // HIFEM 设置页：右脸颊默认贴片。
  static const String hifemCheekRightDefault =
      "assets/expand_settings/hifem/head/cheek_right_default.png";

  // HIFEM 设置页：右脸颊选中贴片。
  static const String hifemCheekRightSelected =
      "assets/expand_settings/hifem/head/cheek_right_selected.png";

  // HIFEM 设置页：射频默认状态图标。
  static const String hifemRfIcon = "assets/expand_settings/hifem/icons/rf.png";

  // HIFEM 设置页：射频禁用状态图标。
  static const String hifemRfDisabledIcon =
      "assets/expand_settings/hifem/icons/rf_disabled.png";

  // HIFEM 设置页：HIFES 默认状态图标。
  static const String hifemHifesIcon =
      "assets/expand_settings/hifem/icons/hifes.png";

  // HIFEM 设置页：HIFES 禁用状态图标。
  static const String hifemHifesDisabledIcon =
      "assets/expand_settings/hifem/icons/hifes_disabled.png";

  // HIFEM 设置页：时间默认状态图标。
  static const String hifemTimeIcon =
      "assets/expand_settings/hifem/icons/time.png";

  // HIFEM 设置页：时间禁用状态图标。
  static const String hifemTimeDisabledIcon =
      "assets/expand_settings/hifem/icons/time_disabled.png";

  // HIFEM 设置页：进度条默认轨道。
  static const String hifemProgressDefaultBar =
      "assets/expand_settings/hifem/progress/default_bar.png";

  // HIFEM 设置页：进度条默认圆点。
  static const String hifemProgressDefaultThumb =
      "assets/expand_settings/hifem/progress/default_thumb.png";

  // HIFEM 设置页：射频进度条轨道。
  static const String hifemRfBar =
      "assets/expand_settings/hifem/progress/rf_bar.png";

  // HIFEM 设置页：射频进度条圆点。
  static const String hifemRfThumb =
      "assets/expand_settings/hifem/progress/rf_thumb.png";

  // HIFEM 设置页：HIFES 进度条轨道。
  static const String hifemHifesBar =
      "assets/expand_settings/hifem/progress/hifes_bar.png";

  // HIFEM 设置页：HIFES 进度条圆点。
  static const String hifemHifesThumb =
      "assets/expand_settings/hifem/progress/hifes_thumb.png";

  // HIFEM 设置页：时间进度条轨道。
  static const String hifemTimeBar =
      "assets/expand_settings/hifem/progress/time_bar.png";

  // HIFEM 设置页：时间进度条圆点。
  static const String hifemTimeThumb =
      "assets/expand_settings/hifem/progress/time_thumb.png";
}
