import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

import './product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  String _authToken;
  String _userId;

  set authToken(String authToken){
    _authToken = authToken;
  }

  set userId(String value){
    _userId=value;
  }

  ProductsProvider(this._items);

  

  List<Product> get items {
    // if(_showFavoritesOnly) {
    //   return _items.where((product) => product.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Future<void> fetchAndSetProduct([bool filterByUser = false]) async {
    final filterString = filterByUser ? '&orderBy="creatorId"&equalTo="$_userId"' : '';
    final url = 'https://shop-flutter-f6145.firebaseio.com/products.json?auth=$_authToken$filterString';
    print('url: $url');
    try {
      final response = await http.get(url);
      print('*** tokenId: $_authToken');
      print('response ${response.body}');
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      print('extractedData: $extractedData');
      if(extractedData == null)  return;

      final favoriteProductsUrl = 'https://shop-flutter-f6145.firebaseio.com/userFavorites/$_userId.json?auth=$_authToken'; 
      final favoriteResponse = await http.get(favoriteProductsUrl);
      final favoriteData = json.decode(favoriteResponse.body);

      print('favoriteData: $favoriteData');

      final List<Product> loadedProducts = [];
      extractedData.forEach((id, data) {
        loadedProducts.add(Product(
            id: id,
            title: data['title'],
            description: data['description'],
            price: data['price'],
            imageUrl: data['imageUrl'],
            isFavorite: favoriteData == null ? false : favoriteData[id] ?? false,
            ),
        );
        
      });
      _items = loadedProducts;

      notifyListeners();
    } catch (error) {
      print('ERROR FEtching products $error');
      throw error.toString();
    }
  }

  Future<void> addProduct(Product product) async {
    final url = 'https://shop-flutter-f6145.firebaseio.com/products.json?auth=$_authToken';

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'imageUrl': product.imageUrl,
          'description': product.description,
          'price': product.price,
          'creatorId': _userId,
        }),
      );

      var firebaseId = json.decode(response.body)['name'];

      final newProduct = Product(
          title: product.title,
          imageUrl: product.imageUrl,
          description: product.description,
          price: product.price,
          id: firebaseId);
      _items.insert(0, newProduct);

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(Product newProduct) async {
    final prodIndex =
        _items.indexWhere((product) => product.id == newProduct.id);
    if (prodIndex >= 0) {
      final url =
          'https://shop-flutter-f6145.firebaseio.com/products/$newProduct.json?auth=$_authToken';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'imageUrl': newProduct.imageUrl,
            'description': newProduct.description,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://shop-flutter-f6145.firebaseio.com/products/$id.json?auth=$_authToken';

    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();
    
    //optimistic update
    final response = await http.delete(url);
    
    if(response.statusCode >=400){
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not be deleted');
    }

    existingProduct=null;
  }

  Product findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }
}
