#import "@preview/touying:0.4.2": *
#import "@preview/pinit:0.1.3": *
#import "@preview/sourcerer:0.2.1": code

#set text(font: "Noto Sans JP")

#let set_link(url) = link(url)[#text(olive)[[link]]]

// Themes: default, simple, metropolis, dewdrop, university, aqua
#let s = themes.metropolis.register(aspect-ratio: "16-9")
#let s = (s.methods.info)(
  self: s,
  title: [組み込みRust講習会],
  subtitle: [Rust編],
  author: [JIJINBEI],
  date: datetime.today(),
  institution: [HiCoder],
)
#let (init, slides, touying-outline, alert, speaker-note) = utils.methods(s)
#show: init

#show strong: alert

#let (slide, empty-slide, title-slide, focus-slide) = utils.slides(s)
#show: slides


= Rustとは

== Rustとは

- Mozillaが開発したプログラミング言語
- Rustは最も愛されている言語として7年目を迎え、87%の開発者が使い続けたいと答えている。 #set_link("https://survey.stackoverflow.co/2022/#most-loved-dreaded-and-wanted-language-love-dread")
- 最近のオープンソースはすべてRustで書かれていると言っても過言ではない#footnote[このスライドもRust製のTypstで作成]

#h(2em)

#align(center)[*Rust is God*]

== Rustが好まれている理由

#absolute-place(
  dx: 65%, dy: 40%, 
  image("image\Rust.png", height: 50%)
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

= 変数

== 変数

`let`で変数の定義

#code(
  lang: "rust",
  ```rust
    fn main() {
        let x = 5;
        println!("The value of x is: {}", x);
        x = 6; // ERROR
        println!("The value of x is: {}", x);
    }
    ```,
)

変数を可変するには、`mut`を使う

#code(
  lang: "rust",
  ```rust
    fn main() {
        let mut x = 5;
        println!("The value of x is: {}", x);
        x = 6;
        println!("The value of x is: {}", x);
    }
    ```,
)

= データ型

== データ型(数値)

- Rustは静的型付け言語

#grid(
  columns: (50%, 50%),
  figure(
    table(
      columns: 3,
      [大きさ],[符号付き],[符号なし],
      [8-bit],[i8],[u8],
      [16-bit],[i16],[u16],
      [32-bit],[i32],[u32],
      [64-bit],[i64],[u64],
      [arch],[isize],[usize],
    ),
    caption: [整数型]
  ),
  figure(
    table(
      columns: 2,
      [大きさ],[浮動小数点],
      [32-bit],[f32],
      [64-bit],[f64],
    ),
    caption: [浮動小数点型]
  )
)

= 配列

== 配列

- 配列は同じ型の要素を持つ

#code(
  lang: "rust",
  ```rust
    fn main() {
        let a: [i32; 5] = [1, 2, 3, 4, 5];
    }
  ```,
)

`i32`が5つの要素を持つ配列`a`を定義

== 所有権

所有権の例(変数の所有権の移動)

#code(
  lang: "rust",
  ```rust
    fn main() {
        let s1 = String::from("hello");
        let s2 = s1;

        // println!("{}, world!", s1); // value borrowed here after move

        println!("{}, world!", s2);
    }
    ```,
)

= 参考文献

- Rust公式ドキュメント #set_link("https://doc.rust-jp.rs/book-ja/")