#import "@preview/touying:0.4.0": *
#import "@preview/pinit:0.1.3": *
#import "@preview/sourcerer:0.2.1": code

#set text(font: "Noto Sans JP", lang: "ja")

#let set_link(url) = link(url)[#text(olive)[[link]]]

// Themes: default, simple, metropolis, dewdrop, university, aqua
#let s = themes.metropolis.register(aspect-ratio: "16-9")
#let s = (s.methods.info)(
  self: s,
  title: [組み込みRust],
  subtitle: [組み込みRust編],
  author: [JIJINBEI],
  date: datetime.today(),
  institution: [HiCoder],
)
#let (init, slides, touying-outline, alert) = utils.methods(s)
#show: init

#show strong: alert

#let (slide, empty-slide, title-slide, focus-slide) = utils.slides(s)
#show: slides

= 組み込みとは

#figure(image("image/rp-pico.png", width: 30%), caption: "Raspberry Pi Pico")

- マイコンを使ったシステム
- LEDを光らせたり、モーターを動かすところから、車載システム、IoTまで

#figure(
  image("image/embedded_example.jpg", height: 90%), caption: [組み込みの例 (組込みシステム産業振興機構)]
)

= なぜ組み込みでRust

== Rustのメリット

- 安全性
  - 型安全性
  - メモリ安全性
    - 所有権
    - ライフタイム
- 処理速度の速さ
  - メモリ管理を自動で行わない
- 並行処理
  - 所有権によるデータ競合の防止
- バージョンやパッケージ管理
  - Cargo

#align(center)[
  *Rustの言語の特徴が使え、CやC++よりも安全にプログラミングができる*
]

== Rustのデメリット

#align(center + horizon)[
  #text(size: 2em)[難しすぎる#pin(1)]
]

#pause

#absolute-place(dx: 75%, dy: 40%, [情報が少ない])
#absolute-place(dx: 75%, dy: 90%, [コミュニティが小さい])
#absolute-place(dx: 5%, dy: 90%, [Rustの所有権システムやライフタイムが理解しづらい])
#absolute-place(dx: 15%, dy: 40%, [組み込みRust特有の機能の理解])
#absolute-place(dx: 5%, dy: 65%, [型でコンパイルが通らない])
#absolute-place(dx: 80%, dy: 65%, [基本的に英語の文献])


= 組み込みRustを試してみよう

== Lチカを試してみよう!!

`https://github.com/rp-rs/rp2040-project-template`のテンプレートを試し、ラズピコを0.5秒毎にLEDを点滅させるコードを書いてみよう

#box(stroke: black, inset: 7pt)[方法]

+ リンクを参考にライブラリをインストール
+ `cargo install cargo-generate`でcargo-generateをインストール
+ rp-picoのテンプレートをダウンロード
#code(
  lang: "terminal",
  ```bash
  cargo generate https://github.com/rp-rs/rp2040-project-template
  ```,
)
4. `config.toml`が`runner = "elf2uf2-rs -d"`となっていることを確認#footnote[
  elf2uf2-rsは、uf2ファイルを作成するツールで、probe-rsはデバックまで行えるツール(後述予定)
]
+ `cargo run`でビルド

== Lチカコードの解説

先程のコードで本質的な部分はどこか？

#pause

#code(lang: "rust", 
  ```rust
  loop {
      led_pin.set_high().unwrap();
      delay.delay_ms(500);
      led_pin.set_low().unwrap();
      delay.delay_ms(500);
  }
  ```
)

#pause

#h(1em)

それでは、それ以外のところは重要でないのか？

#pause

#align(center)[
  *とても重要*
]

= 組み込みRustの重要な概念

== 組み込みRustをやるのに知るべきこと

組み込みRustをやる上で重要な概念

- データシートを読む
- `#![no_std]`
- `#![no_main]` と `#[entry]`
- `use panic_halt as _;`
- `rp_pico::hal` と `embedded_hal`
- `let mut pac = pac::Peripherals::take().unwrap();`
- `let mut led_pin = pins.led.into_push_pull_output();` のような型について

== データシートを読む

ラズピコは、RP2040というマイコンを使っている

- RP2400のデータシート: #set_link("https://www.raspberrypi.com/products/rp2040/")
- ボードのデータシート: #set_link("https://datasheets.raspberrypi.com/pico/pico-datasheet.pdf")

どの部品がどのマイコンのピンに接続されているかを理解する

#box(stroke: black, inset: 0.5em)[問題]

- 内蔵LEDのGPIO番号を調べて、どのようにしたら点灯できるかを考えよう!!
- RP2040に接続されている部品はどのようなものがあるかを調べよう!!

== `#![no_std]`とは

*`#![no_std]`*

