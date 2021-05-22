module Evergreen.V13.Authentication exposing (..)

import Dict
import Evergreen.V13.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V13.User.User
    , token : String
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
