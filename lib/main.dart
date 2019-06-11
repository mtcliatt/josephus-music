import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:audioplayers/audio_cache.dart';

import 'josephus.dart';
import 'josephus_painter.dart';

void main() => runApp(new MaterialApp(home: new JosephusMusic()));

class JosephusMusic extends StatefulWidget {
  @override
  _JosephusMusicState createState() => new _JosephusMusicState();
}

class _JosephusMusicState extends State<JosephusMusic> {
  Timer _timer;
  AudioCache _player;
  AudioPlayer _currentPlayer;

  Scale _scale;
  List<int> _josephusOrdering;
  List<int> _played;
  List<KeyNote> _playedNotes;
  List<int> _executionOrdering;

  // Current index into the josephus list.
  int _index;
  int _skipSize;

  @override
  void initState() {
    _player = AudioCache();
    _index = 0;
    _played = [];
    _skipSize = 2;

    setScale(Scale(
      type: ScaleMode.ionian,
      key: KeyNote('c', 2),
      numOctaves: 2,
    ));

    super.initState();
  }

  void setScale(Scale scale) {
    setState(() {
      _timer?.cancel();
      _scale = scale;
      _index = 0;
      _played = [];
      _playedNotes = [];
      _calculateJosephusThings();
    });
  }

  void updateScale({ScaleMode type, KeyNote key, int numOctaves}) {
    type ??= _scale.type;
    key ??= _scale.key;
    numOctaves ??= _scale.numOctaves;

    setScale(Scale(type: type, key: key, numOctaves: numOctaves));
  }

  void _calculateJosephusThings() {
    _josephusOrdering =
        josephusList(circleSize: _scale.keys.length, skipSize: _skipSize);
    _executionOrdering = [];
    for (var i = 0; i < _josephusOrdering.length; i++) {
      _executionOrdering.add(_josephusOrdering.indexOf(i));
    }
  }

  void updateSkipSize(int skipSize) {
    _skipSize = skipSize;
    _calculateJosephusThings();
    setState(() {});
  }

  void play() {
    print('keys: ${_scale.keys}');
    print('josephus list for those keys: $_josephusOrdering');

    _index = 0;
    _played = [];
    _playedNotes = [];

    _timer = Timer.periodic(
      const Duration(milliseconds: 400),
      (timer) async {
        _currentPlayer?.stop();
        if (_index > _josephusOrdering.length) {
          timer.cancel();
        } else if (_index == _josephusOrdering.length) {
          return; // Let the last note play.
        }

        final keyIndex = _josephusOrdering[_index];
        print('playing key: ${_scale.keys[keyIndex]}');
        _currentPlayer =
            await _player.play('${_scale.keys[keyIndex].toFilename()}');

        setState(() {
          _played.add(keyIndex);
          _playedNotes.add(_scale.keys[keyIndex]);
          _index++;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Example'),
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text('Skip: $_skipSize'),
                        ),
                        Column(
                          children: <Widget>[
                            MaterialButton(
                              child: Text('+'),
                              onPressed: () => updateSkipSize(
                                    _skipSize + 1,
                                  ),
                              minWidth: 32,
                              color: Colors.lightBlueAccent,
                            ),
                            MaterialButton(
                              child: Text('-'),
                              onPressed: () => updateSkipSize(
                                    _skipSize - 1,
                                  ),
                              minWidth: 32,
                              color: Colors.lightBlueAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'Octaves: ${_scale.numOctaves}',
                            softWrap: true,
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            MaterialButton(
                              child: Text('+'),
                              onPressed: () => updateScale(
                                    numOctaves: _scale.numOctaves + 1,
                                  ),
                              minWidth: 32,
                              color: Colors.lightBlueAccent,
                            ),
                            MaterialButton(
                              child: Text('-'),
                              onPressed: () => updateScale(
                                    numOctaves: _scale.numOctaves - 1,
                                  ),
                              minWidth: 32,
                              color: Colors.lightBlueAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            '1st Octave: ${_scale.key.octave}',
                            softWrap: true,
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            MaterialButton(
                              child: Text('+'),
                              onPressed: () => updateScale(
                                  key: KeyNote(_scale.key.letter,
                                      _scale.key.octave + 1)),
                              minWidth: 32,
                              color: Colors.lightBlueAccent,
                            ),
                            MaterialButton(
                              child: Text('-'),
                              onPressed: () => updateScale(
                                  key: KeyNote(_scale.key.letter,
                                      _scale.key.octave - 1)),
                              minWidth: 32,
                              color: Colors.lightBlueAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: GestureDetector(
                              onTap: play,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            child: CustomPaint(
                              painter: JosephusPainter(
                                numPeople: _josephusOrdering?.length ?? 0,
                                notes: _scale.keys,
                                playOrder: _executionOrdering,
                                played: _played,
                                playedNotes: _playedNotes,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
