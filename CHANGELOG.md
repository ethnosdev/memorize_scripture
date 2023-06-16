## 1.1.0 - June 16, 2023

- Not prepopulating example collections.
- Adding link to tutorial.
- Moving add collection and add verse buttons to app bar.
- Making edit button more accessible on practice page.
- Combined add and edit page ui and logic.
- Reset due date by long clicking verse in verse browser.
- Made the yellow more happy.

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
