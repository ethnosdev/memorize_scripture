import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/pages/home/home_page_manager.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:uuid/uuid.dart';

Future<Collection?> showEditCollectionDialog(
  BuildContext context, {
  HomePageManager? manager,
  Collection? oldCollection,
  String? defaultName,
}) async {
  final pageManager = manager ??
      (getIt.isRegistered<HomePageManager>()
          ? getIt<HomePageManager>()
          : null);
  final oldName = oldCollection?.name;
  final initialName = oldName ?? defaultName ?? '';
  final nameController = TextEditingController(text: initialName);
  if (initialName.isNotEmpty) {
    nameController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: initialName.length,
    );
  }
  StudyStyle studyStyle =
      oldCollection?.studyStyle ?? StudyStyle.spacedRepetition;

  // Same number per day
  final versesPerDay =
      oldCollection?.versesPerDay ?? Collection.defaultVersesPerDay;
  final versesPerDayController =
      TextEditingController(text: versesPerDay.toString());

  // Fixed days
  final goodDaysController =
      TextEditingController(text: pageManager?.fixedGoodDays ?? '1');
  final easyDaysController =
      TextEditingController(text: pageManager?.fixedEasyDays ?? '4');

  return showDialog<Collection>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          void submit() {
            final trimmedName = nameController.text.trim();
            if (trimmedName.isEmpty) return;
            if (pageManager != null) {
              pageManager.fixedGoodDays = goodDaysController.text;
              pageManager.fixedEasyDays = easyDaysController.text;
            }
            Navigator.of(context).pop(
              Collection(
                id: oldCollection?.id ?? const Uuid().v4(),
                name: trimmedName,
                studyStyle: studyStyle,
                versesPerDay:
                    int.tryParse(versesPerDayController.text) ??
                        Collection.defaultVersesPerDay,
                createdDate:
                    oldCollection?.createdDate ?? DateTime.now(),
              ),
            );
          }

          return AlertDialog(
            title: const Text("Collection"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: oldName == null,
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (value) {
                      setState(() {});
                    },
                    onSubmitted: (_) => submit(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<StudyStyle>(
                    isExpanded: true,
                    initialValue: studyStyle,
                    items: const [
                      DropdownMenuItem(
                        value: StudyStyle.spacedRepetition,
                        child: Text('Spaced repetition'),
                      ),
                      DropdownMenuItem(
                        value: StudyStyle.fixedDays,
                        child: Text('Choose frequency'),
                      ),
                      DropdownMenuItem(
                        value: StudyStyle.sameNumberPerDay,
                        child: Text('Fixed number of verses'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        studyStyle = value!;
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: 'Review style'),
                  ),
                  if (studyStyle != StudyStyle.spacedRepetition)
                    const SizedBox(height: 16),
                  if (studyStyle == StudyStyle.sameNumberPerDay)
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: versesPerDayController,
                      decoration: const InputDecoration(
                        labelText: 'Verses per day',
                      ),
                    ),
                  if (studyStyle == StudyStyle.fixedDays) ...[
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: goodDaysController,
                      decoration: const InputDecoration(
                        labelText: 'Days for Good',
                      ),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: easyDaysController,
                      decoration: const InputDecoration(
                        labelText: 'Days for Easy',
                      ),
                    ),
                  ]
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: nameController.text.trim().isEmpty ? null : submit,
                child: const Text("OK"),
              )
            ],
          );
        },
      );
    },
  );
}
