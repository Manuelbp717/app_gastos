import 'package:aplicacion_gastos_final/pages/login.dart';
import 'package:aplicacion_gastos_final/utils/constans.dart';
import 'package:aplicacion_gastos_final/utils/validar.dart';
import 'package:flutter/material.dart'; // Importa el paquete principal de Flutter para UI
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Authentication

// Pantalla de registro como un StatefulWidget porque necesita mantener estado
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key}); // Constructor con key opcional

  @override
  State<RegisterScreen> createState() => _RegisterScreenState(); // Crea el estado asociado al widget
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Variable para controlar la visibilidad de la contraseña (mostrar/ocultar)
  bool _isPasswordVisible = false;

  // Controladores para capturar y manipular el texto ingresado por el usuario
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Variable de estado para mostrar indicador de carga durante el registro
  bool _isLoading = false;

  // Clave global para acceder y validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Método para registrar un nuevo usuario en Firebase
  void _register() async {
    // Verifica que todos los campos del formulario sean válidos
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Activa indicador de carga
      });

      try {
        // Crea un nuevo usuario en Firebase con email y contraseña
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(), // Elimina espacios en blanco
              password: passwordController.text,
            );

        // Guarda el nombre del usuario en su perfil de Firebase
        await userCredential.user?.updateDisplayName(
          nameController.text.trim(),
        );

        // Envía email de verificación al correo registrado
        await userCredential.user?.sendEmailVerification();

        // Muestra diálogo informando que se envió el correo de verificación
        _showVerificationDialog('Se ha enviado un correo de verificación');
      } on FirebaseAuthException catch (e) {
        // Manejo específico de errores de Firebase Authentication
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'El correo electrónico ya está registrado'; // Error de email duplicado
            break;
          default:
            errorMessage = 'Error de registro: ${e.message}'; // Otros errores
        }

        // Muestra mensaje de error como notificación en pantalla
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      } finally {
        // Se ejecuta siempre, independientemente de éxito o error
        setState(() {
          _isLoading = false; // Desactiva el indicador de carga
        });
      }
    }
  }

  // Método para mostrar el diálogo de verificación después del registro exitoso
  void _showVerificationDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Verificación de Correo'), // Título del diálogo
            content: Text(message), // Mensaje informativo
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo actual
                  Navigator.of(context).pop(); // Regresa a la pantalla anterior (login)
                },
                child: const Text('Aceptar'), // Texto del botón
              ),
            ],
          ),
    );
  }

  // Construye la interfaz de usuario
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30), // Espacio vertical
                // Encabezado con ícono y texto
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: appPrimaryColor.withOpacity(0.1), // Color primario con transparencia
                          shape: BoxShape.circle, // Contenedor circular
                        ),
                        child: const Icon(
                          Icons.person_add, // Ícono de añadir persona
                          size: 60,
                          color: appPrimaryColor, // Color primario de la app
                        ),
                      ),
                      const SizedBox(height: 20), // Espacio vertical
                      const Text(
                        "Crea tu cuenta", // Título principal
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: appPrimaryColor, // Color primario de la app
                        ),
                      ),
                      const SizedBox(height: 10), // Espacio vertical
                      const Text(
                        "Completa el formulario para registrarte", // Subtítulo
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30), // Espacio vertical

                // Campo para ingresar el nombre completo
                TextFormField(
                  controller: nameController, // Controlador para capturar el texto
                  decoration: InputDecoration(
                    labelText: "Nombre completo", // Etiqueta del campo
                    floatingLabelStyle: TextStyle(color: appPrimaryColor), // Color de la etiqueta al seleccionar
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Bordes redondeados
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300), // Borde normal
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: appPrimaryColor, width: 2), // Borde al seleccionar
                    ),
                    prefixIcon: Icon(Icons.person, color: Colors.grey.shade600), // Ícono izquierdo
                    filled: true,
                    fillColor: Colors.grey.shade50, // Color de fondo del campo
                  ),
                  validator: validateName, // Función de validación importada
                ),
                const SizedBox(height: 20), // Espacio vertical

                // Campo para ingresar el correo electrónico
                TextFormField(
                  controller: emailController, // Controlador para capturar el texto
                  decoration: InputDecoration(
                    labelText: "Correo electrónico", // Etiqueta del campo
                    floatingLabelStyle: TextStyle(color: appPrimaryColor), // Color de la etiqueta al seleccionar
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Bordes redondeados
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300), // Borde normal
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: appPrimaryColor, width: 2), // Borde al seleccionar
                    ),
                    prefixIcon: Icon(Icons.email, color: Colors.grey.shade600), // Ícono izquierdo
                    hintText: "ejemplo@correo.com", // Texto de ejemplo
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
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300), // Borde normal
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: appPrimaryColor, width: 2), // Borde al seleccionar
                    ),
                    prefixIcon: Icon(Icons.lock, color: Colors.grey.shade600), // Ícono izquierdo de candado
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility // Ícono de ojo abierto
                            : Icons.visibility_off, // Ícono de ojo cerrado
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible; // Alterna visibilidad de contraseña
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50, // Color de fondo del campo
                  ),
                  obscureText: !_isPasswordVisible, // Oculta el texto si _isPasswordVisible es false
                  validator: validatePassword, // Función de validación importada
                ),
                const SizedBox(height: 30), // Espacio vertical

                // Botón de registro con ancho completo
                SizedBox(
                  width: double.infinity, // Ocupa todo el ancho disponible
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register, // Desactiva el botón durante la carga
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
                              "Registrarse", // Texto del botón
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600, // Texto semi-negrita
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 25), // Espacio vertical

                // Enlace para navegar a la pantalla de login
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(), // Navega a pantalla de login
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "¿Ya tienes una cuenta? ", // Primera parte del texto
                        style: TextStyle(color: Colors.grey.shade600),
                        children: const [
                          TextSpan(
                            text: "Inicia sesión", // Segunda parte del texto con estilo diferente
                            style: TextStyle(
                              color: appPrimaryColor, // Color primario para destacar
                              fontWeight: FontWeight.w600, // Texto semi-negrita
                            ),
                          ),
                        ],
                      ),
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