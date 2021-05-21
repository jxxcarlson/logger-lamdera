module Data.Manager exposing (..)

import Authentication exposing (AuthenticationDict)
import Data.Data exposing (Data, DataDict, DataType(..))
import DateTimeUtility
import Dict
import Time
import Types exposing (..)


type alias UserName =
    String


type alias DatafileName =
    String


setupLog : Time.Posix -> UserName -> DatafileName -> DataType -> AuthenticationDict -> DataDict -> Result String DataDict
setupLog time userName datafileName dataType authDict dataDict =
    if Dict.get userName authDict == Nothing then
        Err "User name is not registered"

    else if Dict.get ( userName, datafileName ) dataDict /= Nothing then
        Err "This data file already exists"

    else
        Ok <| Data.Data.insertDataFile time userName datafileName dataType dataDict
