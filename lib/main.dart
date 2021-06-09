import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smartbuildingapp/realtime_model.dart';

import 'config.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  /*Future<RealtimeModel> _getRealtime() async {
    var url = Uri.parse(Constants().baseURL);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      return RealtimeModel.fromJson(result);
    } else {
      return RealtimeModel();
    }
  }*/

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Stream<RealtimeModel> _realtimeStream;

  @override
  void initState() {
    super.initState();
    _realtimeStream = realtimeStream();
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
                  width: 60,
                  height: 60,
                ),
              );
            }
          },
        ),
      ]),
    ));
  }
}
