// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:week6/models/catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartModel extends ChangeNotifier {
  /// The private field backing [catalog].
  late CatalogModel _catalog;

  /// Internal, private state of the cart. Stores the ids of each item.
  final List<int> _itemIds = [];

  CartModel({required CatalogModel catalog}) {
    _catalog = catalog;
    _loadItems();
  }

  /// The current catalog. Used to construct items from numeric ids.
  CatalogModel get catalog => _catalog;

  set catalog(CatalogModel newCatalog) {
    _catalog = newCatalog;
    notifyListeners();
  }

  /// List of items in the cart.
  List<Item> get items => _itemIds.map((id) => _catalog.getById(id)).toList();

  /// The current total price of all items.
  int get totalPrice =>
      items.fold(0, (total, current) => total + current.price);

  /// Adds [item] to cart.
  void add(Item item) {
    _itemIds.add(item.id);
    _saveItems();
    notifyListeners();
  }

  /// Removes [item] from cart.
  void remove(Item item) {
    _itemIds.remove(item.id);
    _saveItems();
    notifyListeners();
  }

  /// Removes all items from the cart.
  void removeAll() {
    _itemIds.clear();
    _saveItems();
    notifyListeners();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemIds = prefs.getStringList('cart_items_ids') ?? [];
    _itemIds.clear();
    _itemIds.addAll(itemIds.map(int.parse));
    notifyListeners();
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemIdsString = _itemIds.map((id) => id.toString()).toList();
    await prefs.setStringList('cart_items_ids', itemIdsString);
  }
}
