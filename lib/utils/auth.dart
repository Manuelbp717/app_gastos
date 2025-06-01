import 'package:aplicacion_gastos_final/pages/homepage.dart';
import 'package:aplicacion_gastos_final/pages/login.dart';
import 'package:aplicacion_gastos_final/pages/onbording.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Importa tu pantalla principal si la tienes

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Detecta el estado de autenticación
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data!.emailVerified) {
          return const HomePage(); // Si el usuario está autenticado y verificado
        } else if (snapshot.hasData && !snapshot.data!.emailVerified) {
          return const LoginScreen(); // Si está logueado pero no verificado, podría reenviarse la verificación aquí
        } else {
          return const OnboardingScreen(); // Si no está autenticado
        }
      },
    );
  }
}