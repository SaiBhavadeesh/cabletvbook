import 'package:cableTvBook/global/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/widgets/customer_tile.dart';
import 'package:cableTvBook/global/box_decoration.dart';

bool _showed = false;

class SearchScreenWidget extends StatefulWidget {
  final bool all;
  final bool pending;
  final bool active;
  final bool credits;
  final bool inactive;
  final String areaId;
  SearchScreenWidget(
      {this.all = false,
      this.pending = false,
      this.credits = false,
      this.active = false,
      this.inactive = false,
      this.areaId});

  @override
  _SearchScreenWidgetState createState() => _SearchScreenWidgetState();
}

class _SearchScreenWidgetState extends State<SearchScreenWidget> {

  @override
  void initState() {
    super.initState();
    try {
      if (!_showed) {
        _showed = true;
        Future.delayed(
            Duration(seconds: 0),
            () => Scaffold.of(context).showSnackBar(SnackBar(
                content: SizedBox(
                    height: 16,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('pull down to refresh'),
                          SizedBox(width: 20),
                          Icon(Icons.arrow_downward, size: 18)
                        ])),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)))));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users/${operatorDetails.id}/customers')
            .where(widget.areaId != null ? 'areaId' : '',
                isEqualTo: widget.areaId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final customers = getCustomersFromDoc(snapshot.data);
            if (customers.isEmpty) {
              return Center(
                child: Text('No customer to show',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              );
            }
            return CustomerListView(
                customers: customers);
          } else if (snapshot.connectionState == ConnectionState.waiting)
            return Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.3),
              child: Center(
                child: LoadingIndicator(
                    indicatorType: Indicator.ballClipRotateMultiple),
              ),
            );
          else
            return Center(child: Text('Something went wrong!'));
        });
  }
}

class CustomerListView extends StatefulWidget {
  const CustomerListView(
      {Key key,
      @required this.customers,
      this.all = false,
      this.pending = false,
      this.credits = false,
      this.active = false,
      this.inactive = false})
      : super(key: key);

  final List<Customer> customers;
  final bool all;
  final bool pending;
  final bool active;
  final bool credits;
  final bool inactive;

  @override
  _CustomerListViewState createState() => _CustomerListViewState();
}

class _CustomerListViewState extends State<CustomerListView> {
  final searchController = TextEditingController();
  List<Customer> filteredCustomers = [];
  void onTextChange(String value) {
    setState(() {
      if (value.isNotEmpty)
        filteredCustomers = widget.customers
            .where((customer) => (customer.name.contains(value) ||
                customer.accountNumber.contains(value) ||
                customer.macId.contains(value)))
            .toList();
      else
        filteredCustomers = widget.customers;
    });
  }

  @override
  void initState() {
    super.initState();
    filteredCustomers = widget.customers;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scrollbar(
          child: ListView.builder(
            itemCount: filteredCustomers.length,
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: <Widget>[
                    SizedBox(
                      height: 55,
                    ),
                    CustomerTile(
                        customer: filteredCustomers[index],
                        index: index),
                  ],
                );
              }
              return CustomerTile(
                  customer: filteredCustomers[index],
                  index: index);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onChanged: onTextChange,
            decoration: inputDecoration(
                filled: true,
                filledColor: Colors.white,
                hint: 'Search by Name / mac no / acc no.',
                icon: FlutterIcons.ios_search_ion,
                radius: 30),
          ),
        ),
      ],
    );
  }
}
