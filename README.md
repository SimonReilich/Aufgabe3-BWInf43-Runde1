# Aufgabe 3 - Wandertag

# Lösungsidee

Die Angaben der Mitarbeiter zur minimalen bzw. maximalen Länge können als Intervalle gesehen werden. Dann ist die optimale Lösung das Tripel $(a, b, c)$, dass $|\{x \mid x \in I \land (a \in x \lor b \in x \lor c \in x)\}|$ maximiert ($I$ ist die Menge der Intervalle). Dieses optimale Tripel zu finden benötigt jedoch sehr viel Zeit, weshalb im folgenden ein heuristischer Ansatz mit guten, aber nicht zwangsweise optimalen Ergebnissen beschrieben wird.

Ein guter Ansatz kann dabei sein, mit möglichst großen Intervallen zu starten, und diese durch Schnitt ($\cap$) immer weiter zu verkleinern, bis sich ein leeres Intervall ergeben würde. Dann wird abgebrochen und ein beliebiger Wert im Intervall zurückgegeben. Wenn dabei das andere Intervall immer so gewählt wird, dass der Schnitt immer noch möglichst groß ist, können viele Schritte gemacht werden, es werden also viele Mitarbeiter inkludiert.

Da nun 3 Weglängen gefordert sind, eine kurze, eine mittlere und eine lange, benötigt man 3 unterschiedliche Strategien, um das beste Intervall für den Schnitt zu finden. 

Für das Intervall $i_{klein}$ der kurzen Wegstrecke starten wir zunächst mit dem Intervall von $0$ bis zum Durchschnitt $avg$ der Mittelwerte der Intervalle. Bei einem Schritt des Algorithmus wird dann in allen Intervallen nach denjenigen gefiltert, deren mittlerer Wert kleiner ist als $avg$, und die bei einem Schnitt mit $i_{klein}$ kein leeres Intervall ergeben. von diesen wird dann dasjenige Intervall mit $i_{klein}$ geschnitten und als neues $i_{klein}$ abgespeichert, dessen Schnitt mit $i_{klein}$ am größten ist.

Für das Intervall $i_{groß}$ der langen Wegstrecke funktioniert das zunächst analog, wir starten zunächst mit dem Intervall von $avg$ bis $\infin$. Bei einem Schritt des Algorithmus wird dann in allen Intervallen nach denjenigen gefiltert, deren mittlerer Wert größer ist als $avg$, und die bei einem Schnitt mit $i_{groß}$ kein leeres Intervall ergeben. von diesen wird dann dasjenige Intervall mit $i_{groß}$ geschnitten und als neues $i_{groß}$ abgespeichert, dessen Schnitt mit $i_{groß}$ am größten ist.

Beim Intervall $i_{mittel}$ für die mittlere Wegstrecke starten wir zunächst mit dem Intervall von ${1 \over 2} * avg$ bis $1.5 * avg$. Bei einem Schritt des Algorithmus wird dann in allen Intervallen nach denjenigen gefiltert, deren mittlerer Wert größer zwischen $avg / 2$ und $2 * avg$ liegt, und die bei einem Schnitt mit $i_{mittel}$ kein leeres Intervall ergeben. von diesen wird dann dasjenige Intervall mit $i_{mittel}$ geschnitten und als neues $i_{mittel}$ abgespeichert, dessen Schnitt mit $i_{mittel}$ am größten ist.

Die Startwerte für die Intervalle ergeben sich aus der Annahme, dass die Präferenzen der Mitarbeiter annähernd gleichverteilt sind. Dadurch nehmen am Ende an allen 3 Touren ca. gleich viele Mitarbeitende teil.

# Umsetzung

*Die Lösungsidee wurde in OCaml erstellt. Auf die genaue Dokumentation des Einlesens wird verzichtet.*

Zunächst muss ein Intervall als Datenstruktur implementiert werden, dies geschieht im Modul `Interval`. Ein interval kann dabei entweder ein klassisches Intervall mit oberer und unterer Grenze (`Border of (int * int)`), der Schnitt über zwei Intervalle (`Cut of (interval * interval)`) oder ein leeres Intervall (`EmptyInterval`) sein. Nützlich ist hier die Methode `simplify`, die als Argument ein `interval` entgegennimmt und aus dessen oberer und unterer Grenze ein neues Intervall als Border erstellt. Mit simplify können `Cut`s (und `EmptyInterval`s) in `Border`s umgewandelt werden. `overlap` gibt genau dann `True` zurück, wenn sich die beiden Intervalle `i1` und `i2` überschneiden. (Bei allen anderen Methoden aus `Interval` sollte aus dem Namen heraus bereits ersichtlich sein, was sie tun.)

