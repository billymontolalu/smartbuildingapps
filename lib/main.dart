import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:smartbuildingapp/realtime_model.dart';

import 'config.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Stream<RealtimeModel> _realtimeStream;

  List<charts.Series<HourData, String>> _seriesData;

  @override
  void initState() {
    super.initState();
    _realtimeStream = realtimeStream();
    gethour();
  }

  Future<List<HourData>> gethour() async {
    List<HourData> dataObject = [];
    var url = Uri.parse("${Constants().baseURL}hour");
    final response =
        await http.get(url, headers: {"content-type": "application/json"});
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      for (var item in data) {
        dataObject.add(HourData(item["hour"], item["power"]));
      }
    }
    return dataObject;
  }

  Stream<RealtimeModel> realtimeStream() async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: 10000));
      var url = Uri.parse(Constants().baseURL);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        yield RealtimeModel.fromJson(result);
      } else {
        yield RealtimeModel();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          height: 10,
        ),
        Text("Penggunaan Sekarang"),
        SizedBox(
          height: 10,
        ),
        StreamBuilder<RealtimeModel>(
          stream: _realtimeStream,
          builder:
              (BuildContext context, AsyncSnapshot<RealtimeModel> snapshot) {
            if (snapshot.hasData) {
              return Center(
                child: Column(
                  children: [
                    Text("${snapshot.data.power} w"),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  children: [
                    Text('${snapshot.error} Retry?'),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        child: Text("Retry"),
                        onPressed: () {
                          setState(() {
                            _realtimeStream = realtimeStream();
                          });
                        }),
                  ],
                ),
              );
            } else {
              return Center(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                  width: 10,
                  height: 10,
                ),
              );
            }
          },
        ),
        SizedBox(
          height: 10,
        ),
        FutureBuilder(
            future: gethour(),
            builder:
                (BuildContext context, AsyncSnapshot<List<HourData>> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error"));
              } else if (snapshot.hasData) {
                List<HourData> hourdata = snapshot.data;
                return Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: _buildChart(hourdata),
                ));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            })
      ]),
    ));
  }

  static List<charts.Series<HourData, String>> _createSampleData(
      List<HourData> data) {
    return [
      new charts.Series<HourData, String>(
          id: 'Pemakaian Per Jam (Watt)',
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (HourData sales, _) => sales.hour.toString(),
          measureFn: (HourData sales, _) => sales.power,
          data: data,
          labelAccessorFn: (HourData rebat, _) =>
              '${rebat.power.toStringAsFixed(2)}')
    ];
  }

  Widget _buildChart(List<HourData> hourdata) {
    return charts.BarChart(
      _createSampleData(hourdata),
      animate: true,
      barRendererDecorator: new charts.BarLabelDecorator<String>(),
      domainAxis: new charts.OrdinalAxisSpec(),
      behaviors: [
        new charts.SeriesLegend(
          // Configures the "Other" series to be hidden on first chart draw.
          defaultHiddenSeries: ['Other'],
        )
      ],
    );
  }
}

class HourData {
  int hour;
  num power;

  HourData(this.hour, this.power);
}
