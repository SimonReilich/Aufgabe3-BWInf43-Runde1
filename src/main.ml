module Interval = struct
  type interval = Border of (int * int) | Cut of (interval * interval) | EmptyInterval
  let new_interval lower upper = if lower <= upper then Border (lower, upper) else raise (Invalid_argument "lower bound has to be less or equal to upper bound")
  let rec get_lower_bound = function Border (l, _) -> l | EmptyInterval -> raise (Invalid_argument "cant get lower bound of empty interval!") | Cut (i1, i2) -> let lb1 = get_lower_bound i1 in let lb2 = get_lower_bound i2 in if lb1 < lb2 then lb1 else lb2
  let rec get_upper_bound = function Border (_, u) -> u | EmptyInterval -> raise (Invalid_argument "cant get lower bound of empty interval!") | Cut (i1, i2) -> let ub1 = get_upper_bound i1 in let ub2 = get_upper_bound i2 in if ub1 > ub2 then ub1 else ub2
  let simplify interval = Border (get_lower_bound interval, get_upper_bound interval)
  let rec is_in (v : float) (interval : interval) = match interval with Border (l, u) -> Float.of_int(l) < v && v < Float.of_int(u) | EmptyInterval -> false | Cut (i1, i2) -> is_in v i1 && is_in v i2
  let rec is_in (v : int) (interval : interval) = match interval with Border (l, u) -> l < v && v < u | EmptyInterval -> false | Cut (i1, i2) -> is_in v i1 && is_in v i2
  let overlap interval1 interval2 = is_in (get_lower_bound interval1) interval2 || is_in (get_upper_bound interval1) interval2
  let cut interval1 interval2 = if overlap interval1 interval2 then simplify (Cut (interval1, interval2)) else EmptyInterval
end

let _ = print_string "Hello World\n"