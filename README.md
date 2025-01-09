# 洋服管理アプリ
#### 概要
洋服管理アプリは、ユーザーが所有する洋服を登録し、天気や気温に応じた最適なコーディネートをAIが提案するPC向けアプリケーションです。

#### 主な機能
- 洋服の登録: ブランド、ジャンル（トップス、ボトムスなど）、色を入力して管理可能。
- クローゼット管理: 登録した洋服を一覧表示。
- AIによるコーディネート提案: OpenWeatherAPIから取得した天気情報を元に、Google Gemini APIが提案する最適なコーディネートを表示。

#### ディレクトリ構成
lib  
├── main.dart                     // アプリのエントリーポイント  
├── ClosetScreen.dart             // クローゼット管理画面  
├── ClothingUploadScreen.dart     // 洋服登録画面  
├── CoordinateSuggestionScreen.dart // コーディネート提案画面  
├── firebase_options.dart         // Firebaseの設定ファイル  
pubspec.yaml                      // 依存パッケージと環境設定  
#### 技術スタック
- プログラミング言語：Dart
- フレームワーク: Flutter
- データベース: Firebase Firestore
- 天気情報取得: OpenWeatherAPI
- AIコーディネート提案: Google Gemini API
#### 画面の説明

- #### ClothingUploadScreen
洋服を登録するフォーム画面。ブランド、ジャンル、色を入力可能。
登録後、Firestoreにデータが保存されます。

- #### ClosetScreen
Firestoreに登録された洋服の一覧を表示。
各洋服のブランド、ジャンル、色をカード形式で確認可能。

- #### CoordinateSuggestionScreen
天気や気温を取得し、Firestoreに登録された洋服データを基にAIがコーディネートを提案。
OpenWeatherAPIから天気情報を取得。
手動で天気データを入力してコーディネートを提案する機能も実装。
