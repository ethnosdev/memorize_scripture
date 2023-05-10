import 'package:memorize_scripture/common/verse.dart';
import 'package:uuid/uuid.dart';

final sampleVerses = [
  Verse(
    id: const Uuid().v4(),
    prompt: 'John 3:16',
    answer: 'For God so loved the world, that he gave his one and only Son, '
        'that whoever believes in him should not perish, but have eternal life.'
        '\nJohn 3:16 (WEB)',
    nextDueDate: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Matthew 28:19-20',
    answer: 'Go and make disciples of all nations, baptizing them in the name '
        'of the Father and of the Son and of the Holy Spirit, teaching them to '
        'observe all things that I commanded you. Behold, I am with you '
        'always, even to the end of the age.'
        '\nMatthew 28:19-20 (WEB)',
    nextDueDate: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Philippians 4:13',
    answer: 'I can do all things through Christ, who strengthens me.'
        '\nPhilippians 4:13 (WEB)',
    nextDueDate: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Galatians 2:20',
    answer: 'I have been crucified with Christ, and it is no longer I who '
        'live, but Christ lives in me. That life which I now live in the '
        'flesh, I live by faith in the Son of God, who loved me, and gave '
        'himself up for me.'
        '\nGalatians 2:20 (WEB)',
    nextDueDate: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Proverbs 3:5-6',
    answer: 'Trust in Yahweh with all your heart, and don’t lean on your own '
        'understanding. In all your ways acknowledge him, and he will make '
        'your paths straight.'
        '\nProverbs 3:5-6 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Romans 8:28',
    answer: 'We know that all things work together for good for those who love '
        'God, for those who are called according to his purpose.'
        '\nRomans 8:28 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: '1 Thessalonians 5:16-18',
    answer: 'Always rejoice. Pray without ceasing. In everything give thanks, '
        'for this is the will of God in Christ Jesus toward you.'
        '\n1 Thessalonians 5:16-18 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: '2 Corinthians 5:17',
    answer: 'Therefore if anyone is in Christ, he is a new creation. The old '
        'things have passed away. Behold, all things have become new. '
        '\n2 Corinthians 5:17 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: '2 Timothy 3:16-17',
    answer: 'Every Scripture is God-breathed and profitable for teaching, for '
        'reproof, for correction, and for instruction in righteousness, that '
        'each person who belongs to God may be complete, thoroughly equipped '
        'for every good work.'
        '\n2 Timothy 3:16-17 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Ephesians 2:8-9',
    answer: 'for by grace you have been saved through faith, and that not of '
        'yourselves; it is the gift of God, not of works, that no one '
        'would boast.'
        '\nEphesians 2:8-9 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Ephesians 4:32',
    answer: 'And be kind to one another, tender hearted, forgiving each other, '
        'just as God also in Christ forgave you.'
        '\nEphesians 4:32 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'John 14:6',
    answer: 'I am the way, the truth, and the life. No one comes to the'
        ' Father, except through me.'
        '\nJohn 14:6 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Matthew 5:16',
    answer: 'Even so, let your light shine before men, that they may see your '
        'good works and glorify your Father who is in heaven.'
        '\nMatthew 5:16 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Matthew 6:33',
    answer: 'But seek first God’s Kingdom and his righteousness; and all these '
        'things will be given to you as well.'
        '\nMatthew 6:33 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Romans 3:23',
    answer: 'for all have sinned, and fall short of the glory of God;'
        '\nRomans 3:23 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Romans 5:8',
    answer: 'But God commends his own love toward us, in that while we were '
        'yet sinners, Christ died for us.'
        '\nRomans 5:8 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Romans 6:23',
    answer: 'For the wages of sin is death, but the free gift of God is '
        'eternal life in Christ Jesus our Lord.'
        '\nRomans 6:23 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: '1 John 1:9',
    answer: 'If we confess our sins, he is faithful and righteous to forgive '
        'us the sins, and to cleanse us from all unrighteousness.'
        '\n1 John 1:9 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: '1 Peter 5:6-7',
    answer: 'Humble yourselves therefore under the mighty hand of God, that '
        'he may exalt you in due time, casting all your worries on him, '
        'because he cares for you.'
        '\n1 Peter 5:6-7 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: '2 Corinthians 9:7',
    answer: 'Let each man give according as he has determined in his heart, '
        'not grudgingly or under compulsion, for God loves a cheerful giver.'
        '\n2 Corinthians 9:7 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Galatians 5:22-23',
    answer: 'But the fruit of the Spirit is love, joy, peace, patience, '
        'kindness, goodness, faith, gentleness, and self-control. Against '
        'such things there is no law.'
        '\nGalatians 5:22-23 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Hebrews 11:1',
    answer: 'Now faith is assurance of things hoped for, proof of things '
        'not seen.'
        '\nHebrews 11:1 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Hebrews 4:16',
    answer: 'Let’s therefore draw near with boldness to the throne of grace, '
        'that we may receive mercy and may find grace for help in time '
        'of need.'
        '\nHebrews 4:16 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Jeremiah 29:11',
    answer: 'For I know the thoughts that I think toward you,” says Yahweh, '
        '“thoughts of peace, and not of evil, to give you hope and a future.'
        '\nJeremiah 29:11 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Joshua 1:9',
    answer: 'Haven’t I commanded you? Be strong and courageous. Don’t be '
        'afraid. Don’t be dismayed, for Yahweh your God is with you '
        'wherever you go.'
        '\nJoshua 1:9 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Lamentations 3:22-23',
    answer: 'It is because of Yahweh’s loving kindnesses that we are not '
        'consumed, because his compassion doesn’t fail. They are new '
        'every morning. Great is your faithfulness.'
        '\nLamentations 3:22-23 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Luke 9:23',
    answer: 'If anyone desires to come after me, let him deny himself, take up '
        'his cross, and follow me.'
        '\nLuke 9:23 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Matthew 11:28',
    answer: 'Come to me, all you who labor and are heavily burdened, and I '
        'will give you rest.'
        '\nMatthew 11:28 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Matthew 4:19',
    answer: 'He said to them, “Come after me, and I will make you fishers '
        'for men.”'
        '\nMatthew 4:19 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Matthew 6:34',
    answer: 'Therefore don’t be anxious for tomorrow, for tomorrow will be '
        'anxious for itself. Each day’s own evil is sufficient.'
        '\nMatthew 6:34 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Philippians 4:4',
    answer: 'Rejoice in the Lord always! Again I will say, “Rejoice!”'
        '\nPhilippians 4:4 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Philippians 4:6-7',
    answer: 'In nothing be anxious, but in everything, by prayer and petition '
        'with thanksgiving, let your requests be made known to God. 7 And '
        'the peace of God, which surpasses all understanding, will guard '
        'your hearts and your thoughts in Christ Jesus.'
        '\nPhilippians 4:6-7 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Psalm 46:1',
    answer: 'God is our refuge and strength, a very present help in trouble.'
        '\nPsalm 46:1 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Psalm 46:10',
    answer: 'Be still, and know that I am God. I will be exalted among the '
        'nations. I will be exalted in the earth.'
        '\nPsalm 46:10 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Revelation 3:20',
    answer: 'Behold, I stand at the door and knock. If anyone hears my voice '
        'and opens the door, then I will come in to him, and will dine '
        'with him, and he with me.'
        '\nRevelation 3:20 (WEB)',
  ),
  Verse(
    id: const Uuid().v4(),
    prompt: 'Romans 8:32',
    answer: 'He who didn’t spare his own Son, but delivered him up for us '
        'all, how would he not also with him freely give us all things?'
        '\nRomans 8:32 (WEB)',
  ),
];
