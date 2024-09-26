module Tree = struct
  type tree = Leave of float | Connection of (tree, tree)
end

let _ = print_string "Hello World\n"