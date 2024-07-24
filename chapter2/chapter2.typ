#import "@preview/touying:0.4.0": *
#import "@preview/pinit:0.1.3": *
#import "@preview/sourcerer:0.2.1": code

#set text(font: "Noto Sans JP", lang: "ja")

#let set_link(url) = link(url)[#text(olive)[[link]]]

// Themes: default, simple, metropolis, dewdrop, university, aqua
#let s = themes.metropolis.register(aspect-ratio: "16-9")
#let s = (s.methods.info)(
  self: s,
  title: [LT会],
  subtitle: [組み込みRust],
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
- aaaaaa

#figure(
  image("image/embedded_example.jpg", height: 90%), caption: [組み込みの例 (組込みシステム産業振興機構)]
)

= Rustとは

== Rustの特徴

#absolute-place(
  dx: 70%, dy: 40%, 
  image("image/Rust.png", height: 50%)
)

- 安全性
  - 型安全性
  - メモリ安全性
    - *所有権*
    - *ライフタイム*
- 処理速度の速さ
  - VMを使わない
  - メモリ管理を自動で行わない
- 並行処理
  - 所有権によるデータ競合の防止
- バージョンやパッケージ管理
  - cargo

== 所有権

所有権の例(変数の所有権の移動)

#code(
  lang: "rust",
  ```rust
    fn main() {
        let s1 = String::from("hello");
        let s2 = s1; // 変数s1から変数s2に所有権の移動が発生

        // 所有権が移動しているので、変数s1を利用するとコンパイルエラーが起きる
        // println!("{}, world!", s1); // value borrowed here after move

        println!("{}, world!", s2);
    }
    ```,
)

`s1`は、値と所有権を持っているが、`s2`に所有権を移動すると、`s1`は利用できなくなる。

#align(center)[
  *値は一つであることが保証される*
]

== 所有権

所有権の例(関数の所有権の移動)

#code(
  lang: "rust",
  ```rust
fn main() {
    let s = String::from("hello"); 
    takes_ownership(s);
    // println!("{}", s); // コンパイルエラーが起きる
} 

fn takes_ownership(some_string: String) {
    // sの所有権が関数に移動
    println!("{}", some_string);
} 
```,
)

`some_string`が所有権を持っているので、sは利用できなくなる

#align(center)[
  *値は一つであることが保証される*#footnote[これの利点は後ほど...]
]

= なぜ組み込みでRust

== Rustのメリット

- 安全性
  - 型安全性
  - メモリ安全性
    - *所有権*
    - *ライフタイム*
- 処理速度の速さ
  - メモリ管理を自動で行わない
- 並行処理
  - 所有権によるデータ競合の防止
- バージョンやパッケージ管理
  - Cargo

#v(1em)
#align(center)[
  *Rustの言語の特徴が使え、CやC++よりも安全にプログラミングができる*
]


== Rustのデメリット

#align(center + horizon)[
  #text(size: 2em)[難しすぎる#pin(1)]
]

#pause

#absolute-place(dx: 75%, dy: 40%, [情報が少ない])
#absolute-place(dx: 75%, dy: 100%, [コミュニティが小さい])
#absolute-place(dx: 15%, dy: 100%, [Rustの所有権システムやライフタイムが理解しづらい])
#absolute-place(dx: 15%, dy: 40%, [組み込みRust特有の機能の理解])
#absolute-place(dx: 5%, dy: 70%, [型でコンパイルが通らない])
#absolute-place(dx: 80%, dy: 70%, [基本的に英語の文献])

= 組み込みRustのデモ

== Rustのコード

rp-picoクレートの`pico_blinky.rs`から抜粋。

Raspberry pi picoを0.5秒毎にLEDを点滅させる

#code(
  lang: "rust",
  ```rust
    #![no_std]
    #![no_main]

    use rp_pico::entry;

    use embedded_hal::digital::OutputPin;
    use panic_halt as _;

    use rp_pico::hal::prelude::*;

    use rp_pico::hal::pac;
    use rp_pico::hal;

    #[entry]
    fn main() -> ! {
        let mut pac = pac::Peripherals::take().unwrap();
        let core = pac::CorePeripherals::take().unwrap();

        let mut watchdog = hal::Watchdog::new(pac.WATCHDOG);

        let clocks = hal::clocks::init_clocks_and_plls(
            rp_pico::XOSC_CRYSTAL_FREQ,
            pac.XOSC,
            pac.CLOCKS,
            pac.PLL_SYS,
            pac.PLL_USB,
            &mut pac.RESETS,
            &mut watchdog,
        )
        .ok()
        .unwrap();

        let mut delay = cortex_m::delay::Delay::new(core.SYST, clocks.system_clock.freq().to_Hz());

        let sio = hal::Sio::new(pac.SIO);

        let pins = rp_pico::Pins::new(
            pac.IO_BANK0,
            pac.PADS_BANK0,
            sio.gpio_bank0,
            &mut pac.RESETS,
        );

        let mut led_pin = pins.led.into_push_pull_output();

        loop {
            led_pin.set_high().unwrap();
            delay.delay_ms(500);
            led_pin.set_low().unwrap();
            delay.delay_ms(500);
        }
    }
    ```,
)

== Rustのコード

ここで、本質的な部分はどこか？

#pause

