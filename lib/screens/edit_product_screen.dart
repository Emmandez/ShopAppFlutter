import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: null, title: '', price: 0, description: '', imageUrl: '');

  var _isInit = true;

  final _imageUrlController = TextEditingController();
  var _isLoading = false;
  @override
  void initState() {
    _imageUrlController.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId == null) return;

      _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
          .findById(productId);
      _imageUrlController.text = _editedProduct.imageUrl;
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.removeListener(_updateImageUrl);
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) setState(() {});
  }

  Future<void> _saveForm() async {
    final _isValid = _form.currentState.validate();
    if (!_isValid) return;

    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(_editedProduct);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<ProductsProvider>(context, listen: false).addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred'),
            content: Text('Something went wrong'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.of(context).pop,
                  child: Text('Okay')),
            ],
          ),
        );
      } //finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }

        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Product'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveForm,
            )
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _form,
                  child: ListView(
                    children: <Widget>[
                      TextFormField(
                        initialValue: _editedProduct.title,
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_priceFocusNode),
                        validator: (value) {
                          if (value.isEmpty) return 'Please provide a value';

                          return null;
                        },
                        onSaved: (title) {
                          _editedProduct = Product(
                              title: title,
                              price: _editedProduct.price,
                              description: _editedProduct.description,
                              imageUrl: _editedProduct.imageUrl,
                              id: _editedProduct.id,
                              isFavorite: _editedProduct.isFavorite);
                        },
                      ),
                      TextFormField(
                          initialValue: _editedProduct.price.toString(),
                          decoration: InputDecoration(labelText: 'Price'),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          focusNode: _priceFocusNode,
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_descFocusNode),
                          validator: (value) {
                            if (value.isEmpty) return 'Please enter a price.';
                            if (double.tryParse(value) == null)
                              return 'Please enter a valid number.';
                            if (double.parse(value) <= 0)
                              return 'Please enter a number greater than zero.';

                            return null;
                          },
                          onSaved: (price) {
                            _editedProduct = Product(
                                title: _editedProduct.title,
                                price: double.parse(price),
                                description: _editedProduct.description,
                                imageUrl: _editedProduct.imageUrl,
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite);
                          }),
                      TextFormField(
                          initialValue: _editedProduct.description,
                          decoration: InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                          focusNode: _descFocusNode,
                          keyboardType: TextInputType.multiline,
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_priceFocusNode),
                          validator: (value) {
                            if (value.isEmpty)
                              return 'Please enter a description';
                            if (value.length < 10)
                              return 'Description should be at least 10 characters long';

                            return null;
                          },
                          onSaved: (description) {
                            _editedProduct = Product(
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                description: description,
                                imageUrl: _editedProduct.imageUrl,
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite);
                          }),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Enter a URL')
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'Image URL'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                focusNode: _imageUrlFocusNode,
                                controller: _imageUrlController,
                                onFieldSubmitted: (_) => _saveForm(),
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Please enter an image URL';
                                  if (!value.startsWith('http') ||
                                      !value.startsWith('https'))
                                    return 'Please enter a valid URL';
                                  if (!value.endsWith('.png') &&
                                      !value.endsWith('.jpg') &&
                                      !value.endsWith('.jpeg'))
                                    return 'Please enter a valid image URL.';

                                  return null;
                                },
                                onSaved: (url) {
                                  _editedProduct = Product(
                                      title: _editedProduct.title,
                                      price: _editedProduct.price,
                                      description: _editedProduct.description,
                                      imageUrl: url,
                                      id: _editedProduct.id,
                                      isFavorite: _editedProduct.isFavorite);
                                }),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ));
  }
}