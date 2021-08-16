import 'package:flutter/material.dart';
import 'package:yellowClass/providers/auth.dart';

import 'package:yellowClass/providers/movie.dart';
import 'package:yellowClass/providers/movies.dart';
import 'package:yellowClass/screens/edit_movie_screen.dart';

import 'package:provider/provider.dart';

class ProductItem extends StatelessWidget {
  final String title;
  final String id;
  final String imageUrl;
  ProductItem({this.title, this.imageUrl, this.id});
  //final String id;
  //final String title;

  //final String imageUrl;
  //ProductItem(this.id, this.title, this.imageUrl);
  @override
  Widget build(BuildContext context) {
    final scaffold=Scaffold.of(context);
    final product = Provider.of<Movie>(context);
    
    final auth=Provider.of<Auth>(context,listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            
          },
          child: Container(
           padding: EdgeInsets.all(8),
                      child: InkWell(
             
              child:Image.network(product.imageUrl,fit: BoxFit.cover,),
              
            ),
          ),
        ),
        footer: GridTileBar(
          leading: IconButton(
            icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              product.toggleFavoritesStatus(auth.token,auth.userId);
            },
          ),
          backgroundColor: Colors.black87,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                try {
                  await Provider.of<Movies>(context, listen: false)
                      .deleteProduct(id);
                } catch (error) {
                  scaffold
                      .showSnackBar(SnackBar(content: Text('Deleting failed')));
                }
              },
              color: Theme.of(context).errorColor,
            )
          ],
        ),
      ),
          
        ),
      ),
    );
  }
}
