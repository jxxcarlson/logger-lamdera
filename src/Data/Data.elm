module Data.Data exposing (..)

import Dict exposing (Dict)
import Time


type alias Username =
    String


type alias DataFileName =
    String


type Data
    = Task { start : Time.Posix, end : Time.Posix, desc : String }
    | Quantity { start : Time.Posix, end : Time.Posix, value : Float, desc : String }


type DataType
    = TTask
    | TQuantity


type alias DataFile =
    { name : DataFileName, owner : Username, dataType : DataType, data : List Data }


{-|

    > dd = Dict.insert ("jxx", "qlog") { name = "qlog", owner = "jxx", dataType = TQuantity, data = []} Dict.empty
    Dict.fromList [(("jxx","qlog"),{ data = [], dataType = TQuantity, name = "qlog", owner = "jxx" })]

    > insert "jxx" "qlog" (Quantity {start = Time.millisToPosix 0, end = Time.millisToPosix 1, desc = "Ho ho ho!", value = 123}) dd
    Dict.fromList [(("jxx","qlog"),{ data = [Quantity { desc = "Ho ho ho!", end = Posix 1, start = Posix 0, value = 123 }], dataType = TQuantity, name = "qlog", owner = "jxx" })]

    > insert "jxx2" "qlog" (Quantity {start = Time.millisToPosix 0, end = Time.millisToPosix 1, desc = "Ho ho ho!", value = 123}) dd
    Dict.fromList [(("jxx","qlog"),{ data = [], dataType = TQuantity, name = "qlog", owner = "jxx" })]

    > insert "jxx" "qlog" (Task {start = Time.millisToPosix 0, end = Time.millisToPosix 1, desc = "Ho ho ho!"}) dd
    Dict.fromList [(("jxx","qlog"),{ data = [], dataType = TQuantity, name = "qlog", owner = "jxx" })]

-}
type alias DataDict =
    Dict ( Username, DataFileName ) DataFile


insert : Username -> DataFileName -> Data -> DataDict -> DataDict
insert username dataFileName datum dataDict =
    case Dict.get ( username, dataFileName ) dataDict of
        Nothing ->
            dataDict

        Just dataFile ->
            if dataTypesMatch datum dataFile then
                Dict.insert ( username, dataFileName ) { dataFile | data = datum :: dataFile.data } dataDict

            else
                dataDict


dataTypesMatch : Data -> DataFile -> Bool
dataTypesMatch data dataFile =
    case ( data, dataFile.dataType ) of
        ( Task _, TTask ) ->
            True

        ( Quantity _, TQuantity ) ->
            True

        _ ->
            False
