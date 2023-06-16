import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';
import 'package:test/test.dart';

import 'mocks/data_repo_mocks.dart';
import 'mocks/user_settings_mock.dart';

void main() {
  test('init on empty collection', () async {
    final manager = PracticePageManager(
      dataRepository: EmptyDataRepo(),
      userSettings: MockUserSettings(),
    );

    await manager.init(collectionId: 'whatever');

    expect(manager.verseTextNotifier.value, const TextSpan());
    expect(manager.isShowingAnswerNotifier.value, false);
  });

  test('init with collection', () async {
    final manager = PracticePageManager(
      dataRepository: MockDataRepo(),
      userSettings: MockUserSettings(),
    );

    await manager.init(collectionId: 'whatever');

    expect(manager.verseTextNotifier.value, const TextSpan());
    expect(manager.isShowingAnswerNotifier.value, false);
  });

  test('showNextWordHint', () async {
    final manager = PracticePageManager(
      dataRepository: MockDataRepo(),
      userSettings: MockUserSettings(),
    );
    await manager.init(collectionId: 'whatever');

    manager.showNextWordHint();

    var textBefore =
        manager.verseTextNotifier.value.children?.first as TextSpan;
    var textAfter = manager.verseTextNotifier.value.children?.last as TextSpan;
    expect(textBefore.text, 'one ');
    expect(textAfter.text, 'two three');

    manager.showNextWordHint();

    textBefore = manager.verseTextNotifier.value.children?.first as TextSpan;
    textAfter = manager.verseTextNotifier.value.children?.last as TextSpan;
    expect(textBefore.text, 'one two ');
    expect(textAfter.text, 'three');

    manager.showNextWordHint();

    textBefore = manager.verseTextNotifier.value.children?.first as TextSpan;
    textAfter = manager.verseTextNotifier.value.children?.last as TextSpan;
    expect(textBefore.text, 'one two three ');
    expect(textAfter.text, '');
  });

  test('showFirstLettersHint', () async {
    final manager = PracticePageManager(
      dataRepository: MockDataRepo(),
      userSettings: MockUserSettings(),
    );
    await manager.init(collectionId: 'whatever');

    manager.showFirstLettersHint();

    var text = manager.verseTextNotifier.value.text;
    expect(text, 'o t t');
  });

  test('show', () async {
    final manager = PracticePageManager(
      dataRepository: MockDataRepo(),
      userSettings: MockUserSettings(),
    );

    await manager.init(collectionId: 'whatever');
    manager.show();

    final text = manager.verseTextNotifier.value.text;
    expect(text, 'one two three');
    expect(manager.isShowingAnswerNotifier.value, true);
  });

  test('onResponse', () async {
    // There are two verses

    final manager = PracticePageManager(
      dataRepository: MockDataRepo(),
      userSettings: MockUserSettings(),
    );
    await manager.init(collectionId: 'whatever');

    // mark the first one as hard
    // it should go to the end of the list

    manager.show();
    var prompt = manager.promptNotifier.value;
    var verseText = manager.verseTextNotifier.value.text;
    expect(prompt, 'a 1');
    expect(verseText, 'one two three');
    expect(manager.isShowingAnswerNotifier.value, true);

    manager.onResponse(Difficulty.hard);

    prompt = manager.promptNotifier.value;
    verseText = manager.verseTextNotifier.value.text;
    expect(prompt, 'a 2');
    expect(verseText, null);
    expect(manager.isShowingAnswerNotifier.value, false);

    // mark the next one as easy
    // it should be removed from the list

    manager.show();
    prompt = manager.promptNotifier.value;
    verseText = manager.verseTextNotifier.value.text;
    expect(prompt, 'a 2');
    expect(verseText, 'four five six');
    expect(manager.isShowingAnswerNotifier.value, true);

    manager.onResponse(Difficulty.easy);

    prompt = manager.promptNotifier.value;
    verseText = manager.verseTextNotifier.value.text;
    expect(prompt, 'a 1');
    expect(verseText, null);
    expect(manager.isShowingAnswerNotifier.value, false);

    // mark the remaining one as hard

    manager.show();
    prompt = manager.promptNotifier.value;
    verseText = manager.verseTextNotifier.value.text;
    expect(prompt, 'a 1');
    expect(verseText, 'one two three');
    expect(manager.isShowingAnswerNotifier.value, true);

    manager.onResponse(Difficulty.hard);

    prompt = manager.promptNotifier.value;
    verseText = manager.verseTextNotifier.value.text;
    expect(prompt, 'a 1');
    expect(verseText, null);
    expect(manager.isShowingAnswerNotifier.value, false);

    // since it was marked hard, it's still there

    manager.show();
    prompt = manager.promptNotifier.value;
    verseText = manager.verseTextNotifier.value.text;
    expect(prompt, 'a 1');
    expect(verseText, 'one two three');
    expect(manager.isShowingAnswerNotifier.value, true);

    // mark it as ok now. This finishes the collection.

    manager.onResponse(Difficulty.ok);

    prompt = manager.promptNotifier.value;
    verseText = manager.verseTextNotifier.value.text;
    expect(prompt, '');
    expect(verseText, null);
    expect(manager.isShowingAnswerNotifier.value, false);
  });
}
