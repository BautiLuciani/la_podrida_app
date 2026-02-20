import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localStorageServiceProvider = Provider<LocalStorageService>(
  (ref) => LocalStorageService(),
);

class LocalStorageService {
  static const _blockFourZerosKey = 'blockFourZeros';
  static const _extraRoundKey = 'extraRound';
  static const _pointsPerBazaKey = 'pointsPerBaza';
  static const _lastPlayersKey = 'lastPlayers';
  static const _rankingPointsKey = 'rankingPoints';

  Future<void> saveBlockFourZeros(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_blockFourZerosKey, value);
  }

  Future<bool?> getBlockFourZeros() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_blockFourZerosKey);
  }

  Future<void> saveExtraRound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_extraRoundKey, value);
  }

  Future<bool?> getExtraRound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_extraRoundKey);
  }

  Future<void> savePointsPerBaza(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsPerBazaKey, value);
  }

  Future<int?> getPointsPerBaza() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsPerBazaKey);
  }

  Future<void> saveLastPlayers(List<String> players) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_lastPlayersKey, players);
  }

  Future<List<String>> getLastPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_lastPlayersKey) ?? <String>[];
  }

  Future<void> saveRankingPoints(Map<String, int> pointsByPlayer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rankingPointsKey, jsonEncode(pointsByPlayer));
  }

  Future<Map<String, int>> getRankingPoints() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_rankingPointsKey);
    if (raw == null || raw.isEmpty) {
      return <String, int>{};
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return <String, int>{};
    }

    return decoded.map((key, value) => MapEntry(key, (value as num).toInt()));
  }

  Future<void> clearRankingPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rankingPointsKey);
  }
}
