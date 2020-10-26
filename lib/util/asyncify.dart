import 'dart:async';
import 'dart:isolate';

/// Example
///
/// ```
/// main() async {
///   print(await runAsync<String, String Function(String)>(sing, ["lalalala"]));
///   print(await runAsync<String, Function>(song));
/// }
/// 
/// String sing(String str) => "Singing: " + str;
/// String song() => "lololololo";
/// ```

Future<R> runAsync<R, F>(F func, [List<dynamic> parameters]) async {
  final receivePort = ReceivePort();
  await Isolate.spawn(asyncRunner, receivePort.sendPort);

  // The 'asyncRunner' isolate sends it's SendPort as the first message
  final sendPort = await receivePort.first;

  final responsePort = ReceivePort();
  sendPort.send([responsePort.sendPort, func, parameters ?? []]);
  final res = await responsePort.first;
  if (res is! R)
    return Future.error(res);
  else if (res == null) return null;
  return res as R;
}

// Isolate entry point
void asyncRunner(SendPort sendPort) async {
  // Open the ReceivePort for incoming messages
  final port = ReceivePort();

  // Notify our creator the port we listen to
  sendPort.send(port.sendPort);

  final msg = await port.first;

  // Execute
  final SendPort replyTo = msg[0];
  final Function myFunc = msg[1];
  final List<dynamic> parameters = msg[2] ?? [];

  try {
    switch (parameters.length) {
      case 0:
        replyTo.send(myFunc());
        break;
      case 1:
        replyTo.send(myFunc(parameters[0]));
        break;
      case 2:
        replyTo.send(myFunc(parameters[0], parameters[1]));
        break;
      case 3:
        replyTo.send(myFunc(parameters[0], parameters[1], parameters[2]));
        break;
      case 4:
        replyTo.send(
            myFunc(parameters[0], parameters[1], parameters[2], parameters[3]));
        break;
      case 5:
        replyTo.send(myFunc(parameters[0], parameters[1], parameters[2],
            parameters[3], parameters[4]));
        break;
      default:
        replyTo.send(Exception("Unsupported argument length"));
    }
  } catch (err) {
    replyTo.send(Exception(err.toString()));
  }

  // Done
  port.close();
  Isolate.current.kill();
}