Die Hauptmethode beginnt zunächst, vom Benutzer den Namen der Eingabedatei zu erfragen (Für die Beispiele reicht es, die entsprechende Nummer anzugeben). Dieser wird dann an die Methode `parse_input` übergeben, diese erzeugt dann aus der Eingabedatei eine `interval list` und gibt diese zurück. Anschließend wird der Durchschnitt `avg` der Mittelwerte der Mittelpunkte der Intervalle berechnet. Dann wird die Methode `algo` aufgerufen, die den eigentlichen Algorithmus ausführt. Als Argumente werden dabei die Liste aller Intervalle `ls`, die Intervalle `Border (0, avg)` als `i_low`, `Border (0.5 *. avg, 1.5 *. avg)` als `i_mid` und `Border (avg, Int.max_int)` als `i_high`, sowie `avg` mitgegeben.

Die Methode `algo` arbeitet rekursiv. Zuerst wird geprüft, ob noch Intervalle in der Liste `ls` vorhanden sind. ist dies nicht der Fall, so wird als Lösung das Tripel der Mittelwerte der 3 Intervalle `i_low`, `i_mid` und `i_high` zurückgegeben. Andernfalls werden zunächst die 3 Listen `l1`, `l2` und `l3` erstellt. 

`l1` beinhaltet dabei alle Listen, deren obere Grenze ≤ `avg` ist und die geschnitten mit `i_low` kein `EmptyInterval` erzeugen, es wird absteigend sortiert nach der Größe des Schnittes eines Intervalls mit `i_low`.

`l2` beinhaltet dabei alle Listen, deren untere Grenze ≥ `avg *. 0.5` und deren obere Grenze ≤ `avg *. 1.5` ist und die geschnitten mit `i_mid` kein `EmptyInterval` erzeugen, es wird absteigend sortiert nach der Größe des Schnittes eines Intervalls mit `i_mid`.

`l3` beinhaltet dabei alle Listen, deren unterer Grenze ≥ `avg` ist und die geschnitten mit `i_high` kein `EmptyInterval` erzeugen, es wird absteigend sortiert nach der Größe des Schnittes eines Intervalls mit `i_high`.

Nun wird zuerst überprüft, ob `l1` überhaupt Elemente enthält, ist dies nicht der Fall, wird überprüft, ob `l2` Elemente enthält, ist dies nicht der Fall, wird überprüft, ob `l3` Elemente enthält. Ist dies auch nicht der Fall, bricht der Algorithmus ab und gibt als Lösung das Tripel der Mittelwerte der 3 Intervalle `i_low`, `i_mid` und `i_high` zurück, da keine Intervalle mehr in `ls` vorhanden sind, die geschnitten mit `i_low`, `i_mid` oder `i_high` ein nicht leeres Intervall ergeben.

Sollte `l3` doch Elemente enthalten, wird das erste Element aus `l3` mittels `match l3 with x :: _ -> …` entnommen (Der Fall der leeren Liste muss im `match` nicht beachtet werden, da bereits überprüft wurde, ob `l3` leer ist). `algo` wird dann rekursiv aufgerufen, `i_low`, `i_mid` und `avg` bleiben dabei unverändert, `i_high` wird mit dem Intervall `x` geschnitten und als neues `i_high` übergeben, aus `ls` wird `x` entfernt und diese Liste dann als neues `ls` übergeben.

Sollte `l2` doch Elemente enthalten, wird das erste Element aus `l2` mittels `match l2 with x :: _ -> …` entnommen (Der Fall der leeren Liste muss im `match` nicht beachtet werden, da bereits überprüft wurde, ob `l2` leer ist). `algo` wird dann rekursiv aufgerufen, `i_low`, `i_high` und `avg` bleiben dabei unverändert, `i_mid` wird mit dem Intervall `x` geschnitten und als neues `i_mid` übergeben, aus `ls` wird `x` entfernt und diese Liste dann als neues `ls` übergeben.

Sollte `l1` doch Elemente enthalten, wird das erste Element aus `l1` mittels `match l1 with x :: _ -> …` entnommen (Der Fall der leeren Liste muss im `match` nicht beachtet werden, da bereits überprüft wurde, ob `l1` leer ist). `algo` wird dann rekursiv aufgerufen, `i_mid`, `i_high` und `avg` bleiben dabei unverändert, `i_low` wird mit dem Intervall `x` geschnitten und als neues `i_low` übergeben, aus `ls` wird `x` entfernt und diese Liste dann als neues `ls` übergeben.

