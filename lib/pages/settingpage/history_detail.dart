import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/utils/gender_utils.dart';
import 'package:infibo_app/api/dio/api/api_response.dart';
import 'package:infibo_app/api/dio/therapy_report/therapy_report_api.dart';
import 'package:infibo_app/api/dio/therapy_report/therapy_report_models.dart';
import 'package:infibo_app/components/settingindex.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/customized/customizedPage/setting_page_helpers.dart';
import 'package:infibo_app/stores/user_store.dart';

// 历史记录详情页
class HistoryDetailPage extends StatefulWidget {
  const HistoryDetailPage({super.key});

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  static const int _pageSize = 5;

  //====================历史记录详情页字号统一配置====================//
  // 顶部用户姓名字号
  static const double _userNameFontSize = 20;

  // 顶部用户性别、年龄、手机号字号
  static const double _userInfoFontSize = 14;

  // 左上角方案名称字号
  static const double _planTitleFontSize = 18;

  // 左上角方案名称粗细
  static const FontWeight _planTitleFontWeight = FontWeight.w800;

  // 左下角报告时间字号
  static const double _reportTimeFontSize = 14;

  // 中间标题“治疗模块”字号
  static const double _moduleTitleFontSize = 14;

  // 右上角标题“总治疗时长”字号
  static const double _durationTitleFontSize = 14;

  // 右下角总治疗时长数值字号
  static const double _durationValueFontSize = 18;

  // 右下角总治疗时长数值粗细
  static const FontWeight _durationValueFontWeight = FontWeight.w800;

  // 四个小功能卡片标题字号，例如：能量指数、细胞活化
  static const double _scoreTitleFontSize = 14;

  // 四个小功能卡片分数字号，例如：50分
  static const double _scoreValueFontSize = 22;

  // 四个小功能卡片分数字号中的“分”字字号
  static const double _scoreUnitFontSize = 14;

  // 底部“感受”文字字号
  static const double _feedbackFontSize = 13;

  final ScrollController _scrollController = ScrollController();
  final List<TherapyReportDetailDto> _reports = <TherapyReportDetailDto>[];
  final Set<int> _expandedFeedbackReportIds = <int>{};

  HistoryReportUserItemDto? _summary;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  int _totalReports = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final Object? args = Get.arguments;
    _summary = args is HistoryReportUserItemDto ? args : null;
    _scrollController.addListener(_handleScroll);
    _refreshReports();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshReports() async {
    // 重新进入或刷新时，从第一页重新加载该用户的理疗记录。
    _reports.clear();
    _expandedFeedbackReportIds.clear();
    _page = 1;
    _totalReports = 0;
    _hasMore = false;
    await _loadReports(page: 1, initial: true);
  }

  Future<void> _loadMoreReports() async {
    // 列表滑到底部时分页加载，避免一次性把全部报告拉下来。
    if (_isLoadingMore || _isInitialLoading || !_hasMore) return;
    await _loadReports(page: _page + 1, initial: false);
  }

  Future<void> _loadReports({required int page, required bool initial}) async {
    // 历史详情页不是查单条 lastReportId，而是用 clientId 查这个用户的全部报告。
    final HistoryReportUserItemDto? summary = _summary;
    final int? ownerUserId = UserStore.instance.userId;

    if (summary == null) {
      setState(() {
        _isInitialLoading = false;
        _errorMessage = 'history_detail_missing'.tr;
      });
      return;
    }

    if (ownerUserId == null) {
      setState(() {
        _isInitialLoading = false;
        _errorMessage = 'current_account_not_logged_in'.tr;
      });
      return;
    }

    setState(() {
      if (initial) {
        _isInitialLoading = true;
      } else {
        _isLoadingMore = true;
      }
      _errorMessage = null;
    });

    final ApiResponse<TherapyReportDetailPageDto> response =
        await TherapyReportApi().historyUserReports(
          ownerUserId: ownerUserId,
          clientId: summary.clientId,
          page: page,
          pageSize: _pageSize,
        );

    if (!mounted) return;
    setState(() {
      _isInitialLoading = false;
      _isLoadingMore = false;
      if (response.isSuccess && response.data != null) {
        final TherapyReportDetailPageDto result = response.data!;
        if (page == 1) {
          _reports
            ..clear()
            ..addAll(result.items);
        } else {
          _reports.addAll(result.items);
        }
        _page = result.page;
        _totalReports = result.total;
        _hasMore = result.hasMore;
      } else {
        _errorMessage = response.message.isEmpty
            ? 'therapy_record_load_failed'.tr
            : response.message;
      }
    });
  }

