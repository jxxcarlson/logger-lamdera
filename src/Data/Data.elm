module Data.Data exposing
    ( Data(..)
    , DataDict
    , DataFile
    , DataType(..)
    , filterData
    , heading
    , insertDataFile
    , insertDatum
    , insertDatum_
    , newDataFile
    , replace
    , saveData
    , saveTimeSheet
    , totalValue
    , view
    )

import DateTimeUtility
import Dict exposing (Dict)
import Element as E exposing (Element)
import File.Download as Download
import Time


type alias Username =
    String


type alias DataFileName =
    String


type Data
    = Task { id : String, start : Time.Posix, end : Time.Posix, desc : String, job : String }
    | Quantity { id : String, start : Time.Posix, end : Time.Posix, value : Float, desc : String }


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



-- EXPORT TIME SHEET


saveTimeSheet : Time.Zone -> List Data -> Cmd msg
saveTimeSheet zone dataList =
    Download.string "timesheet.csv" "text/csv" (exportTimeSheet zone dataList)


exportTimeSheet : Time.Zone -> List Data -> String
exportTimeSheet zone dataList =
    List.map (exportTimeSheetDatum zone) dataList |> String.join "\n"


exportTimeSheetDatum : Time.Zone -> Data -> String
exportTimeSheetDatum zone datum =
    case datum of
        Task { start, end, desc, job } ->
            [ DateTimeUtility.zonedDateString zone end
            , DateTimeUtility.elapsedTimeAsString start end
            , String.replace "," ";" desc
            ]
                |> String.join ","

        Quantity { start, end, desc, value } ->
            [ DateTimeUtility.zonedDateString zone end
            , String.fromFloat value
            , String.replace "," ";" desc
            ]
                |> String.join ","



-- EXPORT LIST DATA


saveData : Time.Zone -> List Data -> Cmd msg
saveData zone dataList =
    Download.string "data.csv" "text/csv" (exportData dataList)


exportData : List Data -> String
exportData dataList =
    List.map exportDatum dataList |> String.join "\n"


exportDatum : Data -> String
exportDatum datum =
    case datum of
        Task { id, start, end, desc, job } ->
            [ id
            , Time.posixToMillis start |> String.fromInt
            , Time.posixToMillis start |> String.fromInt
            , String.replace "," ";" desc
            , job
            ]
                |> String.join ","

        Quantity { start, end, desc, value } ->
            [ Time.posixToMillis start |> String.fromInt
            , Time.posixToMillis start |> String.fromInt
            , String.replace "," ";" desc
            , String.fromFloat value
            ]
                |> String.join ","


getValue : Data -> Float
getValue data =
    case data of
        Task { start, end, desc, job } ->
            toFloat <| DateTimeUtility.elapsedTimeAsSeconds start end

        Quantity { start, end, desc, value } ->
            value


totalValue : List Data -> Float
totalValue dataList =
    dataList |> List.map getValue |> List.sum


getJob : Data -> String
getJob datum =
    case datum of
        Task { start, end, desc, job } ->
            job

        Quantity _ ->
            ""


getDesc : Data -> String
getDesc datum =
    case datum of
        Task { start, end, desc, job } ->
            desc

        Quantity { start, end, desc, value } ->
            desc


getEndTime : Data -> Int
getEndTime datum =
    case datum of
        Task { start, end, desc, job } ->
            Time.posixToMillis end

        Quantity { start, end, desc, value } ->
            Time.posixToMillis end


