// API 聚合入口。
//
// 原本用于统一导出网络请求接口；当前项目主要是本地页面和串口通信，
// 所以这个文件暂时没有实际导出内容。后续如果新增 HTTP 接口，可以从这里统一 export。
class ApiResponse<T> {
  const ApiResponse({required this.code, required this.message, this.data});

  final int code;
  final String message;
  final T? data;

  bool get isSuccess => code == 200;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Object? json)? fromJsonT,
  }) {
    return ApiResponse<T>(
      //将后端返回的json转换为dart对象
      code: json['code'] is int ? json['code'] as int : -1,
      message: json['message']?.toString() ?? '',
      data: fromJsonT == null ? null : fromJsonT(json['data']),
    );
  }
}
