import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:yellowClass/providers/movies.dart';

import 'package:yellowClass/widgets/movie_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  ProductsGrid(this.showFavs);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Movies>(
        context); //listen method <> tells which type of data you are listening to
    final products =showFavs? productsData.favouriteItems:productsData.items;
    return GridView.builder(
      //this establishes a direct communication channel between this class and the provider class instance
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10), //how many columns you should hve
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: products[i], //we dont instantiate the product() class here because it has already been instantiated in the products class
          child: ProductItem(title: productsData.items[i].title,
                                      id: productsData.items[i].id,
                                      imageUrl: productsData.items[i].imageUrl,))
              //products[i].id, products[i].title, products[i].imageUrl)
              ,
      padding: const EdgeInsets.all(10),
    );
  }
}
