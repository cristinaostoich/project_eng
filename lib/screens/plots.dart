//import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'cigarette_counter.dart';
import 'package:progetto/charts/plot_creation.dart';




class Plots extends StatefulWidget {
  final String accountName;




  Plots({required this.accountName});




  @override
  _PlotsState createState() => _PlotsState();
}




class _PlotsState extends State<Plots> {
  DateTime? registrationDate;
  List<NicotineLevel> data = [];
  List<HourlyNicotineLevel> hourlyData = [];
  int _cigarettesPerDay = 0;
  int threshold = 0;
  bool isLoading = true;
  double nicotineSmokedToday = 0.0; //questa variabile va bene e non va modificata nel resto del codice
  double _nicotine = 0.0;
  double nicotineSmokedThisHour = 0.0;
  double dailyNicotineTarget = 0.0;




  @override
  void initState() {
    super.initState();
    _loadRegistrationData();
  }




  Future<void> _loadRegistrationData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? usersData = prefs.getString('users');




      Map<String, dynamic> users = usersData != null ? json.decode(usersData) : {};
      //final cigaretteCounter = Provider.of<CigaretteCounter>(context, listen:false);




      if (users.containsKey(widget.accountName)) {
        var userProfile = users[widget.accountName];
        String? dateStr = userProfile['registrationDate'];
        _cigarettesPerDay = userProfile['CigarettesPerDay'] ?? 0;
        _nicotine = userProfile['Nicotine'] ?? 0.0;
        threshold = _cigarettesPerDay; //threshold initialization




        if (dateStr != null) {
          registrationDate = DateTime.parse(dateStr);
        } else {
          registrationDate = DateTime.now();
        }




        // Calcola quanti giorni sono passati dalla registrazione
        if (registrationDate != null) {
          int daysSinceRegistration = DateTime.now().difference(registrationDate!).inDays;




          // Decrementa la soglia di 1 per ogni 7 giorni passati
          threshold -= (daysSinceRegistration ~/ 7);
          if (threshold < 0) threshold = 0; // La soglia non può andare sotto 0
        }




        await _generateChartData(users);
        await _generateHourlyData(users);
      } else {
        print("User not found: ${widget.accountName}");
      }
    } catch (e) {
      print("Error loading registration data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }




  Future<void> _generateChartData(Map<String, dynamic> users) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dailyCountsKey = "${widget.accountName}_dailyCounts";
    String? dailyCountsData = prefs.getString(dailyCountsKey);
    Map<String, int> dailyCounts = dailyCountsData != null ? Map<String, int>.from(json.decode(dailyCountsData)) : {};
    double dailyNicotineTarget = threshold * _nicotine; // Calcola la soglia giornaliera






    if (registrationDate != null) {
      DateTime startDate = registrationDate!;
      data = [];
      DateTime now = DateTime.now();




      int totalCigarettes = 0;
      double nicotineSmokedToday = 0.0;
      //int daysToGenerate = _cigarettesPerDay*7;


      int daysToGenerate = now.difference(startDate).inDays + 1;




      for (int i = 0; i < daysToGenerate; i++) {
        DateTime currentDate = startDate.add(Duration(days: i));
        String dateKey = "${widget.accountName}_cigarettes_${currentDate.year}${currentDate.month}${currentDate.day}";
        double cigarettes = dailyCounts[dateKey]?.toDouble() ?? 0.0;
        //totalCigarettes += cigarettes.toInt();
        //nicotineSmokedToday += totalCigarettes * _nicotine;
        //print('nicotineSmokedToday ${nicotineSmokedToday}');
        //print('nicotine ${_nicotine}');
        //print('total cigarettes ${totalCigarettes}');


        data.add(NicotineLevel(date: currentDate, level: cigarettes));
      }


      final cigaretteCounter = Provider.of<CigaretteCounter>(context, listen: false);
      data.add(NicotineLevel(date: now, level: cigaretteCounter.cigarettesSmokedToday.toDouble()));
      totalCigarettes += cigaretteCounter.cigarettesSmokedToday;
      //nicotineSmokedToday = totalCigarettes * _nicotine;
      //double cigarettesToday = cigaretteCounter.nicotineSmokedToday.toDouble();
      //nicotineSmokedToday = totalCigarettes * _nicotine;
      //print('nicotineSmokedToday ${nicotineSmokedToday}');
      //print('prova: ${cigaretteCounter.nicotineSmokedToday}');
      print('prova2: ${cigaretteCounter.cigarettesSmokedToday}');  //OK VA BENE
      nicotineSmokedToday = totalCigarettes * _nicotine;
      int futureDays = totalCigarettes * 7;


      for (int i = 1; i <= futureDays; i++) {
        DateTime futureDate = now.add(Duration(days: i));
        data.add(NicotineLevel(date: futureDate, level: 0.0));
      }
      setState(() {
        // Questa variabile sarà usata per mostrare il conteggio nel widget
        this.nicotineSmokedToday = nicotineSmokedToday;
        this.dailyNicotineTarget = dailyNicotineTarget;
      });


    }
  }




  Future<void> _generateHourlyData(Map<String, dynamic> users) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
   
    // Recupera i dati di configurazione dalle SharedPreferences
    // MODIFICARE: OGNI 7 GIORNI DALLA DATA DI REGISTRAZIONE, LA SOGLIA DECRESCE DEL VALORE _nicotine
    //double dailyNicotineTarget = _cigarettesPerDay * _nicotine; // Calcola la soglia giornaliera
    String hourlyCountsKey = "${widget.accountName}_hourlyCounts";
    String? hourlyCountsData = prefs.getString(hourlyCountsKey);
    Map<String, int> hourlyCounts = hourlyCountsData != null ? Map<String, int>.from(json.decode(hourlyCountsData)) : {};
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    hourlyData = [];


    //int totalCigarettes = 0;
    int hoursToGenerate = now.difference(startOfDay).inHours + 1;


    // Variabile per tenere traccia della nicotina fumata oggi
    //double nicotineSmokedToday = 0.0;
    double nicotineSmokedThisHour = 0.0;
    //Set<String> keys = prefs.getKeys();




    // Raccogli tutte le sigarette fumate dal salvataggio
        DateTime hour = DateTime(now.year, now.month, now.day, now.hour);




        for (int i = 0; i < hoursToGenerate; i++) {
          DateTime currentHour = startOfDay.add(Duration(hours: i));
          String hourKey = "${widget.accountName}_cigarettes_${currentHour.year}${currentHour.month}${currentHour.day}${currentHour.hour}";
          double cigarettes = hourlyCounts[hourKey]?.toDouble() ?? 0.0;
          //totalCigarettes += cigarettes.toInt();
          nicotineSmokedThisHour += cigarettes.toInt();
          //nicotineSmokedToday += cigarettes.toInt();


          // Aggiungi i dati giornalieri
          hourlyData.add(HourlyNicotineLevel(time: hour, level: cigarettes));


          // Aggiorna il conteggio della nicotina oraria fumata se la data coincide
          if (currentHour.hour == now.hour &&
            currentHour.day == now.day &&
            currentHour.month == now.month &&
            currentHour.year == now.year) {
              nicotineSmokedThisHour += cigarettes;
              //nicotineSmokedToday += cigarettes;
            }
          }


   
    // Aggiorna il totale di nicotina fumata oggi con i dati odierni
    final nicotineCounter = Provider.of<CigaretteCounter>(context, listen: false);
    hourlyData.add(HourlyNicotineLevel(time: now, level: nicotineCounter.hourlyNicotine));
    double nicotineThisHour = nicotineCounter.hourlyNicotine.toDouble();
    nicotineSmokedThisHour += nicotineThisHour;


    hourlyData.add(HourlyNicotineLevel(time: now, level: nicotineThisHour));
    nicotineSmokedThisHour += nicotineCounter.hourlyNicotine.toInt();
    //nicotineSmokedToday += nicotineCounter.nicotineSmokedToday.toInt();
   


    int futureHours = 12; //visualize even hours;


    // Aggiungi i dati futuri
    for (int i = 1; i <= futureHours; i++) {
      DateTime futureHours = now.add(Duration(hours: i));
      hourlyData.add(HourlyNicotineLevel(time: futureHours, level: 0.0));
    }


    // Aggiorna lo stato per riflettere i nuovi dati
    setState(() {
      // Questa variabile sarà usata per mostrare il conteggio nel widget
      //this.nicotineSmokedToday = nicotineSmokedToday;
      //this.dailyNicotineTarget = dailyNicotineTarget;
      this.nicotineSmokedThisHour = nicotineSmokedThisHour;
    });
  }


  @override
  Widget build(BuildContext context) {
    final cigaretteCounter = Provider.of<CigaretteCounter>(context);
    DateTime now = DateTime.now();




    return Scaffold(
      appBar: AppBar(title: Text('Plots')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Cigarettes smoked today: ${cigaretteCounter.cigarettesSmokedToday}/$threshold',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: (_cigarettesPerDay * 7 * 50.0),
                        child: NicotineChart(
                          NicotineChart.createSampleData(data),
                          animate: true,
                          registrationDate: registrationDate!,
                          cigarettesPerDay: _cigarettesPerDay,
                          nicotineSmokedToday: nicotineSmokedToday,
                          dailyNicotineTarget: dailyNicotineTarget,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Slide horizontally to view more data',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Spazio tra i grafici
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3, // Altezza ridotta
                    child: HourlyNicotineChart(
                      HourlyNicotineChart.createSampleData(hourlyData),
                      animate: true,
                      nicotineSmokedThisHour: nicotineSmokedThisHour,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Nicotine smoked today: ${nicotineSmokedToday.toStringAsFixed(1)} / ${dailyNicotineTarget.toStringAsFixed(1)} mg',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
