module BinaryTree = struct
  type tree = Node of (tree * int * tree) | None

  let rec max_depth tree = match tree with
    | None -> 0
    | Node (l, _, r) -> let ll = max_depth l in let lr = max_depth r in if ll < lr then 1 + lr else 1 + ll

  let rec balance tree = match tree with
    | None -> tree
    | Node (l, v, r) -> let l = balance l in let r = balance r in 
    if max_depth l - max_depth r > 1 then tree
    else if max_depth l - max_depth r < -1 then tree
    else Node (l, v, r)

  let insert tree x =
    let rec helper tree = match tree with
    | None -> Node (None, x, None)
    | Node (l, y, r) -> if x = y then tree else if x < y then Node (helper l, y, r) else Node (l, y, helper r)
  in balance (helper tree)
end

let _ = print_string "Hello World\n"