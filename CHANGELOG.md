## 1.4.0

- Backup and restore with .json file formatting.
- Tap letter hint word again to hide word.

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
