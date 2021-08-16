import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yellowClass/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token; //to send requests,it expires at some point of time
  DateTime _expiryDate;
  String _userId;
  Timer authTimer;
  bool get isAuth {
    //if we have a token and the token didnt expire
    return token != null; //then we are authentcated
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }
  String get userId{
    return _userId;
  }

  Future<void> authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/$urlSegment?key=AIzaSyB6GQZCgv585MBZpwMsswgoWKocAMdWPz0';
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        //if error exists
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate =
          DateTime.now().add(Duration(seconds:int.parse( responseData['expiresIn'])));
      autoLogOut();
      notifyListeners();
      final prefs=await SharedPreferences.getInstance(); //to create device storage of the login info
      final userData=json.encode({'token':_token,'userId':_userId,'expiryData':_expiryDate.toIso8601String()});
      prefs.setString('userData',userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return authenticate(email, password, 'accounts:signUp');
  }

  Future<void> logIn(String email, String password) async {
    return authenticate(email, password, 'accounts:signInWithPassword');
  }
  Future<bool> tryAutoLogin () async{
    final prefs=await SharedPreferences.getInstance();
    if(prefs.containsKey('userData')){
      return false;
    }
    final extractedUserData=json.decode(prefs.getString('userData')) as Map<String,Object> ;
    final expiryDate=DateTime.parse(extractedUserData['expiryDate']);
    if(expiryDate.isBefore(DateTime.now())){
      return false;

    }
    _token=extractedUserData['token'];
    _userId=extractedUserData['userId'];
    _expiryDate=expiryDate;
    notifyListeners();
    autoLogOut();
    return true;
  }
  Future<void> logOut() async{
    _token=null;
    _userId=null;
    _expiryDate=null;
    if(authTimer!=null){
      authTimer.cancel(); //cancel existing timers if any
      authTimer=null;
    }
    notifyListeners();
    final prefs=await SharedPreferences.getInstance();
    prefs.remove('userData');
  }
  void autoLogOut(){
    if(authTimer!=null){
      authTimer.cancel(); //cancel existing timers if any
    }
   final timeToExpiry= _expiryDate.difference(DateTime.now()).inSeconds;
    authTimer=Timer(Duration(seconds:timeToExpiry ), logOut);
  }
}
