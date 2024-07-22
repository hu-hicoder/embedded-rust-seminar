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

= はじめに

組み込みRust講習会へようこそ

#h(1em)

#box(stroke: black, inset: 0.7em)[この講習会を開いた理由]

- 組み込みRustが難しくて私の学習が進まないので、一緒に学べる仲間を作りたい
- Rustの普及
- ソフト、競プロだけをやるな！！ハードもやれ！！

= 目標

#grid(
  columns: (70%, 30%),
  column-gutter: 2%,
  [
    - Rustの基本的な文法を理解する
    - 難解な所有権、ライフタイムの概念を理解する
    - 「基礎からわかる組み込みRust」や組み込みRustの公式ドキュメントを難なく読めるようになる
  ],
  figure(
    image("image/embedded_rust_book.jpg"),
  ),
)

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
  image("image/Rust.png", height: 50%)
)

- 安全性
  - 型安全性
  - メモリ安全性
    - *所有権*
    - *ライフタイム*
- 処理速度の速さ
- 並行処理
  - 所有権によるデータ競合の防止
- バージョンやパッケージ管理
  - cargo

== Crowdstrike事件

#grid(
  columns: (50%, 50%),
  [
    - C++で書かれたCrowdstrikeのソフトウェアが、Windowsのカーネルに何らかの影響を与えブルスクリーンを引き起こすという問題が発生
    - この問題はぬるぽ#footnote[
      NullPointerException
    ]が原因であると噂されている#footnote[  
    https://x.com/Perpetualmaniac/status/1814376668095754753

    公式発表はされていないので、真偽は不明
    ]
      - 型安全性、メモリ安全性であれば、このような問題は発生しない
  ],
  figure(
    image("image/blue_screen.jpg", height: 50%),
  ),
)

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

ほかには`char`型(`a`, `b`, `c` ...)や`bool`型(`true`, `false`)などがある

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

`i32`が5つの要素を持つ配列`a`を定義で配列の長さは変更できない

#pagebreak()

文字列は文字(`char`)の配列

文字列は、主に`&str`型と`String`型がある

#code(
  lang: "rust",
  ```rust
  fn main() {
      let world: &str = "world!";
      println!("Hello, {}", world);
  }
  ```,
)

#code(
  lang: "rust",
  ```rust
  fn main() {
      let mut world: String = String::from("world");
      world.push_str("!");
      println!("Hello, {}", world);
  }
  ```,
)

`String`型は配列の長さを変更できる(`Vec`)

= 関数、制御フロー

省略

= 構造体とメソット

#code(
  lang: "rust",
  ```rust
  #[derive(Debug)]
  struct Rectangle {
      width: u32,
      height: u32,
  }

  impl Rectangle {
      fn area(&self) -> u32 {
          self.width * self.height
      }
  }

  fn main() {
      let rect1 = Rectangle { width: 30, height: 50 };

      println!(
          "The area of the rectangle is {} square pixels.",
          rect1.area()
      );
  }
  ```
)

関連するデータと機能を1つの単位にまとめることで、コードの体系化と再利用性が向上する

= ジェネリック

プログラムを抽象化すると、コードの再利用性が高まり、可読性が向上する

#code(
  lang: "rust",
  ```rust
  struct Point<T> {
      x: T,
      y: T,
  }

  fn main() {
      let integer = Point { x: 5, y: 10 };
      let float = Point { x: 1.0, y: 4.0 };
  }
  ```
)

ジェネリック`<T>`を用いることで、`i32`型や`f64`型などの複数型を受け取ることができる#footnote[
  ジェネリックが用いられている標準ライブラリの例: `Option<T>`, `Result<T, E>`

  この型はめちゃくちゃ深いので、興味があれば調べてみてください
]

= トレイト

Rustのトレイトは、複数の型で共有される振る舞い（メソッド）を定義するインターフェースのような機能

以下の例では、`Summary`トレイトを定義し、`NewsArticle`と`Tweet`構造体に`Summary`トレイトを実装している

