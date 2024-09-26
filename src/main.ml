module Tree = struct
  type t = Leave of (float) | Connection of (t * t)
  let rec get_length = function Leave (_) -> 1 | Connection (l, r) -> get_length l + get_length r
  let rec get n tree = match tree with 
    | Connection (l, r) -> if n < get_length l then get n l else get (n - get_length l) r
    | Leave (i) -> if n = 0 then i else raise (Invalid_argument "Tree has to few elements")

  let to_string = Int.to_string
end

let _ = print_string "Hello World\n"