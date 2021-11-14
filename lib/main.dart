import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Siri App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final textController = TextEditingController();
  double volume = 20;
  bool active = true;

  @override
  void initState() {
    super.initState();
    textController.addListener(() => setState(() {}));
    // _initSounds();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  bool checkPlatform() {
    if (Platform.isIOS) {
      return true;
    } else if (Platform.isAndroid) {
      return false;
    }
    return true;
  }

  Future<void> _initSounds(
    String file,
  ) async {
    Soundpool? _pool = Soundpool.fromOptions(
        options: SoundpoolOptions(streamType: StreamType.notification));

    // ファイルの読み込み
    int soundId = await rootBundle.load(file).then((ByteData soundData) {
      return _pool.load(soundData);
    });

    int streamId = await _pool.play(soundId);
    _pool.setVolume(soundId: soundId, streamId: streamId, volume: volume);
  }

  FlutterTts flutterTts = FlutterTts();
  String inputText = "";

  Future speak(String text) async {
    await flutterTts.setLanguage("ja");
    await flutterTts.setPitch(1);
    await flutterTts.setVolume(10);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final leadingStyle1 = TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue);
    final leadingStyle2 =
        TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red);
    return Scaffold(
      appBar: AppBar(
        title: Text("Siri遊び",
            style: TextStyle(color: active ? Colors.white : Colors.black)),
        centerTitle: true,
        backgroundColor: active ? Colors.blue : Colors.black,
        elevation: 0.0,
      ),
      // extendBodyBehindAppBar: false,
      body: active
          ? Center(
              child: ListView(
                children: [
                  ListTile(
                    leading: Text("準備１", style: leadingStyle1),
                    title: Text(
                      "質問を考える",
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  ListTile(
                    leading: Text("準備２", style: leadingStyle1),
                    title: Text(
                      "音を最大にする",
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  ListTile(
                    leading: Text("準備３", style: leadingStyle1),
                    title: CupertinoTextField(
                      controller: textController,
                      maxLines: 5,
                      padding: EdgeInsets.all(16),
                      placeholder: "読み上げるテキストを入力",
                      placeholderStyle: TextStyle(color: Colors.black38),
                      suffix: CupertinoButton(
                          child: Icon(CupertinoIcons.clear),
                          onPressed: () {
                            textController.clear();
                            inputText = textController.text;
                          }),
                      onChanged: (input) {
                        inputText = input;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Text("手順１", style: leadingStyle2),
                    title: checkPlatform()
                        ? Text(
                            "「Hey Siri」と言う",
                            style: TextStyle(fontSize: 30),
                          )
                        : Text(
                            "「Hey Siri」と言う",
                            style: TextStyle(fontSize: 30),
                          ),
                  ),
                  ListTile(
                    leading: Text("手順２", style: leadingStyle2),
                    title: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _initSounds("assets/pushUp.mp3");
                          });
                        },
                        child: Text("ピコん！ (音)")),
                  ),
                  ListTile(
                    leading: Text("手順３", style: leadingStyle2),
                    title: Text(
                      "質問する",
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  ListTile(
                    leading: Text("手順４", style: leadingStyle2),
                    title: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _initSounds("assets/pushDown.mp3");
                          });
                          Future.delayed(Duration(seconds: 2), () {
                            speak(textController.text);
                          });
                        },
                        child: Text("入力したテキストを読ませる")),
                  ),
                ],
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('assets/bg.png'),
                fit: BoxFit.fill,
              )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 180,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Text(
                      inputText,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: active ? Colors.pink : Colors.white.withOpacity(0.0),
          onPressed: () {
            setState(() {
              active = !active;
            });
          },
          child: Icon(
              active ? Icons.change_circle : Icons.change_circle_outlined,
              size: 40)),
    );
  }
}
