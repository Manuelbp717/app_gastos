// Función para validar nombres de usuario
// Parámetros:
//   - value: String que contiene el nombre a validar
// Retorna:
//   - null si el nombre es válido
//   - String con mensaje de error si el nombre es inválido
String? validateName(String? value) {
  // Verifica que el valor no sea nulo o esté vacío
  if (value == null || value.isEmpty) {
    return 'Ingrese su nombre completo';
  }
  // Verifica que el nombre tenga al menos 2 caracteres
  if (value.length < 2) {
    return 'El nombre debe tener al menos 2 caracteres';
  }
  // Expresión regular que permite letras (incluyendo acentos y ñ) y espacios
  // Rechaza números y caracteres especiales
  if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value)) {
    return 'Ingrese un nombre válido';
  }
  // Si pasa todas las validaciones, retorna null (válido)
  return null;
}

// Función para validar direcciones de correo electrónico
// Parámetros:
//   - value: String que contiene el email a validar
// Retorna:
//   - null si el email es válido
//   - String con mensaje de error si el email es inválido
String? validateEmail(String? value) {
  // Verifica que el valor no sea nulo o esté vacío
  if (value == null || value.isEmpty) {
    return 'Ingrese un correo electrónico válido';
  }

  // Expresión regular completa para validar formato de email
  // Estructura: parte local + @ + dominio + . + extensión (mínimo 2 caracteres)
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Ingrese un correo electrónico válido';
  }

  // Si pasa todas las validaciones, retorna null (válido)
  return null;
}

// Función para validar contraseñas
// Parámetros:
//   - value: String que contiene la contraseña a validar
// Retorna:
//   - null si la contraseña es válida
//   - String con mensaje de error si la contraseña es inválida
String? validatePassword(String? value) {
  // Verifica que el valor no sea nulo o esté vacío
  if (value == null || value.isEmpty) {
    return 'Ingrese una contraseña';
  }

  // Verifica longitud mínima de 8 caracteres
  if (value.length < 8) {
    return 'La contraseña debe tener al menos 8 caracteres';
  }

  // Expresión regular con lookaheads para verificar:
  // - Al menos una letra minúscula (?=.*[a-z])
  // - Al menos una letra mayúscula (?=.*[A-Z])
  // - Al menos un dígito (?=.*\d)
  if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
    return 'La contraseña debe contener mayúsculas, minúsculas y números';
  }

  // Si pasa todas las validaciones, retorna null (válido)
  return null;
}

// Función para validar una nueva contraseña
// Implementa la misma lógica que validatePassword
// Se mantiene separada para permitir diferentes requisitos en el futuro
// Parámetros:
//   - value: String que contiene la nueva contraseña a validar
// Retorna:
//   - null si la contraseña es válida
//   - String con mensaje de error si la contraseña es inválida
String? validateNewPassword(String? value) {
  // Verifica que el valor no sea nulo o esté vacío
  if (value == null || value.isEmpty) {
    return 'Ingrese una nueva contraseña';
  }

  // Verifica longitud mínima de 8 caracteres
  if (value.length < 8) {
    return 'La contraseña debe tener al menos 8 caracteres';
  }

  // Misma verificación de complejidad que validatePassword
  if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
    return 'La contraseña debe contener mayúsculas, minúsculas y números';
  }

  // Si pasa todas las validaciones, retorna null (válido)
  return null;
}

// Función para validar la confirmación de contraseña
// Parámetros:
//   - value: String que contiene la confirmación de contraseña
//   - password: String con la contraseña original para comparación
// Retorna:
//   - null si las contraseñas coinciden
//   - String con mensaje de error si las contraseñas no coinciden
String? validateConfirmPassword(String? value, String password) {
  // Verifica que el valor no sea nulo o esté vacío
  if (value == null || value.isEmpty) {
    return 'Confirme su contraseña';
  }

  // Verifica que las contraseñas coincidan exactamente
  if (value != password) {
    return 'Las contraseñas no coinciden';
  }

  // Si pasa todas las validaciones, retorna null (válido)
  return null;
}