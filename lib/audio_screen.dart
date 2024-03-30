import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final player = AudioPlayer();
  Duration? duration;
  ConcatenatingAudioSource? playlist;
  late Stream<Duration?>? _positionStream;

  int selectedIndex = 0;
  @override
  void initState() {
    onInitState();
    // TODO: implement initState
    super.initState();
  }

  void onInitState() async {
    playlist = ConcatenatingAudioSource(
      // Start loading next item just before reaching it
      useLazyPreparation: true,
      // Customise the shuffle algorithm
      shuffleOrder: DefaultShuffleOrder(),
      // Specify the playlist items
      children: [
        AudioSource.uri(Uri.parse(
            'https://pagalfree.com/musics/128-Ghagra%20-%20Crew%20128%20Kbps.mp3')),
        // AudioSource.uri(Uri.parse(
        //     'https://pagalfree.com/musics/128-Abrars%20Entry%20Jamal%20Kudu%20-%20Animal%20128%20Kbps.mp3')),
        // AudioSource.uri(Uri.parse(
        //     'https://pagalfree.com/musics/128-Zinda%20Banda%20-%20Jawan%20128%20Kbps.mp3')),
      ],
    );

    if (playlist == null) return;
    await player.setAudioSource(playlist!,
        initialIndex: 0, initialPosition: Duration.zero);

    // duration = await player.setUrl(// Load a URL
    //     'https://samplelib.com/lib/preview/mp3/sample-15s.mp3');

    // log('durtion is $duration'); // Schemes: (https: | file: | asset: )
    // player.play();
  }

  void onPlayerListon() {
    player.playerStateStream.listen((event) {
      log('player event is $event');
    });
  }

  @override
  Widget build(BuildContext context) {
    _positionStream = player.positionStream;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoButton(
            child: Container(
              width: double.infinity,
              height: 100,
              color: Colors.amber,
            ),
            onPressed: () {
              onInitState();
            },
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () async {
                    // await player.seekToNext(); // Skip to the next item
                  },
                  icon: const Icon(Icons.ac_unit_outlined)),
              IconButton(
                  onPressed: () async {
                    await player.seekToPrevious();
                  },
                  icon: const Icon(Icons.account_balance_outlined)),
            ],
          ),
          Expanded(
              child: ListView(
            children: List.generate(
                3,
                (index) => CupertinoButton(
                      onPressed: () async {
                        // await player.seek(Duration.zero, index: index);

                        if (playlist == null) return;
                        duration = await player.setAudioSource(playlist!,
                            initialIndex: index,
                            initialPosition: Duration.zero);

                        onPlayerListon();
                        await player.play();

                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color: Colors.amber,
                          width: double.infinity,
                          height: 120,
                          child: Column(
                            children: [
                              Center(child: Text('audio ${index + 1}')),
                              selectedIndex == index
                                  ? StreamBuilder<Duration?>(
                                      stream: _positionStream,
                                      builder: (context, snapshot) {
                                        final position =
                                            snapshot.data ?? Duration.zero;
                                        return Slider(
                                          value: position.inSeconds.toDouble(),
                                          onChanged: (value) {
                                            player.seek(Duration(
                                                seconds: value.toInt()));
                                          },
                                          min: 0.0,
                                          max: duration?.inSeconds.toDouble() ??
                                              0.0,
                                        );
                                      },
                                    )
                                  : StreamBuilder<Duration?>(
                                      stream: null,
                                      builder: (context, snapshot) {
                                        final position =
                                            snapshot.data ?? Duration.zero;
                                        return Slider(
                                          value: position.inSeconds.toDouble(),
                                          onChanged: (value) {
                                            player.seek(Duration(
                                                seconds: value.toInt()));
                                          },
                                          min: 0.0,
                                          max: 0.0,
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ),
                    )),
          ))
        ],
      ),
    );
  }
}