- Rustの標準ライブラリは`core`#footnote[`core`クレートはプリミティブ型やアトミック操作], `alloc`#footnote[`alloc`クレートはヒープメモリを利用するが、組み込みはメモリが小さいので`Vec`が簡単に使えない。使い方は`embedded-alloc`クレート #set_link("https://github.com/rust-embedded/embedded-alloc")], `std`の三階層構造
- `no_std`は、Rustの標準ライブラリ#set_link("https://doc.rust-lang.org/std") を使わず、OSを使わないことを示す。
  - `println!`はOSを使っているので使えない
  - 外部ファイルの読み書きもできない

== `#![no_main]`と`#[entry]`

*`#![no_main]` と `#[entry]`*

`no_std`環境では、main関数は使えず、自分でエントリーポイント(プログラムが始まるところ)を指定

今回の例では、`#[entry]`でmain関数を指定している

== `panic_halt`

*`use panic_halt as _;`*

エラーとはどういうものを思い浮かべるか？

#pause

#figure(image("image/errors.png"))

エラー文が出てきて、プログラムが止まること

プログラム的には異常な動作だが、エラー文を出してプログラムを止めているので正常な動作

== `panic_halt`

*`use panic_halt as _;`*

組み込みでは、

- 画面に表示できないハードウェアが多い
- エラーの表示にもメモリを使う(組み込みではメモリは少ない)

そのため、

- エラーが出たら、プログラムを止める(無限ループ)

== 組み込み機器の抽象化

*`rp_pico::hal = rp2040_hal`*

- `rp_pico` #set_link("https://docs.rs/rp-pico/latest/rp_pico/") はラズピコの*BSP(Board Support Package)*クレート
  - コードを見てみると、すごく簡単に書かれている(ほかのボードも) #set_link("https://github.com/rp-rs/rp-hal-boards/tree/main/boards/rp-pico")

#box(stroke: black, inset: 0.5em)[なぜ簡単に書かれているのか？]

- *HAL(Hardware Abstraction Layer)*: ハードウェアの抽象化レイヤー
- 抽象化レイヤーを使うことで、ハードウェアの差異をうまく吸収してくれる
- `rp2040_hal`クレートを用いると、簡単にRP2040のボードを作ることができるはず

#pagebreak()

*`rp_pico::hal = rp2040_hal`*

#figure(image("image/HAL.png", height: 85%))

#pagebreak()

*`embedded_hal`*

#box(stroke: black, inset: 0.5em)[問題意識]

ボードやマイコンが違ってもどれも似たような機能を持っているはずなのに、コードの書き方が変わってしまう

$=>$ Embedded devices Working Group (WG)が書き方を統一するために`embedded_hal`クレートを作成#footnote[トレイトを思い出そう！！]

- OutputPinの例 #set_link("https://github.com/rust-embedded/embedded-hal/blob/master/embedded-hal/src/digital.rs")
- `embedded_hal`に準拠したクレート一覧 #set_link("https://crates.io/crates/embedded-hal/reverse_dependencies")

*`embedded_hal`のおかげで複雑なクレートの関係をシンプルに*

#figure(image("image/crate.png"))

== 組み込みで所有権を賢く使う

*`let mut pac = pac::Peripherals::take().unwrap();`*

#code(lang: "rust", 
  ```rust
  let pins = rp_pico::Pins::new(
      pac.IO_BANK0,
      pac.PADS_BANK0,
      sio.gpio_bank0,
      &mut pac.RESETS,
  );
  ```
)

で何度も出てくる `pac`とは何か？

#pause

`Peripheral Access Crate`の略で

#align(center)[
  *マイコンのPeripheralを使うための許可証で、一個しか使われていないことを保証するもの*
]

#pause

所有権のおかげで一度しか使われていないことを保証している！！

== 所有権をうまく使う

*`let mut pac = pac::Peripherals::take().unwrap();`*

*所有権システム*でPeripheralが使われているのが一つだけであることを保証する

#grid(
  columns: (50%, 50%),
  [
    #box(stroke: black, inset: 7pt)[メリット]
    - 同時アクセスによるデータ競合を防ぐ
  ],
  figure(
    image("image/ownership.png")
  )
)

= 組み込みRustで開発する際に

== Rustで組み込みの情報を得るには

+ どこで情報を得るか？
  - クレートはどのように使うか？
    - 使いたいクレートのexample
      - 例: rp2040-hal#set_link("https://github.com/rp-rs/rp-hal/tree/main/rp2040-hal/examples")やrp-pico#set_link("https://github.com/rp-rs/rp-hal-boards/tree/main/boards/rp-pico/examples")のgithubのexampleを見る
  - 使いたいメソッドでエラーがでたら
    - Docs.rs
      - これの読み方を覚えることが大事（次のスライド）

