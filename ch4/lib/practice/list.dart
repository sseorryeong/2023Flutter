import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blueGrey
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List'),
      ),
      body:
      ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.home),
          title:Text('Home'),
          trailing: Icon(Icons.navigate_next),
          onTap: (){},
        ),
        ListTile(
          leading: Icon(Icons.home),
          title:Text('Event'),
          trailing: Icon(Icons.navigate_next),
          onTap: (){},
        ),
        ListTile(
          leading: Icon(Icons.home),
          title:Text('Camera'),
          trailing: Icon(Icons.navigate_next),
          onTap: (){},
        ),
      ],
    ),
    );
  }
}
