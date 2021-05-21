module Data.Data exposing (..)

import DateTimeUtility
import Dict exposing (Dict)
import Element as E exposing (Element)
import Time


type alias Username =
    String


type alias DataFileName =
    String


type Data
    = Task { start : Time.Posix, end : Time.Posix, desc : String }
    | Quantity { start : Time.Posix, end : Time.Posix, value : Float, desc : String }


view : Time.Zone -> Data -> Element msg
view zone data =
    case data of
        Task { start, end, desc } ->
            E.row [ E.spacing 8 ]
                [ E.el [ E.width (E.px 100) ] (E.text <| DateTimeUtility.zonedTimeString zone start)
                , E.el [ E.width (E.px 100) ] (E.text <| DateTimeUtility.zonedTimeString zone end)
                , E.el [ E.width (E.px 100) ] (E.text <| DateTimeUtility.elapsedTimeAsString start end)
                , E.el [ E.width (E.px 500) ] (E.text <| desc)
                ]

        Quantity { start, end, value, desc } ->
            E.row [ E.spacing 8 ]
                [ E.el [ E.width (E.px 100) ] (E.text <| DateTimeUtility.zonedTimeString zone start)
                , E.el [ E.width (E.px 100) ] (E.text <| DateTimeUtility.zonedTimeString zone end)
                , E.el [ E.width (E.px 100) ] (E.text <| String.fromFloat value)
                , E.el [ E.width (E.px 500) ] (E.text <| desc)
                ]


type DataType
    = TTask
    | TQuantity


type alias DataFile =
    { name : DataFileName
    , owner : Username
    , dataType : DataType
    , data : List Data
    , timeCreated : Time.Posix
    , timeModified : Time.Posix
    }


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


insertDataFile : Time.Posix -> Username -> DataFileName -> DataType -> DataDict -> DataDict
insertDataFile time username dataFileName dataType dataDict =
    Dict.insert ( username, dataFileName )
        { name = dataFileName
        , owner = username
        , dataType = dataType
        , data = []
        , timeCreated = time
        , timeModified = time
        }
        dataDict


insertDatum : Username -> DataFileName -> Data -> DataDict -> DataDict
insertDatum username dataFileName datum dataDict =
    case Dict.get ( username, dataFileName ) dataDict of
        Nothing ->
            dataDict

        Just dataFile ->
            if dataTypesMatch datum dataFile then
                Dict.insert ( username, dataFileName ) { dataFile | data = datum :: dataFile.data } dataDict

            else
                dataDict


insertDatum_ : Username -> DataFileName -> Data -> DataFile -> DataFile
insertDatum_ username dataFileName datum dataFile =
    if dataTypesMatch datum dataFile then
        { dataFile | data = datum :: dataFile.data }

    else
        dataFile


dataTypesMatch : Data -> DataFile -> Bool
dataTypesMatch data dataFile =
    case ( data, dataFile.dataType ) of
        ( Task _, TTask ) ->
            True

        ( Quantity _, TQuantity ) ->
            True

        _ ->
            False
