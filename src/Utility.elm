module Utility exposing (..)


roundTo : Int -> Float -> Float
roundTo n x =
    let
        factor =
            10 ^ toFloat n
    in
    toFloat (round (factor * x)) / factor
