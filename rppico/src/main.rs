fn main() {
    let s = String::from("hello");
    let a = takes_ownership(s);
    // println!("{}", s);
    println!("{}", a);
}

fn takes_ownership(some_string: String) -> String {
    // some_stringがスコープに入る。
    println!("{}", some_string);

    String::from("hello")
}
