import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CigaretteCounter with ChangeNotifier {
  int _cigarettesSmokedToday = 0;
  double _nicotineSmokedToday = 0.0;
  int _hourlyCigarettesSmoked = 0;
  double _hourlyNicotine = 0.0;
  int _dailyCigarettesCount = 0;
  double _dailyNicotine = 0.0;
  DateTime _lastHourlyUpdate = DateTime.now();

  int get cigarettesSmokedToday => _cigarettesSmokedToday;
  double get nicotineSmokedToday => _nicotineSmokedToday;
  int get hourlyCigarettesSmoked => _hourlyCigarettesSmoked;
  int get dailyCigarettesCount => _dailyCigarettesCount;
  double get dailyNicotine => _dailyNicotine;
  double get hourlyNicotine => _hourlyNicotine;

  void incrementCigarettes() {
    _cigarettesSmokedToday++;
    _dailyCigarettesCount++;
    _hourlyCigarettesSmoked++;
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

  void setDailyCigarettes(int count) {
    _dailyCigarettesCount = count;
    notifyListeners();
  }

  void setHourlyNicotine(double nicotine) {
    _hourlyNicotine = nicotine;
    notifyListeners();
  }

    void setDailyNicotine(double nicotine) {
      _dailyNicotine = nicotine;
    notifyListeners();
  }

void updateHourlyCount(int count, double nicotine) async {
  DateTime now = DateTime.now();
  
  if (now.difference(_lastHourlyUpdate).inHours != 0) { 
    // Se siamo in una nuova ora, salviamo i conteggi della precedente
    await saveHourlyData(_hourlyCigarettesSmoked, _hourlyNicotine, _lastHourlyUpdate);

    // Resettiamo i contatori per la nuova ora
    _hourlyCigarettesSmoked = count; // Partiamo dal conteggio attuale
    _hourlyNicotine = nicotine;
    _lastHourlyUpdate = now;
  } else {
    // Se siamo ancora nella stessa ora, aggiorniamo semplicemente i contatori
    _hourlyCigarettesSmoked = count;
    _hourlyNicotine = nicotine;
  }

  
  notifyListeners();
}


  void updateDailyCount(int count, double nicotine) async {
    DateTime now = DateTime.now();
    if (now.difference(_lastHourlyUpdate).inDays == 0) { /////////QUI ERA != 0 MA NON HA SENSO
      _dailyCigarettesCount = count;
      _dailyNicotine = nicotine;
      _lastHourlyUpdate = now;
      //await _saveHourlyData(count, nicotine, now); // Save the updated hourly data
    } else {
      _dailyCigarettesCount = 0; //era count
      _dailyNicotine = 0.0; //era nicotine
      //await _saveHourlyData(0, 0.0, now); // Save the updated hourly data, qui erano (count, nicotine, now)
    }
    notifyListeners();
  }


Future<void> saveHourlyData(int count, double nicotine, DateTime time) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String key = "${time.year}${time.month.toString().padLeft(2, '0')}${time.day.toString().padLeft(2, '0')}${time.hour.toString().padLeft(2, '0')}"; // Ora formattata correttamente
  
  // Carica i dati esistenti
  Map<String, double> hourlyData = {};
  String? existingData = prefs.getString('hourlyData');
  if (existingData != null) {
    try {
      Map<String, dynamic> jsonData = json.decode(existingData);
      
      // Ogni valore deve essere di tipo double
      jsonData.forEach((k, v) {
        if (v is num) {
          hourlyData[k] = v.toDouble();
        }
      });
    } catch (e) {
      print("Errore durante il parsing dei dati: $e");
    }
  }

  // Aggiungi i nuovi dati per l'ora corrente
  hourlyData[key] = nicotine;

  // Salva i dati aggiornati
  await prefs.setString('hourlyData', json.encode(hourlyData));
}



  //////  posso togliere o questo o quello du profilePage mi sembra che sia, si chiama checkAndReset...
Future<void> resetCountersIfNeeded() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  DateTime now = DateTime.now();
  DateTime lastUpdate = DateTime.parse(prefs.getString('lastHourlyUpdate') ?? now.toIso8601String());

  if (now.difference(lastUpdate).inHours != 0) {
    // Prima di resettare, salva i dati dell'ora corrente
    await saveHourlyData(_hourlyCigarettesSmoked, _hourlyNicotine, lastUpdate);

    // Resetta i contatori orari
    _hourlyCigarettesSmoked = 0;
    _hourlyNicotine = 0.0;
    _lastHourlyUpdate = now;

    await prefs.setString('lastHourlyUpdate', now.toIso8601String());
    notifyListeners();
  }
}


  //String _getTodayKey() {
  //  DateTime now = DateTime.now();
  //  return "cigarettes_${now.year}${now.month}${now.day}";
  //}

  //String _getHourlyKey() {
  //  DateTime now = DateTime.now();
  //  return "hourly_cigarettes_${now.year}${now.month}${now.day}${now.hour}";
  //}
}