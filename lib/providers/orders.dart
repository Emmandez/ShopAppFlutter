import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class OrdersProvider with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    const url = 'https://shop-flutter-f6145.firebaseio.com/orders.json';

    try{
      final response = await http.get(url);
      List<OrderItem> loadedOrders = [];
      final extractedOrders = json.decode(response.body) as Map<String, dynamic>;

      if(extractedOrders == null) return;
      print(extractedOrders);
      extractedOrders.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>).map((product)=>CartItem(id: product['id'], title: product['title'], price: product['price'], quantity: product['quantity'])).toList(),

        ));
      });
      print(loadedOrders);
      _orders = loadedOrders.reversed.toList();
      notifyListeners();

    }catch(error){
      print(error);
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url = 'https://shop-flutter-f6145.firebaseio.com/orders.json';
    DateTime now = DateTime.now();

    try {
      var response = await http.post(url,
          body: json.encode({
            'amount': total,
            'dateTime': now.toIso8601String(),
            'products': cartProducts
                .map((product) => {
                      'id': product.id,
                      'title': product.title,
                      'quantity': product.quantity,
                      'price': product.price
                    })
                .toList(),
          }));

      var firebaseId = json.decode(response.body)['name'];
      print('*** order firebaseId: $firebaseId');

      _orders.insert(
          0,
          OrderItem(
              id: firebaseId,
              amount: total,
              products: cartProducts,
              dateTime: now));

      notifyListeners();
    } catch (error) {
      print(error);
      throw HttpException('There was an error saving the order');
    }
  }
}
