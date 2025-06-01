import 'package:aplicacion_gastos_final/utils/constans.dart';
import 'package:flutter/material.dart'; // Proporciona widgets básicos de Flutter
import 'package:firebase_auth/firebase_auth.dart'; // Para manejo de autenticación con Firebase // Constantes de la aplicación (colores, tamaños, etc.)

/// Clase que representa la pantalla de perfil del usuario
/// Implementada como StatelessWidget ya que no necesita mantener estado interno
class ProfileScreen extends StatelessWidget {
  // Constructor con la clave opcional requerida por el sistema de widgets de Flutter
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtiene el usuario actual de Firebase Auth (puede ser nulo si no hay sesión)
    final User? user = FirebaseAuth.instance.currentUser;

    // Estructura principal de la pantalla
    return Scaffold(
      // Color de fondo definido en las constantes de la aplicación
      backgroundColor: appBackgroundColor,
      // Barra superior de la aplicación
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Fondo transparente
        elevation: 0, // Sin sombra
        title: const Text(
          'Perfil de Usuario',
          style: TextStyle(color: appText, fontWeight: FontWeight.bold),
        ),
        // Botón de regreso en la esquina superior izquierda
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: appText),
          onPressed: () async {
            Navigator.pop(context); // Aquí sigue siendo sincrónico
          },
        ),
      ),
      // Contenido principal con scroll para dispositivos pequeños
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          kDefaultPadding,
        ), // Padding definido en constantes
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Centrar contenido horizontalmente
          children: [
            // Foto de perfil del usuario
            CircleAvatar(
              radius: 60, // Tamaño del círculo
              backgroundColor: appPrimaryColor.withOpacity(
                0.3,
              ), // Color de fondo con transparencia
              child:
                  user?.photoURL != null
                      // Si existe foto de perfil, la muestra
                      ? ClipOval(
                        child: Image.network(
                          user!.photoURL!, // URL de la imagen de perfil
                          width: 110,
                          height: 110,
                          fit:
                              BoxFit
                                  .cover, // Ajusta la imagen para cubrir el espacio
                        ),
                      )
                      // Si no hay foto, muestra un ícono genérico
                      : const Icon(
                        Icons.person,
                        size: 60,
                        color: appPrimaryColor,
                      ),
            ),
            const SizedBox(height: 20), // Espacio vertical
            // Nombre del usuario
            Text(
              user?.displayName ??
                  'Nombre no proporcionado', // Usa valor predeterminado si es nulo
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: appText,
              ),
            ),
            const SizedBox(height: 10), // Espacio vertical
            // Email del usuario
            Text(
              user?.email ??
                  'Email no proporcionado', // Usa valor predeterminado si es nulo
              style: const TextStyle(fontSize: 16, color: appText),
            ),
            const SizedBox(height: 30), // Espacio vertical mayor
            // Sección de información detallada en un contenedor con estilo
            Container(
              width: double.infinity, // Ocupa todo el ancho disponible
              padding: const EdgeInsets.all(kDefaultPadding),
              decoration: BoxDecoration(
                color: appPrimaryColor.withOpacity(0.4), // Fondo blanco
                borderRadius: BorderRadius.circular(
                  kDefaultBorderRadius,
                ), // Bordes redondeados
                // Sombra suave para efecto de elevación
                boxShadow: [
                  BoxShadow(
                    color: appPrimaryColor.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 3), // Desplazamiento hacia abajo
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start, // Alinear contenido a la izquierda
                children: [
                  // Título de la sección
                  const Text(
                    'Información de la cuenta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: appText,
                    ),
                  ),
                  const SizedBox(height: 15), // Espacio vertical
                  // ID del usuario (identificador único en Firebase)
                  _buildInfoRow('ID de usuario:', user?.uid ?? 'No disponible'),
                  const SizedBox(height: 10),

                  // Proveedor de autenticación (Email, Google, etc.)
                  _buildInfoRow(
                    'Método de autenticación:',
                    user?.providerData.isNotEmpty ?? false
                        ? user!.providerData[0].providerId
                            .replaceAll('.com', '') // Elimina el sufijo .com
                            .capitalize() // Capitaliza la primera letra usando la extensión
                        : 'No disponible',
                  ),
                  const SizedBox(height: 10),

                  // Fecha de creación de la cuenta
                  _buildInfoRow(
                    'Cuenta creada:',
                    user?.metadata.creationTime != null
                        ? '${user!.metadata.creationTime!.day}/${user.metadata.creationTime!.month}/${user.metadata.creationTime!.year}'
                        : 'No disponible',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Método auxiliar para construir cada fila de información
  /// Recibe una etiqueta y un valor, y los muestra en formato horizontal
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Alinear al inicio para textos largos
      children: [
        // Columna izquierda con ancho fijo para etiquetas
        SizedBox(
          width: 120, // Ancho fijo para todas las etiquetas
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, color: appText),
          ),
        ),
        // Columna derecha expandible para valores
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, color: appText),
          ),
        ),
      ],
    );
  }
}

/// Extensión para agregar funcionalidad a las cadenas de texto
/// Permite capitalizar la primera letra de una cadena
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
