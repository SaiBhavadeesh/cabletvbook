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
  int _year = DateTime.now().year.floor();
  int _selectedYear;
  bool _isLeftActive = true;
  bool _isRightActive = true;

  @override
  void initState() {
    super.initState();
    _selectedYear = _year;
  }

  void _leftArrowClickAction() {
    if (_year - _selectedYear + 1 <= 0) {
      setState(() {
        _isLeftActive = true;
        _isRightActive = true;
        _selectedYear = _selectedYear - 1;
      });
    } else {
      setState(() {
        _selectedYear = _selectedYear - 1;
        _isLeftActive = false;
        _isRightActive = true;
      });
    }
  }

  void _rightArrowClickAction() {
    if (_year - _selectedYear - 1 >= 0) {
      setState(() {
        _isRightActive = true;
        _isLeftActive = true;
        _selectedYear = _selectedYear + 1;
      });
    } else {
      setState(() {
        _selectedYear = _selectedYear + 1;
        _isRightActive = false;
        _isLeftActive = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.1),
      appBar: PreferredSize(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: <Widget>[
              IconButton(
                disabledColor: Colors.black,
                color: Theme.of(context).primaryColor,
                icon: Icon(Icons.arrow_back_ios),
                onPressed: _isLeftActive ? _leftArrowClickAction : null,
              ),
              Expanded(
                child: Text(
                  'Year\n$_selectedYear',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              IconButton(
                disabledColor: Colors.black,
                color: Theme.of(context).primaryColor,
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: _isRightActive ? _rightArrowClickAction : null,
              ),
            ],
          ),
        ),
        preferredSize: Size(width, width * 0.15),
      ),
      body: GridView.builder(
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
        padding: EdgeInsets.symmetric(horizontal: width * 0.025),
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      ),
    );
  }
}
