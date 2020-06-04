import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show OrdersProvider;

import '../widgets/order_item.dart';
import '../widgets/main_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
        future: Provider.of<OrdersProvider>(context, listen: false)
            .fetchAndSetOrders(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapshot.error != null) {
              return Center(
                child: Text('An error occurred'),
              );
            } else {
              return Consumer<OrdersProvider>(builder: (ctx, ordersProvider, child) => ListView.builder(
                itemCount: ordersProvider.orders.length,
                itemBuilder: (ctx, i) => OrderItem(ordersProvider.orders[i]),
              ),);
            }
          }
        },
      ),
    );
  }
}
