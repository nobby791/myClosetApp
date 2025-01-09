import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class CoordinateSuggestionScreen extends StatefulWidget {
  @override
  _CoordinateSuggestionScreenState createState() =>
      _CoordinateSuggestionScreenState();
}

class _CoordinateSuggestionScreenState
    extends State<CoordinateSuggestionScreen> {
  String? _temperature; // 気温
  String? _weatherDescription; // 天気の説明
  String? _suggestedOutfit; // 提案されたコーディネート
  bool _isLoading = false; // ローディング状態を管理

  // OpenWeatherAPIのAPIキーと都市名
  final String _weatherApiKey = 'd9fa7174f25a7f1fc9ba96d9234e8e9b'; // APIキー
  final String _city = 'Tokyo'; // 取得する都市名

  // Google Gemini用モデルとAPIキー
  final _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: 'AIzaSyDddMfggUY5cD0L77wH0VQ6dJOtCqXepnc',
  );

  // プロンプト定義
  static const _promptTemplate = '''
    今日の気温は{temperature}℃で、天気は{weatherDescription}です。
    以下の洋服データを基に、最適なコーディネートを提案してください。
    サイズは気にしなくて大丈夫です。
    洋服データ:
    {clothes}
    ''';

  // OpenWeatherAPIから天気データを取得
  Future<void> _fetchWeather() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$_city&units=metric&appid=$_weatherApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _temperature = data['main']['temp'].toString(); // 気温
          _weatherDescription = data['weather'][0]['description']; // 天気の説明
        });
      } else {
        print('OpenWeatherAPI Error: ${response.statusCode}');
        setState(() {
          _temperature = null;
          _weatherDescription = null;
        });
      }
    } catch (e) {
      print('Failed to fetch weather data: $e');
      setState(() {
        _temperature = null;
        _weatherDescription = null;
      });
    }
  }

  // Firestoreから洋服データを取得
  Future<List<Map<String, dynamic>>> _fetchClothesFromFirestore() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('clothes').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Failed to fetch clothes from Firestore: $e");
      return [];
    }
  }

  // コーディネートを生成
  Future<void> _fetchSuggestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 天気情報を取得
      await _fetchWeather();

      if (_temperature == null || _weatherDescription == null) {
        setState(() {
          _suggestedOutfit = '天気情報が取得できませんでした。';
        });
        return;
      }

      // Firestoreから洋服データを取得
      final clothes = await _fetchClothesFromFirestore();

      if (clothes.isEmpty) {
        setState(() {
          _suggestedOutfit = '洋服データが見つかりませんでした。';
        });
        return;
      }

      // プロンプト生成
      final prompt = _promptTemplate
          .replaceAll('{temperature}', _temperature!)
          .replaceAll('{weatherDescription}', _weatherDescription!)
          .replaceAll('{clothes}', clothes.map((e) => e.toString()).join('\n'));

      // Google Gemini APIを呼び出してテキスト生成
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      // レスポンスを取得
      setState(() {
        _suggestedOutfit = response.text ?? '提案されたコーディネートが見つかりませんでした。';
      });
    } catch (e) {
      setState(() {
        _suggestedOutfit = 'エラーが発生しました: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('コーディネート提案'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _fetchSuggestions,
                  child: Text('コーディネートを提案'),
                ),
              if (_temperature != null && _weatherDescription != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '現在の気温: $_temperature℃\n天気: $_weatherDescription',
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_suggestedOutfit != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 5,
                    margin:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '提案されたコーディネート',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            _suggestedOutfit!,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 16),
                          Divider(color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'AIのコメント',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'このコーディネートは、天気や気温を考慮して作成されました。季節感を取り入れつつ、おしゃれさも保つことを意識しました！',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Center(
                  child: Text(
                    '提案がありません',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
