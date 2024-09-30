module Tree = struct
  type tree = Node of ((tree * int) list) | End of (int)

  let a = 2

  let b = 3
end

let _ = print_string "Hello World\n"