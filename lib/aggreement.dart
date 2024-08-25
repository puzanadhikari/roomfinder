import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'model/onSaleModel.dart';


class AgreementPage extends StatefulWidget {
  String? sellerName;
  String? sellerEmail;
  String? roomUid;


  AgreementPage(this.sellerName, this.sellerEmail,this.roomUid);

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  void _approveRoomStatus(String? roomUid) async {
    log(roomUid!);
    try {
      User? user = FirebaseAuth.instance.currentUser;

      Map<String, dynamic> newStatus = {
        'ownedBy': user?.displayName,
        'ownerId': user?.uid,
        'ownerEmail': user?.email,
        'statusDisplay': 'Owned',
      };

      await FirebaseFirestore.instance
          .collection('onSale')
          .doc(roomUid)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room status updated to Sold!')),
      );

      // setState(() {
      //   room!.status = newStatus;
      // });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agreement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seller Name: ${widget.sellerName}\nSeller Email: ${widget.sellerEmail}\n',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              Text(
                'Agreement Terms:',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 8),
              Text(
                '1. The seller agrees to provide the goods or services as described.\n'
                    '2. The buyer agrees to pay the agreed-upon amount.\n'
                    '3. Both parties agree to adhere to the terms outlined in this agreement.\n'
                    '4. Any disputes will be resolved through mediation.\n'
                    '5. This agreement is legally binding and enforceable.\n',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              const SizedBox(height: 16),
              // Checkbox for acceptance
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'I accept the terms and conditions',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_acceptTerms) {
                      _approveRoomStatus(widget.roomUid);
                      Navigator.of(context).pop(); // Navigate back
                      Navigator.of(context).pop(); // Navigate back
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please accept the terms and conditions.')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
