module Utilities exposing (..)

(>>>): (a -> b -> c) -> (c -> d) -> a -> b -> d
(>>>) f g x y = g (f x y)

(<<<): (c -> d) -> (a -> b -> c) -> a -> b -> d
(<<<) f g x y = f (g x y)    
