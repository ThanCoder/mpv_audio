import 'package:material_ui/material_ui.dart';
import 'package:mpv_audio/mpv_audio.dart';

void main() {
  runApp(MaterialApp(home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

const String libPath =
    '/home/thancoder/Downloads/mpv_audio_lib/libmpv_linux-x86_64.so';
const String aPath = '/home/thancoder/Music/test.mp3';

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  final mpv = MpvAudio();
  String resText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native Packages')),
      body: Column(
        spacing: 10,
        children: [
          SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              try {
                mpv.init();
                setState(() {
                  resText = '';
                });
              } catch (e) {
                setState(() {
                  resText = e.toString();
                });
              }
            },
            child: Text('init'),
          ),
          FilledButton(
            onPressed: () {
              try {
                mpv.dispose();
                setState(() {
                  resText = '';
                });
              } catch (e) {
                setState(() {
                  resText = e.toString();
                });
              }
            },
            child: Text('dispose'),
          ),
          FilledButton(
            onPressed: () async {
              final res = await mpv.playAudio(aPath);

              res.onError(
                onErr: (err) => setState(() {
                  resText = err;
                }),
              );
            },
            child: Text('Play Song'),
          ),
          FilledButton(
            onPressed: () async {
              final res = await mpv.pause(aPath);
              print('pause');

              res.onError(
                onErr: (err) => setState(() {
                  resText = err;
                }),
              );
            },
            child: Text('Pause Song'),
          ),
          Center(child: CircularProgressIndicator.adaptive()),
          SizedBox(height: 10),
          Text(resText),
        ],
      ),
    );
  }
}