Das Ergebnis der Methode `algo` wird nun im Tripel `(l, m, u)` gespeichert und mit der zusätzlichen Information der Teilnehmenden pro Streckenlänge (die Methode `get_particapating_single` zählt die Teilnehmer bei einer einzigen Wegstrecke) und der Gesamtanzahl der Teilnehmenden (die Methode `get_particapating` zählt die Teilnehmer bei drei verschiedenen Wegstrecken) ausgegeben.

# Beispiele

## Beispiel 1

<aside>
📥

7
12 35
22 45
46 46
48 62
51 57
64 64
64 71

</aside>

<aside>
📤

Short route length: 28m, Participating: 2
Middle route length: 54m, Participating: 2
Long route length: 64m, Participating: 2
Number of participants: 6 of 7

</aside>

## Beispiel 2

<aside>
📥

6
60 80
90 90
40 80
40 60
10 30
10 50

</aside>

<aside>
📤

Short route length: 20m, Participating: 2
Middle route length: 60m, Participating: 3
Long route length: 90m, Participating: 1
Number of participants: 6 of 6

</aside>

## Beispiel 3

<aside>
📥

10
53 90
27 67
26 72
92 94
89 94
66 67
16 65
90 96
17 27
19 22

</aside>

<aside>
📤

Short route length: 20m, Participating: 3
Middle route length: 59m, Participating: 4
Long route length: 93m, Participating: 3
Number of participants: 9 of 10

</aside>

## Beispiel 4

<aside>
📥

100
770 846
768 829
143 288
77 922
811 912
762 824
485 698
516 801
658 870
488 798
… [Aus Gründen der Übersichtlichkeit gekürzt]

</aside>

<aside>
📤

Short route length: 224m, Participating: 18
Middle route length: 640m, Participating: 38
Long route length: 799m, Participating: 37
Number of participants: 66 of 100

</aside>

## Beispiel 5

<aside>
📥

200
25968 28434
28459 78949
28194 39195
73503 98273
44322 77563
33902 94345
66569 93493
28874 37983
87905 96516
87953 99183
… [Aus Gründen der Übersichtlichkeit gekürzt]

</aside>

<aside>
📤

Short route length: 33703m, Participating: 74
Middle route length: 58940m, Participating: 90
Long route length: 84898m, Participating: 57
Number of participants: 144 of 200

</aside>

## Beispiel 6

<aside>
📥

500
24681 43540
95355 99444
63183 91205
96398 98512
65938 84141
10268 31971
88368 96778
56522 97709
96891 97965
34346 44231
… [Aus Gründen der Übersichtlichkeit gekürzt]

</aside>

<aside>
📤

Short route length: 37532m, Participating: 148
Middle route length: 57826m, Participating: 164
Long route length: 78795m, Participating: 155
Number of participants: 295 of 500

</aside>

## Beispiel 7

<aside>
📥

800
66525 85529
69953 73154
1596 38773
28911 67500
12483 42104
28919 56220
56922 81977
41694 66037
15470 88627
34785 41384
… [Aus Gründen der Übersichtlichkeit gekürzt]

</aside>

<aside>
📤

Short route length: 35055m, Participating: 259
Middle route length: 59291m, Participating: 292
Long route length: 83147m, Participating: 237
Number of participants: 505 of 800

</aside>

# Quellcode

### Hauptmethode

```ocaml
let _ =
  print_string "Please provide the path of the .txt-file containing the input: ";
  let ls =
    parse_input
      (let file_name = Stdlib.read_line () in
       if file_name = "1" then "wandern1.txt"
       else if file_name = "2" then "wandern2.txt"
       else if file_name = "3" then "wandern3.txt"
       else if file_name = "4" then "wandern4.txt"
       else if file_name = "5" then "wandern5.txt"
       else if file_name = "6" then "wandern6.txt"
       else if file_name = "7" then "wandern7.txt"
       else file_name)
  in
  let avg =
    List.fold_left
      (fun acc a ->
        1.0
        /. float_of_int (List.length ls)
        *. float_of_int (Interval.get_midpoint a)
        +. acc)
      0.0 ls
  in
  let l, m, u =
    algo ls
      (Interval.new_interval 0 (int_of_float avg))
      (Interval.new_interval
         (int_of_float (avg *. 0.5))
         (int_of_float (avg *. 1.5)))
      (Interval.new_interval (int_of_float avg) Int.max_int)
      avg
  in
  print_newline ();
  print_string "Short route length: ";
  print_int l;
  print_string "m, Participating: ";
  print_int (get_particapating_single l ls);
  print_newline ();
  print_string "Middle route length: ";
  print_int m;
  print_string "m, Participating: ";
  print_int (get_particapating_single m ls);
  print_newline ();
  print_string "Long route length: ";
  print_int u;
  print_string "m, Participating: ";
  print_int (get_particapating_single u ls);
  print_newline ();
  print_string "Number of participents: ";
  print_int (get_particapating (l, m, u) ls);
  print_string " of ";
  print_int (List.length ls);
  print_newline ()

```

