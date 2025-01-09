import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClosetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('クローゼット管理'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('clothes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final clothes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: clothes.length,
            itemBuilder: (context, index) {
              final cloth = clothes[index];
              return ListTile(
                title: Text('${cloth['brand']} - ${cloth['type']}'),
                subtitle: Text('サイズ: ${cloth['size']}, 色: ${cloth['color']}'),
                trailing: Icon(Icons.checkroom),
              );
            },
          );
        },
      ),
    );
  }
}