#code(lang: "rust", ```rust
      loop {
          led_pin.set_high().unwrap();
          delay.delay_ms(500);
          led_pin.set_low().unwrap();
          delay.delay_ms(500);
      }
  ```)

#pause
#v(1em)

それでは、それ以外のところは重要でないのか？

#pause
#align(center)[
  *とても重要*
]

= 組み込みRustのデモの要点

== 重要な部分

- 優先度 高
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

== 優先度 高
*`#![no_std]`*

Rustの標準ライブラリを使わず、OSを使わないことを示す。

標準ライブラリ一覧の #set_link("https://doc.rust-lang.org/std")

#v(1em)

stdで使えないもので一番困るもの

`Vec<T>` #set_link("https://doc.rust-lang.org/std/vec/struct.Vec.html")

Vecが使えないと、String型も使えないので、文字列を扱うのが難しい#footnote[
  使えないのは、ヒープ領域を用意する必要(malloc)があり、組み込みではメモリが少ないため
]

== 優先度 高

*`#![no_main]` と `#[entry]`*

OSがない環境では、main関数は使えず、エントリーポイント(プログラムが始まるところ)を自分で指定する

今回の例では、`#[entry]`でmain関数を指定している

== 優先度 高

*`use panic_halt as _;`*

エラーとはどういうものを思い浮かべるか？

#pause

#figure(image("image/errors.png"))

エラー文が出てきて、プログラムが止まること

プログラム的には異常な動作だが、エラー文を出してプログラムを止めているので正常な動作

== 優先度 高

*`use panic_halt as _;`*

組み込みでは、

- 画面に表示できないハードウェアが多い
- エラーの表示にもメモリを使う(組み込みではメモリは少ない)

そのため、

- エラーが出たら、プログラムを止める(無限ループ)

== 優先度 高

*`rp_pico::hal` と `embedded_hal`*

*HAL(Hardware Abstraction Layer)* とは、ハードウェアの抽象化レイヤー

抽象化レイヤーを使うことで、ハードウェアの差異を吸収 // #footnote[よくある勘違いで、抽象化するとプログラムが大きくなっていまうのでは？$arrow$コンパイルすることで最適化されて小さくなる]

#v(0.5em)

`rp_pico` #set_link("https://docs.rs/rp-pico/latest/rp_pico/") はRaspberry Pi
Picoのハードウェアのクレート

- `rp_pico`のクレートに「it re-exports the rp2040_hal crate」という記述がある
  - `rp2040_hal` #set_link("https://docs.rs/rp2040-hal/latest/rp2040_hal/") はRaspberry Pi Picoのマイコンのクレート
  - RP2400とは、Raspberry Pi Picoのマイコンのこと
  - Raspberry Pi Picoはボード全体のことで*BSP (Board Support Package)*と呼ばれる

== 優先度 高

*`rp_pico::hal` と `embedded_hal`*

#figure(image("image/HAL.png", height: 85%))

== 優先度 高

*`rp_pico::hal` と `embedded_hal`*

`rp2040_hal`クレート #set_link("https://docs.rs/rp2040-hal/latest/rp2040_hal/") に次のような記述がある

「This is an implementation of the `embedded-hal` traits for the RP2040
microcontroller」

- `embedded_hal`は、マイコンの抽象化レイヤー

例えば、#set_link("https://crates.io/crates/embedded-hal/reverse_dependencies") には、`embedded_hal`に準拠したマイコンのクレートがある

#v(1em)
`embedded_hal`で継承されたBSPを使うことになるので、プログラミングをする際には意識することが多い。

*言い換えると、`embedded_hal`さえ理解すれば、ほかのマイコンでも同様にプログラミングができる*

#figure(image("image/crate.png"))

== 優先度 高

*`let mut pac = pac::Peripherals::take().unwrap();`*

#code(lang: "rust", ```rust
      let pins = rp_pico::Pins::new(
          pac.IO_BANK0,
          pac.PADS_BANK0,
          sio.gpio_bank0,
          &mut pac.RESETS,
      );
  ```)

で何度も出てくる `pac`とは何か？

#pause
#v(1em)

`Peripheral Access Crate`の略で

#align(center)[
  *マイコンのPeripheralを使うための許可証で一個しか使われていないことを保証するもの*
]

#pause
#v(1em)

△ 今回の場合、`pac.IO_BANK0`などが、ほかのところでは使えなくなっている(pins2は実装できない)

== 優先度 高

*`let mut pac = pac::Peripherals::take().unwrap();`*

*所有権システム*を使って、Peripheralが使われているのが一つだけであることを保証

#box(stroke: black, inset: 7pt)[メリット]

- 同時アクセスによるデータ競合を防ぐ

#figure(image("image/ownership.png", height: 50%))

== 優先度 高

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

== 優先度 高

*`let mut led_pin = pins.led.into_push_pull_output();`*

ここで、重要なのは型である。

#figure(image("image/led_types.png"))

詳しく書くと`Pin<Gpio25, FunctionSio<SioOutput>, PullDown>`となっている。

これによって、led_pinは型によって出力モードであると制限される

$arrow$ 出力モード専用のメソッドしか使えない

- `led_pin.set_high()`や`led_pin.set_low()`

= And more...

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
- データシートを読む
- std環境でのプログラミング 「The Rust on ESP Book」 #set_link("https://docs.esp-rs.org/book/overview/using-the-standard-library.html")
- 組み込みOSのTOCKや組み込みLinuxなど