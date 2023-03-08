import 'package:flutter/material.dart';
import 'package:memorize_scripture/pages/practice/practice_page_manager.dart';
import 'package:test/test.dart';

import 'mocks/data_repo_mocks.dart';

void main() {
  test('init on empty collection', () async {
    final manager = PracticePageManager(dataRepository: EmptyDataRepo());

    await manager.init('whatever');

    expect(manager.answerNotifier.value, const TextSpan());
    expect(manager.isShownNotifier.value, false);
  });

  test('init with collection', () async {
    final manager = PracticePageManager(dataRepository: MockDataRepo());

    await manager.init('whatever');

    expect(manager.answerNotifier.value, const TextSpan());
    expect(manager.isShownNotifier.value, false);
  });

  test('showNextWordHint', () async {
    final manager = PracticePageManager(dataRepository: MockDataRepo());
    await manager.init('whatever');

    manager.showNextWordHint();

    var textBefore = manager.answerNotifier.value.children?.first as TextSpan;
    var textAfter = manager.answerNotifier.value.children?.last as TextSpan;
    expect(textBefore.text, 'one ');
    expect(textAfter.text, 'two three');

    manager.showNextWordHint();

    textBefore = manager.answerNotifier.value.children?.first as TextSpan;
    textAfter = manager.answerNotifier.value.children?.last as TextSpan;
    expect(textBefore.text, 'one two ');
    expect(textAfter.text, 'three');

    manager.showNextWordHint();

    textBefore = manager.answerNotifier.value.children?.first as TextSpan;
    textAfter = manager.answerNotifier.value.children?.last as TextSpan;
    expect(textBefore.text, 'one two three ');
    expect(textAfter.text, '');
  });

  test('showFirstLettersHint', () async {
    final manager = PracticePageManager(dataRepository: MockDataRepo());
    await manager.init('whatever');

    manager.showFirstLettersHint();

    var text = manager.answerNotifier.value.text;
    expect(text, 'o t t');
  });

  test('show', () async {
    final manager = PracticePageManager(dataRepository: MockDataRepo());

    await manager.init('whatever');
    manager.show();

    final text = manager.answerNotifier.value.text;
    expect(text, 'one two three');
    expect(manager.isShownNotifier.value, true);
  });

  test('onResponse', () async {
    // There are two verses

    final manager = PracticePageManager(dataRepository: MockDataRepo());
    await manager.init('whatever');

    // mark the first one as hard
    // it should go to the end of the list

    manager.show();
    var prompt = manager.promptNotifier.value;
    var answer = manager.answerNotifier.value.text;
    expect(prompt, 'a 1');
    expect(answer, 'one two three');
    expect(manager.isShownNotifier.value, true);

    manager.onResponse(Difficulty.hard);

    prompt = manager.promptNotifier.value;
    answer = manager.answerNotifier.value.text;
    expect(prompt, 'a 2');
    expect(answer, null);
    expect(manager.isShownNotifier.value, false);

    // mark the next one as easy
    // it should be removed from the list

    manager.show();
    prompt = manager.promptNotifier.value;
    answer = manager.answerNotifier.value.text;
    expect(prompt, 'a 2');
    expect(answer, 'four five six');
    expect(manager.isShownNotifier.value, true);

    manager.onResponse(Difficulty.easy);

    prompt = manager.promptNotifier.value;
    answer = manager.answerNotifier.value.text;
    expect(prompt, 'a 1');
    expect(answer, null);
    expect(manager.isShownNotifier.value, false);

    // mark the remaining one as hard

    manager.show();
    prompt = manager.promptNotifier.value;
    answer = manager.answerNotifier.value.text;
    expect(prompt, 'a 1');
    expect(answer, 'one two three');
    expect(manager.isShownNotifier.value, true);

    manager.onResponse(Difficulty.hard);

    prompt = manager.promptNotifier.value;
    answer = manager.answerNotifier.value.text;
    expect(prompt, 'a 1');
    expect(answer, null);
    expect(manager.isShownNotifier.value, false);

    // since it was marked hard, it's still there

    manager.show();
    prompt = manager.promptNotifier.value;
    answer = manager.answerNotifier.value.text;
    expect(prompt, 'a 1');
    expect(answer, 'one two three');
    expect(manager.isShownNotifier.value, true);

    // mark it as ok now. This finishes the collection.

    manager.onResponse(Difficulty.ok);

    prompt = manager.promptNotifier.value;
    answer = manager.answerNotifier.value.text;
    expect(prompt, '');
    expect(answer, null);
    expect(manager.isShownNotifier.value, false);
  });
}
