import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:cableTvBook/models/customer.dart';
import 'package:cableTvBook/widgets/customer_tile.dart';
import 'package:cableTvBook/screens/search_screen.dart';
import 'package:cableTvBook/global/box_decoration.dart';

bool showed = false;

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
  bool _val = false;

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

  void onTextChange(String value) {
    filteredCustomers = getSelectedCustomers(
      active: widget.active,
      all: widget.all,
      inactive: widget.inactive,
      providedCustomers: widget.providedCustomers ?? customers,
    );
    setState(() {
      if (value.isNotEmpty)
        filteredCustomers = filteredCustomers
            .where((customer) => (customer.name.contains(value) ||
                customer.accountNumber.contains(value) ||
                customer.macId.contains(value)))
            .toList();
    });
  }

  void showPending(bool value) {
    setState(() {
      if (value)
        filteredCustomers = filteredCustomers
            .where((element) => element.noOfPendingBills > 0)
            .toList();
      else
        filteredCustomers = getSelectedCustomers(
          active: widget.active,
          all: widget.all,
          inactive: widget.inactive,
          providedCustomers: widget.providedCustomers ?? customers,
        );
      _val = !_val;
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
    try {
      if (widget.isRefreshable && !showed) {
        showed = true;
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
          Positioned(
            bottom: 0,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Switch(
                    activeTrackColor: Colors.lightGreen,
                    activeColor: Theme.of(context).primaryColor,
                    inactiveThumbColor: Colors.black45,
                    inactiveTrackColor: Colors.black38,
                    value: _val,
                    onChanged: showPending),
                Text(
                  'Show Pending',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
