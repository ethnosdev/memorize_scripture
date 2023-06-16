# Memorize Scripture

A scripture memory app.

Android: https://play.google.com/store/apps/details?id=dev.ethnos.memorize_scripture
Apple: https://apps.apple.com/us/app/memorize-scripture-ethnosdev/id6449814205

## Tasks for testers

How would you:

- Add a new collection?
- Rename a collection?
- Delete a collection?
- Put the collections in a different order?
- Add a new verse?
- Practice the verses in a collection?
- Play all of the verses in all of the collections?
- Play only the verses in a single collection?

## Backup/restore format

```json
{
    "version": "1",
    "date": "2023-03-01T12:54:54.179",
    "collections": [
        {
            "id": "001",
            "title": "Proverbs 3",
            "verses": [
                {
                    "translation": "ESV",
                    "prompt": "Proverbs 3:1",
                    "text": "jahsd jhsd jh asdjh adjs"
                },
                {
                    "translation": "ESV",
                    "prompt": "Proverbs 3:2",
                    "text": "jahsd jhsd js"
                },
            ]
        },
        {
            "id": "002",
            "title": "John 15",
            "verses": [
                {
                    "translation": "ESV",
                    "prompt": "John 15:1",
                    "text": "jahsd jhsd jh asdjh adjs"
                },
                {
                    "translation": "ESV",
                    "prompt": "John 15:2",
                    "text": "jahsd jhsd js"
                },
            ]
        },
    ]
}
```