import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meroapp/Constants/styleConsts.dart';

class InformationDetails extends StatefulWidget {
  const InformationDetails({super.key});

  @override
  State<InformationDetails> createState() => _InformationDetailsState();
}

class _InformationDetailsState extends State<InformationDetails> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
        centerTitle: true,
        backgroundColor: kThemeColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Center(
                  child: Text(
                "Personal Information",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              )),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => ChangeNameDialog(),
                          );
                        },
                        child: ListTile(
                          title: Text(
                            'Name:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle:
                              Text(user?.displayName ?? 'Name not saved yet'),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          'Email:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(user?.email ?? ''),
                      ),
                      Divider(),
                      ListTile(
                        title: Text(
                          'Phone:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(user?.phoneNumber ?? ''),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeNameDialog extends StatefulWidget {
  @override
  _ChangeNameDialogState createState() => _ChangeNameDialogState();
}

class _ChangeNameDialogState extends State<ChangeNameDialog> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _middleNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Name',
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: kThemeColor),
            ),
            SizedBox(height: 20.0),
            Container(
              height: 50.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.white,
              ),
              child: TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _middleNameController,
              decoration: InputDecoration(
                labelText: 'Middle Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: appBarColor),
                  ),
                ),
                SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(backgroundColor: kThemeColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
