<!-- $Id: README.md 1592 2024-01-03 15:11:50Z sow $ -->
# 爆速ファミコン実機ダウンロード実行環境 MappserZeroAir

MapperZeroAir は、「ファミコン実機で自作プログラムをダウンロード実行」する操作を爆速で回すためのHW/SWです。

# 痛み

ファミコン向けにプログラムを書いてエミュレータで動作確認できていても、いざファミコン実機で試すと思ったように動かないことはありませんか？実機でデバッグしようとするとめちゃくちゃTATが悪いと感じることはありませんか？

# 解決方法

ファミコンからカセットを抜かずに無線でプログラムをダウンロードして完了したら自動的にリセットがかかるようにしました。  
ついでに、無線でV/Hミラーも指定でき、デバッグ用にLEDが付いていて、printデバッグもできて欲しい、のでそうする事にしました。

![(*) --> ソースコード修正
ソースコード修正 --> nesファイル生成
nesファイル生成 --> [従来] ファミコン本体の電源を落とす
ファミコン本体の電源を落とす --> ファミコン本体からロムカートリッジを取り外し
ファミコン本体からロムカートリッジを取り外し --> ロムカートリッジにバイナリ焼き込み
ロムカートリッジにバイナリ焼き込み --> ロムカートリッジをファミコン本体に差し込み直し
ロムカートリッジをファミコン本体に差し込み直し --> ファミコン本体の電源を入れる
ファミコン本体の電源を入れる --> カートリッジ接触不良対応
カートリッジ接触不良対応 --> テスト
テスト --> (*)
nesファイル生成 --> [提案] MapperZeroAir.exe実行
MapperZeroAir.exe実行 --> テスト](http://www.plantuml.com/plantuml/png/fLDDJi906DtFARfK4po2YGVm0XeMBhfmemGtRkSRDVo0DA0O0mQ9e4QaB30H5EXXNcTQR-4u9IxKOYERvilxtlU-zpepAskhLYgrOO6c41FG63JyB4JUzrpLlsLn3JErRnz2N83Qe0v4BpXlgPp3VaKDVqVEQkgwcxRcVT4ogaFLVFAdDN3tlV6cNXrGDNIcu0_WLomvrQo8eHT1UOW-n0sePtBa81uX16YaDMIb3Yh8JXtyaYql4Jc9utADEERV53GO74_0o-5CVptsZvd5kwWQawOdNrpjDD886iyc-F8gKVQ_prUUT44bK94bfnhbd-xKMJUyl_D7vJ0_a8EPz9ei2MdkynGqraJsLHbSFuj5rrXL7DNEfQsjtKp6pcxRsOFDlUowVMHBjnMsIom6_xRo0m00)

# 特徴

ファミコン本体の改造不要、ホストWindowsも専用ドライバのインストール不要。

# 構成

HWは無線機能付きマイコンの載ったファミコンカセットです。SWはWindows向けのexeファイルを作成しました。両者の間は Bluetooth の COMポート を介して無線でやり取りします。

# 使い方

## HWセットアップ

## Bluetoothつなぎ方

## COMポートの確認の仕方

## Mapper#0ダウンロード

# 公開

基本情報、回路図(schema)、ソースコード(exe、arduino)、設計、テスト、サンプルプログラム(asm) を公開していきます。

# 基本情報

## ディレクトリ構成

```
MapperZeroAir
│　LICENSE
│　README.md
│
├─schema
│　　　MapperZeroAir.pdf
│
├─exe
│　　　Makefile
│　　　MapperZeroAir.c
│　　　MapperZeroAir.exe
│
├─arduino
│　└─MapperZeroAir
│　　　　　MapperZeroAir.h
│　　　　　MapperZeroAir.ino
│
└─asm
　　└─prg0000_HelloWorld
　　　　　　prg0000_HelloWorld.asm
```

## 作者開発環境(動作確認環境)

- Windows10 HOME 64bit 22H2
- Arduino IDE 2.2.1
- esp32 by Espressif System 2.0.11
- gcc version 4.8.1 (GCC) for mingw32

# 設計

# テスト

# サンプルプログラム

# フォント

公開アセンブラコードでは、下記自作フォントを使用しています。  
![font.png](img/font.png)

# 引用商標

- ファミコンは、日本またはその他地域における任天堂株式会社の登録商標です。  
- Windowsは、米国またはその他地域におけるMicrosoft社の登録商標です。
- Arduinoは、日本国内においてArduino SRLの商標登録です。
- ESP32は、Espressif Systems (Shanghai) Co., Ltd.の中国または他の国における商標登録または商標です。
