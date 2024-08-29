import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:voive_recorder_app/audio_item.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Home> {
  final _record = AudioRecorder();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final TextEditingController _controller = TextEditingController();

  Timer? _timer;
  int _time = 0;
  bool _isrecording = true;
  String? _audioPath;

  @override
  void initState() {
    requestPermission();
    super.initState();
  }

  requestPermission() async {
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        _time++;
      });
    });
  }

  Future<void> _start() async {
    try {
      if (await _record.hasPermission()) {
        Directory? _dir;

        if (Platform.isIOS) {
          _dir = await getApplicationDocumentsDirectory();
        } else {
          _dir = Directory('/storage/emulated/0/Download/');
          if (!await _dir.exists())
            _dir = (await getExternalStorageDirectory());
        }
        String fullPath = '${_dir?.path}${_controller.text}.m4a';
        await _record.start(
          const RecordConfig(),
          path: fullPath,
        );
      }
    } catch (e) {
      log(e.toString() as num);
    }
  }

  Future<void> _stop() async {
    final path = await _record.stop();
    _audioPath = path;
    if (_audioPath?.isNotEmpty ?? false) {
      log((path ?? "") as num);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _record.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 500,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: IconButton(
                    icon: Image.asset("images/logo.png"),
                    onPressed: () {
                      if (_isrecording) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 150,
                                    width: 350,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(20),
                                          height: 50,
                                          child: Material(
                                            child: TextField(
                                              controller: _controller,
                                              textAlignVertical:
                                                  TextAlignVertical.center,
                                              decoration: const InputDecoration(
                                                  isDense: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(),
                                                  contentPadding:
                                                      EdgeInsets.all(12)),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 80,
                                            color: Colors.blue,
                                            alignment: Alignment.center,
                                            child: const Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            if (_controller.text.isNotEmpty) {
                                              _start();
                                              _startTimer();
                                              setState(() {
                                                _isrecording = false;
                                              });
                                            }
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 80,
                                            color: Colors.blue,
                                            alignment: Alignment.center,
                                            child: const Text(
                                              "Save",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.none),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            });
                      } else {
                        _stop();
                        _timer?.cancel();
                        setState(() {
                          _isrecording = true;
                          _time = 0;
                        });
                      }
                    },
                  ),
                ),
                Text(
                  formattedTime(timeInSecond: _time),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 55,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 550,
            child: FutureBuilder<List<SongModel>>(
              future: _audioQuery.querySongs(
                sortType: null,
                orderType: OrderType.ASC_OR_SMALLER,
                uriType: UriType.EXTERNAL,
                ignoreCase: true,
              ),
              builder: (context, item) {
                if (item.data == null) return const CircularProgressIndicator();
                if (item.data!.isEmpty) return const Text("Nothing found");
                final data = item.data
                        ?.where((item) => item.fileExtension == 'm4a')
                        .toList() ??
                    [];
                return Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return AudioItem(item: data[index]);
                        })
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

String formattedTime({required int timeInSecond}) {
  int sec = timeInSecond % 60;
  int min = (timeInSecond / 60).floor();
  String minute = min.toString().length <= 1 ? '0$min' : '$min';
  String second = sec.toString().length <= 1 ? '0$sec' : '0$sec';
  return '$minute:$second';
}
