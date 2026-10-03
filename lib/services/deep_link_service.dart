import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memorize_scripture/common/collection.dart';
import 'package:memorize_scripture/common/dialog/edit_collection_dialog.dart';
import 'package:memorize_scripture/pages/add_edit_verse/add_edit_verse_page.dart';
import 'package:memorize_scripture/pages/add_edit_verse/select_collection_sheet.dart';
import 'package:memorize_scripture/pages/home/home_page_manager.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/local_storage/local_storage.dart';

class DeepLinkData {
  final String prompt;
  final String text;
  final String? version;

  const DeepLinkData({
    required this.prompt,
    required this.text,
    this.version,
  });

  static DeepLinkData? fromUri(Uri uri) {
    final isMemorizeScriptureScheme = uri.scheme == 'memorizescripture';
    final isRoutePath = uri.scheme.isEmpty && (uri.path == '/' || uri.path == '/add');

    if (isMemorizeScriptureScheme || isRoutePath) {
      if (uri.host.isNotEmpty && uri.host != 'add') {
        return null;
      }
      final prompt = uri.queryParameters['prompt'] ?? '';
      final text = uri.queryParameters['text'] ?? '';
      final version = uri.queryParameters['version'];
      if (prompt.isNotEmpty || text.isNotEmpty) {
        return DeepLinkData(
          prompt: prompt,
          text: text,
          version: version,
        );
      }
    }
    return null;
  }
}

class DeepLinkService with WidgetsBindingObserver {
  final LocalStorage? _localStorage;
  final VoidCallback? onCollectionsChanged;
  final GlobalKey<NavigatorState> navigatorKey;
  bool _isHandling = false;

  DeepLinkService({
    LocalStorage? localStorage,
    this.onCollectionsChanged,
    GlobalKey<NavigatorState>? navigatorKey,
  })  : _localStorage = localStorage,
        navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();

  LocalStorage get _storage => _localStorage ?? getIt<LocalStorage>();

  BuildContext? get context => navigatorKey.currentContext;

  void init([BuildContext? context]) {
    WidgetsBinding.instance.removeObserver(this);
    WidgetsBinding.instance.addObserver(this);

    // Handle initial cold start link if present
    final defaultRoute =
        WidgetsBinding.instance.platformDispatcher.defaultRouteName;
    if (defaultRoute != '/' && defaultRoute.isNotEmpty) {
      final uri = Uri.tryParse(defaultRoute);
      if (uri != null && DeepLinkData.fromUri(uri) != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          handleUri(uri, context);
        });
      }
    }
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    final uri = routeInformation.uri;
    final data = DeepLinkData.fromUri(uri);
    if (data != null) {
      handleUri(uri);
      return true;
    }
    return false;
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> handleUri([dynamic arg1, dynamic arg2]) async {
    BuildContext? ctx;
    Uri? uri;
    if (arg1 is BuildContext) {
      ctx = arg1;
      if (arg2 is Uri) uri = arg2;
    } else if (arg1 is Uri) {
      uri = arg1;
      if (arg2 is BuildContext) ctx = arg2;
    }
    ctx ??= context;
    if (uri == null) return;

    if (ctx == null || !ctx.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleUri(uri);
      });
      return;
    }

    if (_isHandling) return;
    final data = DeepLinkData.fromUri(uri);
    if (data == null) return;

    _isHandling = true;
    try {
      final collections = await _storage.fetchCollections();
      if (!ctx.mounted) return;

      Collection? selectedCollection;

      if (collections.isEmpty) {
        selectedCollection = await showEditCollectionDialog(
          ctx,
          defaultName: 'Bible Verses',
        );
        if (selectedCollection != null) {
          await _storage.insertCollection(selectedCollection);
          _notifyCollectionsChanged();
        }
      } else {
        selectedCollection = await SelectCollectionSheet.show(
          ctx,
          collections: collections,
          localStorage: _storage,
          onCollectionCreated: (_) => _notifyCollectionsChanged(),
        );
        _notifyCollectionsChanged();
      }

      if (selectedCollection != null && ctx.mounted) {
        await Navigator.of(ctx).push(
          MaterialPageRoute(
            builder: (context) => AddEditVersePage(
              collectionId: selectedCollection!.id,
              initialPrompt: data.prompt,
              initialVerseText: data.text,
            ),
          ),
        );
        _notifyCollectionsChanged();
      }
    } finally {
      _isHandling = false;
    }
  }

  void _notifyCollectionsChanged() {
    if (onCollectionsChanged != null) {
      onCollectionsChanged!();
    }
    if (getIt.isRegistered<HomePageManager>()) {
      getIt<HomePageManager>().init();
    }
  }
}
