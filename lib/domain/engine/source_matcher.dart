import 'dart:math';

import '../models/book.dart';
import '../models/search_result.dart';

/// 匹配结果
class MatchResult {
  /// 匹配到的搜索结果（可能为 null 表示无匹配）
  final SearchResult? matched;

  /// 置信度（0.0 ~ 1.0）
  final double confidence;

  /// 匹配级别描述
  final MatchLevel level;

  /// 候选列表（模糊匹配时供用户选择）
  final List<SearchResult> candidates;

  MatchResult({
    this.matched,
    required this.confidence,
    required this.level,
    this.candidates = const [],
  });

  /// 是否为精确匹配
  bool get isExact => level == MatchLevel.exact;

  /// 是否为前缀匹配
  bool get isPrefix => level == MatchLevel.prefix;

  /// 是否为模糊匹配
  bool get isFuzzy => level == MatchLevel.fuzzy;

  /// 是否仅候选
  bool get isCandidateOnly => level == MatchLevel.candidate;

  /// 是否可以自动使用（精确匹配或前缀匹配）
  bool get canAutoUse => isExact || isPrefix;

  @override
  String toString() =>
      'MatchResult(level: $level, confidence: $confidence, '
      'matched: ${matched?.title})';
}

/// 匹配级别
enum MatchLevel {
  /// 精确匹配（标题+作者完全一致）
  exact,

  /// 前缀匹配（标题一致+作者前缀匹配）
  prefix,

  /// 模糊匹配（相似度较高）
  fuzzy,

  /// 仅候选列表（搜索结果展示给用户选择）
  candidate,

  /// 无匹配
  none,
}

/// 书源匹配器 - 实现 4 级书源匹配算法
///
/// 根据本地书籍信息在搜索结果中找到最佳匹配的书源：
/// 1. 精确匹配（100%）：标题+作者完全一致
/// 2. 前缀匹配（85%）：标题一致+作者前4字匹配
/// 3. 模糊匹配（60%）：Levenshtein 相似度 > 0.8
/// 4. 候选列表（30%）：搜索结果供用户选择
class SourceMatcher {
  /// 需要清理的书名后缀模式
  static final List<RegExp> _titleSuffixPatterns = [
    RegExp(r'[(\uff08][^)\uff09]*(?:\u6821\u5bf9\u7248|\u7cbe\u6821\u7248|\u65e0\u9519\u7248|\u5b8c\u7ed3\u7248|\u6700\u65b0\u7248|\u5168\u672c|\u5168\u96c6|txt|TXT|epub|EPUB)[)\uff09]'),
    RegExp(r'[(\uff08][^)\uff09]*\u5b57[)\uff09]'),
    RegExp(r'\s*[-_\u3010\u3011\[\]].*$'),
  ];

  /// 需要移除的标点符号和特殊字符
  static final RegExp _punctuationPattern =
      RegExp(r'[\s\u3000\-\.\,\;\:\!\?\u3001\u3002\uff01\uff0c\uff1a\uff1b\uff1f\u2018\u2019\u201c\u201d\u300a\u300b\u2014\u2026\u00b7\u00a0]+');

  /// 全角转半角映射
  static const Map<String, String> _fullToHalf = {
    '\uff01': '!', '\uff02': '"', '\uff03': '#', '\uff04': '\$',
    '\uff05': '%', '\uff06': '&', '\uff07': "'", '\uff08': '(',
    '\uff09': ')', '\uff0a': '*', '\uff0b': '+', '\uff0c': ',',
    '\uff0d': '-', '\uff0e': '.', '\uff0f': '/',
    '\uff10': '0', '\uff11': '1', '\uff12': '2', '\uff13': '3',
    '\uff14': '4', '\uff15': '5', '\uff16': '6', '\uff17': '7',
    '\uff18': '8', '\uff19': '9', '\uff1a': ':', '\uff1b': ';',
    '\uff1c': '<', '\uff1d': '=', '\uff1e': '>', '\uff1f': '?',
    '\uff20': '@',
    '\uff21': 'A', '\uff22': 'B', '\uff23': 'C', '\uff24': 'D',
    '\uff25': 'E', '\uff26': 'F', '\uff27': 'G', '\uff28': 'H',
    '\uff29': 'I', '\uff2a': 'J', '\uff2b': 'K', '\uff2c': 'L',
    '\uff2d': 'M', '\uff2e': 'N', '\uff2f': 'O', '\uff30': 'P',
    '\uff31': 'Q', '\uff32': 'R', '\uff33': 'S', '\uff34': 'T',
    '\uff35': 'U', '\uff36': 'V', '\uff37': 'W', '\uff38': 'X',
    '\uff39': 'Y', '\uff3a': 'Z',
    '\uff3b': '[', '\uff3c': '\\', '\uff3d': ']',
    '\uff5e': '~',
  };

