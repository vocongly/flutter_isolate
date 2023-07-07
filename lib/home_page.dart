import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:isolate';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demon Isolate Flutter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(
              height: 50,
            ),
            TextButton(
                onPressed: () {
                  // createNewIsolate();
                  demoCompute();
                },
                child: Container(
                  color: Colors.grey[400],
                  padding: const EdgeInsets.all(8),
                  child: const Text(
                    'Click',
                    style: TextStyle(color: Colors.white),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  void demoCompute()async {
    var result = await compute(sum, 1000000);
    print(result);
  }

  static int sum(int num) {
    int sum = 0;
    for (int i = 0; i <= num; i++) {
      sum += i;
    }
    return sum;
  }

  void createNewIsolate() async {
    //main isolate
    var receivePort = ReceivePort();
    var newIsolate = await Isolate.spawn(taskRunner, receivePort.sendPort);

    Future.delayed(const Duration(seconds: 2), () {
      newIsolate.kill(priority: Isolate.immediate);
      print("New isolate killed");
    });

    receivePort.listen((message) {
      print(message[0]);
      print(message[1]);
      if (message[1] is SendPort) {
        message[1].send("From Main Isolate");
      }
    });
  }

  static void taskRunner(SendPort sendPort) {
    // new isolate
    var receivePort = ReceivePort();

    receivePort.listen((message) {
      print(message);
    });

    var sum = 0;
    for (int i = 0; i <= 10000000000; i++) {
      sum += i;
    }
    sendPort.send([sum, receivePort.sendPort]);
  }
}
