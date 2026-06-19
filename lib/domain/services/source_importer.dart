import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../platform/path_service.dart';
import '../models/source_definition.dart';

class SourceImporter {
  final PathService _pathService;
  SourceImporter(this._pathService);

  SourceDefinition? importFromJsonString(String jsonStr) { try { final json = jsonDecode(jsonStr); if (json is Map<String, dynamic>) return SourceDefinition.fromJson(json); return null; } catch (e) { debugPrint('[SourceImporter] 解析 JSON 失败: $e'); return null; }}

  List<SourceDefinition> importFromJsonArray(String jsonStr) {
    try { final json = jsonDecode(jsonStr); if (json is List) return json.whereType<Map<String, dynamic>>().map((e) => SourceDefinition.fromJson(e)).where(_validateSource).toList(); if (json is Map<String, dynamic>) { final source = SourceDefinition.fromJson(json); return _validateSource(source) ? [source] : []; } return []; }
    catch (e) { debugPrint('[SourceImporter] 批量解析 JSON 失败: $e'); return []; }
  }

  Future<List<SourceDefinition>> importFromFile(String filePath) async { try { final file = File(filePath); if (!await file.exists()) return []; final content = await file.readAsString(); return importFromJsonArray(content); } catch (e) { debugPrint('[SourceImporter] 从文件导入失败: $e'); return []; }}

  String exportToJsonString(List<SourceDefinition> sources) => const JsonEncoder.withIndent('  ').convert(sources.map((s) => s.toJson()).toList());
  String exportSingleToJson(SourceDefinition source) => const JsonEncoder.withIndent('  ').convert(source.toJson());

  Future<String> exportToFile(List<SourceDefinition> sources, {String? fileName}) async { final exportDir = await _pathService.getExportPath(); final name = fileName ?? 'sources_${DateTime.now().millisecondsSinceEpoch}.json'; final filePath = '$exportDir/$name'; final file = File(filePath); await file.writeAsString(exportToJsonString(sources)); return filePath; }

  bool _validateSource(SourceDefinition source) => source.bookSourceName.isNotEmpty && source.bookSourceUrl.isNotEmpty;
  bool isValidSourceJson(String jsonStr) { try { final json = jsonDecode(jsonStr); if (json is Map<String, dynamic>) return json.containsKey('bookSourceName') && json.containsKey('bookSourceUrl'); if (json is List) return json.every((item) => item is Map<String, dynamic> && item.containsKey('bookSourceName') && item.containsKey('bookSourceUrl')); return false; } catch (_) { return false; }}
}