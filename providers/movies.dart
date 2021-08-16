import 'package:flutter/material.dart';
import 'package:yellowClass/models/http_exception.dart';
import 'dart:convert';
import 'package:yellowClass/providers/movie.dart';
import 'package:http/http.dart' as http;

class Movies with ChangeNotifier {
  //mixin
  List<Movie> _items = [];
 
  final String token;
  final String userId;
  Movies(this.token,this._items,this.userId);
  List<Movie> get items {
    //if(showFavouritesOnly){
    // return _items.where((item) => item.isFavorite).toList();

    return [..._items];

    //returns a copy of items
  }

  List<Movie> get favouriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Movie findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndShowProducts([bool filterByUser=false]) async {
    final filterString=filterByUser?'orderBy="createrId"&equalTo="$userId"':'';
    var url =
        'https://yellow-class-c2353-default-rtdb.firebaseio.com/movies.json?auth=$token&$filterString'; //after the ? enter the token value
    try {
      final response = await http.get(url);
      final List<Movie> loadedProduct = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData==null){
        return;
      }
      final favResponse=await http.get('https://yellow-class-c2353-default-rtdb.firebaseio.com/userFavourites/$userId.json?auth=$token');
      final favData=json.decode(favResponse.body);
      extractedData.forEach((id, prodData) {
        loadedProduct.add(Movie(
            id: id,
            director: prodData['director'],
            
            isFavorite:favData==null? false:favData['id']?? false, //?? to chrck if its null
            title: prodData['title'],
            imageUrl: prodData['imageUrl']));
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  
  Future<void> addProducts(Movie movie) async {
    //async added after parameter list of func
    final url =
        'https://yellow-class-c2353-default-rtdb.firebaseio.com/movies.json?auth=$token'; //creates a new folder named products in database
    //_items.add(); //.json is required to be added in firebase
    try {
      final response = await http.post(url,
          body: json.encode({
            //assign the result of that operation to a variable
            'title': movie.title, //adding async wraps whole func in future
            'description': movie.director,
            'imageUrl': movie.imageUrl,
            
            'createrId':userId
             //the future of post recieves a response argument
          }));
      final newMovie = Movie(
          id: json.decode(response.body)['name'],
          title: movie.title,
          director: movie.director,
          imageUrl: movie.imageUrl
          );
      _items.add(newMovie);
      notifyListeners(); //establishes a communication channel between this class and the widgets that are interested in
    } //inside try block add code which might fail
    catch (error) {
      throw error;
    }
    //the code here will execute once the code in the await line is done executing

    //print(error);
    //throw error; //throw returns another error //if the post method gets an error the code in the then block will be skipped and catchError will run

    //post to store data in server,body is the content you want to send
  }

  Future<void> updateProduct(String id, Movie newMovie) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://yellow-class-c2353-default-rtdb.firebaseio.com/movies/$id.json?auth=$token';
      await http.patch(url,
          body: json.encode({
            'title': newMovie.title,
            'director': newMovie.director,
            
            'imageUrl': newMovie.imageUrl,
          }));
      _items[prodIndex] = newMovie;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://yellow-class-c2353-default-rtdb.firebaseio.com/movies/$id.json?auth=$token';
    final existingId = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingId];
    
    _items.removeAt(existingId);
    notifyListeners();
    final response=await http.delete(url);
     
      if(response.statusCode>=400){
        _items.insert(existingId, existingProduct);
        notifyListeners();
        throw HttpException('Could not delete product');
      }
      existingProduct = null;
     
     
      

   
  }
}
