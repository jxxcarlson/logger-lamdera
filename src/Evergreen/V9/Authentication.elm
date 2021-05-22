module Evergreen.V9.Authentication exposing (..)

import Dict
import Evergreen.V9.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V9.User.User
    , token : String
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
