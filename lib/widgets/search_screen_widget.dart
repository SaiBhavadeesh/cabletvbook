import 'package:cableTvBook/global/variables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  final String? areaId;

  const SearchScreenWidget({
    super.key,
    this.all = false,
    this.pending = false,
    this.credits = false,
    this.active = false,
    this.inactive = false,
    this.areaId,
  });

  @override
  _SearchScreenWidgetState createState() => _SearchScreenWidgetState();
}

class _SearchScreenWidgetState extends State<SearchScreenWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_showed && mounted) {
        _showed = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const SizedBox(
              height: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('pull down to refresh'),
                  SizedBox(width: 20),
                  Icon(Icons.arrow_downward, size: 18, color: Colors.white),
                ],
              ),
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.blueGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final op = operatorDetails;
    if (op == null) {
      return const Center(child: Text('Operator information unavailable'));
    }

    Query collection = FirebaseFirestore.instance
        .collection('users/${op.id}/customers');
    if (widget.areaId != null && widget.areaId!.isNotEmpty) {
      collection = collection.where('areaId', isEqualTo: widget.areaId);
    }
    if (widget.active) {
      collection = collection.where('curSts', isEqualTo: 'Active');
    } else if (widget.inactive) {
      collection = collection.where('curSts', isEqualTo: 'Inactive');
    }

    return StreamBuilder<QuerySnapshot>(
      stream: collection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final customers = getCustomersFromDoc(
            snapshot.data!,
            active: widget.active,
            all: widget.all,
            credits: widget.credits,
            inactive: widget.inactive,
            pending: widget.pending,
          );
          if (customers.isEmpty) {
            return const Center(
              child: Text(
                'No customer to show',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            );
          }
          return CustomerListView(customers: customers);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: LoadingIndicator(
                indicatorType: Indicator.ballClipRotateMultiple,
                colors: [Theme.of(context).primaryColor],
              ),
            ),
          );
        } else {
          return const Center(child: Text('Something went wrong!'));
        }
      },
    );
  }
}

class CustomerListView extends StatefulWidget {
  const CustomerListView({
    super.key,
    required this.customers,
  });

  final List<Customer> customers;

  @override
  _CustomerListViewState createState() => _CustomerListViewState();
}

class _CustomerListViewState extends State<CustomerListView> {
  final searchController = TextEditingController();
  List<Customer> filteredCustomers = [];

  void onTextChange(String value) {
    setState(() {
      final query = value.toLowerCase().trim();
      if (query.isNotEmpty) {
        filteredCustomers = widget.customers
            .where((customer) =>
                customer.name.toLowerCase().contains(query) ||
                customer.accountNumber.toLowerCase().contains(query) ||
                customer.macId.toLowerCase().contains(query))
            .toList();
      } else {
        filteredCustomers = widget.customers;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    filteredCustomers = widget.customers;
  }

  @override
  void didUpdateWidget(CustomerListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customers != widget.customers) {
      onTextChange(searchController.text);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scrollbar(
          child: ListView.builder(
            itemCount: filteredCustomers.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: <Widget>[
                    const SizedBox(height: 55),
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
              icon: Icons.search,
              radius: 30,
            ),
          ),
        ),
      ],
    );
  }
}
