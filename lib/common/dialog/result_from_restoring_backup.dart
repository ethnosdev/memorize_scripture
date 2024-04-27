String resultOfRestoringBackup(int added, int updated, int errorCount) {
  // 000
  if (added == 0 && updated == 0 && errorCount == 0) {
    return 'No verses were added or updated.';
  }
  // 001
  if (added == 0 && updated == 0 && errorCount != 0) {
    final verses = (errorCount == 1) ? 'verse' : 'verses';
    return '$errorCount $verses had errors and couldn\'t be imported.';
  }
  // 010
  if (added == 0 && updated != 0 && errorCount == 0) {
    return '$updated ${_versesWere(updated)} updated.';
  }
  // 011
  if (added == 0 && updated != 0 && errorCount != 0) {
    return '$updated ${_versesWere(updated)} updated, '
        'but $errorCount ${_versesWere(errorCount)} not '
        'added because of errors.';
  }
  // 100
  if (added != 0 && updated == 0 && errorCount == 0) {
    return '$added ${_versesWere(added)} added.';
  }
  // 101
  if (added != 0 && updated == 0 && errorCount != 0) {
    return '$added ${_versesWere(added)} added, '
        'but $errorCount ${_versesWere(errorCount)} not '
        'added because of errors.';
  }
  // 110
  if (added != 0 && updated != 0 && errorCount == 0) {
    return '$added ${_versesWere(added)} added, '
        'and $updated ${_versesWere(updated)} updated.';
  }

  /// 111
  return '$added ${_versesWere(added)} added, '
      '$updated ${_versesWere(updated)} updated, '
      'and $errorCount ${_versesWere(errorCount)} not added because of errors.';
}

String _versesWere(int count) {
  if (count == 1) return 'verse was';
  return 'verses were';
}
