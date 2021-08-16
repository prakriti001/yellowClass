import 'package:flutter/material.dart';

import 'package:yellowClass/providers/movies.dart';

import 'package:yellowClass/widgets/app_drawer.dart';

import 'package:provider/provider.dart';
import 'edit_movie_screen.dart';
import 'package:yellowClass/widgets/movies_grid.dart';

enum FilterOptions { Favorites, All }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  
  var _isInit = true;
  var _isLoading=false;
  var showOnlyFavourites = false;
  
    //Provider.of<Products>(context).fetchAndShowProducts(); //inside init state of context things doesnt work because initState works even before the app is initialized
    //Future.delayed(Duration.zero).then((_) =>Provider.of<Products>(context).fetchAndShowProducts() ); can be used as a solution

    

  @override
  
  void didChangeDependencies() {
    if (_isInit) {
     setState(() {
       _isLoading=true;
     });
      Provider.of<Movies>(context).fetchAndShowProducts().then((response) {
        setState(() {
          _isLoading=false;
        });
      } );
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Movies'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  showOnlyFavourites = true;
                } else {
                  showOnlyFavourites = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              )
            ],
          ),
         IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body:_isLoading? Center(child:CircularProgressIndicator()):ProductsGrid(showOnlyFavourites),
    );
  }
}
