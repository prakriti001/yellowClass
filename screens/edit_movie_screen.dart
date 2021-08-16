import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yellowClass/providers/movie.dart';
import 'package:yellowClass/providers/movies.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<
      FormState>(); //used when you need to interact with something inside the widget tree
  var _editedProduct =
      Movie(id: null, title: '', director: '', imageUrl: '');
  var _isInit = true;
  var _isLoading = false;
  var _initValues = {
    'title': '',
    
    'director': '',
    'imageUrl': ''
  };
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Movies>(context, listen: false).findById(productId);

        _initValues = {
          'title': _editedProduct.title,
          
          'imageUrl': _editedProduct.imageUrl,
          'director': _editedProduct.director
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https'))) {
        return;
      }

      setState(() {});
    }
  }

  Future<void> _saveForm() async{
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.id != null) {
      await Provider.of<Movies>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try{
         await Provider.of<Movies>(context, listen: false)
          .addProducts(_editedProduct);
          

      }
      catch(error) {
         await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occured'),
                  content: Text('Something went wrong here'),
                  actions: <Widget>[
                    FlatButton(onPressed: (){
                      Navigator.of(context).pop();
                    }, child: Text('Okay'))
                  ],
                ));
      }
      
        
      
    }
    setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm)
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _form, //to establish connection
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Name'),
                      initialValue: _initValues['title'],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(
                            _priceFocusNode); //when next button is pressed in the keyboard it takes the input to the next feild in focus
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Movie(
                            title: value,
                            
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            director: _editedProduct.director,
                            imageUrl: _editedProduct.imageUrl);
                      },
                    ),
                    
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Director'),
                      maxLines: 3,
                      focusNode: _descFocusNode,
                      initialValue: _initValues['director'],
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value';
                        }
                        if (value.length < 10) {
                          return 'Should be atleast 10 characters long';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Movie(
                            title: _editedProduct.title,
                            
                            id: _editedProduct.id,
                            director: value,
                            isFavorite: _editedProduct.isFavorite,
                            imageUrl: _editedProduct.imageUrl);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            color: Colors.grey,
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
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onSaved: (value) {
                              _editedProduct = Movie(
                                  title: _editedProduct.title,
                                  
                                  id: _editedProduct.id,
                                  director: _editedProduct.director,
                                  imageUrl: value,
                                  isFavorite: _editedProduct.isFavorite);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please provide a value';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid URL';
                              }
                              
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
