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
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.grey.shade200,
        iconTheme: IconThemeData(
          color: kThemeColor,
        ),
        title: Text(
          "Details",
          style: TextStyle(
            color: kThemeColor,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Personal Information",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 8.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20.0),
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            user?.displayName ?? 'Name not saved yet',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          trailing:
                              Icon(Icons.edit, color: kThemeColor, size: 22),
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey.shade300),
                      ListTile(
                        title: Text(
                          'Email:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          user?.email ?? 'Email not received yet',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        trailing:
                            Icon(Icons.email, color: kThemeColor, size: 22),
                      ),
                      Divider(height: 1, color: Colors.grey.shade300),
                      ListTile(
                        title: Text(
                          'Phone:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          user?.phoneNumber ?? 'Phone number not available',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        trailing:
                            Icon(Icons.phone, color: kThemeColor, size: 22),
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
  const ChangeNameDialog({super.key});

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
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Name',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: kThemeColor,
              ),
            ),
            SizedBox(height: 20.0),
            _buildTextField(_firstNameController, 'First Name'),
            SizedBox(height: 12.0),
            _buildTextField(_middleNameController, 'Middle Name'),
            SizedBox(height: 12.0),
            _buildTextField(_lastNameController, 'Last Name'),
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
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                SizedBox(width: 12.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Add logic to save the new name
                  },
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kThemeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        prefixIcon: Icon(Icons.person, color: kThemeColor),
      ),
    );
  }
}