+ 開発が進まないなら
  - 俺に聞いてくれ。そして一緒に考えよう。
  - Rustの過度な神格化をやめ、CやPythonで書く

== Docs.rsの読み方（型）

考え方 (Lチカの場合)

+ Lチカでは、`set_high()`のメソッドを使いたい
+ docs.rsで`rp2040-hal`を検索
+ `set_high()`を検索し、型を確認
#code(
  lang: "rust",
  ```rust
  impl<I, P> OutputPin for Pin<I, FunctionSio<SioOutput>, P>
  where
      I: PinId, // Gpio0, Gpio1, ...
      P: PullType, // PullUp, PullDown, ...
  ```
)
4. Pinの型を満たすものに変換するものがないかを探す#footnote[
  型変換に関するものなので、FromトレイトやIntoトレイトを使っていることが多い $->$ `into`から絞る
]
  
*`let mut led_pin = pins.led.into_push_pull_output();`*

`let mut led_pin = pins.led.reconfigure::<FunctionSio<SioOutput>, PullDown>();`

== おめでとう

組み込みRustの学習がおわりました

= And more...

== debugをするには

elf2uf2-rsでは、printデバッグは簡単に使えない
  - 使うには空いているピンやUSBなどを用いて通信を行う

#h(1em)

*probe-rs* #set_link("https://probe.rs/")を使うと便利#footnote[githubのスターが少ないのはなぜ]

+ ラズピコが２コ用意し、片方に

== さらば`no_std`、こんにちは`std`

組み込みRustでは高度なことをやりたいなら、マイコンはRP2400より*ESP32*

- `std`環境でのプログラミングができるため
  - 例) 簡易的な温度計サーバーを建てる
  - 例) bluetooth通信をする

- `std`環境でのプログラミング 「The Rust on ESP Book」 #set_link("https://docs.esp-rs.org/book/overview/using-the-standard-library.html")

== スタックとヒープの話をしたので、flip-linkを語りたい

#grid(
  columns: (50%, 50%),
  gutter: 2%,
  figure(image("image/flipped.svg")),
  [
    #box(stroke: black, inset: 7pt)[flip-linkを使わないと]
    + 普通はstackは下から積み上がる
    + heap領域を破壊
    + どのように動作するのか謎になる
    
    #box(stroke: black, inset: 7pt)[flip-linkを使うと]
    + stackは上から積み上がる
    + メモリの端までいくと*エラーが出る*
  ]
)


== おすすめの書籍やサイト

- 基礎から学ぶ 組込みRust (著者：中林 智之／井田 健太)
  - 聖書です。読んでください。
- The Embedded Rust Book(日本語版) #set_link("https://tomoyuki-nakabayashi.github.io/book/")
  - 組み込みRustならではの機能がまとまっている
- Interface 2023年5月号特集 質実剛健Rust言語
  - 最新の情報が載っているし、`std`のことが書かれている貴重な文献
- awesome-embedded-rust #set_link("https://github.com/rust-embedded/awesome-embedded-rust")


== 次にやること

- UART通信 `rp2040-hal` #set_link("https://docs.rs/rp2040-hal/latest/rp2040_hal/uart/index.html")
- `core::fmt::Write` #set_link("https://doc.rust-lang.org/core/fmt/trait.Write.html")でUART通信で文字列を送信
- I2C通信 `rp2040-hal` #set_link("https://docs.rs/rp2040-hal/latest/rp2040_hal/i2c/index.html")
- SPI通信 `rp2040-hal` #set_link("https://docs.rs/rp2040-hal/latest/rp2040_hal/spi/index.html")
- PWM出力 `rp2040-hal` #set_link("https://docs.rs/rp2040-hal/latest/rp2040_hal/pwm/index.html")
- タイマー `rp2040-hal` #set_link("https://docs.rs/rp2040-hal/latest/rp2040_hal/timer/index.html")
- USB `rp2040-hal` #set_link("https://docs.rs/rp2040-hal/latest/rp2040_hal/usb/index.html") `usb_device` #set_link("https://docs.rs/usb-device/latest/usb_device/index.html")
- ADC `rp2040-hal` #set_link("https://docs.rs/rp2040-hal/latest/rp2040_hal/adc/index.html")
- `heapless` #set_link("https://docs.rs/heapless/latest/heapless/") でVecが使える
- `embedded-graphic` #set_link("https://docs.rs/embedded-graphics/latest/embedded_graphics/")でdisplay表示 (DrawTarget, Drawable)
- `cortex-m` #set_link("https://docs.rs/cortex-m/latest/cortex_m/")で割り込み処理やスリープ
- 組み込みOSのTOCKや組み込みLinuxなど