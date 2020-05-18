import 'package:flutter/material.dart';
import '../screens/products_overview_screen.dart';
import '../screens/orders_screen.dart';

class MainDrawer extends StatelessWidget {
  Widget buildListTile(BuildContext ctx, String title, IconData icon, Function tapHandler){
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: tapHandler,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            color: Theme.of(context).primaryColor,
            child: Text(
              'Shopping!',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white, 
              ),
            ),
          ),
          SizedBox(height: 20),
          buildListTile(context, 'Shop', Icons.shop, ()=>Navigator.of(context).pushReplacementNamed('/')),
          Divider(thickness: 1,),
          buildListTile(context, 'Orders', Icons.payment, ()=>Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName)),
        ],
      ),
    );
  }
}