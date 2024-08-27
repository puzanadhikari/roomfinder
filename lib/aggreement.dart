import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AgreementPage extends StatefulWidget {
  final String? sellerName;
  final String? sellerEmail;
  final String? roomUid;

  AgreementPage(this.sellerName, this.sellerEmail, this.roomUid);

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  bool _acceptTerms = false;

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
        const SnackBar(content: Text('Room status updated to Sold!')),
      );

      Navigator.of(context).pop(); // Close the agreement page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Booking Agreement'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Seller Information'),
              _buildInfoText('Seller Name: ${widget.sellerName}'),
              _buildInfoText('Seller Email: ${widget.sellerEmail}'),
              const SizedBox(height: 20),

              _buildSectionHeader('Agreement Terms'),
              _buildAgreementTerms(),

              const SizedBox(height: 20),
              _buildAcceptanceCheckbox(),

              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAgreementTerms() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '1. The seller agrees to provide the room as described in the listing.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            '2. The buyer agrees to pay the agreed-upon amount for the room.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            '3. Both parties agree to adhere to the terms outlined in this agreement.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            '4. Any disputes will be resolved through mediation.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            '5. This agreement is legally binding and enforceable.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptanceCheckbox() {
    return Row(
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
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _acceptTerms
            ? () {
          _approveRoomStatus(widget.roomUid);
        }
            : null,
        style: ElevatedButton.styleFrom(
          primary: Colors.indigo,
          onPrimary: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Submit',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}