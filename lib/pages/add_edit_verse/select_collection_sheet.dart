import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/dialog/edit_collection_dialog.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/local_storage/local_storage.dart';

class SelectCollectionSheet extends StatefulWidget {
  final List<Collection> collections;
  final LocalStorage localStorage;
  final void Function(Collection)? onCollectionCreated;

  const SelectCollectionSheet({
    super.key,
    required this.collections,
    required this.localStorage,
    this.onCollectionCreated,
  });

  static Future<Collection?> show(
    BuildContext context, {
    required List<Collection> collections,
    LocalStorage? localStorage,
    void Function(Collection)? onCollectionCreated,
  }) async {
    final storage = localStorage ?? getIt<LocalStorage>();
    return showModalBottomSheet<Collection>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SelectCollectionSheet(
        collections: collections,
        localStorage: storage,
        onCollectionCreated: onCollectionCreated,
      ),
    );
  }

  @override
  State<SelectCollectionSheet> createState() => _SelectCollectionSheetState();
}

class _SelectCollectionSheetState extends State<SelectCollectionSheet> {
  late List<Collection> _collections;

  @override
  void initState() {
    super.initState();
    _collections = List.from(widget.collections);
  }

  Future<void> _createNewCollection() async {
    final newCollection = await showEditCollectionDialog(
      context,
      defaultName: 'Bible Verses',
    );

    if (newCollection != null) {
      await widget.localStorage.insertCollection(newCollection);
      widget.onCollectionCreated?.call(newCollection);
      if (mounted) {
        Navigator.of(context).pop(newCollection);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Collection',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.add_circle_outline,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      'Create new collection',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: _createNewCollection,
                  ),
                  const Divider(height: 1),
                  if (_collections.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No collections found. Tap above to create one.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    )
                  else
                    ..._collections.map(
                      (collection) => ListTile(
                        leading: const Icon(Icons.collections_bookmark_outlined),
                        title: Text(collection.name),
                        onTap: () => Navigator.of(context).pop(collection),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
