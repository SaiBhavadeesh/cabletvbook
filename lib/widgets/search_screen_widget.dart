import 'package:cableTvBook/global/variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

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
  final searchController = TextEditingController();
  List<Customer> filteredCustomers = [];

  Future<void> _refreshCustomers() async {
    if (widget.areaId == null)
      customers = await getAllCustomers();
    else
      customers = await getSelectedAreaCustomers(widget.areaId);
    filteredCustomers = getSelectedCustomers(
        all: widget.all,
        pending: widget.pending,
        credits: widget.credits,
        active: widget.active,
        inactive: widget.inactive,
        providedCustomers: customers);
    if (mounted) setState(() {});
  }

  void onTextChange(String value) {
    filteredCustomers = getSelectedCustomers(
      all: widget.all,
      pending: widget.pending,
      credits: widget.credits,
      active: widget.active,
      inactive: widget.inactive,
      providedCustomers: customers,
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

  @override
  void initState() {
    super.initState();
    filteredCustomers = getSelectedCustomers(
      all: widget.all,
      pending: widget.pending,
      credits: widget.credits,
      active: widget.active,
      inactive: widget.inactive,
      providedCustomers: customers,
    );
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
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      onRefresh: _refreshCustomers,
      child: Stack(
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
                          refresh: _refreshCustomers,
                          index: index),
                    ],
                  );
                }
                return CustomerTile(
                    customer: filteredCustomers[index],
                    refresh: _refreshCustomers,
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
      ),
    );
  }
}
