import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../platform/path_service.dart';
import '../models/source_definition.dart';

/// 书源导入导出服务
class SourceImporter {
  final PathService _pathService;

  SourceImporter(this._pathService);

  /// 从 JSON 字符串导入单个书源
  SourceDefinition? importFromJsonString(String jsonStr) {
    try {
      final json = jsonDecode(jsonStr);
      if (json is Map<String, dynamic>) {
        return SourceDefinition.fromJson(json);
      }
      return null;
    } catch (e) {
      debugPrint('[SourceImporter] 解析 JSON 失败: $e');
      return null;
    }
  }

  /// 从 JSON 字符串批量导入书源
  List<SourceDefinition> importFromJsonArray(String jsonStr) {
    try {
      final json = jsonDecode(jsonStr);
      if (json is List) {
        return json
            .whereType<Map<String, dynamic>>()
            .map((e) => SourceDefinition.fromJson(e))
            .where(_validateSource)
            .toList();
      }
      // 单个对象也支持
      if (json is Map<String, dynamic>) {
        final source = SourceDefinition.fromJson(json);
        return _validateSource(source) ? [source] : [];
      }
      return [];
    } catch (e) {
      debugPrint('[SourceImporter] 批量解析 JSON 失败: $e');
      return [];
    }
  }

  /// 从文件导入书源
  Future<List<SourceDefinition>> importFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      return importFromJsonArray(content);
    } catch (e) {
      debugPrint('[SourceImporter] 从文件导入失败: $e');
      return [];
    }
  }

  /// 导出书源为 JSON 字符串
  String exportToJsonString(List<SourceDefinition> sources) {
    final jsonArray = sources.map((s) => s.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(jsonArray);
  }

  /// 导出单个书源为 JSON 字符串
  String exportSingleToJson(SourceDefinition source) {
    return const JsonEncoder.withIndent('  ').convert(source.toJson());
  }

  /// 导出书源到文件
  Future<String> exportToFile(
    List<SourceDefinition> sources, {
    String? fileName,
  }) async {
    final exportDir = await _pathService.getExportPath();
    final name = fileName ??
        'sources_${DateTime.now().millisecondsSinceEpoch}.json';
    final filePath = '$exportDir/$name';
    final file = File(filePath);
    await file.writeAsString(exportToJsonString(sources));
    return filePath;
  }

  /// 验证书源定义是否有效
  bool _validateSource(SourceDefinition source) {
    if (source.bookSourceName.isEmpty) return false;
    if (source.bookSourceUrl.isEmpty) return false;
    return true;
  }

  /// 验证 JSON 格式是否为书源格式
  bool isValidSourceJson(String jsonStr) {
    try {
      final json = jsonDecode(jsonStr);
      if (json is Map<String, dynamic>) {
        return json.containsKey('bookSourceName') &&
            json.containsKey('bookSourceUrl');
      }
      if (json is List) {
        return json.every((item) =>
            item is Map<String, dynamic> &&
            item.containsKey('bookSourceName') &&
            item.containsKey('bookSourceUrl'));
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
