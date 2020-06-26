import 'package:flutter/material.dart';

final List<Color> colors = [
  Colors.orange,
  Colors.red,
  Colors.blue,
  Colors.purple,
  Colors.pink,
  Colors.green,
  Colors.indigo,
  Colors.brown,
];

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int year = DateTime.now().year.floor();
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  disabledColor: Colors.black,
                  color: Theme.of(context).primaryColor,
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      year = year - 1;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'Year\n$year',
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  disabledColor: Colors.black,
                  color: Theme.of(context).primaryColor,
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    setState(() {
                      year = year + 1;
                    });
                  },
                ),
              ],
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 8,
              itemBuilder: (context, index) => GestureDetector(
                child: Container(
                  margin: EdgeInsets.all(width * 0.025),
                  padding: EdgeInsets.all(width * 0.05),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        colors[index % 8].withOpacity(0.2),
                        colors[index % 8].withOpacity(0.6),
                        colors[index % 8].withOpacity(0.4),
                        colors[index % 8].withOpacity(0.8),
                        colors[index % 8].withOpacity(0.6),
                        colors[index % 8].withOpacity(1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Area Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Total number of customers : 200'),
                      Text('Active accounts : 150'),
                      Text('In-Active accounts : 50'),
                    ],
                  ),
                ),
                onTap: () {},
                onLongPress: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    title: Text(
                      'Edit name',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: TextField(
                      maxLength: 10,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                        onPressed: () {},
                        icon: Icon(Icons.save_alt),
                        label: Text('save'),
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
              padding: EdgeInsets.all(width * 0.025),
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            ),
          ],
        ),
      ),
    );
  }
}