heading : DataType -> Element msg
heading dataType =
    let
        nudge =
            E.moveRight 4
    in
    case dataType of
        TTask ->
            E.row [ E.spacing 8 ]
                [ E.el [ E.width (E.px 100), nudge ] (E.text "Job")
                , E.el [ E.width (E.px 100), nudge ] (E.text <| "Date")
                , E.el [ E.width (E.px 50), nudge ] (E.text <| "Start")
                , E.el [ E.width (E.px 44), nudge ] (E.text <| "End")
                , E.el [ E.width (E.px 70), nudge ] (E.text <| "Elapsed")
                , E.el [ E.width (E.px 500), nudge ] (E.text <| "Description")
                ]

        TQuantity ->
            E.row [ E.spacing 8 ]
                [ E.el [ E.width (E.px 100), nudge ] (E.text <| "Start")
                , E.el [ E.width (E.px 100), nudge ] (E.text <| "End")
                , E.el [ E.width (E.px 100), nudge ] (E.text <| "Value")
                , E.el [ E.width (E.px 500), nudge ] (E.text <| "Description")
                ]


view : Time.Zone -> Data -> Element msg
view zone data =
    case data of
        Task { start, end, desc, job } ->
            E.row [ E.spacing 8 ]
                [ E.el [ E.width (E.px 100) ] (E.text job)
                , E.el [ E.width (E.px 100) ] (E.text <| DateTimeUtility.zonedDateString zone end)
                , E.el [ E.width (E.px 50) ] (E.text <| DateTimeUtility.zonedTimeString zone start)
                , E.el [ E.width (E.px 44) ] (E.text <| DateTimeUtility.zonedTimeString zone end)
                , E.el [ E.width (E.px 70) ] (E.text <| DateTimeUtility.elapsedTimeAsString start end)
                , E.el [ E.width (E.px 500) ] (E.text <| desc)
                ]

        Quantity { start, end, value, desc } ->
            E.row [ E.spacing 8 ]
                [ E.el [ E.width (E.px 100) ] (E.text <| DateTimeUtility.zonedTimeString zone start)
                , E.el [ E.width (E.px 100) ] (E.text <| DateTimeUtility.zonedTimeString zone end)
                , E.el [ E.width (E.px 100) ] (E.text <| String.fromFloat value)
                , E.el [ E.width (E.px 500) ] (E.text <| desc)
                ]


filterData1 : String -> String -> List Data -> List Data
filterData1 jobFragment taskFragment data =
    data
        |> List.filter (\datum -> String.contains jobFragment (getJob datum))
        |> List.filter (\datum -> String.contains taskFragment (getDesc datum))


filterData : Time.Posix -> String -> String -> String -> List Data -> List Data
filterData posix jobFragment taskFragment earliestDateAsString data =
    let
        earliestTime : Int
        earliestTime =
            DateTimeUtility.millisecondsFromDateString (earliestDateAsString ++ "/" ++ String.fromInt (DateTimeUtility.yearFromPosix posix))
    in
    data
        |> filterIf (jobFragment /= "") (\datum -> String.contains jobFragment (getJob datum))
        |> filterIf (taskFragment /= "") (\datum -> String.contains taskFragment (getDesc datum))
        |> filterIf (earliestTime > 0) (\datum -> earliestTime <= getEndTime datum)


filterIf : Bool -> (b -> Bool) -> List b -> List b
filterIf condition predicate list =
    if condition then
        List.filter predicate list

    else
        list


{-| If the test succeeds, return `transform a`, otherwise
return `a`.
-}
ifApply : (a -> Bool) -> (a -> a) -> a -> a
ifApply test transform a =
    if test a then
        transform a

    else
        a


newDataFile : Time.Posix -> Username -> DataFileName -> DataType -> DataFile
newDataFile time username dataFileName dataType =
    { name = dataFileName
    , owner = username
    , dataType = dataType
    , data = []
    , timeCreated = time
    , timeModified = time
    }


insertDataFile : Time.Posix -> Username -> DataFileName -> DataType -> DataDict -> DataDict
insertDataFile time username dataFileName dataType dataDict =
    Dict.insert ( username, dataFileName )
        (newDataFile time username dataFileName dataType)
        dataDict


replace : DataFile -> DataDict -> DataDict
replace dataFile dataDict =
    Dict.insert ( dataFile.owner, dataFile.name ) dataFile dataDict


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