#code(
  lang: "rust",
  ```rust
  pub trait Summary {
      fn summarize(&self) -> String;
  }

  pub struct NewsArticle {
      pub headline: String,
      pub location: String,
      pub author: String,
      pub content: String,
  }

  impl Summary for NewsArticle {
      fn summarize(&self) -> String {
          format!("{}, by {} ({})", self.headline, self.author, self.location)
      }
  }

  pub struct Tweet {
      pub username: String,
      pub content: String,
      pub reply: bool,
      pub retweet: bool,
  }

  impl Summary for Tweet {
      fn summarize(&self) -> String {
          format!("{}: {}", self.username, self.content)
      }
  }

  fn main() {
      let tweet = Tweet {
          username: String::from("horse_ebooks"),
          content: String::from(
              "of course, as you probably already know, people",
          ),
          reply: false,
          retweet: false,
    };

    println!("1 new tweet: {}", tweet.summarize());
  }
  ```
)

= 所有権とライフタイム

== 所有権の不便な例

Rustのキモいところ

#code(
  lang: "rust",
  ```rust
    fn main() {
        let s1 = String::from("hello");
        let s2 = s1;

        // println!("{}, world!", s1); // ERROR
        println!("{}, world!", s2);
    }
    ```,
)

#code(
  lang: "rust",
  ```rust
    fn main() {
        let s = String::from("hello");
        takes_ownership(s);
        // println!("{}", s); // ERROR
    }

    fn takes_ownership(some_string: String) {
        println!("{}", some_string);
    }
    ```,
)

== ヒープとスタック

所有権を理解するためには、ヒープとスタックの違いを理解する必要がある

#grid(
  columns: (80%, 20%),
  [
    - TEXT領域
      - 機械語に翻訳されたプログラム
    - DATA領域
      - 初期値のデータ
        - global変数, 静的変数
    - *HEAP領域*
      - 寿命があるデータ（可変長）
        - `malloc()`でスタック領域を確保し、`free()`でメモリの開放
    - *STACK領域*
      - stack(下から積み上げ)をしていく寿命があるデータ（固定長）
        - ヒープ領域を参照するポインタを持つことが多い
  ],
  figure(
    image("image/Memory.svg"),
  ),
)

== バイナリを見る

Rustのバイナリを見てよう

#code(
  lang: "terminal",
  ```bash
  $ objdump -S binary_file
  $ objdump -h binary_file
  ```
)

`.text`や`.rodata`や`.bss`(heapに対応)がある

== 所有権のルール

- 変数一つに対して、所有権は一つ
- 所有権が動くと、変数は無効になる
- &:参照
  - 所有権を移さずに借用できる


== 問題1

なにがわるい？

#code(
  lang: "rust",
  ```rust
  fn main() {
    let mut v = vec![1, 2, 3, 4, 5];
    let first = &v[0];
    v.clear();
    println!("The first element is: {}", first);
  }
  ```
)

#pause

vectorの要素への参照を保持したまま、vectorの内容をクリアしようとしています。これは、無効な参照を引き起こす可能性があるため、コンパイラによってエラーとして検出されます。

== 問題2

#code(
  lang: "rust",
  ```rust
  struct Person {
      name: String,
      age: u32,
  }

  fn main() {
      let p = Person {
          name: String::from("Alice"),
          age: 30,
      };
      let name = p.name;

      println!("The person's age is: {}", p.age);
      println!("The person's name is: {}", p.name);
  }
  ```
)

#pause

構造体の一部のフィールド（name）を移動させると、元の構造体全体が部分的に移動した状態になり、移動されたフィールドにアクセスできなくなる

= 参考文献

- The Rust Programming Language 日本語版 #set_link("https://doc.rust-jp.rs/book-ja/")
  - コードをたくさん引用しました。ありがとうございます。
- 【Rust入門】宮乃やみさんにRustの所有権とライフタイムを絶対理解させる #set_link("https://www.youtube.com/watch?v=lG7YbM2AfU8")
  - 所有権の世界一わかりやすい説明