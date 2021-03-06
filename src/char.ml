open! Import

module String = String0

include Char0

module T = struct
  type t = char [@@deriving_inline compare, hash, sexp]
  let compare : t -> t -> int = compare_char
  let (hash_fold_t :
         Ppx_hash_lib.Std.Hash.state -> t -> Ppx_hash_lib.Std.Hash.state) =
    hash_fold_char

  and (hash : t -> Ppx_hash_lib.Std.Hash.hash_value) =
    let func = hash_char  in fun x  -> func x

  let t_of_sexp : Sexplib.Sexp.t -> t = char_of_sexp
  let sexp_of_t : t -> Sexplib.Sexp.t = sexp_of_char
  [@@@end]

  let to_string t = String.make 1 t

  let of_string s =
    match String.length s with
    | 1 -> String.get s 0
    | _ -> failwithf "Char.of_string: %S" s ()
end

include T

(* [Replace_polymorphic_compare] should come before functor instantiations so it doesn't
   pick up definitions that cannot be inlined. *)
module Replace_polymorphic_compare = struct
  let compare = compare
  let ascending = compare
  let descending x y = compare y x
  let equal (x : t) y = phys_equal x y
  let ( >= ) (x : t) y = Poly.(>=)  x y
  let ( <= ) (x : t) y = Poly.(<=)  x y
  let ( =  ) (x : t) y = phys_equal x y
  let ( >  ) (x : t) y = Poly.(>)   x y
  let ( <  ) (x : t) y = Poly.(<)   x y
  let ( <> ) (x : t) y = Poly.(<>)  x y
  let min (x : t) y = if x < y then x else y
  let max (x : t) y = if x > y then x else y
end

include Identifiable.Make (struct
    include T
    let module_name = "Base.Char"
  end)

(* Include [Replace_polymorphic_compare] after functor instantiations so they do not
   shadow its definitions. *)
include Replace_polymorphic_compare

let all =
  Array.init 256 ~f:unsafe_of_int
  |> Array.to_list

let is_lowercase = function
  | 'a' .. 'z' -> true
  | _ -> false

let is_uppercase = function
  | 'A' .. 'Z' -> true
  | _ -> false

let is_print = function
  | ' ' .. '~' -> true
  | _ -> false

let is_whitespace = function
  | '\t'
  | '\n'
  | '\011' (* vertical tab *)
  | '\012' (* form feed *)
  | '\r'
  | ' '
    -> true
  | _
    -> false
;;

let is_digit = function
  | '0' .. '9' -> true
  | _ -> false

let is_alpha = function
  | 'a' .. 'z' | 'A' .. 'Z' -> true
  | _ -> false

(* Writing these out, instead of calling [is_alpha] and [is_digit], reduces
   runtime by approx. 30% *)
let is_alphanum = function
  | 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' -> true
  | _ -> false

let get_digit_unsafe t = to_int t - to_int '0'

let get_digit_exn t =
  if is_digit t
  then get_digit_unsafe t
  else failwithf "Char.get_digit_exn %C: not a digit" t ()
;;

let get_digit t = if is_digit t then Some (get_digit_unsafe t) else None

module O = struct
  let ( >= ) = ( >= )
  let ( <= ) = ( <= )
  let ( =  ) = ( =  )
  let ( >  ) = ( >  )
  let ( <  ) = ( <  )
  let ( <> ) = ( <> )
end
