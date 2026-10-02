import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/adoption_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/map_provider.dart';
import '../providers/pet_provider.dart';
import '../providers/store_provider.dart';
import '../providers/theme_provider.dart';
import '../repositories/database_repository.dart';
import '../services/auth_service.dart';
import 'routes.dart';
import 'theme.dart';

/// Root Application Widget for Whisker World
class WhiskerWorldApp extends StatefulWidget {
  final DatabaseRepository repository;
  final AuthService authService;

  const WhiskerWorldApp({
    super.key,
    required this.repository,
    required this.authService,
  });

  @override
  State<WhiskerWorldApp> createState() => _WhiskerWorldAppState();
}

class _WhiskerWorldAppState extends State<WhiskerWorldApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(authService: widget.authService);
    _router = AppRoutes.createRouter(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(
          create: (_) => PetProvider(repository: widget.repository)..fetchPets(),
        ),
        ChangeNotifierProvider(
          create: (_) => StoreProvider(repository: widget.repository)..fetchStores(),
        ),
        ChangeNotifierProvider(
          create: (_) => AdoptionProvider(repository: widget.repository),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoriteProvider(repository: widget.repository),
        ),
        ChangeNotifierProvider(
          create: (_) => MapProvider(repository: widget.repository),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Whisker World',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
