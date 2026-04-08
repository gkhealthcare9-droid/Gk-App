import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class NativeCheckScreen extends StatefulWidget {
  const NativeCheckScreen({super.key});

  @override
  _NativeCheckScreenState createState() => _NativeCheckScreenState();
}

class _NativeCheckScreenState extends State<NativeCheckScreen> {
  static const platform = MethodChannel('com.example/native');
  int _secondsLeft = 0;
  String _status = 'Waiting to start...';
  Timer? _uiTimer;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestOverlayPermission();
  }

  void requestOverlayPermission() async {
    if (!await Permission.systemAlertWindow.isGranted) {
      await Permission.systemAlertWindow.request();
    }
  }
  // void requestNotificationPermission() async {
  //   var status = await Permission.notification.status;
  //   if (!status.isGranted) {
  //     await Permission.notification.request();
  //   }
  // }
  Future<void> startNativeTimer(int seconds) async {
    setState(() {
      _secondsLeft = seconds;
      _status = 'Timer running...';
    });

    try {
      await platform.invokeMethod('startNativeTimer', {'seconds': seconds});
      _uiTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (_secondsLeft <= 1) {
          timer.cancel();
          await _checkTimerStatus();
        } else {
          setState(() {
            _secondsLeft--;
          });
        }
      });
    } catch (e) {
      setState(() {
        _status = '⚠️ Error starting timer: $e';
      });
    }
  }

  Future<void> _checkTimerStatus() async {
    try {
      final String result = await platform.invokeMethod('getTimerResult');
      setState(() {
        _status = result;
      });
    } catch (e) {
      setState(() {
        _status = '⚠️ Error checking timer: $e';
      });
    }
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer Native Check')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$_secondsLeft', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => startNativeTimer(5),
              child: const Text('Start Timer'),
            ),
            const SizedBox(height: 20),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
