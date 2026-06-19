import 'dart:math';
import '../models/book.dart';
import '../models/search_result.dart';

class MatchResult {
  final SearchResult? matched;
  final double confidence;
  final MatchLevel level;
  final List<SearchResult> candidates;

  MatchResult({this.matched, required this.confidence, required this.level, this.candidates = const []});
  bool get isExact => level == MatchLevel.exact;
  bool get isPrefix => level == MatchLevel.prefix;
  bool get isFuzzy => level == MatchLevel.fuzzy;
  bool get isCandidateOnly => level == MatchLevel.candidate;
  bool get canAutoUse => isExact || isPrefix;
}

enum MatchLevel { exact, prefix, fuzzy, candidate, none }

class SourceMatcher {
  static final List<RegExp> _titleSuffixPatterns = [
    RegExp(r'[(\uff08][^)\uff09]*(?:\u6821\u5bf9\u7248|\u7cbe\u6821\u7248|\u65e0\u9519\u7248|\u5b8c\u7ed3\u7248|\u6700\u65b0\u7248|\u5168\u672c|\u5168\u96c6)[)\uff09]'),
    RegExp(r'[(\uff08][^)\uff09]*\u5b57[)\uff09]'),
    RegExp(r'\s*[-_\u3010\u3011\[\]].*$'),
  ];

  static final RegExp _punctuationPattern = RegExp(r'[\s\u3000\-\.\,\;\:\!\?\u3001\u3002\uff01\uff0c\uff1a\uff1b\uff1f\u2018\u2019\u201c\u201d\u300a\u300b\u2014\u2026\u00b7\u00a0]+');

  static const Map<String, String> _fullToHalf = {
    '\uff01': '!', '\uff02': '"', '\uff03': '#', '\uff04': '$', '\uff05': '%', '\uff06': '&', '\uff07': "'", '\uff08': '(', '\uff09': ')',
    '\uff0a': '*', '\uff0b': '+', '\uff0c': ',', '\uff0d': '-', '\uff0e': '.', '\uff0f': '/',
  };

  MatchResult matchSource(Book localBook, List<SearchResult> candidates) {
    if (candidates.isEmpty) return MatchResult(confidence: 0.0, level: MatchLevel.none);

    final normalizedLocalTitle = normalizeTitle(localBook.title);
    final normalizedLocalAuthor = _normalizeAuthor(localBook.author);

    for (final candidate in candidates) {
      final normalizedCandidateTitle = normalizeTitle(candidate.title);
      final normalizedCandidateAuthor = _normalizeAuthor(candidate.author);
      if (normalizedLocalTitle == normalizedCandidateTitle && normalizedLocalAuthor == normalizedCandidateAuthor && normalizedLocalAuthor.isNotEmpty) {
        return MatchResult(matched: candidate, confidence: 1.0, level: MatchLevel.exact, candidates: candidates);
      }
    }

    for (final candidate in candidates) {
      final normalizedCandidateTitle = normalizeTitle(candidate.title);
      final normalizedCandidateAuthor = _normalizeAuthor(candidate.author);
      if (normalizedLocalTitle == normalizedCandidateTitle) {
        if (_isAuthorPrefixMatch(normalizedLocalAuthor, normalizedCandidateAuthor)) {
          return MatchResult(matched: candidate, confidence: 0.85, level: MatchLevel.prefix, candidates: candidates);
        }
      }
    }

    SearchResult? bestFuzzyMatch;
    double bestFuzzyScore = 0.0;
    for (final candidate in candidates) {
      final normalizedCandidateTitle = normalizeTitle(candidate.title);
      final titleSimilarity = levenshteinDistance(normalizedLocalTitle, normalizedCandidateTitle);
      if (titleSimilarity > 0.8) {
        final normalizedCandidateAuthor = _normalizeAuthor(candidate.author);
        final authorSimilarity = levenshteinDistance(normalizedLocalAuthor, normalizedCandidateAuthor);
        final combinedScore = titleSimilarity * 0.7 + authorSimilarity * 0.3;
        if (combinedScore > bestFuzzyScore) {
          bestFuzzyScore = combinedScore;
          bestFuzzyMatch = candidate;
        }
      }
    }

    if (bestFuzzyMatch != null && bestFuzzyScore > 0.6) {
      return MatchResult(matched: bestFuzzyMatch, confidence: bestFuzzyScore, level: MatchLevel.fuzzy, candidates: candidates);
    }

    return MatchResult(matched: null, confidence: 0.3, level: MatchLevel.candidate, candidates: candidates);
  }

  static String normalizeTitle(String title) {
    if (title.isEmpty) return '';
    var result = title;
    result = _convertFullToHalf(result);
    for (final pattern in _titleSuffixPatterns) {
      result = result.replaceAll(pattern, '');
    }
    result = result.replaceAll(_punctuationPattern, '');
    return result.trim().toLowerCase();
  }

  static double levenshteinDistance(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    final aLen = a.length, bLen = b.length;
    List<int> prev = List.generate(bLen + 1, (i) => i), curr = List.filled(bLen + 1, 0);
    for (int i = 1; i <= aLen; i++) {
      curr[0] = i;
      for (int j = 1; j <= bLen; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = min(min(prev[j] + 1, curr[j - 1] + 1), prev[j - 1] + cost);
      }
      final temp = prev; prev = curr; curr = temp;
    }
    final editDistance = prev[bLen];
    return 1.0 - (editDistance / max(aLen, bLen));
  }

  static String _normalizeAuthor(String author) {
    if (author.isEmpty) return '';
    var result = author;
    result = _convertFullToHalf(result);
    result = result.replaceAll(RegExp(r'^\u4f5c\u8005[\uff1a:]?\s*'), '');
    result = result.replaceAll(_punctuationPattern, '');
    return result.trim().toLowerCase();
  }

  static String _convertFullToHalf(String input) {
    final buffer = StringBuffer();
    for (final char in input.split('')) {
      buffer.write(_fullToHalf[char] ?? char);
    }
    return buffer.toString();
  }

  static bool _isAuthorPrefixMatch(String authorA, String authorB) {
    if (authorA.isEmpty || authorB.isEmpty) return false;
    const prefixLen = 4;
    final minLen = min(authorA.length, authorB.length);
    final compareLen = min(minLen, prefixLen);
    if (compareLen == 0) return false;
    return authorA.substring(0, compareLen) == authorB.substring(0, compareLen);
  }
}