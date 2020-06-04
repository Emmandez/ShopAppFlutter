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
    var itemCount = cartProvider.itemCount;
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
                      OrderButton(cart: cartProvider)
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
                        cartProvider.items.keys.toList()[i],
                      )),
            )
          ],
        ));
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  Future<void> _placeOrder(BuildContext context) async {
    setState((){
      _isLoading = true;
    });

    await Provider.of<OrdersProvider>(context, listen: false).addOrder(widget.cart.items.values.toList(), widget.cart.totalAmount);
    widget.cart.clear();

    setState((){
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        onPressed: (widget.cart.itemCount <= 0 || _isLoading)
        ? null
        : () => _placeOrder(context),
        child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
        textColor: Theme.of(context).primaryColor,
      );
  }
}
