module Utilities exposing (..)

(>>>): (a -> b -> c) -> (c -> d) -> a -> b -> d
(>>>) f g x y = g (f x y)

(<<<): (c -> d) -> (a -> b -> c) -> a -> b -> d
(<<<) f g x y = f (g x y)

update: (a -> b -> a) -> (a -> b) -> (b -> b) -> a -> a
update updateRecord getNested updateNested record =
    getNested record |> updateNested |> updateRecord record
