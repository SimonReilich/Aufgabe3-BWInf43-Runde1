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
