import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pokedex/core/router/app_router.dart';

import 'package:pokedex/core/theme/app_status_bar_style.dart';

import 'package:pokedex/core/theme/app_theme.dart';



void main() {

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(AppStatusBarStyle.light);

  runApp(const ProviderScope(child: PokedexApp()));

}



class PokedexApp extends ConsumerWidget {

  const PokedexApp({super.key});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final router = ref.watch(goRouterProvider);



    return MaterialApp.router(

      title: 'Pokedex',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.light(),

      routerConfig: router,

    );

  }

}


