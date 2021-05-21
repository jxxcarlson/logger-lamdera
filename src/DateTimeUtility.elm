module DateTimeUtility exposing (elapsedTimeAsSeconds, elapsedTimeAsString, zonedDateString, zonedDateTime, zonedTimeString)

import Calendar exposing (Date)
import Clock
import DateTime exposing (DateTime)
import Time exposing (Month(..))


type alias Seconds =
    Int


elapsedTimeAsString : Time.Posix -> Time.Posix -> String
elapsedTimeAsString a b =
    let
        elapsedInSeconds =
            elapsedTimeAsSeconds a b

        elapsedInMinutes =
            elapsedInSeconds // 60

        minutes =
            modBy 60 elapsedInMinutes

        hours =
            (elapsedInMinutes - minutes) // 60
    in
    String.padLeft 2 '0' (String.fromInt hours) ++ ":" ++ String.padLeft 2 '0' (String.fromInt minutes)


elapsedTimeAsSeconds : Time.Posix -> Time.Posix -> Seconds
elapsedTimeAsSeconds a b =
    let
        aa =
            Time.posixToMillis a

        bb =
            Time.posixToMillis b
    in
    (bb - aa) // 1000


zonedDateString : Time.Zone -> Time.Posix -> String
zonedDateString zone time =
    let
        date =
            zonedDateTime zone time |> DateTime.getDate
    in
    monthFromDate date ++ " " ++ dayFromDate date ++ " " ++ yearFromDate date


zonedTimeString : Time.Zone -> Time.Posix -> String
zonedTimeString zone time_ =
    let
        time =
            zonedDateTime zone time_ |> DateTime.getTime
    in
    hoursFromClockTime time ++ ":" ++ minutesFromClockTime time


zonedDateTime : Time.Zone -> Time.Posix -> DateTime
zonedDateTime zone time_ =
    let
        offset : Int
        offset =
            DateTime.getTimezoneOffset zone time_

        timeInMilliseconds =
            Time.posixToMillis time_

        newTime =
            Time.millisToPosix (timeInMilliseconds + offset)
    in
    DateTime.fromPosix newTime



-- CONVERTERS


hoursFromClockTime : Clock.Time -> String
hoursFromClockTime time =
    Clock.getHours time |> String.fromInt |> String.padLeft 2 '0'


minutesFromClockTime : Clock.Time -> String
minutesFromClockTime time =
    Clock.getMinutes time |> String.fromInt |> String.padLeft 2 '0'


yearFromDate : Date -> String
yearFromDate date =
    Calendar.getYear date |> String.fromInt


dayFromDate : Date -> String
dayFromDate date =
    Calendar.getDay date |> String.fromInt


monthFromDate : Date -> String
monthFromDate date =
    Calendar.getMonth date |> stringFromMonth


stringFromMonth : Time.Month -> String
stringFromMonth month =
    case month of
        Jan ->
            "Jan"

        Feb ->
            "Feb"

        Mar ->
            "Mar"

        Apr ->
            "Apr"

        May ->
            "May"

        Jun ->
            "Jun"

        Jul ->
            "Jul"

        Aug ->
            "Aug"

        Sep ->
            "Sep"

        Oct ->
            "Oct"

        Nov ->
            "Nov"

        Dec ->
            "Dec"
