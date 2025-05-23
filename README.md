<!-- $Id: README.md 2057 2025-05-05 01:52:01Z sow $ -->
# 無線ダウンロード実行カセット MappserZeroAir

MapperZeroAir は、「ファミコン実機で自作プログラムを無線でダウンロード実行」するためのファミコンカセットです。

![MapperZeroAir500x480.png](img/MapperZeroAir500x480.png)

# 1. 概要

## 1-1. 痛み

ファミコン向けにプログラムを書いてエミュレータで動作確認できていても、いざファミコン実機で試すと思ったように動かない。実機でデバッグしようとするとファミコンの電源切ってカセット抜いてROM焼き直してカセット挿し直して電源入れて...とめちゃくちゃ手間がかかる。もっと効率よく小さいプログラムの塊を実機でデバッグできるようにならないものか。

## 1-2. 解決方法

ファミコンからカセットを抜かずに無線でプログラムをダウンロードし、ダウンロードが完了したら自動的にリセットがかかるようにする。ついでに、無線でV/Hミラーも変更でき、デバッグ用にLEDが付いていて、printデバッグもできて欲しい、のでそうする。

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

## 1-3. 特徴

- ファミコン本体の改造不要、ホストPC(Windowsマシン)も専用ドライバのインストール不要で使える
- ホストPCから無線越しにNESファイル(PRG-ROM最大32kバイト、CHR-ROM最大8kバイト)をダウンロード可能
- NESファイルのヘッダに記載されているVミラー/Hミラーの設定をカセットに反映
- カセットから本体へ送るIRQ割り込み信号を無線越しに生成可能
- カセットに実装されたデバッグ用のLEDをファミコン用のプログラムから制御可能
- ファミコンによるI/O操作によりホストPCへデータを送信可能

## 1-4. 構成

ハードウェアは無線機能付きマイコンの載ったファミコンカセットです。ソフトウェアはWindows向けのexeファイルを作成しました。両者の間は Bluetooth の COMポート を介して無線でやり取りします。

# 2. 使い始めるまで

この章では、MapperZeroAirを利用開始する前での手順を示します。<br>
※ここでは、Windows11 HOME 24H2 の場合の接続方法です。OSのエディションやバージョンの違いで見た目や手順が多少異なる場合があります。

## 2-1. ハードウェアのセットアップ

MapperZeroAirをファミコン本体に挿し、ファミコン本体に電源を入れます。

## 2-2. BluetoothでホストPCとMapperZeroAirを接続

ファミコン本体に挿したMapperZeroAirとホストPCとをBluetoothで接続します。

0. Windowsキーを押下し、設定を開きます。

1. 「Bluetooth とデバイス」を選択し、「Bluetooth」を「オン」にしてから「＋デバイスの追加」を押下し「デバイを追加する」を開きます。

![BluetoothSetup1.png](img/BluetoothSetup1.png)

2. 「追加するデバイスの種類」に「Bluetooth」を選択してください。

![BluetoothSetup2.png](img/BluetoothSetup2.png)

3. しばらくすると現れる「MapperZeroAir」を選択してください。

![BluetoothSetup3.png](img/BluetoothSetup3.png)

4. 「接続しています...」となりますが、接続完了を待ってください。

![BluetoothSetup4.png](img/BluetoothSetup4.png)

5. 右下のボタンが「完了」になったら「完了」を押下してください。

![BluetoothSetup5.png](img/BluetoothSetup5.png)

## 2-3. COMポートの確認

ホストPCからMapperZeroAirに接続するためのCOMポートを確認します。

6. 「Bluetooth とデバイス」の「その他のデバイスを表示」を押下します。

![BluetoothSetup6.png](img/BluetoothSetup6.png)

7. 下までスクロールして「その他の Bluetooth 設定」を押下し、「Bluetooth 設定」を開きます。

![BluetoothSetup7.png](img/BluetoothSetup7.png)

8. タブ「COMポート」を選択し、名前が「MapperZeroAir 'ESP32SPP'」となっているポートを控えます。(下の例では「COM3」を控えることになります)

![BluetoothSetup8.png](img/BluetoothSetup8.png)

## 2-4. Hello World! のダウンロード実行