### Der zentrale Algorithmus

```ocaml
let rec algo (ls : Interval.interval list) (i_low : Interval.interval)
    (i_mid : Interval.interval) (i_high : Interval.interval) (avg : float) =
  if List.length ls = 0 then
    ( Interval.get_midpoint i_low,
      Interval.get_midpoint i_mid,
      Interval.get_midpoint i_high )
  else
    let l1 =
      List.sort
        (fun a b ->
          let ca = Interval.cut i_low a in
          let cb = Interval.cut i_low b in
          Interval.compare_sz cb ca)
        (List.filter
           (fun a ->
             float_of_int (Interval.get_upper_bound a) <= avg
             &&
             match Interval.cut a i_low with
             | EmptyInterval -> false
             | _ -> true)
           ls)
    in
    let l2 =
      List.sort
        (fun a b ->
          let ca = Interval.cut i_mid a in
          let cb = Interval.cut i_mid b in
          Interval.compare_sz cb ca)
        (List.filter
           (fun a ->
             float_of_int (Interval.get_upper_bound a) >= avg *. 0.5
             && float_of_int (Interval.get_upper_bound a) <= avg *. 1.5
             &&
             match Interval.cut a i_mid with
             | EmptyInterval -> false
             | _ -> true)
           ls)
    in
    let l3 =
      List.sort
        (fun a b ->
          let ca = Interval.cut i_high a in
          let cb = Interval.cut i_high b in
          Interval.compare_sz cb ca)
        (List.filter
           (fun a ->
             float_of_int (Interval.get_lower_bound a) >= avg
             &&
             match Interval.cut a i_high with
             | EmptyInterval -> false
             | _ -> true)
           ls)
    in
    if List.length l1 = 0 then
      if List.length l2 = 0 then
        if List.length l3 = 0 then
          ( Interval.get_midpoint i_low,
            Interval.get_midpoint i_mid,
            Interval.get_midpoint i_high )
        else
          match l3 with
          | x :: _ ->
              algo
                (List.filter (fun a -> a != x) ls)
                i_low i_mid (Interval.cut x i_high) avg
      else
        match l2 with
        | x :: _ ->
            algo
              (List.filter (fun a -> a != x) ls)
              i_low (Interval.cut x i_mid) i_high avg
    else
      match l1 with
      | x :: _ ->
          algo
            (List.filter (fun a -> a != x) ls)
            (Interval.cut x i_low) i_mid i_high avg
```

### Hilfsmethoden

```ocaml
let get_particapating ((l1, l2, l3) : int * int * int)
    (list : Interval.interval list) =
  List.fold_left
    (fun acc a ->
      if
        Interval.int_is_in l1 a || Interval.int_is_in l2 a
        || Interval.int_is_in l3 a
      then acc + 1
      else acc)
    0 list

let get_particapating_single l ls =
  List.fold_left
    (fun acc a -> if Interval.int_is_in l a then acc + 1 else acc)
    0 ls

```

### Einlesen der Eingabedatei

```ocaml
let extract (str : string) =
  let rec helper (acc : string list) (str : string) =
    if String.length str = 0 then acc
    else
      match acc with
      | [] ->
          helper
            [ Char.escaped (String.get str 0) ]
            (String.sub str 1 (String.length str - 1))
      | x :: xs ->
          if
            String.get str 0 = ' '
            || String.get str 0 = '\n'
            || String.get str 0 = '\r'
          then helper ("" :: acc) (String.sub str 1 (String.length str - 1))
          else
            helper
              ((x ^ Char.escaped (String.get str 0)) :: xs)
              (String.sub str 1 (String.length str - 1))
  in
  let l = List.filter (fun a -> String.length a > 0) (helper [] str) in
  (int_of_string (List.nth l 0), int_of_string (List.nth l 1))

let rec read_lines (infile : in_channel) (acc : Interval.interval list) =
  try
    let u, l = extract (input_line infile) in
    read_lines infile (Interval.new_interval l u :: acc)
  with
  | Failure _ -> read_lines infile acc
  | End_of_file -> acc

let parse_input (file_name : string) =
  let infile = open_in file_name in
  let _ = input_line infile in
  read_lines infile []

```

