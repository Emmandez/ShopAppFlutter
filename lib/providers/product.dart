import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite});

  void _revertFavValue() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  Future<void> toogleFavoriteStatus(String authToken, String userId) async {
    final url =
        'https://shop-flutter-f6145.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';
    print(this.isFavorite);
    this.isFavorite = !this.isFavorite;
    notifyListeners();

    try {
      final response = await http.put(url, body: json.encode(isFavorite));

      if (response.statusCode >= 400) _revertFavValue();
    } catch (error) {
      print('There was an error updating the product.');
      print('Error message: $error');
      _revertFavValue();
    }
  }
}
