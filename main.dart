import 'package:flutter/material.dart';
import 'package:yellowClass/providers/auth.dart';


import 'package:yellowClass/providers/movies.dart';
import 'package:yellowClass/screens/auth_screen.dart';

import 'package:yellowClass/screens/edit_movie_screen.dart';

import 'package:yellowClass/screens/movie_detail_screen.dart';

import 'package:provider/provider.dart';
import 'package:yellowClass/screens/movies_overview_screen.dart';
import 'package:yellowClass/screens/splash_screen.dart';
import 'package:yellowClass/screens/users_movies_screen.dart';

void main() => runApp(MyApp());

//create a provider in the parent class of the widget you want to rebuild when the state changes and then lsiten to that provider in the widgets class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Movies>(
            //proxyprovider means that this provider depends upon another provider that is declared before this
            //second argument is the type of data you provide here
            //sets up a provider alt is ChangeNotifierProvider.value() where you use value: instead of create and that does not take a ctx arg
            update: (ctx, auth, previousProducts) => Movies(
                auth.token,
                previousProducts == null ? [] : previousProducts.items,
                auth.userId),
            create: null, //auth here is the Auth object
          ),
         
          
        ], //create instead of builder in dependencies > 4 //creates an instance of provider class],)
        child: Consumer<Auth>(
          builder: (ctx, authData, _) => MaterialApp(
            //authData gives the latest Auth state object
            //all child widgets can listen to this instance of the providers class
            title: 'My Movies',
            theme: ThemeData(
              //whenever we change anything in the class the only widgets that are listening to it will rebuild
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
            ),
            home: authData.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: authData.tryAutoLogin(),
                    builder: (ctx, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              
              
              UsersProductsScreen.routeName: (ctx) => UsersProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen()
            },
          ),
        ));
  }
}
