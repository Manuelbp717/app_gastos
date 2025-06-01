import 'package:aplicacion_gastos_final/utils/constans.dart';
import 'package:aplicacion_gastos_final/utils/validar.dart';
import 'package:flutter/material.dart'; // Importa el paquete principal de Flutter para UI
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Authentication
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
  bool _isPasswordVisible = false; // Controla si la contraseña se muestra o se oculta
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
          MaterialPageRoute(builder: (_) => HomePage()), // Navega a la página principal
          (route) => false, // Elimina todas las rutas anteriores de la pila
        );
      });
    }
  }

  // Método para iniciar sesión con correo electrónico y contraseña
  Future<void> _signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) { // Valida los campos del formulario
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
        String errorMessage = 'Error de inicio de sesión'; // Mensaje predeterminado
        if (e.code == 'user-not-found') {
          errorMessage = 'No se encontró un usuario con este correo'; // Error de usuario no encontrado
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Contraseña incorrecta'; // Error de contraseña incorrecta
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
                onPressed: () => Navigator.of(context).pop(), // Cierra el diálogo
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

  // Construye la interfaz de usuario de la pantalla de login
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor, // Color de fondo definido en constants.dart
      body: SafeArea(
        child: SingleChildScrollView( // Permite scroll cuando el teclado aparece
          padding: const EdgeInsets.symmetric(horizontal: 30.0), // Padding horizontal
          child: Form(
            key: _formKey, // Asocia la clave global al formulario para validación
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40), // Espacio vertical inicial
                // Ícono decorativo con contenedor circular
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: appPrimaryColor.withOpacity(0.1), // Color primario con transparencia
                    shape: BoxShape.circle, // Forma circular
                  ),
                  child: const Icon(
                    Icons.lock, // Ícono de candado para representar login
                    size: 60,
                    color: appPrimaryColor, // Color primario de la app
                  ),
                ),
                const SizedBox(height: 30), // Espacio vertical

                // Título de la página
                const Text(
                  "Inicia Sesión", // Texto del título
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: appPrimaryColor, // Color primario de la app
                  ),
                ),
                const SizedBox(height: 30), // Espacio vertical

                // Campo para ingresar el correo electrónico
                TextFormField(
                  controller: emailController, // Controlador para capturar el texto
                  decoration: InputDecoration(
                    labelText: "Correo electrónico", // Etiqueta del campo
                    floatingLabelStyle: TextStyle(color: appPrimaryColor), // Color de la etiqueta al seleccionar
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Bordes redondeados
                      borderSide: BorderSide(color: Colors.grey.shade300), // Color del borde
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300), // Borde cuando no está seleccionado
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: appPrimaryColor, width: 2), // Borde más grueso al seleccionar
                    ),
                    prefixIcon: Icon(Icons.email, color: Colors.grey.shade600), // Ícono de correo a la izquierda
                    filled: true,
                    fillColor: Colors.grey.shade50, // Color de fondo del campo
                  ),
                  keyboardType: TextInputType.emailAddress, // Teclado optimizado para emails
                  validator: (value) => validateEmail(value), // Función de validación importada
                ),
                const SizedBox(height: 20), // Espacio vertical

                // Campo para ingresar la contraseña
                TextFormField(
                  controller: passwordController, // Controlador para capturar el texto
                  decoration: InputDecoration(
                    labelText: "Contraseña", // Etiqueta del campo
                    floatingLabelStyle: TextStyle(color: appPrimaryColor), // Color de la etiqueta al seleccionar
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Bordes redondeados
                      borderSide: BorderSide(color: Colors.grey.shade300), // Color del borde
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300), // Borde cuando no está seleccionado
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: appPrimaryColor, width: 2), // Borde más grueso al seleccionar
                    ),
                    prefixIcon: Icon(Icons.lock, color: Colors.grey.shade600), // Ícono de candado a la izquierda
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility // Ícono de ojo abierto si la contraseña es visible
                            : Icons.visibility_off, // Ícono de ojo cerrado si la contraseña está oculta
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible; // Alterna la visibilidad de la contraseña
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50, // Color de fondo del campo
                  ),
                  obscureText: !_isPasswordVisible, // Oculta el texto si _isPasswordVisible es false
                  validator: validatePassword, // Función de validación importada
                ),

                // Enlace para recuperar contraseña olvidada
                Align(
                  alignment: Alignment.centerRight, // Alinea a la derecha
                  child: TextButton(
                    onPressed: () {
                      
                    },
                    child: const Text(
                      "¿Olvidaste tu contraseña?", // Texto del enlace
                      style: TextStyle(color: appPrimaryColor), // Color primario para destacar
                    ),
                  ),
                ),

                // Botón principal de inicio de sesión
                SizedBox(
                  width: double.infinity, // Ocupa todo el ancho disponible
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signInWithEmailAndPassword, // Desactiva el botón durante la carga
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimaryColor, // Color de fondo del botón
                      foregroundColor: Colors.white, // Color del texto
                      padding: const EdgeInsets.symmetric(vertical: 16), // Relleno vertical
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Bordes redondeados
                      ),
                      elevation: 3, // Sombra del botón
                      shadowColor: appPrimaryColor.withOpacity(0.3), // Color de la sombra
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator( // Indicador de carga circular
                                strokeWidth: 3,
                                color: Colors.white, // Color blanco para contraste
                              ),
                            )
                            : const Text(
                              "Iniciar sesión", // Texto del botón
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600, // Texto semi-negrita
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 25), // Espacio vertical

                // Separador con texto "o continúa con"
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1), // Línea divisoria izquierda
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15), // Espacio alrededor del texto
                      child: Text(
                        "o continúa con", // Texto del separador
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1), // Línea divisoria derecha
                    ),
                  ],
                ),
                const SizedBox(height: 25), // Espacio vertical

                // Botón de inicio de sesión con Google
                SizedBox(
                  width: double.infinity, // Ocupa todo el ancho disponible
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _signInWithGoogle, // Desactiva el botón durante la carga
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white, // Fondo blanco
                      foregroundColor: Colors.black87, // Color del texto casi negro
                      padding: const EdgeInsets.symmetric(vertical: 14), // Relleno vertical
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Bordes redondeados
                      ),
                      side: BorderSide(color: Colors.grey.shade300, width: 1), // Borde gris claro
                      elevation: 0, // Sin elevación
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Centra horizontalmente
                      children: [
                        Image.asset('lib/assets/icon/google.png', height: 24), // Logo de Google
                        const SizedBox(width: 10), // Espacio entre logo y texto
                        const Text(
                          "Google", // Texto del botón
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500, // Texto medium
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30), // Espacio vertical final
              ],
            ),
          ),
        ),
      ),
    );
  }
}