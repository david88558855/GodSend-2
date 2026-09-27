/// 纯局域网版：遥测（OpenPanel）已移除，[Analytics] 保留为无操作实现，
/// 上层调用点无需改动。
class Analytics {
  Analytics._();

  static void track(String name, [Map<String, dynamic>? properties]) {
    // no-op：纯局域网版不上报任何数据。
  }

  /// 文件总字节数分桶（不上报精确值）。
  static String sizeBucket(int bytes) {
    if (bytes < 0) return 'unknown';
    if (bytes < 1024 * 1024) return 'lt_1mb';
    if (bytes < 10 * 1024 * 1024) return '1mb_10mb';
    if (bytes < 100 * 1024 * 1024) return '10mb_100mb';
    if (bytes < 1024 * 1024 * 1024) return '100mb_1gb';
    return 'gt_1gb';
  }

  /// 文本长度分桶。
  static String lengthBucket(int len) {
    if (len < 10) return 'lt_10';
    if (len < 50) return '10_50';
    if (len < 200) return '50_200';
    return 'gt_200';
  }
}
