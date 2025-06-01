import 'package:aplicacion_gastos_final/utils/constans.dart';
import 'package:aplicacion_gastos_final/utils/validar.dart';
import 'package:flutter/material.dart'; // Importa el paquete principal de Flutter para UI
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Authentication
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Importa el paquete para autenticación con Google
import 'package:aplicacion_gastos_final/pages/homepage.dart';

// Pantalla de inicio de sesión como un StatefulWidget porque necesita mantener estado
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // Constructor con key opcional

  @override
  State<LoginScreen> createState() => _LoginScreenState(); // Crea el estado asociado al widget
}

class _LoginScreenState extends State<LoginScreen> {
  // Variables de estado para controlar la visibilidad de la contraseña y el estado de carga
  bool _isPasswordVisible =
      false; // Controla si la contraseña se muestra o se oculta
  bool _isLoading = false; // Controla si se muestra el indicador de carga

  // Clave global para acceder y validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar y manipular el texto ingresado por el usuario
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState(); // Llama al método initState de la clase padre
    // Verifica si el usuario ya está autenticado al iniciar la pantalla
    _checkIfUserIsLoggedIn();
  }

  // Método para verificar si hay un usuario ya autenticado en Firebase
  void _checkIfUserIsLoggedIn() {
    final user = FirebaseAuth.instance.currentUser; // Obtiene el usuario actual
    if (user != null && user.emailVerified) {
      // Si el usuario está autenticado y su correo está verificado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Programa la navegación para después de que se construya el widget
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => HomePage(),
          ), // Navega a la página principal
          (route) => false, // Elimina todas las rutas anteriores de la pila
        );
      });
    }
  }

  // Método para iniciar sesión con correo electrónico y contraseña
  Future<void> _signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      // Valida los campos del formulario
      // Establece el estado de carga para mostrar el indicador
      setState(() => _isLoading = true);
      try {
        // Intenta iniciar sesión con Firebase usando email y contraseña
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: emailController.text.trim(), // Elimina espacios en blanco
              password: passwordController.text,
            );

        // Verifica si el correo electrónico del usuario está verificado
        if (!userCredential.user!.emailVerified) {
          // Si no está verificado, envía un nuevo enlace de verificación
          await userCredential.user!.sendEmailVerification();
          _showVerificationDialog(); // Muestra diálogo informativo
          return; // Sale del método para no continuar con la navegación
        }

        // Si está verificado, redirige a la página de inicio
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomePage()),
          (route) => false, // Elimina todas las rutas anteriores
        );
      } on FirebaseAuthException catch (e) {
        // Manejo específico de errores de Firebase Authentication
        String errorMessage =
            'Error de inicio de sesión'; // Mensaje predeterminado
        if (e.code == 'user-not-found') {
          errorMessage =
              'No se encontró un usuario con este correo'; // Error de usuario no encontrado
        } else if (e.code == 'wrong-password') {
          errorMessage =
              'Contraseña incorrecta'; // Error de contraseña incorrecta
        }

        // Muestra un SnackBar con el mensaje de error
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      } finally {
        // Se ejecuta siempre, independientemente de éxito o error
        setState(() => _isLoading = false); // Desactiva el indicador de carga
      }
    }
  }

  // Método para mostrar un diálogo informando sobre la verificación de correo
  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Verificación de Correo'), // Título del diálogo
            content: const Text(
              'Por favor verifica tu correo electrónico. Se ha enviado un nuevo enlace de verificación.',
            ), // Mensaje informativo
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.of(context).pop(), // Cierra el diálogo
                child: const Text('Aceptar'), // Texto del botón
              ),
            ],
          ),
    );
  }

  // Método para iniciar sesión con Google
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true); // Activa el indicador de carga
    try {
      // Inicia el flujo de inicio de sesión de Google mostrando el selector de cuentas
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return; // El usuario canceló el inicio de sesión

      // Obtiene los detalles de autenticación de la cuenta de Google seleccionada
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Crea una credencial de Firebase con los tokens obtenidos de Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, // Token de acceso
        idToken: googleAuth.idToken, // Token de ID
      );

      // Inicia sesión en Firebase con la credencial de Google
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Redirige a la página de inicio tras el login exitoso
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
    } catch (e) {
      // Captura y muestra cualquier error durante el proceso
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error con Google Sign-In: $e')));
    } finally {
      // Se ejecuta siempre, independientemente de éxito o error
      setState(() => _isLoading = false); // Desactiva el indicador de carga
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      // Primero cierro sesión por si quedó algo guardado
      await FacebookAuth.instance.logOut();
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken;
        if (accessToken == null) {
          print('Error: accessToken es null');
          return;
        }

        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);

        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
      } else {
        print('Error en login: ${result.message}');
      }
    } catch (e) {
      print('Excepción en login: $e');
    }
  }

  // Construye la interfaz de usuario de la pantalla de login
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: appPrimaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock,
                              size: 60,
                              color: appPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Inicia Sesión",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: appPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: "Correo electrónico",
                              floatingLabelStyle: TextStyle(
                                color: appPrimaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: appPrimaryColor,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.grey.shade600,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => validateEmail(value),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: "Contraseña",
                              floatingLabelStyle: TextStyle(
                                color: appPrimaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: appPrimaryColor,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.grey.shade600,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            obscureText: !_isPasswordVisible,
                            validator: validatePassword,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                "¿Olvidaste tu contraseña?",
                                style: TextStyle(color: appPrimaryColor),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : _signInWithEmailAndPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appPrimaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                shadowColor: appPrimaryColor.withOpacity(0.3),
                              ),
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Text(
                                        "Iniciar sesión",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: Text(
                                  "o continúa con",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _signInWithGoogle,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                elevation: 0,
                              ),
                              child: FittedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'lib/assets/icon/google.png',
                                      height: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "Google",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed:
                                  _isLoading ? null : _signInWithFacebook,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                elevation: 0,
                              ),
                              child: FittedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'lib/assets/icon/social.png',
                                      height: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Facebook",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
