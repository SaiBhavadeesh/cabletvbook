import 'package:flutter/material.dart';

class CollectionScreen extends StatelessWidget {
  static const routeName = '/collectionScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collection Information'),
      ),
      body: Center(
        child: Container(
          child: Text('Comming soon...'),
        ),
      ),
    );
  }
}