  void _handleScroll() {
    // 距离底部 120px 时提前加载下一页，让用户滚动时更顺。
    if (!_scrollController.hasClients) return;
    final ScrollPosition position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      _loadMoreReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 构建历史记录详情页
    return AppSettingHeaderPage(
      children: <Widget>[
        // 主体内容：用户信息，姓名，年龄，性别，电话；历史记录列表
        Positioned.fill(top: 115, child: _buildBody()),
        // 构建返回按钮
        Positioned(
          left: 44,
          top: 115,
          child: ExpandBackButton(onTap: () => Get.back()),
        ),
      ],
    );
  }

  Widget _buildBody() {
    final HistoryReportUserItemDto? summary = _summary;
    if (summary == null) {
      return _buildError('history_detail_missing'.tr);
    }

    if (_isInitialLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E84FF)),
      );
    }

    final String? error = _errorMessage;
    if (error != null && _reports.isEmpty) {
      return _buildError(error);
    }

    // 构建历史记录列表（包含用户信息头，记录卡片，加载更多按钮）
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(44, 0, 44, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildUserHeader(summary),
          const SizedBox(height: 25),
          if (_reports.isEmpty)
            _buildEmptyState()
          else
            for (int index = 0; index < _reports.length; index++) ...<Widget>[
              _buildReportCard(
                _reports[index],
                showComparison: _shouldShowComparison(index),
              ),
              // 卡片与卡片之间的距离
              const SizedBox(height: 20),
            ],
          // 加载更多按钮
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF2E84FF),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    // 构建错误信息提示
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.72),
          fontSize: 18,
          fontFamily: 'Microsoft YaHei',
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    // 构建暂无记录提示
    return Padding(
      padding: const EdgeInsets.only(top: 150),
      child: Center(
        child: Text(
          'no_therapy_records'.tr,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.52),
            fontSize: 16,
            fontFamily: 'Microsoft YaHei',
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(HistoryReportUserItemDto summary) {
    // 构建用户信息头
    final String gender = localizedGenderText(summary.userGender);
    return Column(
      children: <Widget>[
        Text(
          summary.userName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: _userNameFontSize,
            fontFamily: 'Microsoft YaHei',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$gender · ${summary.userAge ?? '--'}${'years_old_unit'.tr} · ${summary.userPhone}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: _userInfoFontSize,
            fontFamily: 'Microsoft YaHei',
          ),
        ),
      ],
    );
  }

  bool _shouldShowComparison(int index) {
    // 后端按时间倒序返回：最新在前，最早的那条是第一次记录。
    // 只有第一次记录不显示“较上次”，第二次及之后都显示。
    if (_totalReports <= 1) return false;
    return index < _totalReports - 1;
  }

  void _toggleFeedback(int reportId) {
    // 感受默认省略，点击后按报告 ID 展开/收起全文。
    setState(() {
      if (_expandedFeedbackReportIds.contains(reportId)) {
        _expandedFeedbackReportIds.remove(reportId);
      } else {
        _expandedFeedbackReportIds.add(reportId);
      }
    });
  }

  Widget _buildReportCard(
    TherapyReportDetailDto detail, {
    required bool showComparison,
  }) {
    // 创建历史记录卡片详细内容
    final TherapyReportDto report = detail.report;
    final bool feedbackExpanded = _expandedFeedbackReportIds.contains(
      report.reportId,
    );

    // 构建历史记录底部卡片背景
    return Container(
      width: 711,
      constraints: const BoxConstraints(minHeight: 317),
      // EdgeInsets.fromLTRB(左边距, 上边距, 右边距, 下边距)
      padding: const EdgeInsets.fromLTRB(44, 28, 44, 25),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.historyCard),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _buildInfoBlock(
                  title: report.planNameSnapshot.isEmpty
                      ? 'therapy_report'.tr
                      : report.planNameSnapshot, // 方案名称
                  value: _formatDateTime(report.reportTime),
                  titleFontSize: _planTitleFontSize,
                  valueFontSize: _reportTimeFontSize,
                  titleFontWeight: _planTitleFontWeight,
                ),
              ),
              _buildVerticalDivider(),
              Expanded(child: _buildModuleSummary(detail.modules)),
              _buildVerticalDivider(),
              Expanded(
                child: _buildInfoBlock(
                  title: 'total_therapy_duration'.tr,
                  value: _formatDuration(report.durationSeconds),
                  alignRight: true,
                  titleFontSize: _durationTitleFontSize,
                  valueFontSize: _durationValueFontSize,
                  valueFontWeight: _durationValueFontWeight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildScoreCard(
                  title: 'energy_score'.tr,
                  value: report.energyScore,
                  iconPath: Assets.energyicon,
                  showComparison: showComparison,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildScoreCard(
                  title: 'cell_score'.tr,
                  value: report.cellScore,
                  iconPath: Assets.cellicon,
                  showComparison: showComparison,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildScoreCard(
                  title: 'relaxation_score'.tr,
                  value: report.relaxScore,
                  iconPath: Assets.relaxicon,
                  showComparison: showComparison,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildScoreCard(
                  title: 'immune_score'.tr,
                  value: report.immuneScore,
                  iconPath: Assets.immuneicon,
                  showComparison: showComparison,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _toggleFeedback(report.reportId),
            child: Text(
              '${'feedback_label'.tr}${report.therapyFeedback.isEmpty ? 'no_feedback'.tr : report.therapyFeedback}',
              maxLines: feedbackExpanded ? null : 1,
              overflow: feedbackExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: _feedbackFontSize,
                fontFamily: 'Microsoft YaHei',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleSummary(List<TherapyReportModuleDto> modules) {
    // 构建治疗模块区域
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'treatment_modules'.tr,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: _moduleTitleFontSize,
            fontFamily: 'Microsoft YaHei',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: modules.isEmpty
              ? <Widget>[_buildEmptyModuleIcon()]
              : modules.take(6).map((TherapyReportModuleDto module) {
                  return _buildModuleIcon(module);
                }).toList(),
        ),
      ],
    );
  }

  Widget _buildModuleIcon(TherapyReportModuleDto module) {
    // 构建治疗模块图标，大小为 24x24
    return SizedBox(
      width: 24,
      height: 24,
      child: Image.asset(
        _moduleIconPath(module.moduleCode),
        width: 24,
        height: 24,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildEmptyModuleIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
      ),
    );
  }

  String _moduleIconPath(String code) {
    // 根据后端返回的 moduleCode 匹配对应图标
    switch (code.toLowerCase()) {
      case 'red':
      case 'redlight':
        return Assets.startRedLightIconOn;
      case 'pemf':
        return Assets.startPemfIconOn;
      case 'vat':
        return Assets.startVatIconOn;
      case 'hydrogen':
        return Assets.startHydrogenIconOn;
      case 'chakra':
      case 'chakras':
      case 'expand':
        return Assets.startExpandIconOn;
      case 'terahertz':
        return Assets.startTerahertzIconOn;
      case 'hifem':
        return Assets.startHifemIconOn;
      case 'fragrance':
        return Assets.startFragranceIconOn;
      default:
        return Assets.startExpandIconOn;
    }
  }

  Widget _buildScoreCard({
    required String title,
    required int value,
    required String iconPath,
    required bool showComparison,
  }) {
    // 四个小功能卡片
    return Container(
      height: 136,
      padding: const EdgeInsets.fromLTRB(18, 22, 22, 12),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.fuctionCard),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            // 身体指数图标和标题
            children: <Widget>[
              Image.asset(iconPath, width: 24, height: 24, fit: BoxFit.contain),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: _scoreTitleFontSize,
                    fontFamily: 'Microsoft YaHei',
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: RichText(
              text: TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: '$value',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: _scoreValueFontSize,
                      fontFamily: 'Microsoft YaHei',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: 'score_unit'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _scoreUnitFontSize,
                      fontFamily: 'Microsoft YaHei',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (showComparison)
            Center(
              child: Text(
                'compared_to_last'.tr,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.62),
                  fontSize: 14,
                  fontFamily: 'Microsoft YaHei',
                ),
              ),
            )
          else
            const SizedBox(height: 17),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 66,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white.withValues(alpha: 0.08),
    );
  }

  Widget _buildInfoBlock({
    required String title,
    required String value,
    bool alignRight = false,
    double titleFontSize = 18,
    double valueFontSize = 14,
    FontWeight titleFontWeight = FontWeight.w400,
    FontWeight valueFontWeight = FontWeight.w400,
  }) {
    // 历史记录详情页：历史记录卡片内容（方案名称、治疗时间）
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        // 方案名称标题
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.78),
            fontSize: titleFontSize,
            fontWeight: titleFontWeight,
            fontFamily: 'Microsoft YaHei',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: valueFontSize,
            fontFamily: 'Microsoft YaHei',
            fontWeight: valueFontWeight,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime time) {
    // 后端返回 DateTime，这里统一转成 2026.06.10 12:30 格式。
    String two(int value) => value.toString().padLeft(2, '0');
    return '${time.year}.${two(time.month)}.${two(time.day)} '
        '${two(time.hour)}:${two(time.minute)}';
  }

  String _formatDuration(int seconds) {
    // 总时长以后端 durationSeconds 为准，显示成“分秒”。
    final int minutes = seconds ~/ 60;
    final int remainSeconds = seconds % 60;
    if (minutes <= 0) return '$remainSeconds${'seconds_unit'.tr}';
    if (remainSeconds <= 0) return '$minutes${'minutes_unit'.tr}';
    return '$minutes${'minutes_unit'.tr}$remainSeconds${'seconds_unit'.tr}';
  }
}
