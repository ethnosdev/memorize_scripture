## 1.6.0

- Add custom verse hint.

## 1.5.0 - August 19, 2023

- Optional daily reminder notifications available in settings.
- Apply color theme to settings screen.
- Show loading indicator while collection list is loading.
- Revert hiding the hint buttons when showing the verse text (from version 1.4.0). Just remove the box around the buttons to save space.
- Fix bug where editing a new verse on the second pass loses progress.

## 1.4.2 - August 10, 2023

- Fix practice screen not updating after editing verse.

## 1.4.1 - August 9, 2023

- Bug fix for iOS version. File picker permissions.

## 1.4.0 - August 7, 2023

- Backup and restore with .json file formatting.
- Tap letter hint word again to hide word.
- Move verse to other collection.
- Fix bug where editing resets progress.
- Tap word hints area to show next word.
- Hide hint box when showing answer.
- Reset due dates for entire collection.
- Undo last practice response.
- Share individual collections without progress data.
- Make 4-button mode the default rather than 2-button mode.
- Button to practice all verses in collection regardless of due date (casual practice mode).
- Make display name shorter on iOS.

## 1.3.0 - July 26, 2023

- Tap the words in the letter hints to make them visible.
- Launch tutorial in an external application so users can switch back and forth.
- Suggest keyboard capitalize first word of sentence for prompt, verse text, and collection name.

## 1.2.1 - July 15, 2023

- practice: sort alphabetically by prompt rather than due date
- fix bug where pressing hard was not resetting the interval.

## 1.2.0 - July 14, 2023

- Support 4-button mode (Hard, OK, Good, Easy) and 2-button mode (Hard, Good)
- Added mokito library for better testing

## 1.1.1 - June 24, 2023

- Fix bug where tutorial link not launching on Android

## 1.1.0 - June 23, 2023

- Not prepopulating example collections.
- Adding link to tutorial.
- Moving add collection and add verse buttons to app bar.
- Making edit button more accessible on practice page.
- Combined add and edit page ui and logic.
- Reset due date by long clicking verse in verse browser.
- Made the yellow more happy.
- Fix bug with adding two words as hint.

## 1.0.0 - May 16, 2023

Basic features:

- Home screen with collection list.
- Can view, edit, and delete collections.
- Drawer with Settings and About
- Settings allows dark/light mode and max new verses.
- About shows title, version, and contact email.
- Practice screen shows prompt and hints for new verses and review verses.
- Hints include letters and words.
- Letter hint shows first letter of every word.
- Word hind shows one more word for each press.
- Answer button shows answer and reveals response buttons.
- Three response buttons: Hard, OK, Easy.
- Hard puts new verses three back in line and review verses at the end of the list.
- OK puts new verses at the end of the list and schedules review verses some interval number of days in the future.
- Easy schedules verses double the number of the interval days in the future.
- Verses and collections are saved locally in a SQLite database.
- Can add new verses and edit existing verses.
