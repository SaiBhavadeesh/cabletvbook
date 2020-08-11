import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/models/customer.dart';
import 'package:flutter/material.dart';
import 'package:cableTvBook/widgets/customer_tile.dart';
import 'package:flutter_icons/flutter_icons.dart';

class SearchScreenWidget extends StatefulWidget {
  final bool all;
  final bool active;
  final bool inactive;
  final List<Customer> providedCustomers;
  SearchScreenWidget({
    this.all = false,
    this.active = false,
    this.inactive = false,
    this.providedCustomers,
  });

  @override
  _SearchScreenWidgetState createState() => _SearchScreenWidgetState();
}

class _SearchScreenWidgetState extends State<SearchScreenWidget> {
  final searchController = TextEditingController();

  List<Customer> customers = [];

  onTextChange(String value) {
    customers = getSelectedCustomers(
      active: widget.active,
      all: widget.all,
      inactive: widget.inactive,
      providedCustomers: widget.providedCustomers,
    );
    setState(() {
      if (value.isNotEmpty)
        customers = customers
            .where((customer) => (customer.name.contains(value) ||
                customer.accountNumber.contains(value) ||
                customer.macId.contains(value)))
            .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    customers = getSelectedCustomers(
      active: widget.active,
      all: widget.all,
      inactive: widget.inactive,
      providedCustomers: widget.providedCustomers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scrollbar(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: <Widget>[
                    SizedBox(
                      height: 55,
                    ),
                    CustomerTile(
                      customer: customers[index],
                      index: index,
                    ),
                  ],
                );
              }
              return CustomerTile(
                customer: customers[index],
                index: index,
              );
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
                hint: 'Search by Name / mac no / acc no.',
                icon: FlutterIcons.ios_search_ion,
                radius: 30),
          ),
        ),
      ],
    );
  }
}
