import 'package:flutter/material.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services here (e.g., Firebase, Local Storage, GetIt Locator)
  // await Firebase.initializeApp();
  // setupLocator();

  runApp(const PikMyCarApp());
}
