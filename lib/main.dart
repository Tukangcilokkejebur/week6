// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:week6/common/theme.dart';
import 'package:week6/models/cart.dart';
import 'package:week6/models/catalog.dart';
import 'package:week6/screens/cart.dart';
import 'package:week6/screens/catalog.dart';
import 'package:week6/screens/login.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupWindow();
  runApp(const MyApp());
}

const double windowWidth = 400;
const double windowHeight = 800;

void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    setWindowTitle('Provider Demo');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(
        Rect.fromCenter(
          center: screen!.frame.center,
          width: windowWidth,
          height: windowHeight,
        ),
      );
    });
  }
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const MyLogin()),
      GoRoute(
        path: '/catalog',
        builder: (context, state) => const MyCatalog(),
        routes: [
          GoRoute(path: 'cart', builder: (context, state) => const MyCart()),
        ],
      ),
    ],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CatalogModel>(create: (_) => CatalogModel()),

        ChangeNotifierProxyProvider<CatalogModel, CartModel>(
          create: (context) {
            final catalog = Provider.of<CatalogModel>(context, listen: false);
            return CartModel(catalog: catalog);
          },
          update: (context, catalog, cart) {
            if (cart == null) {
              throw ArgumentError.notNull('cart');
            }
            cart.catalog = catalog;
            return cart;
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'Provider Demo',
        theme: appTheme,
        routerConfig: createRouter(),
      ),
    );
  }
}
