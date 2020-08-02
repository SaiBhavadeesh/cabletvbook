import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

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
          child: FadingText('Coming soon...'),
        ),
      ),
    );
  }
}