9. https://github.com/isariyokurari/MapperZeroAir/archive/refs/heads/main.zip をダウンロードして展開してください。※以降の例では「C:\MapperZeroAir-main」に展開されたものとして説明を続けます。

10. コマンドプロンプトを開き(例：Windowsキーを押下し、「cmd」と入力してEnterキーを押す)、展開したディレクトリへ移動してください。(例：「cd C:\MapperZeroAir-main」を実行する)

11. 先に控えたCOMポートを使い、「exe\MapperZeroAir.exe <COMポート> nes\prg0000_HelloWorld.nes」を実行してください。(例：「exe\MapperZeroAir.exe COM3 nes\prg0000_HelloWorld.nes」)

12. 「Successed to write from 0x8000 to 0xFFFF.」と表示されたらダウンロード完了です。ファミコン本体のリセットボタンを押し、「Hello World!」と表示されることを確認してください。

![prg0000_HelloWorld0000.png](img/prg0000_HelloWorld0000.png)

実行した様子を収めた動画は下から閲覧できます。

https://youtu.be/zyV-2UMJdmg<br>
[![prg0000_HelloWorld0000_thumbnail.png](img/prg0000_HelloWorld0000_thumbnail.png)](https://www.youtube.com/watch?v=zyV-2UMJdmg)

# 3. 使い方

## 3-1. MapperZeroAir.exe の使い方

**ダウンロード実行**<br>
MapperZeroAirにプログラムをダウンロードするモードです。「--irq」オプションは、プログラムのダウンロードの前にIRQ割り込みを発生させるオプションです。

```
Usage : MapperZeroAir.exe <COMn> <FILE> [--irq]
```

対応しているマッパーは マッパー#0 と マッパー#2(CHR-ROMが0kバイト) です。PRG-ROMは16kバイトか32kバイト、CHR-ROMは0kバイトか8kバイトに対応しています。マッパー#0のダウンロードは、最初にCHR-ROMローダをダウンロード実行した後、PRG-ROMをダウンロードします。この時、CHR-ROMローダのダウンロード後とPRG-ROMのダウンロード後にリセット操作の指示が出るので従ってください。マッパー#2をダウンロードする場合、CHR-ROMローダのダウンロード実行はありません。マッパー#2 且つ「--irq」オプション指定し、後述する「IRQをトリガとしたリセット」を実装すると、ファミコン本体の操作なしにダウンロード後にリセットベクタへ飛ばすことができます。16kバイトのPRG-ROMのみのマッパー#2をダウンロード実行することで効率よく実機確認を行えます。

参考動画：ファミコンカセットに無線でダウンロードして実行＆自動リセット<br>
https://youtu.be/zyV-2UMJdmg

**モニタ実行**<br>
ファミコン用プログラムから送られてくるデータをASCII文字で表示するモードです。

```
Usage: MapperZeroAir.exe <COMn> --spi
```

参考動画：ホストPCでファミコンのコントローラ情報を表示<br>
https://youtu.be/Nj-gnS3i97A

## 3-2. ファミコン用プログラムの書き方

※アセンブラによるファミコン向けプログラムを作成、修正、エミュレータなどで実行、デバッグできる方を対象として説明します。また、ファミコン用のアセンブラにはNESASMを想定しています。

**IRQをトリガとしたリセット**<br>
サンプル「asm/prg0000_HelloWorld/prg0000_HelloWorld.asm」は、「16kバイトのPRG-ROMのみのマッパー#2」なサンプルプログラムとなっており、「IRQ割り込みをトリガとしたリセット」が実装されています。コード中の FILL_CHR_ROM_EN および USE_IRQ_LOADER を「1」にしておくことで、コード修正後のダウンロード実行を本体に触れずに実行できます。一度 CHR-ROM の内容が転送された後は、FILL_CHR_ROM_EN を「0」にすることで、さらにプログラムの起動を早くすることができます。この仕組みを利用する場合は、FILL_CHR_ROM_EN と記載のある行や USE_IRQ_LOADER と記載のある行を自身のコードに埋め込んでください。シーケンスの詳細は設計情報「ダウンロード実行のシーケンス図」を参考にしてください。

参考動画：ファミコンカセットに無線でダウンロードして実行＆自動リセット<br>
https://youtu.be/zyV-2UMJdmg

**LEDの操作**<br>
サンプル「asm/prg0001_BlinkLED/prg0001_BlinkLED.asm」は、LEDを操作するサンプルプログラムです。LEDはCPUアドレスマップの$6000の下位3bitに接続されたラッチの出力の最下位bitに接続されています。1をセットするとLEDが点灯し、0をセットすると消灯します。LEDを制御するラッチの出力は、後述するSPIバスのSCK信号と共有しています。

参考動画：MapperZeroAirを使った「ファミコンでLチカ」<br>
https://youtu.be/3pPrdFvhvLE

**printの操作**<br>
サンプル「asm/prg0002_HowToUseSPI/prg0002_HowToUseSPI.asm」は、CPUアドレスマップの$6000の下位3bitに接続されたラッチでSPIバスを操作して、ホストPCにprint出力をするサンプルプログラムです。SPI_OUTPUT_EN を「1」にすると、SPI_BUS_RESET と SPI_SEND_A_BYTE が使えるようになります。SPI_BUS_RESET を実行後、printしたいデータをXレジスタに入れて SPI_SEND_A_BYTE を呼び出すことで、ホストPCに1Byteのデータを送信、print出力することができます。ホストPCは、前述の「モニタ実行」をしておくと、ファミコンからprint出力されたデータをASCII文字で表示することができます。この仕組みを利用する場合は、SPI_OUTPUT_EN と記載のある行を自身のコードに埋め込み、SPI_BUS_RESET を実行後、printしたいデータをXレジスタに入れて SPI_SEND_A_BYTE を呼び出してください。

参考動画：ファミコンからホストPCにデータを送る例<br>
https://youtu.be/u2sw9qeY_OA

サンプル「asm/prg0003_DumpPad1ViaSPI/prg0003_DumpPad1ViaSPI.asm」も、ファミコンからホストPCにデータを送る例です。ファミコンのコントローラの入力状態をホストPCで表示しているため、ファミコンからデータを送っていることが分かりやすいです。文字コード「0x0D」(キャリッジリターン)によりカーソルが行頭に戻され、表示中の0と1が更新されていることが見て取れます。

参考動画：ホストPCでファミコンのコントローラ情報を表示<br>
https://youtu.be/Nj-gnS3i97A

# 4. 公開

基本情報、回路図(schema)、ソースコード(exe、arduino)、設計、テスト、サンプルプログラム(asm) を公開していきます。

## 4-1. ディレクトリ構成

```
MapperZeroAir
│　LICENSE
│　README.md
│
├─schema
│　　　MapperZeroAir.pdf          ... MapperZeroAirの回路図
│
├─exe
│　　　Makefile
│　　　MapperZeroAir.c            ... ホストPC用実行ファイルのソースコード
│　　　MapperZeroAir.exe          ... ホストPC用実行ファイル
│
├─arduino
│　└─MapperZeroAir
│　　　　　MapperZeroAir.h        ... MapperZeroAir用のヘッダファイル(.cおよび.inoから参照)
│　　　　　MapperZeroAir.ino      ... MapperZeroAirに搭載されたマイコン用のコード
│
├─nes
│　　　prg0000_HelloWorld..nes    ... 動作確認用のnesファイル
│
└─asm
　　└─prg0000_HelloWorld
　　　　　　prg0000_HelloWorld.asm ... サンプルコード(NESASM用)
```

## 4-2. 開発環境(動作確認環境)

- Windows10 HOME 64bit 22H2 / Windows11 HOME 24H2
- Arduino IDE 2.2.1
- esp32 by Espressif System 2.0.11
- gcc version 4.8.1 (GCC) for mingw32

## 4-3. 設計

**PRG-ROM BUS**<br>
カードエッジコネクタのPRG-ROMバスは、32kByteのSRAMを接続します。ただし、マイコンからSRAMへ書き込みができるように、アドレスバス(A[14:0])やアウトプットイネーブル(OE)を非選択にできるようにします。使用するGPIOを節約するため、マイコンから指定するアドレスはマイコンのデータバスをラッチします。I/Oのレベル調整のため、PRG-ROMからの出力は5VトレラントのICで受け、SRAMの出力は低Vthのバッファを介してPRG-ROMに接続します。<br>
![MapperZeroAirBlockDiagram_PRG-ROM.png](img/MapperZeroAirBlockDiagram_PRG-ROM.png)

**CHR-ROM BUS**<br>
カードエッジコネクタのCHR-ROMバスは、8kByteのSRAMを接続します。マイコンから直接8kByteのSRAMへ書き込むことをあきらめ、CHR-ROMの内容を8kByteのSRAMへ書き込むファミコン用のソフトウェアを実行することで代替することにより、部品点数を削減しています。また、Vミラー/Hミラーの切り替えをマイコンから行えるよう、VRAM_A10への接続を切り替えるセレクタ回路を設けます。セレクタ回路はVRAM-A10に接続するため5V系とし、低Vthのバッファを介したマイコンの出力を選択信号として使用します。<br>
![MapperZeroAirBlockDiagram_CHR-ROM.png](img/MapperZeroAirBlockDiagram_CHR-ROM.png)

**IRQ**<br>
カードエッジコネクタのIRQ信号は、IRQ信号が5V系の信号であるため、低Vthのバッファを介したマイコンの出力を接続します。バッファの出力は、0Vとハイインピーダンスの2状態を使用します。出力にプルアップ抵抗を接続することでオープンドレインの信号として扱います。<br>
![MapperZeroAirBlockDiagram_IRQ.png](img/MapperZeroAirBlockDiagram_IRQ.png)

**SPI**<br>
カードエッジコネクタのPRG-ROMバスとPHI2を使用し、マイコンに対してファミコンがSPIバスのマスターとして動作できるようにします。A[13]、A[14]、OEをデコードし、ファミコンがCPUバス空間の$6000～$7FFFアクセスにしたときに有効となる信号を生成、さらにPHY2とR/Wをイネーブラとすることで、データバスの下位3bitをラッチするラッチ信号とします。カードエッジコネクタ側は5Vでマイコン側は3.3V系であるため、デコーダやラッチは5Vトレラントのものを使用します。また、ラッチ後の最下位bitにはデバッグ用のLEDを接続しておきます。<br>
![MapperZeroAirBlockDiagram_SPI.png](img/MapperZeroAirBlockDiagram_SPI.png)

**Audio**<br>
カードエッジコネクタのAudio周りは特になにもせずそのまま戻します。<br>
![MapperZeroAirBlockDiagram_Audio.png](img/MapperZeroAirBlockDiagram_Audio.png)

**「Hello World!」実行の詳細**<br>
ファミコンにMapperZeroAirを挿して電源をONにした直後は、PRG-RAMにプログラムがないためCPUは暴走します。MapperZeroAir.exeを実行すると、マイコン(ESP32)はPRG-RAMの制御を奪い(Disconnect CPU)、「Hello World!」のプログラム16kByteをPRG-RAMへダウンロードします。ダウンロード完了後、ファミコン本体のリセットボタンを押すことにより、ダウンロードした「Hello World!」のプログラムが実行されます。「Hello World!」のプログラムは、PPUを介してCHR-RAMへパターンを転送した後、Hello World! と表示するプログラムを実行します。下に、動作の概念を図示します。
![title: "Execute 'Hello World!' by MapperZeroAir"
box HUMAN
participant "Finger"
end box
box HOST
participant "MapperZeroAir.exe"
end box
box MapperZeroAir
participant "ESP32"
participant "PRG-RAM"
participant "CHR-RAM"
end box
box "Family Computer"
participant "CPU"
participant "PPU"
end box
box "TV"
participant "Display"
end box
activate "Finger"
"Finger" -> "CPU": Power On
activate "ESP32"
activate "CPU"
activate "PPU"
loop runaway
"CPU" -> "PRG-RAM": Fetch
"CPU" <- "PRG-RAM": Garbage
end
"Finger" -> "MapperZeroAir.exe": Execute
activate "MapperZeroAir.exe"
"MapperZeroAir.exe" -> "ESP32":Disconnect CPU
loop runaway
"CPU" -> "CPU": Fetch Fail
end
loop 32kByte
"MapperZeroAir.exe" -> "ESP32":Download
"ESP32" -> "PRG-RAM": Download
activate "PRG-RAM"
end
deactivate "MapperZeroAir.exe"
"Finger" -> "CPU": Reset
deactivate "Finger"
"PRG-RAM" <- "CPU":Fetch
"PRG-RAM" -> "CPU":Code
"CPU" -> "PPU":Write Pattern
"PPU" -> "CHR-RAM":Write Pattern
activate "CHR-RAM"
"CPU" -> "PPU":Prepare Screen
loop Terminate
"CPU" -> "CPU":Jump
end
deactivate "CPU"
loop Normary
"CHR-RAM" <- "PPU":Fetch
"CHR-RAM" -> "PPU":Pattern
"PPU" -> "Display":Output
activate "Display"
end loop](http://www.plantuml.com/plantuml/png/XLHDRy8m3BttLtYzS687k5NJ16DyQ19GyJ6atKAnMBGqgK8wwBzVchGbAMox5Vlv-VdPON1IHAeyPO6YYc44uVY2IQuGEZDaJC1EI7PuwC2-W3d9CfGVACMGoZ3OYmlCjlFX8iWq1KreHhY2S4Bv4NKQ-G4qnCAMwusFyhWUyO9-WPVsAyVhkDyB_LYycdPNmtahEfgjRDHb3YSafQo0aKWpFQPiryJRDdSPyHWsxot8AprbZ1HN64aK_IRQnCQD-WEwpxP91B4ueuGbTz3LRDU0aNFzQRGm8JAGEITdKWG6OKXh3oAOe4e-gynJryrCYToJ8vOwVKMtwuYWEWId_PsbtOaPGZj9f9r91EUOAD1oVfDk_J2oOK8eC_eCjj_xUYcqXl_QY3DdWkYXRA1bI9DsdAmlfcnrmBzdlDtT2a-elBfcqJMpiTwWgtqqYOPc90xeRh2CxIJLT35H-ZPvO6Ase3hc5i0vbVhQMuInH7si2Ej48d9hwmPbIZbHs5x2MvvcDvQCcgjR29aIMQwkQcRloncoILpxtunIFvTecIlz1fqPl8TKTWm6-glyT_e1)

※PRG-ROMサイズが16kByteであっても、同じ16kByteのデータを2回転送し32kByteの転送を行います。PRG-ROMサイズが16kByteなカセットにおけるアドレス線を無視することによるミラー効果を再現させています。

**ダウンロード実行のシーケンス図**<br>
USE_IRQ_LOADERの実装されたプログラムを実行している場合、MapperZeroAir.exeによるダウンロード実行時「--irq」オプションを付与することで、リセットボタンを押下せずにダウンロードしたプログラムの実行が始まります。これは、マイコン(ESP32)がPRG-RAMの制御を奪う前に、CPUのプログラムフェッチ先をWRAM上のコードに移すことで実現しています。USE_IRQ_LOADERのIRQ割り込みルーチンでは、IRQ_SWITCHが0の場合IRQ_SWITCHに1をセットしてWRAM上に自己ループのコードをコピーし、そのコードの先頭へジャンプします。IRQ_SWITCHが1の場合は、RSTベクタへジャンプします。IRQ_SWITCHはRSTベクタで実行されるコードの中で0にします。IRQ-SWITCHは、WRAM上の1Byteを使用します。
![title: "Execute 'Good Morning' after "Hello World!" by MapperZeroAir"
box HUMAN
participant "Finger"
end box
box HOST
participant "MapperZeroAir.exe"
end box
box MapperZeroAir
participant "ESP32"
participant "PRG-RAM"
participant "CHR-RAM"
end box
box "Family Computer"
participant "CPU"
participant "WRAM"
end box
activate "Finger"
activate "ESP32"
activate "CPU"
activate "PRG-RAM"
activate "CHR-RAM"
activate "WRAM"
"CPU" -> "WRAM": Write 0 to IRQ_SWITCH
loop
"CPU" -> "PRG-RAM": Fetch
"CPU" <- "PRG-RAM": Code
end
"Finger" -> "MapperZeroAir.exe": Execute w/ --irq
deactivate "Finger"
activate "MapperZeroAir.exe"
"MapperZeroAir.exe" -> "ESP32":IRQ
"ESP32" -> "CPU": IRQ
"CPU" -> "CPU": IRQ routine
activate "CPU"
alt IRQ_SWITCH = 0
"CPU" -> "WRAM": Write 1 to IRQ_SWITCH
"CPU" -> "WRAM":Copy code
activate "WRAM"
loop
"CPU" -> "WRAM": Fetch
"CPU" <- "WRAM": Code
deactivate "WRAM"
deactivate "CPU"
end
end
"MapperZeroAir.exe" -> "ESP32":Disconnect CPU
"ESP32" -> "PRG-RAM":Disconnect
deactivate "PRG-RAM"
loop Finish Download
"MapperZeroAir.exe" -> "ESP32":Download
"ESP32" -> "PRG-RAM": Download
activate "PRG-RAM"
end
"MapperZeroAir.exe" -> "CPU": IRQ
deactivate "MapperZeroAir.exe"
"CPU" -> "CPU":IRQ routine
activate "CPU"
alt IRQ_SWITCH = 1
"CPU" -> "PRG-RAM":Fetch RST vector
"CPU" <- "PRG-RAM":RST vector
"CPU" -> "CPU":Jump to RST vector
deactivate "CPU"
"CPU" -> "WRAM":Write 0 to IRQ_SWITCH
loop
"CPU" -> "PRG-RAM": Fetch
"CPU" <- "PRG-RAM": Code
end
end](http://www.plantuml.com/plantuml/png/hLJBJeD05Dtp5LSsNQ6jxeYQDlHfKgsq3OaRGs6qaqovE9s-_jvXQ666Oes92mXpxlkSExJN8kHYisAMe88H5-pUdaGRGQ0nG8nXZ3oXoMS3mWz1EDX3mXX2W9p5LpOi3Z0EqvJmDyAnGxbjBN0Fm_cuysobCY-DQ1ec0ko-p46acIGnI9VSxMKwCxsCNDTaJym0msn6zgQJkrlRn2R-mF4xumhg3VqSrJFR_N15sG4yNALoTbwDcSmhI62a22D1jw7ah9YpH8wTbO1ALXwBBZMFKuibbDTJiU0y7iyk19nAQnC4miX_VPy6evatj1XYglcUAhZG9o9Q7YttZcxnC2RPEDPf0XLvheSBf_NOtO3ZKFvbnUJI-3MIrc2gMiwKAmUnZjyAphfrGQ75I0K673U29kICNoOqHk01cZ-HrwgGLtNpC3r0bD5JLQD2Sr3FSQ0Hh5ELvz0HrNYcWTBXCabTkeumIKWaG8OPV1MYbZv6cMBXilv1AaRNI-ZYBc4O_bwtyAkhMAQfANTfgb9ZlTEwtJ5Nu2yRqAgx4aejyASps4gUaDTTZZDhKVvfiqgpzT4ypWIjBiZ_NzdiQSjNzXF_1W00)

**マッパー#0のダウンロード**<br>
マッパー#0のダウンロードは、「CHR-ROMローダのダウンロード実行」「PRG-ROMのダウンロード」の2段階で行われます。「CHR-ROMローダのダウンロード」後、CHR-ROMローダを実行するためファミコン本体のリセットボタンを押し、MapperZeroAir.exeの出力「Release reset button after 0 sec.」のタイミングに合わせてファミコン本体のリセットボタンを話してください。続いてCHR-ROMローダの実行完了を待って「PRG-ROMのダウンロード」が実行されVミラー/Hミラーの設定が行われます。MapperZeroAir.exeの出力に「H_MIRROR request was accepted.」または「V_MIRROR request was accepted.」が表示されたら、ファミコン本体のリセットボタンを押してください。
![title: "Execute Mapper #0 by MapperZeroAir"
box HUMAN
participant "Finger"
end box
box HOST
participant "MapperZeroAir.exe"
end box
box MapperZeroAir
participant "ESP32"
participant "PRG-RAM"
participant "CHR-RAM"
end box
box "Family Computer"
participant "CPU"
participant "PPU"
end box
activate "Finger"
"Finger" -> "CPU": Power On
activate "ESP32"
activate "CPU"
activate "PPU"
loop runaway
"CPU" -> "PRG-RAM": Fetch
"CPU" <- "PRG-RAM": Garbage
end
"Finger" -> "MapperZeroAir.exe": Execute
activate "MapperZeroAir.exe"
"MapperZeroAir.exe" -> "ESP32":Disconnect CPU
loop runaway
"CPU" -> "CPU": Fetch Fail
end
"MapperZeroAir.exe" -> "ESP32":Download\nCHR-ROM loader
"ESP32" -> "PRG-RAM": Download\nCHR-ROM loader
activate "PRG-RAM"
"Finger" -> "CPU": Reset
"MapperZeroAir.exe" -> "MapperZeroAir.exe":Wait 3 sec
activate "MapperZeroAir.exe"
"PRG-RAM" <- "CPU":Fetch
"PRG-RAM" -> "CPU":Code
"CPU" -> "PPU":Write Pattern
"PPU" -> "CHR-RAM":Write Pattern
activate "CHR-RAM"
loop Terminate
"CPU" -> "CPU":Jump
end
deactivate "MapperZeroAir.exe"
"MapperZeroAir.exe" -> "ESP32":Download\nPRG-ROM
"ESP32" -> "PRG-RAM": Download\nPRG-ROM
"Finger" -> "CPU": Reset
deactivate "Finger"
loop
"CPU" -> "PRG-RAM": Fetch
"CPU" <- "PRG-RAM": Garbage
end](http://www.plantuml.com/plantuml/png/fLHDRu904BtpAoRqRDFK6saQZHLD4mf1ZKdZPOM9tGHsoR9K_VTTbWyN2l7WXR0pRsRVl3SmooKHiaWJIrAPe0Fsye9H8H4yacKeuEa5ZjVwy8s2pwcmhIE_m7hdpR-iJ5NJY6Q4IR1ToaweqiXYK90Avc-sNLIdrpDUi5lGINShbvjW-cftOq6uceHphnTThCCgQdQsNPBIv0eBdcPgGj6l2NRztcMawK0YIN-94gOTitc1oNjLxK30pqepdndeclGjeE-v7VKb2USPY8AHCxbQ6g6RDiCvuAACVkhCsyJCh8WuaXEMFBkC_kliG6skSVs06mCntR2QnFcWUSGPmqY2eZD6lT93qmQNqAJYTwSpFxE4a_Z0j7--1-K9XLK3UfgCmWrnc-qOy2h47EKefG7rzeHAc4AEqHtzcbkrK_goshusqR9Oy1XDmylONb3LEI1IxIYpTAmgg9Uw1p0sgzbwxSaMHKgPIlHT-IpIJDiHuqDxqCgln_AzkpQrk34pJ4BDLrREyi0dCLEFylVs1m00)

## 4-4. テスト

MapperZeroAir.exe

exe/Makefile にて、ターゲット「test」でテストが実装されています。

**出荷前テスト**<br>
下に出荷前テストの項目を示します。
- 工事中

## 4-5. サンプルプログラム

asm/prgXXXX_YYYYYYYY にサンプルコードがあります。詳細は、asm/prgXXXX_YYYYYYYY/readme.md を参照してください。

## 4-6. フォント

公開アセンブラコードでは、下記自作フォントを使用しています。

![font.png](img/font.png)

# 5. Q&A

Q. 「デバイスの準備が整いました!」となっても「MapperZeroAir」が「未接続」になる<br>
A. 「接続済み」となった後、すぐに「未接続」となりますが、「完了」を押していただければ問題ありません。

![BluetoothSetupA.png](img/BluetoothSetupA.png)

Q. ダウンロード実行がうまくいきません<br>
A. ダウンロード中にファミコンのプログラムが暴走している可能性があります。ファミコン本体のリセットボタンを押した状態でnes/prg0000_HelloWorld.nesをダウンロードしてみてください。

# 6. 販売ページ

以下から MapperZeroAir を購入できます。<br>
https://isariyokurari.booth.pm/items/6864946<br>
※2025年5月1日現在、SRAMが2種類ともOELとなっています。数に限りがございますので早めにお買い求めください。

# 7. 引用商標

- ファミコンは、日本またはその他地域における任天堂株式会社の登録商標です。
- Windowsは、米国またはその他地域におけるMicrosoft社の登録商標です。
- Arduinoは、日本国内においてArduino SRLの商標登録です。
- ESP32は、Espressif Systems (Shanghai) Co., Ltd.の中国または他の国における商標登録または商標です。

