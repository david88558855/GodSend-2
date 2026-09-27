import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../logger.dart';
import 'env.dart';

const String _divider =
    '============================================================';

const int _keyColumnWidth = 20;

bool _scheduled = false;

/// Schedule the boot env snapshot to run after the first frame.
///
/// On cold start in debug builds the IDE console attaches *after* `main()`
/// begins, so logs emitted before the first paint can be dropped from the
/// IDE output (they are still written to [AppLogFile] though). Deferring
/// until after the first frame ensures the snapshot is visible in the
/// console on cold start as well as on hot reload/restart.
///
/// Idempotent: subsequent calls within the same isolate are no-ops.
void scheduleBootEnvSnapshot() {
  if (_scheduled) return;
  _scheduled = true;
  SchedulerBinding.instance.addPostFrameCallback((_) {
    unawaited(_logBootEnvSnapshot());
  });
}

/// Print build/runtime environment parameters to [logBoot] once.
///
/// Output is wrapped between divider lines so the snapshot is easy to spot
/// in IDE console.
Future<void> _logBootEnvSnapshot() async {
  final pkg = await _safeReadPackageInfo();

  logBoot.info(_divider);
  logBoot.info('[Boot] Env snapshot / 启动环境参数');
  logBoot.info(_divider);
  for (final entry in _buildEntries(pkg)) {
    logBoot.info('${entry.key.padRight(_keyColumnWidth)}: ${entry.value}');
  }
  logBoot.info(_divider);
}

Future<PackageInfo?> _safeReadPackageInfo() async {
  try {
    return await PackageInfo.fromPlatform();
  } catch (_) {
    return null;
  }
}

List<MapEntry<String, String>> _buildEntries(PackageInfo? pkg) => [
      MapEntry(
        'platform',
        '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      ),
      MapEntry('kDebugMode', '$kDebugMode'),
      MapEntry('kProfileMode', '$kProfileMode'),
      MapEntry('kReleaseMode', '$kReleaseMode'),
      MapEntry(
        'appVersion',
        '${pkg?.version ?? '-'} (build ${pkg?.buildNumber ?? '-'})',
      ),
      MapEntry('packageName', pkg?.packageName ?? '-'),
      MapEntry('AppEnv.current', '${Env.current.name} (${Env.label})'),
      MapEntry('OVERSEAS_BUILD', '${Env.overseasBuild}'),
      MapEntry('ANDROID_PLAY_DIST', '${Env.androidPlayDistribution}'),
      MapEntry('serviceRegion', Env.prodServiceRegion.name),
      MapEntry('apiUrl', Env.apiUrl),
      MapEntry('realtimeWs', Env.realtimeWs),
    ];
