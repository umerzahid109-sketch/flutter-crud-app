// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'data/repositories/course_repository.dart';
import 'state/course_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthController _authController = AuthController();

  // Built once and shared with the whole course feature subtree. The provider
  // is created above MaterialApp so it is reachable from every pushed route.
  final CourseRepository _courseRepository = CourseRepository();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CourseProvider>(
          create: (_) => CourseProvider(repository: _courseRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Auth App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2962FF),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0A0F1E),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: LoginScreen(authController: _authController),
      ),
    );
  }
}
