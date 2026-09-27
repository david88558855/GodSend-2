import 'package:flutter/foundation.dart';

import '../preferences/service_region.dart';

enum AppEnv { dev, prod }

/// 纯局域网发行版。
///
/// 所有云端（官方集群 / 中转 / 账号体系）端点均已移除：
/// API / WebSocket 指向回环地址（本机自建服务可选，默认不可达），
/// 应用仅在局域网内通过 mDNS 发现设备并直连传输。
class Env {
  Env._();

  /// 出海发行包（历史字段，仅保留品牌/区域默认值用途）。
  static const overseasBuild = bool.fromEnvironment(
    'OVERSEAS_BUILD',
    defaultValue: false,
  );

  /// 面向 Google Play 等需合规清单的 Android 包：与 `play` Gradle flavor 对齐，应同时传入
  /// `--dart-define=ANDROID_PLAY_DISTRIBUTION=true`；用于隐藏 APK 发送/安装并配合 Manifest 移除敏感权限。
  static const androidPlayDistribution = bool.fromEnvironment(
    'ANDROID_PLAY_DISTRIBUTION',
    defaultValue: false,
  );

  /// 纯局域网版：不连接任何服务器，端点固定为回环地址（占位），
  /// 所有云端调用在本地即快速失败，应用始终走局域网 mDNS 发现 + 直连传输。
  static const _devApiUrl = 'http://127.0.0.1:9000';

  static const _devWs = 'ws://127.0.0.1:5200';

  static const _prodApiUrl = _devApiUrl;

  static const _prodWs = _devWs;

  /// 区域概念仅为兼容旧配置/品牌文案保留，不再影响任何网络端点。
  static ServiceRegion _prodServiceRegion = ServiceRegion.mainlandChina;

  static ServiceRegion get prodServiceRegion => _prodServiceRegion;

  static void setProdServiceRegion(ServiceRegion region) {
    _prodServiceRegion = region;
  }

  /// `https://api.example.com` → `wss://api.example.com/wkws`。
  static String websocketEndpointFromHttpApi(String apiUrl) {
    return _connectionEndpointFromHttpApi(apiUrl, 'wkws', asWebsocket: true);
  }

  static String httpStreamEndpointFromHttpApi(String apiUrl) {
    return _connectionEndpointFromHttpApi(apiUrl, 'wkws', asWebsocket: false);
  }

  static String _connectionEndpointFromHttpApi(
    String apiUrl,
    String pathSuffix, {
    required bool asWebsocket,
  }) {
    final uri = Uri.parse(apiUrl);
    final https = uri.scheme == 'https';
    return Uri(
      scheme: asWebsocket ? (https ? 'wss' : 'ws') : (https ? 'https' : 'http'),
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: '/$pathSuffix',
    ).toString();
  }

  static AppEnv _current = kReleaseMode ? AppEnv.prod : AppEnv.dev;

  static AppEnv get current => _current;

  static bool get canSwitch => !kReleaseMode;

  static void switchTo(AppEnv env) {
    if (kReleaseMode) return;
    _current = env;
  }

  static String get apiUrl =>
      _current == AppEnv.prod ? _prodApiUrl : _devApiUrl;

  static String get centrifugoWs => _current == AppEnv.prod ? _prodWs : _devWs;

  /// Public WuKongIM websocket URL (debug override). Runtime prefers token.websocketUrl.
  static String get realtimeWs => centrifugoWs;

  /// Phones cannot open `ws://127.0.0.1`. If the token still points at
  /// loopback, rewrite the host to [apiUrl] and keep the WS port/path.
  static String rewriteLoopbackRealtimeWs(
    String websocketUrl, {
    String? apiUrl,
  }) {
    final ws = Uri.tryParse(websocketUrl);
    if (ws == null || ws.host.isEmpty) return websocketUrl;
    if (ws.host != '127.0.0.1' && ws.host != 'localhost') return websocketUrl;
    final api = Uri.tryParse(apiUrl ?? Env.apiUrl);
    if (api == null || api.host.isEmpty) return websocketUrl;
    if (api.host == '127.0.0.1' || api.host == 'localhost') return websocketUrl;
    return ws.replace(host: api.host).toString();
  }

  /// 授权页 / Web 端入口（纯局域网版默认无云端 Web）。
  static String get webUrl {
    return Uri.parse(apiUrl)
        .replace(port: 3000, path: '', query: '', fragment: '')
        .toString()
        .replaceFirst(RegExp(r'/+$'), '');
  }

  static String get label => _current == AppEnv.prod ? '线上' : '测试';
}
