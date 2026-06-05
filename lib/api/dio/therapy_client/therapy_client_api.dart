import 'package:infibo_app/api/dio/api/api_client.dart';
import 'package:infibo_app/api/dio/api/api_response.dart';
import 'package:infibo_app/api/dio/therapy_client/therapy_client_models.dart';

class TherapyClientApi {
  Future<ApiResponse<List<TherapyClientDto>>> list({required int ownerUserId}) {
    return ApiClient.instance.get<List<TherapyClientDto>>(
      '/therapy/client/list',
      headers: _ownerHeaders(ownerUserId),
      fromJsonT: (Object? json) {
        final List<dynamic> items = json as List<dynamic>? ?? <dynamic>[];
        return items
            .map(
              (dynamic item) =>
                  TherapyClientDto.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      },
    );
  }

  Future<ApiResponse<TherapyClientDto>> create({
    required int ownerUserId,
    required TherapyClientRequestDto request,
  }) {
    return ApiClient.instance.post<TherapyClientDto>(
      '/therapy/client',
      headers: _ownerHeaders(ownerUserId),
      data: request.toJson(),
      fromJsonT: (Object? json) {
        return TherapyClientDto.fromJson(Map<String, dynamic>.from(json as Map));
      },
    );
  }

  Future<ApiResponse<void>> delete({
    required int ownerUserId,
    required int clientId,
  }) {
    return ApiClient.instance.delete<void>(
      '/therapy/client/$clientId',
      headers: _ownerHeaders(ownerUserId),
    );
  }

  Map<String, Object?> _ownerHeaders(int ownerUserId) {
    return <String, Object?>{'X-User-Id': ownerUserId};
  }
}
