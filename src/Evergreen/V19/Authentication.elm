module Evergreen.V19.Authentication exposing (..)

import Dict
import Evergreen.V19.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V19.User.User
    , token : String
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
