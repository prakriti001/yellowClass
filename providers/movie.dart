import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Movie with ChangeNotifier{
  final String id;
  final String title;
  final String director;
  
  final String imageUrl;
  bool isFavorite;
  Movie(
      {@required this.id,
      @required this.title,
      @required this.director,
      @required this.imageUrl,
     
      this.isFavorite=false});
  Future<void> toggleFavoritesStatus(String token,String userId) async{
    final oldStatus=isFavorite;
    isFavorite=!isFavorite;
    notifyListeners();
    final url='https://yellow-class-c2353-default-rtdb.firebaseio.com/userFavourites/$userId/$id.json?auth=$token';
    try{
      final response=await http.put(url,body:json.encode(
      isFavorite
      ));

    if(response.statusCode>=400){
      isFavorite=oldStatus;
      notifyListeners();
    }
    }catch(error){
      isFavorite=oldStatus;
      notifyListeners();
    }
    

  }   
}
