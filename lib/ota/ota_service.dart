import 'dart:convert';
import 'dart:io';
import 'ota_file_verifier.dart';
import 'package:dio/dio.dart';
import 'android_update_gateway.dart';
import 'ota_config.dart';
import 'ota_manifest.dart';

class OtaFailure implements Exception {
  const OtaFailure(this.key);
  final String key;
  @override
  String toString() => key;
}

class UpdateCheck {
  const UpdateCheck(this.installed, this.manifest);
  final InstalledApp installed;
  final OtaManifest manifest;
}

class OtaService {
  OtaService({required this.config, required this.gateway, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );
  // 初始化时检查配置是否已配置，未配置则抛出异常
  final OtaConfig config;
  final UpdateGateway gateway;
  final Dio _dio;
  bool _downloading = false;
  Future<UpdateCheck> check() async {
    // 检查配置是否已配置，未配置则抛出异常
    if (!config.configured) throw const OtaFailure('ota_not_configured');
    final installed = await gateway.installedApp();
    try {
      final response = await _dio.get<String>(
        config.uri.toString(),
        options: Options(
          responseType: ResponseType.plain,
          followRedirects: false,
          validateStatus: (status) => status == 200,
        ),
      );
      final text = response.data;
      // 检查响应是否为空或者大小是否超过256kb
      // 超过256kb则抛出异常
      if (text == null || utf8.encode(text).length > 256 * 1024) {
        throw const FormatException('Manifest too large');
      }
      return UpdateCheck(
        installed,
        OtaManifest.parse(
          jsonDecode(text),
          channel: config.channel,
          packageName: installed.packageName,
          allowHttp: config.allowHttp,
        ),
      );
    } on FormatException {
      throw const OtaFailure('ota_invalid_manifest');
    } on DioException {
      throw const OtaFailure('ota_network_error');
    }
  }

  //  验证文件是否已下载完成，大小和 sha256 校验是否通过
  Future<bool> verified(File file, OtaFile release) => verifyOtaFile(
    path: file.path,
    size: release.size,
    expectedSha256: release.sha256,
  );

  // 下载文件，返回下载完成后的文件路径
  Future<File> download(
    OtaFile release, {
    CancelToken? cancelToken,
    void Function(double)? onProgress,
  }) async {
    if (_downloading) throw const OtaFailure('ota_busy');
    if (release.size < 1 ||
        release.size > maxOtaFileSize ||
        !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(release.sha256)) {
      throw const OtaFailure('ota_invalid_manifest');
    }
    checkedOtaUrl(release.url.toString(), allowHttp: config.allowHttp);
    _downloading = true;
    File? partial;
    IOSink? sink;
    try {
      if (cancelToken?.isCancelled == true) {
        throw const OtaFailure('ota_cancelled');
      }
      final directory = await Directory(
        await gateway.cacheDirectory(),
      ).create(recursive: true);
      final extension = release is AppRelease ? 'apk' : 'bin';
      final base =
          '${directory.path}${Platform.pathSeparator}update-${release.sha256.toLowerCase()}';
      partial = File('$base.part');
      final target = File('$base.$extension');
      if (await verified(target, release)) {
        onProgress?.call(1);
        if (cancelToken?.isCancelled == true) {
          throw const OtaFailure('ota_cancelled');
        }
        return target;
      }
      onProgress?.call(0);
      if (cancelToken?.isCancelled == true) {
        throw const OtaFailure('ota_cancelled');
      }
      final response = await _dio.get<ResponseBody>(
        release.url.toString(),
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          followRedirects: false,
          validateStatus: (status) => status == 200,
        ),
      );
      final body = response.data;
      if (body == null) throw const OtaFailure('ota_download_failed');
      sink = partial.openWrite();
      var received = 0;
      await for (final chunk in body.stream) {
        if (cancelToken?.isCancelled == true) {
          throw const OtaFailure('ota_cancelled');
        }
        received += chunk.length;
        if (received > release.size) throw const OtaFailure('ota_file_invalid');
        sink.add(chunk);
        onProgress?.call(received / release.size);
      }
      await sink.flush();
      await sink.close();
      sink = null;
      if (cancelToken?.isCancelled == true) {
        throw const OtaFailure('ota_cancelled');
      }
      if (!await verified(partial, release)) {
        throw const OtaFailure('ota_file_invalid');
      }
      if (cancelToken?.isCancelled == true) {
        throw const OtaFailure('ota_cancelled');
      }
      if (await target.exists()) await target.delete();
      await partial.rename(target.path);
      return target;
    } on DioException catch (error) {
      throw OtaFailure(
        CancelToken.isCancel(error) ? 'ota_cancelled' : 'ota_network_error',
      );
    } on FileSystemException {
      throw const OtaFailure('ota_storage_error');
    } finally {
      try {
        await sink?.close();
        if (partial != null && await partial.exists()) await partial.delete();
      } on FileSystemException {
        // A storage failure must not leave the downloader permanently busy.
      } finally {
        _downloading = false;
      }
    }
  }

  Future<InstallAction> install(File file, AppRelease release) async {
    if (!await verified(file, release)) {
      throw const OtaFailure('ota_file_invalid');
    }
    final installed = await gateway.installedApp();
    // 上位机只安装更高内部编号；主板固件沿用独立的目标版本规则。
    if (installed.packageName != release.packageName ||
        !release.isNewerThan(installed.versionCode)) {
      throw const OtaFailure('ota_invalid_manifest');
    }
    return gateway.install(file, release);
  }

  void dispose() => _dio.close(force: true);
}
