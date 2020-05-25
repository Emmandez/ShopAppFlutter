import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<Cart>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Your cart'),
        ),
        body: Column(
          children: <Widget>[
            Card(
              margin: EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Total:',
                      style: TextStyle(fontSize: 20),
                    ),
                    Spacer(),
                    SizedBox(
                      width: 20,
                    ),
                    Chip(
                      label: Text(
                        '\$ ${cartProvider.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            color:
                                Theme.of(context).primaryTextTheme.title.color),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    FlatButton(
                      onPressed: () {
                        Provider.of<OrdersProvider>(context, listen: false).addOrder(cartProvider.items.values.toList(), cartProvider.totalAmount);
                        cartProvider.clear();
                      },
                      child: Text('ORDER NOW'),
                      textColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            
            Expanded(
              child: ListView.builder(
                  itemCount: cartProvider.itemCount,
                  itemBuilder: (ctx, i) => CartItem(
                      cartProvider.items.values.toList()[i].id,
                      cartProvider.items.values.toList()[i].price,
                      cartProvider.items.values.toList()[i].quantity,
                      cartProvider.items.values.toList()[i].title,
                      cartProvider.items.keys.toList()[i],)
              ),
            )
          ],
        ));
  }
}
