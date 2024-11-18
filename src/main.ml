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
