import 'dart:math' show pi;

import 'package:flutter/material.dart';

import 'josephus.dart';

class JosephusPainter extends CustomPainter {
  JosephusPainter(
      {this.numPeople,
      this.notes,
      this.played,
      this.playedNotes,
      this.playOrder});

  final int numPeople;
  final List<int> playOrder;
  final List<int> played;
  final List<KeyNote> playedNotes;
  final List<KeyNote> notes;

  List<Offset> noteOrderTextPositions;
  List<Offset> notePositions;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(radius, radius);
    paintContent(canvas, size);
    canvas.restore();
  }

  void paintContent(Canvas canvas, Size size) {
    final angle = 2 * pi / numPeople;
    final radius = size.width / 2;
    noteOrderTextPositions = [];
    notePositions = [];

    for (var i = 0; i < numPeople; i++) {
      bool notePlayed = played.contains(i);

      Offset notePosition = Offset.fromDirection(angle * i, radius * 0.85);
      notePositions.add(notePosition);

      Color circleColor;
      Color noteColor;

      if (notePlayed) {
        noteOrderTextPositions
            .add(Offset.fromDirection(angle * i, radius * 0.65));

        // Color the last note played (the winner) note gold.
        circleColor = i == playOrder.last ? Colors.amber : Colors.red;
        noteColor = Colors.white;
      } else {
        circleColor = Colors.white;
        noteColor = Colors.black;
      }

      canvas.drawCircle(
        notePosition,
        20,
        Paint()..color = circleColor,
      );

      paintTextAt(canvas, notes[i], notePosition, noteColor);
    }

    for (var i = 0; i < noteOrderTextPositions.length; i++) {
      paintTextAt(canvas, played[i], noteOrderTextPositions[i]);
    }
  }

  void paintTextAt(Canvas canvas, dynamic text, Offset offset,
      [Color color = Colors.white]) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$text',
        style: TextStyle(
          color: color,
          fontSize: 20.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    textPainter.paint(
      canvas,
      offset - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(JosephusPainter old) => true;
}
