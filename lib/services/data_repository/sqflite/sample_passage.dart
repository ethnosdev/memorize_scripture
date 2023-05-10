import 'package:memorize_scripture/common/verse.dart';
import 'package:uuid/uuid.dart';

// Adding the nextDueDate will allow all of the verses to show as review
// even when the daily limit is only one.
final samplePassage = [
  Verse(
    id: const Uuid().v4(),
    prompt: 'Psalm 23:01',
    answer: 'Yahweh is my shepherd: I shall lack nothing.'
        '\nPsalm 23:1 (WEB)',
    nextDueDate: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Psalm 23:01 (WEB)\n'
        'Yahweh is my shepherd: I shall lack nothing.',
    answer: 'Psalm 23:02 (WEB)\n'
        'He makes me lie down in green pastures. '
        'He leads me beside still waters.',
    nextDueDate: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Psalm 23:02 (WEB)\n'
        'He makes me lie down in green pastures. '
        'He leads me beside still waters.',
    answer: 'Psalm 23:03 (WEB)\n'
        'He restores my soul. '
        'He guides me in the paths of righteousness for his name’s sake.',
    nextDueDate: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Psalm 23:03 (WEB)\n'
        'He restores my soul. '
        'He guides me in the paths of righteousness for his name’s sake.',
    answer: 'Psalm 23:04 (WEB)\n'
        'Even though I walk through the valley of the shadow of death, '
        'I will fear no evil, for you are with me. '
        'Your rod and your staff, they comfort me.',
    nextDueDate: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Psalm 23:04 (WEB)\n'
        'Even though I walk through the valley of the shadow of death, '
        'I will fear no evil, for you are with me. '
        'Your rod and your staff, they comfort me.',
    answer: 'Psalm 23:05 (WEB)\n'
        'You prepare a table before me in the presence of my enemies. '
        'You anoint my head with oil. My cup runs over.',
    nextDueDate: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Psalm 23:05 (WEB)\n'
        'You prepare a table before me in the presence of my enemies. '
        'You anoint my head with oil. My cup runs over.',
    answer: 'Psalm 23:06 (WEB)\n'
        'Surely goodness and loving kindness shall follow me all the '
        'days of my life, and I will dwell in Yahweh’s house forever.',
    nextDueDate: DateTime.fromMillisecondsSinceEpoch(0),
  ),
];
