import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/user_provider.dart';

import 'screens/login_screen.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
       
        ChangeNotifierProvider(create: (_) => UserProvider()),
       
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
 
    
    return MaterialApp(
      title: 'Quản lý chi tiêu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      
        useMaterial3: true, 
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const LoginScreen(), 
      debugShowCheckedModeBanner: false,
    );
  }
}