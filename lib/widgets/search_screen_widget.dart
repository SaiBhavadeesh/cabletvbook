import 'package:cableTvBook/models/customer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cableTvBook/widgets/customer_tile.dart';
import 'package:flutter_icons/flutter_icons.dart';

class SearchScreenWidget extends StatelessWidget {
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
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final customers = getSelectedCustomers(
      active: active,
      all: all,
      inactive: inactive,
      providedCustomers: providedCustomers,
    );
    return Stack(
      children: <Widget>[
        Scrollbar(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 55,
                ),
                // AnimatedList(
                //   shrinkWrap: true,
                //   physics: NeverScrollableScrollPhysics(),
                //   initialItemCount: customers.length,
                //   itemBuilder: (context, index, animation) => SlideTransition(
                //     position: animation.drive(
                //       Tween(
                //         begin: Offset(0, 10),
                //         end: Offset(100, 10),
                //       ),
                //     ),
                //     child: CustomerTile(
                //       customer: customers[index],
                //     ),
                //   ),
                // )
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: customers.length,
                  itemBuilder: (context, index) => CustomerTile(
                    customer: customers[index],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              prefixIcon: Icon(FlutterIcons.ios_search_ion),
              hintText: 'Search by Name / mac no / acc no.',
            ),
          ),
        ),
      ],
    );
  }
}