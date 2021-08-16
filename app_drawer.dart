import 'package:flutter/material.dart';
import 'package:yellowClass/providers/auth.dart';
import 'package:provider/provider.dart';



class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello Friend'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.movie_creation),
            title: Text('My Movies'),
            onTap: () {
              Navigator.of(context).pushNamed('/');
            },
          ),
          
          
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context,listen: false).logOut();
            },
          )
        ],
      ),
    );
  }
}
