import 'package:aplicacion_gastos_final/utils/constans.dart';
import 'package:aplicacion_gastos_final/utils/graphic.dart';
import 'package:aplicacion_gastos_final/utils/lista.dart';
import 'package:aplicacion_gastos_final/utils/settings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _controller;
  int currentPage = 0;

  List<List<double>> monthlyGraphData = List.generate(
    12,
    (_) => List.generate(7, (_) => Random().nextDouble() * 100),
  );

  final List<ExpenseItem> _items = [
    ExpenseItem(
      icon: FontAwesomeIcons.shoppingCart,
      name: "Shopping",
      percent: 14,
      value: 145.12,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: currentPage,
      viewportFraction: 0.4,
    );
  }

  Widget _bottomAction(
    IconData icon, {
    Color color = appPrimaryColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: color),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: appBackgroundColor,
        elevation: 4.0,
        toolbarHeight: 60.0,
        flexibleSpace: SafeArea(child: _selector()),
      ),
      bottomNavigationBar: BottomAppBar(
        color: appPrimaryColor,
        notchMargin: 8.0,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _bottomAction(
              FontAwesomeIcons.history,
              color: appBackgroundColor,
              onTap: () {
                print("Historial pulsado");
                // Aquí puedes poner la acción que quieras
              },
            ),
            _bottomAction(
              FontAwesomeIcons.chartPie,
              color: appBackgroundColor,
              onTap: () {
                print("Gráficos pulsado");
              },
            ),
            const SizedBox(width: 40.0),
            _bottomAction(
              FontAwesomeIcons.wallet,
              color: appBackgroundColor,
              onTap: () {
                print("Cartera pulsado");
              },
            ),
            _bottomAction(
              Icons.settings,
              color: appBackgroundColor,
              onTap: () {
                Navigator.pop(context); // Cierra el drawer primero

                // Espera un pequeño momento antes de hacer push
                Future.delayed(Duration(milliseconds: 300), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: appPrimaryColor, // Fondo negro
        child: Icon(Icons.add, color: appBackgroundColor), // Ícono verde
        onPressed: () async {
          final newItem = await showDialog<ExpenseItem>(
            context: context,
            builder: (context) => _buildFormDialog(),
          );

          if (newItem != null) {
            setState(() {
              _items.add(newItem);
            });
          }
        },
      ),

      body: _body(),
    );
  }

  Widget _buildFormDialog() {
    final nameController = TextEditingController();
    final percentController = TextEditingController();
    final valueController = TextEditingController();
    IconData selectedIcon = FontAwesomeIcons.shoppingCart;

    return AlertDialog(
      title: Text('Agregar gasto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: percentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "% del gasto"),
            ),
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Valor (\$)"),
            ),
            DropdownButton<IconData>(
              value: selectedIcon,
              items:
                  [
                    FontAwesomeIcons.shoppingCart,
                    FontAwesomeIcons.car,
                    FontAwesomeIcons.utensils,
                    FontAwesomeIcons.house,
                  ].map((icon) {
                    return DropdownMenuItem(value: icon, child: Icon(icon));
                  }).toList(),
              onChanged: (icon) {
                if (icon != null) {
                  selectedIcon = icon;
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            final name = nameController.text;
            final percent = int.tryParse(percentController.text) ?? 0;
            final value = double.tryParse(valueController.text) ?? 0.0;

            if (name.isNotEmpty && percent > 0 && value > 0) {
              Navigator.of(context).pop(
                ExpenseItem(
                  icon: selectedIcon,
                  name: name,
                  percent: percent,
                  value: value,
                ),
              );
            }
          },
          child: Text("Agregar"),
        ),
      ],
    );
  }

  Widget _body() {
    return SafeArea(
      child: Container(
        color: appBackgroundColor, // Fondo negro para todo el cuerpo
        child: Column(
          children: <Widget>[
            _expenses(),
            _graph(),
            Container(
              color: appBackgroundColor,
              height: 24.0,
            ), // Asegúrate de que appBackgroundColor combine con negro
            _list(),
          ],
        ),
      ),
    );
  }

  Widget _pageItem(String name, int position) {
    Alignment alignment;
    final selected = TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: appPrimaryColor,
    );
    final unselected = TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.normal,
      color: appPrimaryColor.withOpacity(0.2),
    );

    if (position == currentPage) {
      alignment = Alignment.center;
    } else if (position > currentPage) {
      alignment = Alignment.centerRight;
    } else {
      alignment = Alignment.centerLeft;
    }

    return Align(
      alignment: alignment,
      child: Text(name, style: position == currentPage ? selected : unselected),
    );
  }

  Widget _selector() {
    return SizedBox.fromSize(
      size: Size.fromHeight(70.0),
      child: PageView(
        onPageChanged: (newPage) {
          setState(() {
            currentPage = newPage;
          });
        },
        controller: _controller,
        children: <Widget>[
          _pageItem("Enero", 0),
          _pageItem("Febrero", 1),
          _pageItem("Marzo", 2),
          _pageItem("Abril", 3),
          _pageItem("Mayo", 4),
          _pageItem("Junio", 5),
          _pageItem("Julio", 6),
          _pageItem("Agosto", 7),
          _pageItem("Septiembre", 8),
          _pageItem("Octubre", 9),
          _pageItem("Noviembre", 10),
          _pageItem("Diciembre", 11),
        ],
      ),
    );
  }

  Widget _expenses() {
    return Column(
      children: <Widget>[
        Text(
          "\$2361,41",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
            color: appText,
          ),
        ),
        Text(
          "Total expenses",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
            color: appPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _graph() {
    return Container(
      height: 250.0,
      child: GraphWidget(data: monthlyGraphData[currentPage]),
    );
  }

  Widget _item(IconData icon, String name, int percent, double value) {
    return ListTile(
      leading: Icon(icon, size: 32.0, color: appPrimaryColor),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          color: appPrimaryColor,
        ),
      ),
      subtitle: Text(
        "$percent% of expenses",
        style: TextStyle(
          fontSize: 16.0,
          color: appPrimaryColor.withOpacity(0.3),
        ),
      ),
      trailing: Container(
        decoration: BoxDecoration(
          color: appPrimaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "\$$value",
            style: TextStyle(
              color: appPrimaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
          ),
        ),
      ),
    );
  }

Widget _list() { 
  return Expanded(
    child: ListView.separated(
      padding: const EdgeInsets.only(bottom: 40.0), // Espacio al final
      itemCount: _items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = _items[index];
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: appPrimaryColor.withOpacity(0.3),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 4.0,
          ),
          child: _item(item.icon, item.name, item.percent, item.value),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          color: appBackgroundColor,
          height: 8.0,
        );
      },
    ),
  );
}

}