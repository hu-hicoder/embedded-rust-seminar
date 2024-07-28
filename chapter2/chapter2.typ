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
#absolute-place(dx: 40%, dy: 110%, [どういうときにunsafeか])

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

= 組み込みRustの解説

== 組み込みRustをやるのに知るべきこと

- 優先度 高
  - データシートを読む
  - `#![no_std]`
  - `#![no_main]` と `#[entry]`
  - `use panic_halt as _;`
  - `rp_pico::hal` と `embedded_hal`
  - `let mut pac = pac::Peripherals::take().unwrap();`
  - `let mut led_pin = pins.led.into_push_pull_output();`

- 優先度 中
  - 組み込み用語
    - Peripherals
    - WATCHDOG
    - clocks
    - cortex
    - SIO
  - `rp_pico`のクレートの中身
  - `defmt`クレート

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
  - `println!`はOSを使っているので使えない 😭
  - 外部ファイルの読み書きもできない 😭

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

#pagebreak()

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
- `rp2040_hal`クレートを用いると、簡単にRP2040のボードを作ることができる


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
  *マイコンのPeripheralを使うための許可証で一個しか使われていないことを保証するもの*
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

== 型で状態変化を表す

*`let mut led_pin = pins.led.into_push_pull_output();`*

`pins`の中から`led`を取り出して、`push_pull_output`に変換しているが、`push_pull_output`とは何だろうか?

#pause

LEDを点灯させるために出力モードを指定している。

- `push_pull_output`は、出力モード
  - LEDを光らす
  - モーターを動かす
  - 電流を流す
- `into_pull_up_input()`や `into_pull_down_input()`は、入力モード
  - スイッチを押したときに反応する

== 所有権をうまく使う

*`let mut led_pin = pins.led.into_push_pull_output();`*

ここで、重要なのは型である。

#figure(image("image/led_types.png"))

詳しく書くと`Pin<Gpio25, FunctionSio<SioOutput>, PullDown>`となっている。

これによって、led_pinは型によって出力モードであると制限される

$arrow$ 出力モード専用のメソッドしか使えない

- `led_pin.set_high()`や`led_pin.set_low()`

= And more...

== 組み込みRustの難しいところ

+ どのクレートにどの機能があるか？

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
- probe-rs #set_link("https://probe.rs/")でデバッグ
- `embedded-graphic` #set_link("https://docs.rs/embedded-graphics/latest/embedded_graphics/")でdisplay表示 (DrawTarget, Drawable)
- `cortex-m` #set_link("https://docs.rs/cortex-m/latest/cortex_m/")で割り込み処理やスリープ
- std環境でのプログラミング 「The Rust on ESP Book」 #set_link("https://docs.esp-rs.org/book/overview/using-the-standard-library.html")
- 組み込みOSのTOCKや組み込みLinuxなど