### Das Modul Interval

```ocaml
module Interval = struct
  type interval =
    | Border of (int * int)
    | Cut of (interval * interval)
    | EmptyInterval

  let new_interval (l : int) (u : int) =
    if l <= u then Border (l, u)
    else
      raise
        (Invalid_argument "lower bound has to be less or equal to upper bound")

  let rec get_lower_bound = function
    | Border (l, _) -> l
    | EmptyInterval ->
        raise (Invalid_argument "cant get lower bound of empty interval!")
    | Cut (i1, i2) ->
        let lb1 = get_lower_bound i1 in
        let lb2 = get_lower_bound i2 in
        if lb1 < lb2 then lb2 else lb1

  let rec get_upper_bound = function
    | Border (_, u) -> u
    | EmptyInterval ->
        raise (Invalid_argument "cant get lower bound of empty interval!")
    | Cut (i1, i2) ->
        let ub1 = get_upper_bound i1 in
        let ub2 = get_upper_bound i2 in
        if ub1 > ub2 then ub2 else ub1

  let rec get_midpoint = function
    | Border (l, u) -> (l + u) / 2
    | EmptyInterval -> raise (Invalid_argument "empty interval has no midpoint")
    | Cut (i1, i2) -> (get_midpoint i1 + get_midpoint i2) / 2

  let simplify (i : interval) = Border (get_lower_bound i, get_upper_bound i)

  let rec float_is_in (v : float) = function
    | Border (l, u) -> Float.of_int l < v && v < Float.of_int u
    | EmptyInterval -> false
    | Cut (i1, i2) -> float_is_in v i1 && float_is_in v i2

  let rec int_is_in (v : int) = function
    | Border (l, u) -> l <= v && v <= u
    | EmptyInterval -> false
    | Cut (i1, i2) -> int_is_in v i1 && int_is_in v i2

  let interval_is_in (i : interval) (interval : interval) =
    int_is_in (get_lower_bound i) interval
    && int_is_in (get_upper_bound i) interval

  let overlap (i1 : interval) (i2 : interval) =
    int_is_in (get_lower_bound i1) i2
    || int_is_in (get_upper_bound i1) i2
    || int_is_in (get_lower_bound i2) i1
    || int_is_in (get_upper_bound i2) i1

  let cut (i1 : interval) (i2 : interval) =
    if overlap i1 i2 then simplify (Cut (i1, i2)) else EmptyInterval

  let compare_lb (i1 : interval) (i2 : interval) =
    Int.compare (get_lower_bound i1) (get_lower_bound i2)

  let compare_ub (i1 : interval) (i2 : interval) =
    Int.compare (get_upper_bound i1) (get_upper_bound i2)

  let compare_md (i1 : interval) (i2 : interval) =
    Int.compare
      (get_lower_bound i1 + get_upper_bound i1)
      (get_lower_bound i2 + get_upper_bound i2)

  let compare_sz (i1 : interval) (i2 : interval) =
    Int.compare
      (get_upper_bound i1 - get_lower_bound i1)
      (get_upper_bound i2 - get_lower_bound i2)

  let to_string (i : interval) =
    "["
    ^ string_of_int (get_lower_bound i)
    ^ "; "
    ^ string_of_int (get_upper_bound i)
    ^ "]"
end

```

### .mli-Datei mit Typdefinitionen der Methoden (nicht notwendig)

```ocaml
module Interval : sig
    type interval =
        Border of (int * int)
      | Cut of (interval * interval)
      | EmptyInterval

    val new_interval : int -> int -> interval

    val get_lower_bound : interval -> int

    val get_upper_bound : interval -> int

    val get_midpoint : interval -> int

    val simplify : interval -> interval

    val float_is_in : float -> interval -> bool

    val int_is_in : int -> interval -> bool

    val interval_is_in : interval -> interval -> bool

    val overlap : interval -> interval -> bool

    val cut : interval -> interval -> interval

    val compare_lb : interval -> interval -> int

    val compare_ub : interval -> interval -> int

    val compare_md : interval -> interval -> int

    val compare_sz : interval -> interval -> int

    val to_string : interval -> string
end

val extract : string -> int * int

val read_lines :
  in_channel -> Interval.interval list -> Interval.interval list

val parse_input : string -> Interval.interval list

val get_particapating : int * int * int -> Interval.interval list -> int

val get_particapating_single : int -> Interval.interval list -> int

val algo :
  Interval.interval list ->
  Interval.interval ->
  Interval.interval -> Interval.interval -> float -> int * int * int

```