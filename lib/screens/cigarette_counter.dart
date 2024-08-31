import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CigaretteCounter with ChangeNotifier {
  int _cigarettesSmokedToday = 0;
  double _nicotineSmokedToday = 0.0;
  int _hourlyCigarettesSmoked = 0;
  double _hourlyNicotine = 0.0;
  DateTime _lastHourlyUpdate = DateTime.now();

  int get cigarettesSmokedToday => _cigarettesSmokedToday;
  double get nicotineSmokedToday => _nicotineSmokedToday;
  int get hourlyCigarettesSmoked => _hourlyCigarettesSmoked;
  double get hourlyNicotine => _hourlyNicotine;

  void incrementCigarettes() {
    _cigarettesSmokedToday++;
    notifyListeners();
  }

  void setCigarettes(int count) {
    _cigarettesSmokedToday = count;
    notifyListeners();
  }

  void setHourlyCigarettes(int count) {
    _hourlyCigarettesSmoked = count;
    notifyListeners();
  }

  void setHourlyNicotine(double nicotine) {
    _hourlyNicotine = nicotine;
    notifyListeners();
  }

  void updateHourlyCount(int count, double nicotine) async {
    DateTime now = DateTime.now();
    // Check if an hour has passed since the last update
    if (now.difference(_lastHourlyUpdate).inMinutes >= 60) {
      _hourlyCigarettesSmoked = count;
      _hourlyNicotine = nicotine;
      _lastHourlyUpdate = now;
      await _saveHourlyData(count, nicotine, now); // Save the updated hourly data
    } else {
      _hourlyCigarettesSmoked = count;
      _hourlyNicotine = nicotine;
      await _saveHourlyData(count, nicotine, now); // Save the updated hourly data
    }
    notifyListeners();
  }

  Future<void> _saveHourlyData(int count, double nicotine, DateTime now) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = "${now.year}${now.month}${now.day}${now.hour}";
    Map<String, double> hourlyData = {};
    // Load existing data if available
    String? existingData = prefs.getString('hourlyData');
    if (existingData != null) {
      hourlyData = Map<String, double>.from(json.decode(existingData));
    }
    hourlyData[key] = nicotine; // Save nicotine level
    await prefs.setString('hourlyData', json.encode(hourlyData));
  }

  Future<void> resetCountersIfNeeded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    DateTime lastUpdate = DateTime.parse(prefs.getString('lastHourlyUpdate') ?? now.toIso8601String());

    if (now.difference(lastUpdate).inMinutes >= 60) {
      // Reset hourly counters
      _hourlyCigarettesSmoked = 0;
      _hourlyNicotine = 0.0;
      _lastHourlyUpdate = now;

      await prefs.setString('lastHourlyUpdate', now.toIso8601String());
      notifyListeners();
    }
  }

  Future<void> saveDailyCount(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todayKey = _getTodayKey();
    String dailyCountsKey = "dailyCounts";
    String? dailyCountsData = prefs.getString(dailyCountsKey);
    Map<String, int> dailyCounts = dailyCountsData != null ? Map<String, int>.from(json.decode(dailyCountsData)) : {};
    dailyCounts[todayKey] = count;
    await prefs.setString(dailyCountsKey, json.encode(dailyCounts));
  }

  String _getTodayKey() {
    DateTime now = DateTime.now();
    return "cigarettes_${now.year}${now.month}${now.day}";
  }

  Future<void> saveHourlyCount(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String hourlyKey = _getHourlyKey();
    String hourlyCountsKey = "hourlyCounts";
    String? hourlyCountsData = prefs.getString(hourlyCountsKey);
    Map<String, int> hourlyCounts = hourlyCountsData != null ? Map<String, int>.from(json.decode(hourlyCountsData)) : {};
    hourlyCounts[hourlyKey] = count;
    await prefs.setString(hourlyCountsKey, json.encode(hourlyCounts));
  }

  String _getHourlyKey() {
    DateTime now = DateTime.now();
    return "hourly_cigarettes_${now.year}${now.month}${now.day}${now.hour}";
  }
}