  /// 匹配书源
  ///
  /// 根据本地书籍 [localBook] 在搜索候选列表 [candidates] 中查找最佳匹配。
  MatchResult matchSource(
    Book localBook,
    List<SearchResult> candidates,
  ) {
    if (candidates.isEmpty) {
      return MatchResult(
        confidence: 0.0,
        level: MatchLevel.none,
      );
    }

    final normalizedLocalTitle = normalizeTitle(localBook.title);
    final normalizedLocalAuthor = _normalizeAuthor(localBook.author);

    // 第一级：精确匹配 - 标题完全一致 + 作者完全一致
    for (final candidate in candidates) {
      final normalizedCandidateTitle = normalizeTitle(candidate.title);
      final normalizedCandidateAuthor = _normalizeAuthor(candidate.author);

      if (normalizedLocalTitle == normalizedCandidateTitle &&
          normalizedLocalAuthor == normalizedCandidateAuthor &&
          normalizedLocalAuthor.isNotEmpty) {
        return MatchResult(
          matched: candidate,
          confidence: 1.0,
          level: MatchLevel.exact,
          candidates: candidates,
        );
      }
    }

    // 第二级：前缀匹配 - 标题一致 + 作者前4字符匹配
    for (final candidate in candidates) {
      final normalizedCandidateTitle = normalizeTitle(candidate.title);
      final normalizedCandidateAuthor = _normalizeAuthor(candidate.author);

      if (normalizedLocalTitle == normalizedCandidateTitle) {
        if (_isAuthorPrefixMatch(
          normalizedLocalAuthor,
          normalizedCandidateAuthor,
        )) {
          return MatchResult(
            matched: candidate,
            confidence: 0.85,
            level: MatchLevel.prefix,
            candidates: candidates,
          );
        }
      }
    }

    // 第三级：模糊匹配 - Levenshtein 相似度 > 0.8
    SearchResult? bestFuzzyMatch;
    double bestFuzzyScore = 0.0;

    for (final candidate in candidates) {
      final normalizedCandidateTitle = normalizeTitle(candidate.title);
      final titleSimilarity =
          levenshteinDistance(normalizedLocalTitle, normalizedCandidateTitle);

      // 标题相似度 > 0.8
      if (titleSimilarity > 0.8) {
        // 综合考虑作者匹配度
        final normalizedCandidateAuthor =
            _normalizeAuthor(candidate.author);
        final authorSimilarity = levenshteinDistance(
          normalizedLocalAuthor,
          normalizedCandidateAuthor,
        );

        // 综合得分：标题权重 0.7 + 作者权重 0.3
        final combinedScore =
            titleSimilarity * 0.7 + authorSimilarity * 0.3;

        if (combinedScore > bestFuzzyScore) {
          bestFuzzyScore = combinedScore;
          bestFuzzyMatch = candidate;
        }
      }
    }

    if (bestFuzzyMatch != null && bestFuzzyScore > 0.6) {
      return MatchResult(
        matched: bestFuzzyMatch,
        confidence: bestFuzzyScore,
        level: MatchLevel.fuzzy,
        candidates: candidates,
      );
    }

    // 第四级：候选列表 - 返回所有搜索结果供用户选择
    return MatchResult(
      matched: null,
      confidence: 0.3,
      level: MatchLevel.candidate,
      candidates: candidates,
    );
  }

  /// 标准化书名
  ///
  /// 移除全角/半角括号中的后缀（如"校对版"、"精校版"等），
  /// 将全角字符转为半角，移除标点符号和空格。
  static String normalizeTitle(String title) {
    if (title.isEmpty) return '';

    var result = title;

    // 全角转半角
    result = _convertFullToHalf(result);

    // 移除常见的书名后缀
    for (final pattern in _titleSuffixPatterns) {
      result = result.replaceAll(pattern, '');
    }

    // 移除标点符号和空白字符
    result = result.replaceAll(_punctuationPattern, '');

    return result.trim().toLowerCase();
  }

  /// Levenshtein 编辑距离相似度
  ///
  /// 返回 0.0 ~ 1.0 之间的相似度分数，1.0 表示完全相同。
  /// 使用经典动态规划算法。
  static double levenshteinDistance(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final aLen = a.length;
    final bLen = b.length;

    // 使用一维数组优化空间复杂度
    List<int> prev = List.generate(bLen + 1, (i) => i);
    List<int> curr = List.filled(bLen + 1, 0);

    for (int i = 1; i <= aLen; i++) {
      curr[0] = i;
      for (int j = 1; j <= bLen; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = min(
          min(prev[j] + 1, curr[j - 1] + 1),
          prev[j - 1] + cost,
        );
      }
      // 交换数组
      final temp = prev;
      prev = curr;
      curr = temp;
    }

    final editDistance = prev[bLen];
    final maxLen = max(aLen, bLen);
    return 1.0 - (editDistance / maxLen);
  }

  /// 关键词重叠率
  ///
  /// 计算两个字符串中共同出现的字符占比。
  /// 返回 0.0 ~ 1.0 之间的值。
  static double keywordOverlap(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    // 将字符串拆分为字符集合
    final setA = a.split('').toSet();
    final setB = b.split('').toSet();

    // 计算交集
    final intersection = setA.intersection(setB).length;
    final union = setA.union(setB).length;

    if (union == 0) return 0.0;
    return intersection / union;
  }

  // ==================== 内部方法 ====================

  /// 标准化作者名
  static String _normalizeAuthor(String author) {
    if (author.isEmpty) return '';

    var result = author;
    // 全角转半角
    result = _convertFullToHalf(result);
    // 移除"作者："等前缀
    result = result.replaceAll(RegExp(r'^\u4f5c\u8005[\uff1a:]?\s*'), '');
    // 移除标点符号和空白
    result = result.replaceAll(_punctuationPattern, '');

    return result.trim().toLowerCase();
  }

  /// 全角转半角
  static String _convertFullToHalf(String input) {
    final buffer = StringBuffer();
    for (final char in input.split('')) {
      buffer.write(_fullToHalf[char] ?? char);
    }
    return buffer.toString();
  }

  /// 检查作者是否前缀匹配
  ///
  /// 比较两个作者名的前 4 个字符是否一致。
  /// 如果任一作者名长度不足 4 字符，则进行完整比较。
  static bool _isAuthorPrefixMatch(String authorA, String authorB) {
    if (authorA.isEmpty || authorB.isEmpty) return false;

    const prefixLen = 4;
    final minLen = min(authorA.length, authorB.length);
    final compareLen = min(minLen, prefixLen);

    if (compareLen == 0) return false;

    return authorA.substring(0, compareLen) ==
        authorB.substring(0, compareLen);
  }
}
