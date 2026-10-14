import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
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
  final OtaConfig config;
  final UpdateGateway gateway;
  final Dio _dio;
  bool _downloading = false;
  Future<UpdateCheck> check() async {
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

  Future<bool> verified(File file, OtaFile release) async {
    if (!await file.exists() || await file.length() != release.size) {
      return false;
    }
    return (await sha256.bind(file.openRead()).first).toString() ==
        release.sha256.toLowerCase();
  }

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
    if (installed.packageName != release.packageName ||
        !release.isNewerThan(installed.versionCode)) {
      throw const OtaFailure('ota_invalid_manifest');
    }
    return gateway.install(file, release);
  }

  void dispose() => _dio.close(force: true);
}
