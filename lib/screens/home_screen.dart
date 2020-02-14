import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_mbientlab/componants/scan_result_tile.dart';

import 'device_screen.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  HomeScreen({this.title});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BluetoothDevice device;
  FlutterBlue flutterBlue;
  bool scanningRunning = false;
  StreamSubscription<ScanResult> scanSubScription;

  @override
  void initState() {
    super.initState();
    //checks bluetooth current state
    try {
      flutterBlue = FlutterBlue.instance;
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder<bool>(
                stream: flutterBlue.isScanning,
                initialData: false,
                builder: (c, snapshot) {
                  scanningRunning = snapshot.data;
                  return Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          child: Text("Start Scanning"),
                          onPressed: scanningRunning ? null : _startScanning,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: RaisedButton(
                          child: Text("Stop Scanning"),
                          onPressed: scanningRunning ? _stopScanning2 : null,
                        ),
                      )
                    ],
                  );
                },
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: StreamBuilder<List<ScanResult>>(
                  stream: flutterBlue.scanResults,
                  initialData: [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data
                        .map(
                          (scanResult) => ScanResultTile(
                            result: scanResult,
                            onTap: () => Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              scanResult.device.connect();
                              return DeviceScreen(
                                  title: widget.title,
                                  device: scanResult.device);
                            })),
                          ),
                        )
                        .toList(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _startScanning() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
  }

  void _stopScanning2() {
    flutterBlue.stopScan();
  }
}
