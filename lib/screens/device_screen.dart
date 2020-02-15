import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceScreen extends StatefulWidget {
  final title;
  final BluetoothDevice device;

  DeviceScreen({this.title, this.device});

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          child: StreamBuilder<List<BluetoothService>>(
            stream: widget.device.services,
            initialData: [],
            builder: (c, snapshot) {
              _characteristicScanning(snapshot);
              return ListView(
                children: snapshot.data
                    .map(
                      (bluetoothService) => Card(
                        child: Text(bluetoothService.uuid.toString()),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  void _characteristicScanning(AsyncSnapshot<List<BluetoothService>> snapshot) {
    Stream<List<int>> stream;
    List<BluetoothService> services = snapshot.data;
    services.forEach((service) {
      service.characteristics.forEach((character) {
        print('character uuid = ${character.uuid}');
        Stream<List<int>> stream = character.value;
        stream.listen((snapshot) {
          String characterValue = _dataParser(snapshot);
          print('character value = ${characterValue}');
        });
      });
    });
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }
}
