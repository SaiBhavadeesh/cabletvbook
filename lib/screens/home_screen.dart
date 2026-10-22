import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:cableTvBook/models/operator.dart';
import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/global/default_buttons.dart';
import 'package:cableTvBook/services/database_services.dart';
import 'package:cableTvBook/widgets/default_dialog_box.dart';
import 'package:cableTvBook/screens/area_customers_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/homeScreen';

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Color> colors = const [
    Colors.red,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.indigo,
    Colors.green,
    Colors.brown,
    Colors.orange,
  ];

  Future<dynamic> showEditOrAddDialog({int index = -1, bool delete = false}) {
    return showDialog(
      context: context,
      builder: (ctx) {
        final textController = TextEditingController();
        if (index >= 0 && index < areas.length) {
          textController.text = areas[index].areaName;
        }
        return Form(
          key: _formKey,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: AlertDialog(
              title: Text(
                delete
                    ? 'Delete area'
                    : index < 0
                        ? 'Add new area'
                        : 'Edit area name',
              ),
              content: delete
                  ? const Text('Are you sure ?')
                  : index < 0
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'NOTE: You can add maximum of 16 areas.\n',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            TextFormField(
                              maxLength: 10,
                              controller: textController,
                              validator: nameValidator,
                              decoration:
                                  inputDecoration(icon: Icons.add_location),
                            ),
                          ],
                        )
                      : TextFormField(
                          maxLength: 10,
                          controller: textController,
                          validator: nameValidator,
                          decoration:
                              inputDecoration(icon: Icons.edit_location),
                        ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.check_circle),
                  color: Theme.of(context).primaryColor,
                  onPressed: delete
                      ? () async {
                          if (ctx.mounted) Navigator.pop(ctx);
                          await DatabaseService.deleteArea(
                              context, areas[index].id);
                        }
                      : () async {
                          if (_formKey.currentState?.validate() == true) {
                            _formKey.currentState?.save();
                            if (index < 0) {
                              bool isExist = areas.any((element) =>
                                  element.areaName ==
                                  textController.text.trim());
                              if (isExist) {
                                await DefaultDialogBox.errorDialog(
                                  ctx,
                                  title: 'Alert !',
                                  content: 'Area already exists !',
                                );
                              } else {
                                await DatabaseService.addArea(
                                  context,
                                  data: AreaData(
                                          areaName: textController.text.trim())
                                      .toJson(),
                                );
                              }
                            } else {
                              await DatabaseService.updateArea(
                                context,
                                data: areas[index].toJson()
                                  ..['an'] = textController.text.trim(),
                              );
                            }
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          }
                        },
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.cancel,
                      color: Theme.of(context).colorScheme.error),
                  onPressed: () => Navigator.pop(ctx),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final top = MediaQuery.of(context).padding.top;
    final op = operatorDetails;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size(size.width, size.width * 0.1),
          child: Column(
            children: <Widget>[
              Text(
                op?.networkName ?? '',
                style: TextStyle(
                  fontSize: (size.height - top) * 0.025,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02,
                  vertical: size.width * 0.01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      op?.name ?? '',
                      style: TextStyle(
                        fontSize: (size.height - top) * 0.023,
                        color: Colors.amber,
                      ),
                    ),
                    Text(
                      op?.phoneNumber ?? '',
                      style: TextStyle(
                        fontSize: (size.height - top) * 0.023,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: size.width * 0.01),
                color: Colors.white,
                child: Text(
                  'Areas',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.06,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: op == null
          ? const Center(child: Text('Operator information not loaded'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users/${op.id}/areas')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  areas = snapshot.data!.docs
                      .map((e) =>
                          AreaData.fromMap(e.data() as Map<String, dynamic>))
                      .toList();
                  return areas.isEmpty
                      ? const Center(
                          child: Text(
                            'No area to show',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        )
                      : GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: areas.length,
                          itemBuilder: (context, index) => GestureDetector(
                            key: ValueKey(areas[index].id),
                            onTap: areas[index].totalAccounts == 0
                                ? null
                                : () => Navigator.of(context).pushNamed(
                                      AreaCustomersScreen.routeName,
                                      arguments: areas[index],
                                    ),
                            onDoubleTap: () => showEditOrAddDialog(index: index),
                            onLongPress: () =>
                                showEditOrAddDialog(delete: true, index: index),
                            child: Container(
                              margin: EdgeInsets.all(size.width * 0.025),
                              padding: EdgeInsets.all(size.width * 0.04),
                              decoration: BoxDecoration(
                                backgroundBlendMode: BlendMode.darken,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(3, 3),
                                    spreadRadius: 5,
                                    blurRadius: 5,
                                  ),
                                ],
                                gradient: LinearGradient(
                                  colors: [
                                    colors[index % 8].withAlpha(102),
                                    colors[index % 8].withAlpha(153),
                                    colors[index % 8].withAlpha(204),
                                    colors[index % 8].withAlpha(153),
                                    colors[index % 8],
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: FittedBox(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      areas[index].areaName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.width * 0.06,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Divider(color: Colors.black38),
                                    FittedBox(
                                      child: Text(
                                        'Total customers : ${areas[index].totalAccounts}',
                                        style: TextStyle(
                                          fontSize: size.width * 0.045,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Divider(color: Colors.black38),
                                    FittedBox(
                                      child: Text(
                                        'Active : ${areas[index].activeAccounts}',
                                        style: TextStyle(
                                          fontSize: size.width * 0.045,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Divider(color: Colors.black38),
                                    FittedBox(
                                      child: Text(
                                        'In-Active : ${areas[index].inActiveAccounts}',
                                        style: TextStyle(
                                          fontSize: size.width * 0.045,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.025),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                        );
                }
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
              },
            ),
      floatingActionButton: areas.length < 16
          ? defaultbutton(
              context: context,
              function: () => showEditOrAddDialog(),
              title: 'Add Area',
              height: 12,
              width: 18,
              icon: Icons.add_location,
            )
          : null,
    );
  }
}
