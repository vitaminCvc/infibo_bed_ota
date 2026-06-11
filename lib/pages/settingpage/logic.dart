// 设置页逻辑文件。

import 'package:infibo_app/api/dio/api/api_response.dart';
import 'package:infibo_app/api/dio/therapy_report/therapy_report_api.dart';
import 'package:infibo_app/api/dio/therapy_report/therapy_report_models.dart';
import 'package:infibo_app/stores/user_store.dart';

//创建治疗记录报告用户仓库接口
abstract class HistoryRecordRepository {
  //获取治疗记录报告用户列表
  Future<HistoryReportUserPageDto> historyUsers({
    required int ownerUserId,
    required int page,
    required int pageSize,
    required String keyword,
  });

  //删除治疗记录报告用户
  Future<void> deleteHistoryUser({
    required int ownerUserId,
    required int clientId,
  });
}

//实现治疗记录报告用户仓库接口(真正调用后端接口)
class BackendHistoryRecordRepository implements HistoryRecordRepository {
  BackendHistoryRecordRepository({TherapyReportApi? api})
    : _api = api ?? TherapyReportApi();

  final TherapyReportApi _api;

  @override
  Future<HistoryReportUserPageDto> historyUsers({
    required int ownerUserId,
    required int page,
    required int pageSize,
    required String keyword,
  }) async {
    final ApiResponse<HistoryReportUserPageDto> response = await _api
        .historyUsers(
          ownerUserId: ownerUserId,
          page: page,
          pageSize: pageSize,
          keyword: keyword,
        );

    if (!response.isSuccess || response.data == null) {
      throw HistoryRecordException(response.message);
    }

    return response.data!;
  }

  @override
  Future<void> deleteHistoryUser({
    required int ownerUserId,
    required int clientId,
  }) async {
    final ApiResponse<void> response = await _api.deleteHistoryUser(
      ownerUserId: ownerUserId,
      clientId: clientId,
    );

    if (!response.isSuccess) {
      throw HistoryRecordException(response.message);
    }
  }
}

class HistoryRecordLogic {
  HistoryRecordLogic({
    HistoryRecordRepository? repository,
    int pageSize = 10,
    int? ownerUserId,
  }) : _repository = repository ?? BackendHistoryRecordRepository(),
       _pageSize = pageSize,
       _ownerUserId = ownerUserId;

  final HistoryRecordRepository _repository;
  final int _pageSize;
  final int? _ownerUserId;

  final List<HistoryReportUserItemDto> users = [];

  int _page = 0;
  String keyword = '';
  bool isLoading = false;
  bool hasMore = true;

  int get page => _page;
  int get pageSize => _pageSize;

  Future<void> init() async {
    await refresh();
  }

  Future<void> refresh({String keyword = ''}) async {
    this.keyword = keyword.trim();
    _page = 0;
    hasMore = true;
    users.clear();
    await loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    try {
      final int nextPage = _page + 1;
      final HistoryReportUserPageDto result = await _repository.historyUsers(
        ownerUserId: _currentOwnerUserId(),
        page: nextPage,
        pageSize: _pageSize,
        keyword: keyword,
      );

      users.addAll(result.items);
      _page = result.page;
      hasMore = result.hasMore;
    } finally {
      isLoading = false;
    }
  }

  Future<void> deleteUserReports(int clientId) async {
    await _repository.deleteHistoryUser(
      ownerUserId: _currentOwnerUserId(),
      clientId: clientId,
    );

    users.removeWhere((user) => user.clientId == clientId);
  }

  int _currentOwnerUserId() {
    final int? userId = _ownerUserId ?? UserStore.instance.userId;
    if (userId == null) {
      throw const HistoryRecordException('current user is not logged in');
    }
    return userId;
  }
}

class HistoryRecordException implements Exception {
  const HistoryRecordException(this.message);

  final String message;

  @override
  String toString() => message;
}
