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


testString2 =
    """1, 1621787941573,1621787941573,Work on hasing & random seeds,logger
2, 1621777864406,1621777864406,more parser tests; some abstractions for writing them,brilliant
3, 1621776891413,1621776891413,add editable view,logger
4, 1621757165312,1621757165312,parser tests,brilliant
5, 1621754611282,1621754611282,parser tests for verbatim constructs,brilliant
6, 1621740937313,1621740937313,import tasks from csv,logger
7, 1621737507264,1621737507264,task parser (csv string -> list data),logger
8, 1621731384247,1621731384247,aaa,auth
9, 1621729743234,1621729743234,new auth scheme: use salt and hash on backend,auth
10, 1621719392855,1621719392855,Studying password schemes,logger
11, 1621713384078,1621713384078,Parser tests: annotations,brilliant
12, 1621711277043,1621711277043,Parser tests,brilliant
13, 1621708302630,1621708302630,Study parser; write parser tests,brilliant
14, 1621700510210,1621700510210,Automatically add year in filtering by mm/dd ...,logger
15, 1621688841683,1621688841683,Add column header for data,logger
16, 1621688286890,1621688286890,Round totals; fix initial total computation,logger
17, 1621684855558,1621684855558,Display total hours of selected items; UI work,logger
18, 1621653502974,1621653502974,filtration,logger
19, 1621640575037,1621640575037,Ensure that a log file is created when a new account is created; UI tweaks,logger
20, 1621640466038,1621640466038,ho ho ho!,test
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
    succeed (\id start end desc job -> Task { id = id, start = start, end = end, desc = desc, job = job })
        |= itemParser
        |. symbol ","
        |. spaces
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
