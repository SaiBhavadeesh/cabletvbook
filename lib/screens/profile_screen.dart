import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:cableTvBook/global/variables.dart';
import 'package:cableTvBook/global/validators.dart';
import 'package:cableTvBook/helpers/image_getter.dart';
import 'package:cableTvBook/helpers/avatar_image_provider.dart';
import 'package:cableTvBook/global/box_decoration.dart';
import 'package:cableTvBook/global/default_buttons.dart';
import 'package:cableTvBook/services/database_services.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profileScreen';

  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _selectedImageFile;

  Widget getTitle(BuildContext context, String title) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).primaryColor,
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget getTitleValueEdit(String title, String value, VoidCallback? function) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
              child: Text(value),
            ),
          ],
        ),
        if (function != null)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: function,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final op = operatorDetails;
    if (op == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Operator profile not loaded')),
      );
    }

    ImageProvider avatarImage;
    if (_selectedImageFile != null) {
      avatarImage = FileImage(_selectedImageFile!);
    } else {
      avatarImage = getAvatarImageProvider(op.profileImageLink);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Stack(
                children: <Widget>[
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: avatarImage,
                  ),
                  Positioned(
                    bottom: 5,
                    left: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () async {
                          final file =
                              await ImageGetter.getImageFromDevice(context);
                          if (file != null) {
                            _selectedImageFile = file;
                            await DatabaseService.uploadProfilePicture(context,
                                file: file);
                            if (mounted) setState(() {});
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            getTitle(context, 'Primary Information'),
            const SizedBox(height: 10),
            getTitleValueEdit('Email', op.email, null),
            const SizedBox(height: 10),
            getTitleValueEdit('Phone number', op.phoneNumber, null),
            const SizedBox(height: 10),
            getTitleValueEdit(
              'Name',
              op.name,
              () => showDialog(
                context: context,
                builder: (ctx) {
                  final formKey = GlobalKey<FormState>();
                  String name = op.name;
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: AlertDialog(
                      content: Form(
                        key: formKey,
                        child: TextFormField(
                          initialValue: op.name,
                          validator: nameValidator,
                          decoration: const InputDecoration(
                            labelText: 'Edit Name',
                          ),
                          onSaved: (value) {
                            if (value != null) name = value.trim();
                          },
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (formKey.currentState?.validate() == true) {
                              formKey.currentState?.save();
                              await DatabaseService.updateData(context,
                                  data: {'name': name});
                              if (ctx.mounted) Navigator.of(ctx).pop();
                              if (mounted) setState(() {});
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            getTitleValueEdit(
              'Network name',
              op.networkName,
              () => showDialog(
                context: context,
                builder: (ctx) {
                  final formKey = GlobalKey<FormState>();
                  String networkName = op.networkName;
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: AlertDialog(
                      content: Form(
                        key: formKey,
                        child: TextFormField(
                          initialValue: op.networkName,
                          validator: (value) =>
                              nameValidator(value, maxLength: 40),
                          decoration: const InputDecoration(
                            labelText: 'Edit Network name',
                          ),
                          onSaved: (value) {
                            if (value != null) networkName = value.trim();
                          },
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (formKey.currentState?.validate() == true) {
                              formKey.currentState?.save();
                              await DatabaseService.updateData(context,
                                  data: {'nn': networkName});
                              if (ctx.mounted) Navigator.of(ctx).pop();
                              if (mounted) setState(() {});
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            getTitle(context, 'Secondary Information'),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
              child: Text(
                'Areas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            areas.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'No area to show',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  )
                : GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        decoration: sweepGradientDecoration(context),
                        child: Text(
                          areas[index].areaName,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                    itemCount: areas.length,
                  ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 4.0),
              child: Text(
                'Plans',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
              ),
              itemBuilder: (context, index) {
                return InkResponse(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    decoration: sweepGradientDecoration(context),
                    child: Text(
                      op.plans[index].toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
              itemCount: op.plans.length,
            ),
            const SizedBox(height: 10),
            if (op.plans.length < 16)
              Align(
                alignment: Alignment.centerRight,
                child: defaultbutton(
                  context: context,
                  title: 'Add Plan',
                  width: 18,
                  height: 12,
                  function: () {
                    final formKey = GlobalKey<FormState>();
                    final planController = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (dialogCtx) => Form(
                        key: formKey,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: AlertDialog(
                            title: const Text('Add Plan'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'NOTE: Plan cannot be deleted. You can add maximum of 16 plans!\n',
                                  style: TextStyle(color: Colors.red),
                                ),
                                TextFormField(
                                  controller: planController,
                                  validator: planValidator,
                                  decoration: inputDecoration(
                                    icon: Icons.currency_rupee,
                                  ),
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(dialogCtx).colorScheme.error,
                                ),
                                child: const Text('cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  if (formKey.currentState?.validate() ==
                                      true) {
                                    formKey.currentState?.save();
                                    final list = List<double>.from(op.plans)
                                      ..add(double.parse(
                                          planController.text.trim()));
                                    await DatabaseService.updateData(
                                      context,
                                      data: {'plans': list},
                                    );
                                    if (dialogCtx.mounted) {
                                      Navigator.pop(dialogCtx);
                                    }
                                    if (mounted) setState(() {});
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(dialogCtx).primaryColor,
                                ),
                                child: const Text(
                                  'save',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
