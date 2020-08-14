import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/widgets/customer_tile.dart';
import 'package:cableTvBook/screens/search_screen.dart';
import 'package:cableTvBook/global/box_decoration.dart';

class SearchScreenWidget extends StatefulWidget {
  final bool all;
  final bool active;
  final bool inactive;
  final bool isRefreshable;
  final List<Customer> providedCustomers;
  SearchScreenWidget({
    this.all = false,
    this.active = false,
    this.inactive = false,
    this.isRefreshable = false,
    this.providedCustomers,
  });

  @override
  _SearchScreenWidgetState createState() => _SearchScreenWidgetState();
}

class _SearchScreenWidgetState extends State<SearchScreenWidget> {
  final searchController = TextEditingController();

  List<Customer> filteredCustomers = [];

  Future<void> _refreshCustomers() async {
    if (widget.isRefreshable) {
      customers = await getAllCustomers();
      filteredCustomers = getSelectedCustomers(
          active: widget.active,
          all: widget.all,
          inactive: widget.inactive,
          providedCustomers: customers);
      if (mounted) setState(() {});
    }
  }

  onTextChange(String value) {
    filteredCustomers = getSelectedCustomers(
      active: widget.active,
      all: widget.all,
      inactive: widget.inactive,
      providedCustomers: widget.providedCustomers??customers,
    );
    setState(() {
      if (value.isNotEmpty)
        filteredCustomers = customers
            .where((customer) => (customer.name.contains(value) ||
                customer.accountNumber.contains(value) ||
                customer.macId.contains(value)))
            .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    filteredCustomers = getSelectedCustomers(
      active: widget.active,
      all: widget.all,
      inactive: widget.inactive,
      providedCustomers: widget.providedCustomers ?? customers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      onRefresh: _refreshCustomers,
      child: Stack(
        children: <Widget>[
          Scrollbar(
            child: ListView.builder(
              itemCount: filteredCustomers.length,
              physics: widget.isRefreshable
                  ? const AlwaysScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: <Widget>[
                      SizedBox(
                        height: 55,
                      ),
                      CustomerTile(
                        customer: filteredCustomers[index],
                        index: index,
                      ),
                    ],
                  );
                }
                return CustomerTile(
                  customer: filteredCustomers[index],
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
                  filled: true,
                  filledColor: Colors.white,
                  hint: 'Search by Name / mac no / acc no.',
                  icon: FlutterIcons.ios_search_ion,
                  radius: 30),
            ),
          ),
        ],
      ),
    );
  }
}
