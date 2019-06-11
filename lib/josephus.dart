List<int> josephusList({int circleSize, int skipSize}) {
  init();

  final List<int> result = [];
  final List<int> circle = List.generate(circleSize, (i) => i);

  int index = 0;

  while (circle.isNotEmpty) {
    index = (index + skipSize - 1) % circle.length;
    result.add(circle.removeAt(index));
  }

  return result;
}

Map<int, List<KeyNote>> octaves = {};
List<KeyNote> standardKeys = [];
bool alreadyDoneInit = false;

void init() {
  if (alreadyDoneInit) return;
  alreadyDoneInit = true;

  for (var i = 1; i <= 7; i++) {
    final c = KeyNote('c', i);
    final cSharp = KeyNote('c', i, sharp: true);
    final d = KeyNote('d', i);
    final eFlat = KeyNote('e', i, flat: true);
    final e = KeyNote('e', i);
    final f = KeyNote('f', i);
    final fSharp = KeyNote('f', i, sharp: true);
    final g = KeyNote('g', i);
    final aFlat = KeyNote('a', i, flat: true);
    final a = KeyNote('a', i);
    final bFlat = KeyNote('b', i, flat: true);
    final b = KeyNote('b', i);

    octaves[i] = [c, cSharp, d, eFlat, e, f, fSharp, g, aFlat, a, bFlat, b];
    standardKeys
        .addAll([c, cSharp, d, eFlat, e, f, fSharp, g, aFlat, a, bFlat, b]);
  }
}

enum Step { half, whole }

final List<Step> stepIntervals = [
  Step.whole,
  Step.whole,
  Step.half,
  Step.whole,
  Step.whole,
  Step.whole,
  Step.half,
];

List rotate(List list, int offset) =>
    list.sublist(offset)..addAll(list.sublist(0, offset));

class ScaleMode {
  static final ionian = ScaleMode(
    startingNoteOffset: 0,
    formula: rotate(stepIntervals, 0),
  );
  static final dorian = ScaleMode(
    startingNoteOffset: 2,
    formula: rotate(stepIntervals, 2),
  );
  static final phyrgian = ScaleMode(
    startingNoteOffset: 3,
    formula: rotate(stepIntervals, 3),
  );
  static final lydian = ScaleMode(
    startingNoteOffset: 4,
    formula: rotate(stepIntervals, 4),
  );
  static final mixolydian = ScaleMode(
    startingNoteOffset: 5,
    formula: rotate(stepIntervals, 5),
  );
  static final aeolian = ScaleMode(
    startingNoteOffset: 1,
    formula: rotate(stepIntervals, 1),
  );
  static final locrian = ScaleMode(
    startingNoteOffset: 6,
    formula: rotate(stepIntervals, 6),
  );

  ScaleMode({this.startingNoteOffset, this.formula});

  final List<Step> formula;
  final int startingNoteOffset;
}

class KeyNote {
  final String letter;
  final int octave;
  final bool sharp;
  final bool flat;

  KeyNote(this.letter, this.octave, {this.sharp = false, this.flat = false});

  String toString() => '$letter$octave${sharp ? '♯' : ''}${flat ? '♭' : ''}';

  String toFilename() =>
      '${nonFlatEnharmonicEquivalent.letter}${sharp ? '-' : ''}$octave.ogg';

  KeyNote get nonFlatEnharmonicEquivalent {
    if (!flat) return this;

    switch (letter) {
      case 'd':
      case 'e':
      case 'g':
      case 'a':
      case 'b':
        // This -1 is safe because 'c' is handled separately.
        return KeyNote(letters[letters.indexOf(letter) - 1], octave,
            sharp: true);
      case 'f':
        return KeyNote('e', octave);
      case 'c':
        return KeyNote('b', octave);
      default:
        throw ArgumentError('hmm. The note was: $letter');
    }
  }

  KeyNote get accidentalEnharmonicEquivalent {
    if (!flat && !sharp) return this;

    if (flat) {
      switch (letter) {
        case 'f':
          return KeyNote('e', octave);
        case 'c':
          return KeyNote('b', octave);
      }
    }

    switch (letter) {
      case 'e':
        return KeyNote('e', octave);
      case 'b':
        return KeyNote('b', octave);
    }

    throw ArgumentError('expected a flat f/c, or a sharp e/b. got: $this');
  }

  KeyNote operator +(Step step) {
    final key = nonFlatEnharmonicEquivalent;

    switch (key.letter) {
      case 'c':
      case 'f':
      case 'g':
        if (step == Step.whole) {
          return KeyNote(letters[letters.indexOf(letter) + 1], octave,
              sharp: key.sharp);
        }
        if (key.sharp) {
          return KeyNote(letters[letters.indexOf(letter) + 1], octave);
        }
        return KeyNote(key.letter, octave, sharp: true);
      case 'a':
        if (key.sharp) {
          if (step == Step.half) return KeyNote('b', octave);
          return KeyNote('c', octave + 1);
        }
        if (step == Step.half) return KeyNote('a', octave, sharp: true);
        return KeyNote('b', octave);
      case 'd':
        if (key.sharp) {
          if (step == Step.half) return KeyNote('e', octave);
          return KeyNote('f', octave);
        }
        if (step == Step.half) return KeyNote('d', octave, sharp: true);
        return KeyNote('e', octave);
      case 'b':
        return KeyNote('c', octave + 1, sharp: step == Step.whole);
      case 'e':
        return KeyNote('f', octave, sharp: step == Step.whole);
    }

    return KeyNote(letters[letters.indexOf(letter) - 1], octave, sharp: true);
  }
}

class Scale {
  ScaleMode type;
  KeyNote key;
  int numOctaves;

  List<KeyNote> keys = [];

  Scale({
    this.type,
    this.key, // right now, this is only used for the octave.
    this.numOctaves = 1,
  }) {
    KeyNote previousKey = KeyNote(letters[type.startingNoteOffset], key.octave);
    keys.add(previousKey);

    // print('building keys for scale type $type, key $key');
    // print('first key: $previousKey');

    for (var i = 0; i < 7 * numOctaves; i++) {
      final key = previousKey + type.formula[i % type.formula.length];

      // print(
      //     'the ${i}th step in the formula says to take a: ${type.formula[i % type.formula.length]}');
      // print('next key: $key');

      keys.add(key);
      previousKey = key;
    }
  }
}

final letters = ['c', 'd', 'e', 'f', 'g', 'a', 'b'];
final cMajorScale = ['c4', 'd4', 'e4', 'f4', 'g4', 'a4', 'b4', 'c5'];
final cMinorScale = ['c4', 'd4', 'd-4', 'f4', 'g4', 'g-4', 'a-4', 'c5'];
final chromaticScale = [...octaves[3], 'c5'];
