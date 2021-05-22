module Evergreen.V13.Data.Data exposing (..)

import Dict
import Time


type alias DataFileName =
    String


type alias Username =
    String


type DataType
    = TTask
    | TQuantity


type Data
    = Task
        { start : Time.Posix
        , end : Time.Posix
        , desc : String
        , job : String
        }
    | Quantity
        { start : Time.Posix
        , end : Time.Posix
        , value : Float
        , desc : String
        }


type alias DataFile =
    { name : DataFileName
    , owner : Username
    , dataType : DataType
    , data : List Data
    , timeCreated : Time.Posix
    , timeModified : Time.Posix
    }


type alias DataDict =
    Dict.Dict ( Username, DataFileName ) DataFile
