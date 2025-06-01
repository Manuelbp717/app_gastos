import 'package:aplicacion_gastos_final/utils/constans.dart';
import 'package:flutter/material.dart';

class AgregarTarjetaPage extends StatefulWidget {
  const AgregarTarjetaPage({super.key});

  @override
  _AgregarTarjetaPageState createState() => _AgregarTarjetaPageState();
}

class _AgregarTarjetaPageState extends State<AgregarTarjetaPage> {
  final _formKey = GlobalKey<FormState>();
  String nombreTitular = '';
  String numeroTarjeta = '';
  String fechaVencimiento = '';
  String cvv = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: appBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appText),
          onPressed: () async {
            Navigator.pop(context); // Regresa a la pantalla anterior
          },
        ),
        title: Text('Agregar Tarjeta', style: TextStyle(color: appText)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre del titular',
                  labelStyle: TextStyle(color: appText.withOpacity(0.8)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: appPrimaryColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: appPrimaryColor, width: 2),
                  ),
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => nombreTitular = value!,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Este campo es requerido' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Número de tarjeta',
                  labelStyle: TextStyle(color: appText.withOpacity(0.8)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: appPrimaryColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: appPrimaryColor, width: 2),
                  ),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => numeroTarjeta = value!,
                validator:
                    (value) =>
                        value!.length < 16
                            ? 'Debe tener al menos 16 dígitos'
                            : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Fecha de vencimiento (MM/AA)',
                        labelStyle: TextStyle(color: appText.withOpacity(0.8)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: appPrimaryColor.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: appPrimaryColor,
                            width: 2,
                          ),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => fechaVencimiento = value!,
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        labelStyle: TextStyle(color: appText.withOpacity(0.8)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: appPrimaryColor.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: appPrimaryColor,
                            width: 2,
                          ),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => cvv = value!,
                      validator:
                          (value) =>
                              value!.length != 3
                                  ? 'Debe tener 3 dígitos'
                                  : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Aquí puedes manejar el guardado de los datos, como enviarlos a una base de datos
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tarjeta guardada correctamente')),
                    );
                    Navigator.pop(
                      context,
                    ); // Opcional: regresar después de guardar
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appPrimaryColor, // Color de fondo del botón
                  foregroundColor: Colors.white, // Color del texto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Bordes redondeados
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(
                  'Guardar Tarjeta',
                  style: TextStyle(color: appText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
