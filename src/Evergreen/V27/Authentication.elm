module Evergreen.V27.Authentication exposing (..)

import Dict
import Evergreen.V27.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V27.User.User
    , token : String
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
