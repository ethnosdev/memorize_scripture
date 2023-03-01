# memorize_scripture

A scripture memory app.

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
            "title": "Proverbs 3",
            "verses": [
                {
                    "translation": "ESV",
                    "prompt": "Proverbs 3:1",
                    "answer": "jahsd jhsd jh asdjh adjs"
                },
                {
                    "translation": "ESV",
                    "prompt": "Proverbs 3:2",
                    "answer": "jahsd jhsd js"
                },
            ]
        },
        {
            "title": "John 15",
            "verses": [
                {
                    "translation": "ESV",
                    "prompt": "John 15:1",
                    "answer": "jahsd jhsd jh asdjh adjs"
                },
                {
                    "translation": "ESV",
                    "prompt": "John 15:2",
                    "answer": "jahsd jhsd js"
                },
            ]
        },
    ]
}
```