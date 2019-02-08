---
title: À descoberta do *Rust*
author: Pedro Vasconcelos
date: Janeiro 2019
...


# Motivação

## O que é o *Rust*?

<img src="images/rust-logo-blk.svg" 
	width="300px" style="float:right"/>

Uma linguagem para **programação de sistemas** que combina:

* segurança
* fiabilidade
* *performance*
* previsibilidade 

\

<center>
[https://www.rust-lang.org/](https://www.rust-lang.org/)
</center>

## Esta apresentação

* Visão geral da linguagem
* Conceitos de *ownership* e *borrowing*

Pre-requisitos:

* conhecimentos básico de C
* opcionais: um pouco de Haskell, C++, Python




## Programação de sistemas?

* *kernels* 
* *device drivers* 
* *web browsers*
* sistemas embutidos/críticos/tempo real
* sistemas móveis (*smarphones*)

## *Performance* e previsibilidade?

* Compilação para código máquina nativo
     - usa a infraestrutura *LLVM*
* Sem necessitar de *runtime system* ou *garbage collector*
* Controlo sobre a *libertação de recursos*
     - memória, *file handles*, *locks*
	 - previsibilidade sobre *quando* são libertados


## Segurança e fiabilidade?

Garantir durante a compilação:

* A memoria alocada é libertada *exatamente* uma vez
* Não ocorrem erros de execução
	- *segmentation faults*, *null-pointer exceptions*,
	*iterator invalidation*
* Não usa recursos já libertados (*use-after-free*)
* Ausência de *race conditions* (concorrência)

NB: sem custos extra de execução!


## Utilizadores de *Rust* 

* Mozilla 
    - *engine* CSS do Firefox
	- *Servo* (*engine* de próxima gereação)
* Dropbox
* Cloudflare
* Atlassian
* ...

[https://www.rust-lang.org/production/users](https://www.rust-lang.org/production/users)


## Influências

\

<img align="center" width="90%" src="images/rust-influences.svg"/>


# Visão geral

## Hello, world!

```rust
fn main() {
	println!("Hello, world!");
}
```


* `fn`{.rust} declara a função `main` (sem argumentos)
* Chavetas `{...}` agrupam instruções (como em C/C++)
* `println!`{.rust} é uma *macro* (símbolo `!`)

Experimentar:
  [https://play.rust-lang.org](https://play.rust-lang.org/?version=stable&mode=debug&edition=2018&gist=030d80f87f53a328f9dc7875cad93e04)

## Variáveis 

*Let* declara variáveis:

~~~rust
let x = 5;
~~~

Por omissão, são **imutáveis**:

~~~rust
let x = 5;
x += 1;
// error[E0384]: cannot assign twice to immutable variable `x`
~~~

Declaramos **variáveis mutáveis** explictamente:

~~~rust
let mut x = 5;
x += 1;         // OK
~~~

## Tipos básicos

~~~rust 
i8, i16, i32, i64, ...   // com sinal
u8, u16, u32, u64, ...   // sem sinal
f32, f64                 // virgula flutuante
bool                     // booleanos
char, String             // carateres, strings
~~~

* A *inferência* permite frequentemente omitir tipos
* Podemos usar anotações para desambiguar

~~~rust 
let x: i32 = 5;
~~~

## Funções

~~~rust
fn add_one(x: i32) -> i32 {
	x + 1
}
~~~

* Tipos dos argumentos e resultado (**não** são inferidos)
* O corpo da função é uma **expressão** 
* Podemos usar  `return` explícito:
  
~~~rust
fun add_one(x: i32) -> i32 {
	return x + 1;
}
~~~

(Serve também para terminar cedo.)

## Funções (cont.)

* A função retorna um único resultado
* Mas pode ser um *tuplo*

~~~rust
fn digit(n: u32) -> (u32, u32) {
    (n%10, n/10)   // digito, restantes
}
~~~

<!--
Experimentar: 
[https://play.rust-lang.org/](https://play.rust-lang.org/?version=stable&mode=debug&edition=2018&gist=cf9fc1a1f23c6afe3974e4d85dfaafb2)
-->

## Efeitos colaterais

Uma função usada pelos efeitos colaterais
retorna o **tuplo vazio**: 

~~~rust
fn greet(name: String) -> () {
   println!("Hello, {}", name);
}
~~~

Podemos omitir o tipo do resultado:

~~~rust
fn greet(name: String) {
   println!("Hello, {}", name);
}
~~~

## Ciclos (1)

Somar os quadrados dos inteiros de 1 a $n$.

~~~rust
fn sum_squares(n: u32) -> u32 {
   let mut s = 0;
   let mut i = 0;
   while i<=n {
	   s += i*i;
	   i += 1;
   }
   s
}
~~~

O resultado é o valor final de `s`.

## Ciclos (2)

Versão com  `for`:

~~~rust
fn sum_squares(n: u32) -> u32 {
   let mut s = 0;
   for i in 1..n+1 {
	   s += i*i;
   }
   s
}
~~~

* `1..n+1` itera de 1 até $n$ (**não** inclui o limite)
* O âmbito de `i` é (apenas) o corpo do ciclo

## Ciclos (3)

Versão funcional (usando iteradores):

~~~rust
fn sum_squares(n: u32) -> u32 {
	(1..n+1).map(|i| i*i).sum()
}
~~~

* `|i| i*i`{.rust} é uma *função anónima* (expressão-$\lambda$)
* `map()` aplica uma função a um iterador
* `sum()` soma todos os valores 

Em Haskell:

~~~haskell
sum_squares n = sum (map (\i -> i*i) [1..n])
~~~

## Estruturas

Permitem *agrupar* mútiplos tipos num só:

~~~rust
struct Person {
   name: String,
   age: u32,
}

let alice = Person {
   name: String::from("alice"),
   age: 32
};
~~~

## Enumerações

Permitem *optar* entre *alternativas*
mutuamente exclusivas:

~~~rust
enum TrafficLight {
	Green,
	Yellow,
	Red,
}

let light = TrafficLight::Red;
~~~

## Enumerações (2)

Ao contrário do C/C++, as enumerações podem
ter campos.

~~~rust
enum Shape {
  Square(f32),   // lado
  Rectangle(f32, f32), // altura, largura
  Circle(f32),  // raio
}
~~~

Equivalentes a *tipos algébricos* em ML ou Haskell:

~~~haskell
data Shape = Square Float 
	       | Rectangle Float Float
		   | Circle Float
~~~


## Encaixe de padrões


~~~rust
fn area(sh: Shape) -> f32 {
   match sh {
     Shape::Square(side) => side*side,
	 Shape::Rectangle(w,h) => w*h,
	 Shape::Circle(r) => PI*r*r,
   }
}
~~~

* Escrutinar usando **encaixe de padrões**.
* O compilador **obriga** a considerar todos os casos!

Experimentar:
[https://play.rust-lang.org](https://play.rust-lang.org/?version=stable&mode=debug&edition=2018&gist=aabd79bc4aeb327104159e32cdb573fe)

## *Null pointer exceptions* (NPEs)

*  `NULL` é usando para 
   representar a *ausência* de um valor em C/C++/Java
* Em Rust: usamos `Option`

~~~rust
enum Option<T> {
	None,     // ausência de valor
	Some(T)   // um valor de tipo T
}
~~~

* Tipo paramétrico sobre `T` ("genérico")
* Em Haskell: corresponde ao tipo `Maybe`
* Escrutinar o resultado com `match` evita NPEs 

<!--
~~~haskell
data Maybe a = Nothing | Just a
~~~
-->	

	
## Option

~~~rust	
fn lookup(name: String) -> Option<Person> {
  ...
}

fn main() {
   let n = String::from("alice")
   match lookup(n) {
      None => println!("not found"),
	  Some(p) => println!("{}", p.age)
   }
}
~~~ 


# *Ownership* e *borrowing*

## Motivação

* O sistema de tipos regista informação sobre a *partilha* de valores
* Permite efetuar a libertação de recursos automática
  sem *garbage collection*
* Permite detetar usos incorretos durante a compilação


## Regras básicas

* Em cada âmbito, há uma variável *owner* de um valor
* Quando o âmbito fecha: o valor é libertado (*drop*)


~~~rust
fn main() {
   let p = Person { 
	   name: String::from("alice"),
	   age: 30
   };
   println!("{}, {}", p.name, p.age);
   // p libertado aqui
}
~~~

(NB: isto é chamado *padrão RAII* em C++.)

## Transferência de *ownership*

Passar um valor de tipo `T` transfere a *ownership*.

~~~rust
fn bye(p: Person) {
   println!("Goodbye, {}", p.name);
}

fn main() {
   let p = Person { 
       ... 
   };
   bye(p);  // transfere `p`
   println!("{}", p.age); 
   // error[E0382]: borrow of moved value: `p`
}
~~~

## Empréstimo

Para usar a estrutura depois do retorno
passamos uma referência `&T` (*immutable borrow*).

~~~rust
fn bye(p: &Person) {
   println!("Goodbye, {}", p.name);
}

fn main() {
   let p = Person { ...  };
   bye(&p);     // &Person (borrow) 
   println!("{}", p.age);  // OK
}
~~~

## Regras de empréstimo imutável

Uma referência `&T` (*immutable borrow*):

1. Permite leitura mas **não escrita**
2. Podem co-existir **múltiplas referências imutáveis**
   no mesmo âmbito


## Leitura mas não escrita

 O compilador não permite a escrita usando referências `&T`.

~~~rust
fn bye(p: &Person)  {
	println!("Goodbye, {}", p.name);
	// every time I say goodbye I die a little
	p.age += 1; 
	//	error[E0594]: cannot assign to `p.age` which is behind a `&` reference
}
~~~



## Multiplas referências imutáveis

~~~rust
fn eq_age(p1: &Person, p2: &Person) -> bool {
	p1.age == p2.age
}

fn main() {
	let p = Person { ... };
	let b = eq_age(&p, &p);    // OK
	...
}
~~~


## Empréstimo mutável

Para poder modificar um valor `T` passamos uma referência `&mut T`.

~~~rust
fn set_age(p1: &mut Person, years: u32) {
	p1.age = years;
}

fn main() {
	let mut p = Person { ... };
	set_age(&mut p, 30); 
	// NB: `p' tem ser declarado `let mut`
}
~~~



## Regras de empréstimo imutável

* Só pode existir **uma referência** `&mut T` 
* **Não** podem co-existir referências imutáveis `&T`
  no mesmo âmbito

## Exemplo

~~~rust
fn copy_age(p1: &mut Person, p2: &Person) { 
    p1.age = p2.age;
}

fn main() {
    let mut p = Person { ... };
    copy_age(&mut p, &p);
    // error[E0502]: cannot borrow `p` as immutable because it is also borrowed as mutable
}
~~~

## Sistema de tipos com *ownership*

* Permite garantir libertação de memória
* Elimina erros de *use-after-free*
* Mas também outros erros 
    - *iterator invalidation*
	- *race conditions* em programas concorrentes

## *Iterator invalidation*

* Modificar uma coleção durante iteração sobre os valores
* Erro em C++ (mas também em Java e Python)
* Exemplo (em Python):

~~~python
v = [1,2,3]
s = 0
for i in v:
	s += i
	v.append(i)
	# modificação no meio da iteração 
	# em Python 3.6: o ciclo não termina!
# fim do ciclo	
v.append(999)
# NB: aqui podemos modificar
~~~

## Em Rust

O sistema de tipos deteta o erro durante a compilação:

~~~rust 
let mut v : Vec<i32> = vec![1,2,3];
let mut s = 0;
for &i in v.iter() {
	s += i;
	v.push(i);
	// error[E0502]: cannot borrow `v` as mutable because it is also borrowed as immutable
}
v.push(999); // OK
~~~



 
  


  
