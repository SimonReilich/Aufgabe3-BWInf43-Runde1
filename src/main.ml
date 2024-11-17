module Interval = struct
  type interval =
    | Border of (int * int)
    | Cut of (interval * interval)
    | EmptyInterval

  let new_interval lower upper =
    if lower <= upper then Border (lower, upper)
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

  let simplify interval =
    Border (get_lower_bound interval, get_upper_bound interval)

  let rec float_is_in (v : float) (interval : interval) =
    match interval with
    | Border (l, u) -> Float.of_int l < v && v < Float.of_int u
    | EmptyInterval -> false
    | Cut (i1, i2) -> float_is_in v i1 && float_is_in v i2

  let rec int_is_in (v : int) (interval : interval) =
    match interval with
    | Border (l, u) -> l <= v && v <= u
    | EmptyInterval -> false
    | Cut (i1, i2) -> int_is_in v i1 && int_is_in v i2

  let interval_is_in (i : interval) (interval : interval) =
    int_is_in (get_lower_bound i) interval
    && int_is_in (get_upper_bound i) interval

  let overlap interval1 interval2 =
    int_is_in (get_lower_bound interval1) interval2
    || int_is_in (get_upper_bound interval1) interval2
    || int_is_in (get_lower_bound interval2) interval1
    || int_is_in (get_upper_bound interval2) interval1

  let cut interval1 interval2 =
    if overlap interval1 interval2 then simplify (Cut (interval1, interval2))
    else EmptyInterval

  let compare_lb i1 i2 = Int.compare (get_lower_bound i1) (get_lower_bound i2)
  let compare_ub i1 i2 = Int.compare (get_upper_bound i1) (get_upper_bound i2)

  let compare_md i1 i2 =
    Int.compare
      (get_lower_bound i1 + get_upper_bound i1)
      (get_lower_bound i2 + get_upper_bound i2)

      let compare_sz i1 i2 =
            Int.compare 
            (get_upper_bound i1 - get_lower_bound i1)
            (get_upper_bound i2 - get_lower_bound i2)

  let to_string i =
    "["
    ^ string_of_int (get_lower_bound i)
    ^ "; "
    ^ string_of_int (get_upper_bound i)
    ^ "]"
end

let extract string =
  let rec helper (acc : string list) (string : string) =
    if String.length string = 0 then acc
    else
      match acc with
      | [] ->
          helper
            [ Char.escaped (String.get string 0) ]
            (String.sub string 1 (String.length string - 1))
      | x :: xs ->
          if
            String.get string 0 = ' '
            || String.get string 0 = '\n'
            || String.get string 0 = '\r'
          then
            helper ("" :: acc) (String.sub string 1 (String.length string - 1))
          else
            helper
              ((x ^ Char.escaped (String.get string 0)) :: xs)
              (String.sub string 1 (String.length string - 1))
  in
  let l = List.filter (fun a -> String.length a > 0) (helper [] string) in
  (int_of_string (List.nth l 0), int_of_string (List.nth l 1))

let rec read_lines infile acc =
  try
    let u, l = extract (input_line infile) in
    read_lines infile (Interval.new_interval l u :: acc)
  with
  | Failure _ -> read_lines infile acc
  | End_of_file -> acc

let parse_input file =
  let infile = open_in file in
  let _ = input_line infile in
  read_lines infile []

let rem_nth n l =
  let rec helper i l acc =
    match l with
    | x :: xs -> if i = 0 then acc @ xs else helper (i - 1) xs (acc @ [ x ])
    | [] -> acc
  in
  helper n l []

let get_particapating (length1, length2, length3) list =
  List.fold_left
    (fun acc a ->
      if
        Interval.int_is_in length1 a
        || Interval.int_is_in length2 a
        || Interval.int_is_in length3 a
      then acc + 1
      else acc)
    0 list

let get_particapating_single l list =
  List.fold_left
    (fun acc a -> if Interval.int_is_in l a then acc + 1 else acc)
    0 list

let rec algo intervals i_low i_mid i_high avg =
  if List.length intervals = 0 then
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
           intervals)
    in
    let l2 =
      List.sort
        (fun a b ->
          let ca = Interval.cut i_mid a in
          let cb = Interval.cut i_mid b in
          Interval.compare_sz cb ca)
        (List.filter
           (fun a ->
             float_of_int (Interval.get_upper_bound a) >= avg /. 2.0
             && float_of_int (Interval.get_upper_bound a) <= avg *. 2.0
             &&
             match Interval.cut a i_mid with
             | EmptyInterval -> false
             | _ -> true)
           intervals)
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
           intervals)
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
                (List.filter (fun a -> a != x) intervals)
                i_low i_mid (Interval.cut x i_high) avg
          | [] ->
              ( Interval.get_midpoint i_low,
                Interval.get_midpoint i_mid,
                Interval.get_midpoint i_high )
      else
        match l2 with
        | x :: _ ->
            algo
              (List.filter (fun a -> a != x) intervals)
              i_low (Interval.cut x i_mid) i_high avg
        | [] ->
            ( Interval.get_midpoint i_low,
              Interval.get_midpoint i_mid,
              Interval.get_midpoint i_high )
    else
      match l1 with
      | x :: _ ->
          algo
            (List.filter (fun a -> a != x) intervals)
            (Interval.cut x i_low) i_mid i_high avg
      | [] ->
          ( Interval.get_midpoint i_low,
            Interval.get_midpoint i_mid,
            Interval.get_midpoint i_high )

let _ =
  print_string "Please provide the path of the .txt-file containing the input: ";
  let input = parse_input (Stdlib.read_line ()) in
  let avg =
    List.fold_left
      (fun acc a ->
        1.0
        /. float_of_int (List.length input)
        *. float_of_int (Interval.get_midpoint a)
        +. acc)
      0.0 input
  in
  let l, m, u =
    algo
      input
      (Interval.new_interval 0 (int_of_float avg))
      (Interval.new_interval (int_of_float(avg *. 0.5)) (int_of_float (avg *. 1.5)))
      (Interval.new_interval (int_of_float avg) Int.max_int)
      avg
  in
  print_newline ();
  print_string "Short route length: ";
  print_int l;
  print_string "m, Participating: ";
  print_int (get_particapating_single l input);
  print_newline ();
  print_string "Middle route length: ";
  print_int m;
  print_string "m, Participating: ";
  print_int (get_particapating_single m input);
  print_newline ();
  print_string "Long route length: ";
  print_int u;
  print_string "m, Participating: ";
  print_int (get_particapating_single u input);
  print_newline ();
  print_string "Number of participents: ";
  print_int (get_particapating (l, m, u) input);
  print_string " of ";
  print_int (List.length input);
  print_newline ()
