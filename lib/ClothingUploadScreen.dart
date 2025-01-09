import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClothingUploadScreen extends StatefulWidget {
  @override
  _ClothingUploadScreenState createState() => _ClothingUploadScreenState();
}

class _ClothingUploadScreenState extends State<ClothingUploadScreen> {
  final TextEditingController _brandController = TextEditingController();

  // 初期値を空文字に設定
  String _selectedGenre = '';
  String _selectedSize = '';
  String _selectedColor = '';

  final List<String> _genres = ["トップス", "ボトムス", "アウター", "アクセサリー"];
  final List<String> _sizes = ["S", "M", "L", "XL"];
  final List<String> _colors = [
    "ホワイト",
    "ブラック",
    "レッド",
    "ブルー",
    "グリーン",
    "イエロー",
    "ピンク",
    "パープル",
    "グレー",
    "ブラウン",
    "ベージュ",
    "オレンジ",
    "ネイビー",
    "カーキ",
    "シルバー",
    "ゴールド"
  ];

  // Firestoreに洋服を追加
  Future<void> _addClothing() async {
    if (_brandController.text.isNotEmpty &&
        _selectedGenre.isNotEmpty &&
        _selectedSize.isNotEmpty &&
        _selectedColor.isNotEmpty) {
      await FirebaseFirestore.instance.collection('clothes').add({
        'brand': _brandController.text,
        'type': _selectedGenre,
        'size': _selectedSize,
        'color': _selectedColor,
        'uploadedAt': Timestamp.now(),
      });

      _brandController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('洋服を登録しました！')),
      );

      setState(() {
        _selectedGenre = '';
        _selectedSize = '';
        _selectedColor = '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('すべてのフィールドを選択してください。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('洋服登録'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _brandController,
              decoration: InputDecoration(labelText: 'ブランド'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGenre.isEmpty ? null : _selectedGenre,
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Text('ジャンルを選択してください'),
                ),
                ..._genres.map((genre) {
                  return DropdownMenuItem(
                    value: genre,
                    child: Text(genre),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGenre = value ?? '';
                });
              },
              decoration: InputDecoration(labelText: 'ジャンル'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSize.isEmpty ? null : _selectedSize,
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Text('サイズを選択してください'),
                ),
                ..._sizes.map((size) {
                  return DropdownMenuItem(
                    value: size,
                    child: Text(size),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSize = value ?? '';
                });
              },
              decoration: InputDecoration(labelText: 'サイズ'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedColor.isEmpty ? null : _selectedColor,
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Text('色を選択してください'),
                ),
                ..._colors.map((color) {
                  return DropdownMenuItem(
                    value: color,
                    child: Text(color),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedColor = value ?? '';
                });
              },
              decoration: InputDecoration(labelText: '色'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addClothing,
              child: Text('登録'),
            ),
          ],
        ),
      ),
    );
  }
}
