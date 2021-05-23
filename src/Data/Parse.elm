module Data.Parse exposing (..)

import Data.Data as Data exposing (Data(..), DataFile, DataType(..))
import Maybe.Extra
import Parser exposing (..)
import Time
import User exposing (User)


testString =
    """1621653742145,1621653742145,quantum gates,physics
1621642063565,1621642063565,testing ...,test
"""


createDataFileFromTasks : Time.Posix -> String -> List Data -> DataFile
createDataFileFromTasks time username dataList =
    { name = "Work Log"
    , owner = username
    , dataType = TTask
    , data = dataList
    , timeCreated = time
    , timeModified = time
    }


parseTasks : String -> List Data
parseTasks str =
    str
        |> String.lines
        |> List.map parseTask
        |> Maybe.Extra.values


parseTask : String -> Maybe Data
parseTask str =
    case run taskParser str of
        Ok datum ->
            Just datum

        Err _ ->
            Nothing


taskParser : Parser Data
taskParser =
    succeed (\start end desc job -> Task { start = start, end = end, desc = desc, job = job })
        |= (int |> map Time.millisToPosix)
        |. spaces
        |. symbol ","
        |. spaces
        |= (int |> map Time.millisToPosix)
        |. spaces
        |. symbol ","
        |. spaces
        |= itemParser
        |. symbol ","
        |= itemParser


itemParser : Parser String
itemParser =
    (getChompedString <|
        chompUntilEndOr ","
    )
        |> map String.trim
