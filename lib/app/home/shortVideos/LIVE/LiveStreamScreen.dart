import 'package:flutter/material.dart';


class LiveStreamScreen extends StatefulWidget {
  @override
  _LiveStreamScreenState createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {

  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {

    super.dispose();
  }

  void _startStreaming() {

    setState(() {
      _isStreaming = true;
    });
  }

  void _stopStreaming() {

    setState(() {
      _isStreaming = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transmisión en Vivo'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: _isStreaming
                  ? Text('Transmitiendo...')
                  : Text('No está transmitiendo'),
            ),
            ElevatedButton(
              onPressed: _isStreaming ? _stopStreaming : _startStreaming,
              child: Text(_isStreaming ? 'Detener Transmisión' : 'Iniciar Transmisión'),
            ),
          ],
        ),
      ),
    );
  }
}
