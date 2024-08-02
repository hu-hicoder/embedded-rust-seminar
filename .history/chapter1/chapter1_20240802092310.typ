#import "@preview/touying:0.4.2": *
#import "@preview/pinit:0.1.3": *
#import "@preview/sourcerer:0.2.1": code

#set text(font: "Noto Sans JP", lang: "ja")

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
- テストがしやすい

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

`String`型は配列の長さを変更できる

`String`はデータの書き込み、`&str`はデータの読み込みを行うときに使うとよい

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

  この型はエラーを扱うときに用いられる型
]

= トレイト

トレイトは、複数の型で共有される振る舞い（メソッド）を定義するインターフェースのような機能

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

*所有権*とは、メモリの解放を自動的に行うための仕組み

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


== 所有権のルール

公式ドキュメントにかかれている所有権のルール

- *値(データ)は所有者と呼ばれる変数と対応（1対1対応）*
- *変数をアサインする(`let x = y`)際や、関数に引数を値渡しする(`foo(x)`)際は、所有権が移動（move）*
- *所有者がスコープから外れたら、値は破棄*
- *参照渡し(`&`)を使うことで、所有権を移さずに値を借用*
  - *生存期間の長いものが、短いものを参照してはいけない*

#pause

#h(2em)

#align(center)[#text(size: 1.5em)[？？？？？？？？]]


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
      - 寿命があるデータ
        - `malloc()`でヒープ領域を確保し、`free()`でメモリの開放
    - *STACK領域*
      - stack(下から積み上げ)をしていく寿命があるデータ（固定長）
        - ヒープ領域を参照するポインタを持つ
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

`.text`や`.rodata`や`.bss`(heapに対応？)がある

== 所有権のイメージ

所有権は、*変数にメモリの解放をする責任を持たせる*

#box(stroke: black, inset: 0.5em)[知っておくこと]

- スタックにはデータのポインタが、ヒープにはデータがある
- 変数の定義で、スタックは下から積み上げられ、ヒープでデータを確保される
- 所有権を持っている変数は、スコープ#footnote[`{}`の領域内]の外で、ヒープのメモリは解放され、スタックはポップされる


== 所有権のイメージ

#grid(
  columns: (50%, 50%),
  gutter: 2%,
  code(
    lang: "rust",
    ```rust
    fn main() {
        let x = String::from("hello world");
        func(x);
    }

    fn func(s: String) {
        println!("{}", s);
    }
    ```
  ),
  figure(
    image("image/xs.svg"),
  ),
)

`String`の実態はポインタ、長さ、容量の3つの要素とヒープ上の文字列

#box(stroke: black, inset: 0.7em)[データの流れ]

+ `x`がstack + ヒープにメモリ確保(`malloc`) + `x`がデータの所有権を持つ
+ `s`がstack + 所有権の移動(move)
+ `func`のスコープの外で`s`が破棄(push)、ヒープのメモリを解放(`free`)

#pagebreak()

- データのコピーはコストがかかるが、今回の例ではコストが小さい
- `func(x)`のあとで`x`は、メモリを解放されているので使うことはできない

#pagebreak()

#grid(
  columns: (50%, 50%),
  gutter: 2%,
  code(
    lang: "rust",
    ```rust
    fn main() {
        let x = String::from("hello world");
        func(&x);
    }

    fn func(f: &str) {
        println!("{}", f);
    }
    ```
  ),
  figure(
    image("image/xf.svg"),
  ),
)

`str`の実態はポインタと長さの2つの要素とヒープ上の文字列

#box(stroke: black, inset: 0.4em)[データの流れ]

+ `x`がstack + ヒープにメモリ確保(`malloc`) + `x`がデータの所有権を持つ
+ `f`がstack + xを参照 + 所有権の移動が起こらない
+ `func`のスコープの外で`f`が破棄(pop)、所有権を持っていないのでヒープのメモリは解放されない

#pagebreak()

- まず参照は危険という認識が必要
  - 参照先を書き換えると、そのデータを利用している他の参照にも影響がある

#h(2em)


- `func(&x)`のあとで`x`は、メモリを解放されていないので使うことができる

== ライフタイム

- `x`のほうが`f`よりも長く生存している
- `func`あとに`x`を使えるか使えないかは
  - heapのメモリが解放されているかどうか
  - 所有権を持っているかどうか

*ライフタイム*(その参照が有効になるスコープ)が自然にわかる

#code(
  lang: "rust", 
  ```rust
  {
      let r;

      {
          let x = 5;
          r = &x;
      }

      println!("r: {}", r); // ERROR
  }
  ```
)

== メモリ安全性

ヒープ領域が`free`されると、スタック領域にあるポインタが無効になる

所有権では絶対に以下の問題が起こらない

- ダンダリングポインタ：メモリ領域の無効な場所を指し示しているポインタ
  - 2重freeが起こると、メモリの破壊が起こる

== 問題1

通る？

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

vectorの要素への参照を保持したまま、vectorの内容をクリアしている。

これは、無効な参照を引き起こす可能性があるため、コンパイラによってエラーとして検出されます。

== 問題2

#code(
  lang: "rust",
  ```rust
  fn add_to_slice(slice: &[str], new_item: &str) {
      slice.push(new_item);
  }

  fn main() {
      let mut words = vec!["hello", "world"];
      let slice = &mut words[..];
      add_to_slice(slice, "!");
  }
  ```
)

#pause

`&[str]`は`push`というメソッドを持っていない

もっていたとしても、所有権を借りている身で`words`の配列の長さを変更することはできない

== 問題3

#code(
  lang: "rust",
  ```rust
  fn get_slice_length(slice: &[str]) -> usize {
      slice.len()
  }

  fn main() {
      let words = vec!["hello", "world"];
      let slice = &words[..];
      println!("Slice length: {}", get_slice_length(slice));
  }
  ```
)

#pause

`&[str]`で参照渡しをしており、データの所有権を移動していない

データの長さを取得している(非加工)ので、問題ない

== 問題4

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

= $+alpha$

追加でしゃべりたいこと

- `Result`と`Option`の使い方
- `ptr`と`len`の万能さ
  - 配列のスライス
  - 文字列の抽出
  - `Copy`しないことのメモリ効率
- `'static`, `const`のデータは`.rodata`にある
- `let x = 5; let y = x;`は`Copy`なので注意
- Rustはバッファオーバーフロー攻撃がないメモリ安全
- 型安全性
// - 並列処理と所有権

= 参考文献

- The Rust Programming Language 日本語版 #set_link("https://doc.rust-jp.rs/book-ja/")
  - コードをたくさん引用しました。ありがとうございます。
- 【Rust入門】宮乃やみさんにRustの所有権とライフタイムを絶対理解させる #set_link("https://www.youtube.com/watch?v=lG7YbM2AfU8")
  - 所有権の世界一わかりやすい説明