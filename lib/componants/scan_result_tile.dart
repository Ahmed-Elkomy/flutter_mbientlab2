import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key key, this.result, this.onTap}) : super(key: key);

  final ScanResult result;
  final VoidCallback onTap;

  Widget _buildTitle(BuildContext context) {
    if (result.device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            result.device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result.device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(result.device.id.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: _buildTitle(context),
        leading: CircleAvatar(child: Text(result.rssi.toString())),
        trailing: StreamBuilder<BluetoothDeviceState>(
          stream: result.device.state,
          initialData: BluetoothDeviceState.connecting,
          builder: (c, snapshot) {
            print(snapshot.data);
            VoidCallback onPressed =
                (result.advertisementData.connectable) ? onTap : null;
            String text;
            switch (snapshot.data) {
              case BluetoothDeviceState.connected:
                onPressed = () => result.device.disconnect();
                text = 'DISCONNECT';
                break;
              case BluetoothDeviceState.disconnected:
                text = 'CONNECT';
                break;
              default:
                text = snapshot.data.toString().substring(21).toUpperCase();
                break;
            }
            return RaisedButton(
              child: Text(text),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              onPressed: onPressed,
            );
          },
        ),
      ),
    );
  }
}
